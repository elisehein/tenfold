//
//  Play.swift
//  Numbers
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import AudioToolbox

class Play: UIViewController {

    private static let gridMargin: CGFloat = 10
    private static let nextRoundTriggerThreshold: CGFloat = 150

    private var game: Game
    private var rules: GameRules

    private let gameGrid: GameGrid
    private var nextRoundGrid: NextRoundGrid?
    private var passedNextRoundThreshold = false

    init() {
        let savedGame = StorageService.restoreGame()

        self.game = savedGame == nil ? Game() : savedGame!
        self.rules = GameRules(game: game)
        self.gameGrid = GameGrid(game: game)

        super.init(nibName: nil, bundle: nil)

        gameGrid.onScroll = handleScroll
        gameGrid.onDraggingEnd = handleDraggingEnd
        gameGrid.onPairingAttempt = handlePairingAttempt

        nextRoundGrid = NextRoundGrid(cellsPerRow: GameRules.numbersPerLine,
                                      frame: CGRect.zero)
        nextRoundGrid?.hidden = true

        view.backgroundColor = UIColor.themeColor(.OffWhite)
        view.addSubview(nextRoundGrid!)
        view.addSubview(gameGrid)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gameGrid.frame = CGRect(x: Play.gridMargin,
                                y: 0,
                                width: view.bounds.size.width - (2 * Play.gridMargin),
                                height: view.bounds.size.height)
        self.positionGameGrid()
        self.nextRoundGrid?.itemSize = self.gameGrid.cellSize()
    }


    // MARK: Shake gestures
    // http://stackoverflow.com/questions/10154958/ios-how-to-detect-shake-motion

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }

    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            game.restart()
            StorageService.saveGame(game)
            gameGrid.reloadData()
            positionGameGrid()
        }
    }

    // MARK: Positioning

    private func positionGameGrid () {
        let currentGridHeight = CGFloat(game.totalRows()) * gameGrid.cellSize().height
        let optimalHeight = optimalGridHeight()

        var frame = gameGrid.frame
        frame.size.height = optimalHeight
        frame.origin.y = (view.bounds.size.height - optimalHeight) / 2.0
        gameGrid.frame = frame

        let topInset = max(0, optimalHeight - currentGridHeight)
        gameGrid.contentInset.top = topInset
    }

    private func positionNextRoundGrid () {
        var nextRoundGridFrame = gameGrid.frame
        nextRoundGridFrame.size.height = nextRoundGrid!.heightRequired()

        nextRoundGridFrame.origin.y += gameGrid.bottomEdgeY() - gameGrid.cellSize().height
        nextRoundGrid?.frame = nextRoundGridFrame
    }

    private func optimalGridHeight () -> CGFloat {
        let cellHeight = gameGrid.cellSize().height
        let availableHeight = view.bounds.size.height

        return availableHeight - (availableHeight % cellHeight)
    }

    // MARK: Gameplay logic

    private func handlePairingAttempt (itemIndex: Int, otherItemIndex: Int) {
        let successfulPairing = rules.attemptPairing(itemIndex, otherIndex: otherItemIndex)

        if successfulPairing {
            game.crossOutPair(itemIndex, otherIndex: otherItemIndex)
            StorageService.saveGame(game)
            gameGrid.crossOutPair(itemIndex, otherIndex: otherItemIndex)
        } else {
            gameGrid.dismissSelection()
        }
    }

    // Instead of calling reloadData on the entire grid, dynamically add the next round
    // This function assumes that the state of the game has diverged from the state of
    // the collectionView.
    private func loadNextRound () -> Bool {
        let hypotheticalNextRound = game.hypotheticalNextRound()

        if hypotheticalNextRound.count == 0 {
            return false
        }

        game.makeNextRound(usingNumbers: hypotheticalNextRound)
        gameGrid.loadNextRound({ _ in
            self.positionGameGrid()
        })

        StorageService.saveGame(game)

        return true
    }

    // NOTE this does not take into account content insets
    private func handleDraggingEnd () {
        if gameGrid.pullUpDistanceExceeds(Play.nextRoundTriggerThreshold) {
            nextRoundGrid?.hidden = true
            loadNextRound()
        }
    }

    private func handleScroll () {
        if gameGrid.pullUpInProgress() {
            positionNextRoundGrid()
            nextRoundGrid?.hidden = false

            let pullUpRatio = gameGrid.pullUpPercentage(ofThreshold: Play.nextRoundTriggerThreshold)
            let proportionVisible = min(1, pullUpRatio)

            if proportionVisible == 1 && !passedNextRoundThreshold {
//                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                passedNextRoundThreshold = true
            }

            nextRoundGrid?.proportionVisible = proportionVisible
        } else {
            nextRoundGrid?.hidden = true
            passedNextRoundThreshold = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
