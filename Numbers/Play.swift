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
    private static let showMenuPullDownThreshold: CGFloat = 100

    private var game: Game

    private let menu = Menu()
    private let gameGrid: GameGrid
    private var nextRoundGrid: NextRoundGrid?

    private var passedNextRoundThreshold = false

    private var viewHasLoaded = false

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
        gameGrid.onSnappedToStartingPosition = handleSnappedToStartingPosition
        gameGrid.onPullUpThresholdExceeded = handlePullUpThresholdExceeded
        gameGrid.onSnappedToGameplayPosition = handleSnappedToGameplayPosition
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

        gameGrid.initialisePositionWithinFrame(view.bounds, withInsets: Play.gridInsets)
        positionMenu()
        initNextRoundMatrix()

        menu.defaultFrame = menuFrame(atStartingPosition: true)

        gameGrid.snapToGameplayPositionThreshold = Play.hideMenuPullUpThreshold
        gameGrid.snapToStartingPositionThreshold = Play.showMenuPullDownThreshold

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
//        guard !menu.hidingInProgress else { return }
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

    private func hideMenuIfNeeded () {
        menu.hideIfNeeded()
    }

    private func showMenuIfNeeded () {
        menu.prepareToShow()
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
            if game.allCrossedOut(rowIndeces) {
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
        nextRoundGrid!.update(startIndex: nextRoundStartIndex(),
                              values: nextRoundValues)
        gameGrid.pullUpThreshold = calcNextRoundPullUpThreshold(nextRoundValues.count)
        StorageService.saveGame(game)
    }

    // MARK: Scrolling interactions

    private func handleSnappedToStartingPosition() {
        showMenuIfNeeded()
    }

    private func handleSnappedToGameplayPosition() {
        hideMenuIfNeeded()
    }

    private func handlePullUpThresholdExceeded() {
        nextRoundGrid?.hidden = true
        loadNextRound()
        hideMenuIfNeeded()
    }

    private func handleScroll() {
        guard viewHasLoaded else { return }

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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
