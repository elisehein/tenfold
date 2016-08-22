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

    private static let gridInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    private static let maxNextRoundPullUpThreshold: CGFloat = 150
    private static let hideMenuPullUpThreshold: CGFloat = 50
    private static let showMenuPullDownThreshold: CGFloat = 70

    private static let pullDownIndicatorMaxCurve: CGFloat = 60.0

    private var game: Game

    private let menu = Menu()
    private let gameGrid: GameGrid
    private var nextRoundGrid: NextRoundGrid?

    private var passedNextRoundThreshold = false

    private var viewHasLoaded = false

    private let menuPullDownBlob: CAShapeLayer = {
        let blob = CAShapeLayer()
        blob.rasterizationScale = 2.0 * UIScreen.mainScreen().scale
        blob.shouldRasterize = true
        blob.fillColor = UIColor.themeColorHighlighted(.OffWhite).CGColor
        return blob
    }()

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
        gameGrid.onPullUpThresholdExceeded = handlePullUpThresholdExceeded
        gameGrid.onWillSnapToStartingPosition = handleWillSnapToStartingPosition
        gameGrid.onWillSnapToGameplayPosition = handleWillSnapToGameplayPosition
        gameGrid.onPairingAttempt = handlePairingAttempt

        menu.onTapNewGame = handleTapNewGame
        menu.onTapInstructions = showInstructions

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(Play.showInstructions))
        swipe.direction = .Left

        view.backgroundColor = UIColor.themeColor(.OffWhite)
        view.addGestureRecognizer(swipe)
        view.addSubview(gameGrid)
        view.addSubview(menu)
        view.layer.addSublayer(menuPullDownBlob)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gameGrid.initialisePositionWithinFrame(view.bounds, withInsets: Play.gridInsets)
        positionMenu()
        initNextRoundMatrix()

        gameGrid.snapToStartingPositionThreshold = Play.showMenuPullDownThreshold
        gameGrid.snapToGameplayPositionThreshold = Play.hideMenuPullUpThreshold

        viewHasLoaded = true
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
        gameGrid.pullUpThreshold = calcNextRoundPullUpThreshold(nextRoundValues.count)

        view.insertSubview(nextRoundGrid!, belowSubview: gameGrid)
    }

    // MARK: Positioning

    private func positionMenu() {
        guard !menu.locked else { return }
        menu.frame = menuFrame()
    }

    private func menuFrame(atStartingPosition atStartingPosition: Bool = false) -> CGRect {
        var menuFrame = gameGrid.frame

        let maxMenuHeight = gameGrid.emptySpaceVisible(atStartingPosition: true)

        if atStartingPosition {
            menuFrame.size.height = maxMenuHeight
        } else {
            let requestedMenuHeight = gameGrid.emptySpaceVisible()
            menuFrame.size.height = min(maxMenuHeight, requestedMenuHeight)
        }

        return menuFrame
    }

    private func positionNextRoundMatrix() {
        nextRoundGrid?.frame = nextRoundMatrixFrame()
    }

    private func nextRoundMatrixFrame() -> CGRect {
        var nextRoundMatrixFrame = gameGrid.frame
        nextRoundMatrixFrame.origin.y += gameGrid.bottomEdgeY() - gameGrid.cellSize().height
        return nextRoundMatrixFrame
    }

    private func calcNextRoundPullUpThreshold(numberOfItemsInNextRound: Int) -> CGFloat {
        let rowsInNextRound = Matrix.singleton.totalRows(numberOfItemsInNextRound)
        let threshold = nextRoundGrid?.heightForGame(withTotalRows: rowsInNextRound)
        return min(threshold!, Play.maxNextRoundPullUpThreshold)
    }

    // MARK: Menu interactions

    private func handleTapNewGame() {
        game = Game()
        gameGrid.restart(withGame: game, completion: {
            self.updateState()
        })
    }

    func showInstructions() {
        navigationController?.pushViewController(Instructions(), animated: true)
    }

    // MARK: Gameplay logic

    private func handlePairingAttempt(itemIndex: Int, otherItemIndex: Int) {
        let successfulPairing = Pairing.validate(itemIndex, otherItemIndex, inGame: game)

        if successfulPairing {
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
            gameGrid.loadNextRound(atIndeces: nextRoundIndeces, completion: nil)

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
            if game.allCrossedOut(rowIndeces) &&
               !Set(rowIndeces).isSubsetOf(Set(surplusIndeces)) {
                surplusIndeces += rowIndeces
            }
        }

        removeNumbers(atIndeces: surplusIndeces)
    }

    private func removeNumbers(atIndeces indeces: Array<Int>) {
        game.removeNumbers(atIndeces: indeces)

        let indexPaths = indeces.map({ NSIndexPath(forItem: $0, inSection: 0) })
        gameGrid.removeNumbers(atIndexPaths: indexPaths)
        updateState()
    }

    private func updateState() {
        let nextRoundValues = game.nextRoundValues()
        nextRoundGrid!.update(startIndex: nextRoundStartIndex(), values: nextRoundValues)
        gameGrid.pullUpThreshold = calcNextRoundPullUpThreshold(nextRoundValues.count)
        StorageService.saveGame(game)
    }

    // MARK: Scrolling interactions

    private func handleWillSnapToStartingPosition() {
        menu.showIfNeeded(atEndPosition: menuFrame(atStartingPosition: true))
    }

    private func handleWillSnapToGameplayPosition() {
        menu.hideIfNeeded()
    }

    private func handlePullUpThresholdExceeded() {
        nextRoundGrid?.hidden = true
        loadNextRound()
        menu.hideIfNeeded()
    }

    private func handleScroll() {
        guard viewHasLoaded else { return }

        if gameGrid.pullDownInProgress() {
            let pullDownRatio = gameGrid.distancePulledDown() / Play.showMenuPullDownThreshold
            menuPullDownBlob.path = curvedIndicatorPath(pullDownRatio)
        }

        if gameGrid.pullUpInProgress() {
            positionNextRoundMatrix()
            nextRoundGrid?.hidden = false

            let pullUpRatio = gameGrid.distancePulledUp() / gameGrid.pullUpThreshold!
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

    private func curvedIndicatorPath(proportionCurved: CGFloat) -> CGPath {
        let y = min(1, proportionCurved) * Play.showMenuPullDownThreshold
        var curvedY = y

        if proportionCurved > 1 {
            curvedY += Play.pullDownIndicatorMaxCurve * (proportionCurved - 1)
        }

        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: view.bounds.size.width, y: 0))
        path.addLineToPoint(CGPoint(x: view.bounds.size.width, y: y))

        let controlPoint2 = CGPoint(x: view.bounds.size.width / 2, y : curvedY)
        path.addCurveToPoint(CGPoint(x: 0, y: y),
                             controlPoint1: CGPoint(x: view.bounds.size.width, y: y),
                             controlPoint2: controlPoint2)
        path.closePath()
        return path.CGPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
