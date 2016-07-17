//
//  Play.swift
//  Numbers
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import AVFoundation

class Play: UIViewController {

    private static let matrixMargin: CGFloat = 10
    private static let maxNextRoundTriggerThreshold: CGFloat = 150
    private static let hideMenuPullUpThreshold: CGFloat = 50
    private static let showMenuPullDownThreshold: CGFloat = 100

    private var game: Game

    private let menu = Menu()
    private let gameGrid: GameGrid
    private var nextRoundGrid: NextRoundGrid?

    private var nextRoundTriggerThreshold: CGFloat?
    private var passedNextRoundThreshold = false

    private var viewLoaded = false

    private var blimpPlayer: AVAudioPlayer? = {
        var player = AVAudioPlayer()
        if let sound = NSDataAsset(name: "blimp") {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
                player.prepareToPlay()
            } catch {
                print("Error initializing AVAudioPlayer")
            }
        }

        return player
    }()

    init() {
        let savedGame = StorageService.restoreGame()

        self.game = savedGame == nil ? Game() : savedGame!
        self.gameGrid = GameGrid(game: game)

        super.init(nibName: nil, bundle: nil)

        gameGrid.onScroll = handleScroll
        gameGrid.onDraggingEnd = handleDraggingEnd
        gameGrid.onPairingAttempt = handlePairingAttempt

        menu.onTapNewGame = handleTapNewGame
        menu.onTapInstructions = showInstructions

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(Play.showInstructions))
        swipe.direction = .Left

        view.backgroundColor = UIColor.themeColor(.OffWhite)
        view.addGestureRecognizer(swipe)
        view.addSubview(gameGrid)
        view.addSubview(menu)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        positionGameGrid()
        positionMenu()
        initNextRoundMatrix()

        menu.defaultFrame = menuFrame(fullyVisible: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func initNextRoundMatrix() {
        let nextRoundValues = game.nextRoundValues()
        nextRoundGrid = NextRoundGrid(cellsPerRow: Game.numbersPerRow,
                                      startIndex: nextRoundStartIndex(),
                                      values: nextRoundValues,
                                      frame: gameGrid.frame)
        nextRoundGrid?.hidden = true
        nextRoundTriggerThreshold = calcNextRoundTriggerThreshold(nextRoundValues.count)

        view.insertSubview(nextRoundGrid!, belowSubview: gameGrid)
    }

    // MARK: Positioning

    private func positionMenu() {
        guard !menu.animationInProgress else { return }
        menu.frame = menuFrame()
    }

    private func menuFrame(fullyVisible fullyVisible: Bool = false) -> CGRect {
        var menuFrame = gameGrid.frame
        let spaceAvailable = fullyVisible ?
                             gameGridTopInset(showingMenu: true) :
                             -gameGrid.contentOffset.y
        menuFrame.size.height = spaceAvailable
        return menuFrame
    }

    private func positionGameGrid() {
        if CGRectEqualToRect(gameGrid.frame, CGRect.zero) {
            gameGrid.frame = CGRect(x: Play.matrixMargin,
                                      y: 0,
                                      width: view.bounds.size.width - (2 * Play.matrixMargin),
                                      height: view.bounds.size.height)
        }

        let optimalHeight = gameGrid.optimalHeight(forAvailableHeight: view.bounds.size.height)

        var frame = gameGrid.frame
        frame.size.height = optimalHeight
        frame.origin.y = (view.bounds.size.height - optimalHeight) / 2.0
        gameGrid.frame = frame

        adjustGameGridInset()
        gameGrid.toggleBounce(false)
    }

    private func adjustGameGridInset() {
        // Whatever the game state, we initially start with 3 rows showing
        // in the bottom of the view
        if !viewLoaded {
            gameGrid.contentInset.top = gameGridTopInset(showingMenu: true)
            viewLoaded = true
        } else {
            gameGrid.contentInset.top = gameGridTopInset()
        }
    }

    private func gameGridTopInset(showingMenu showingMenu: Bool = false) -> CGFloat {
        if showingMenu {
            return gameGrid.frame.size.height - gameGrid.initialGameHeight()
        } else {
            return max(0, gameGrid.frame.size.height - gameGrid.currentGameHeight())
        }
    }

    private func positionNextRoundMatrix() {
        nextRoundGrid?.frame = nextRoundMatrixFrame()
    }

    private func nextRoundMatrixFrame() -> CGRect {
        var nextRoundMatrixFrame = gameGrid.frame
        nextRoundMatrixFrame.origin.y += gameGrid.bottomEdgeY() - gameGrid.cellSize().height
        return nextRoundMatrixFrame
    }

    private func calcNextRoundTriggerThreshold(numberOfItemsInNextRound: Int) -> CGFloat {
        let rowHeight = gameGrid.cellSize().height
        let threshold = CGFloat(Matrix.singleton.totalRows(numberOfItemsInNextRound)) * rowHeight
        return min(threshold, Play.maxNextRoundTriggerThreshold)
    }

    // MARK: Menu interactions

    private func handleTapNewGame() {
        game = Game()
        gameGrid.restart(withGame: game, beforeReappearing: {
            self.positionGameGrid()
            self.updateState()
        })
    }

    func showInstructions() {
        navigationController?.pushViewController(Instructions(), animated: true)
    }

    private func hideMenuIfNeeded () {
        menu.hideIfNeeded(alongWithAnimationBlock: {
            let topInset = self.gameGridTopInset()
            self.gameGrid.contentInset.top = topInset
            self.gameGrid.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
        }, completion: {
            self.gameGrid.prematureBottomBounceEnabled = false
        })
    }

    private func showMenuIfNeeded () {
        let topInset = self.gameGridTopInset(showingMenu: true)

        menu.showIfNeeded(alongWithAnimationBlock: {
            self.gameGrid.contentInset.top = topInset
        }, completion: {
            self.gameGrid.setContentOffset(CGPoint(x: 0, y: -topInset), animated: true)
            self.gameGrid.prematureBottomBounceEnabled = true
        })
    }

    // MARK: Gameplay logic

    private func handlePairingAttempt(itemIndex: Int, otherItemIndex: Int) {
        let successfulPairing = Pairing.validate(itemIndex, otherItemIndex, inGame: game)

        if successfulPairing {
            hideMenuIfNeeded()
            game.crossOutPair(itemIndex, otherIndex: otherItemIndex)
            gameGrid.crossOutPair(itemIndex, otherIndex: otherItemIndex)
            updateState()
            removeSurplusRows(containingIndeces: [itemIndex, otherItemIndex])
        } else {
            gameGrid.dismissSelection()
        }
    }

    // Instead of calling reloadData on the entire matrix, dynamically add the next round
    // This function assumes that the state of the game has diverged from the state of
    // the collectionView.
    private func loadNextRound() -> Bool {
        let nextRoundStartIndex = game.totalNumbers()
        let nextRoundNumbers = game.nextRoundNumbers()

        if game.makeNextRound(usingNumbers: nextRoundNumbers) {
            let nextRoundEndIndex = nextRoundStartIndex + nextRoundNumbers.count - 1
            let nextRoundIndeces = Array(nextRoundStartIndex...nextRoundEndIndex)
            gameGrid.loadNextRound(atIndeces: nextRoundIndeces,
                                     completion: { _ in
                self.adjustGameGridInset()
                self.hideMenuIfNeeded()
            })

            updateState()
            return true
        } else {
            return false
        }
    }

    private func nextRoundStartIndex() -> Int {
        return game.lastNumberColumn() + 1
    }

    private func removeSurplusRows(containingIndeces indeces: Array<Int>) {
        var surplusIndeces: Array<Int> = []

        for index in indeces {
            let rowIndeces = game.indecesOnRow(containingIndex: index)
            if game.allCrossedOut(rowIndeces) {
                surplusIndeces += rowIndeces
            }
        }

        removeNumbers(atIndeces: surplusIndeces)
    }

    private func removeNumbers(atIndeces indeces: Array<Int>) {
        game.removeNumbers(atIndeces: indeces)

        let indexPaths = indeces.map({ NSIndexPath(forItem: $0, inSection: 0) })
        gameGrid.deleteItemsAtIndexPaths(indexPaths)
        adjustGameGridInset()
        updateState()
    }

    private func updateState() {
        let nextRoundValues = game.nextRoundValues()
        nextRoundGrid!.update(startIndex: nextRoundStartIndex(),
                              values: nextRoundValues)
        nextRoundTriggerThreshold = calcNextRoundTriggerThreshold(nextRoundValues.count)
        StorageService.saveGame(game)
    }

    // MARK: Scrolling interactions

    // NOTE this does not take into account content insets
    private func handleDraggingEnd() {
        if gameGrid.pullUpDistanceExceeds(nextRoundTriggerThreshold!) {
            nextRoundGrid?.hidden = true
            loadNextRound()
        } else if gameGrid.prematureBounceDistanceExceeds(Play.hideMenuPullUpThreshold) {
            hideMenuIfNeeded()
        } else if gameGrid.pullDownDistanceExceeds(Play.showMenuPullDownThreshold) {
            showMenuIfNeeded()
        }
    }

    private func handleScroll() {
        guard viewLoaded else { return }

        if gameGrid.pullUpInProgress() {
            positionNextRoundMatrix()
            nextRoundGrid?.hidden = false

            let pullUpRatio = gameGrid.distancePulledUp() / nextRoundTriggerThreshold!
            let proportionVisible = min(1, pullUpRatio)

            if proportionVisible == 1 {
                if !passedNextRoundThreshold {
                    blimpPlayer?.play()
                    passedNextRoundThreshold = true
                }
            } else {
                passedNextRoundThreshold = false
            }

            nextRoundGrid?.proportionVisible = proportionVisible
        } else {
            nextRoundGrid?.hidden = true
            passedNextRoundThreshold = false
        }

        positionMenu()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
