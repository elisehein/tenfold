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

    private var game: Game

    private let menu = Menu()
    private let gameMatrix: GameMatrix
    private var nextRoundMatrix: NextRoundMatrix?

    private var nextRoundTriggerThreshold: CGFloat?
    private var passedNextRoundThreshold = false

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

    init () {
        let savedGame = StorageService.restoreGame()

        self.game = savedGame == nil ? Game() : savedGame!
        self.gameMatrix = GameMatrix(game: game)

        super.init(nibName: nil, bundle: nil)

        gameMatrix.onScroll = handleScroll
        gameMatrix.onDraggingEnd = handleDraggingEnd
        gameMatrix.onPairingAttempt = handlePairingAttempt

        menu.onTapNewGame = handleTapNewGame
        menu.onTapInstructions = handleTapInstructions
        menu.layer.borderWidth = 1
        menu.layer.borderColor = UIColor.redColor().CGColor

        view.backgroundColor = UIColor.themeColor(.OffWhite)
        view.addSubview(gameMatrix)
        view.addSubview(menu)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        positionGameMatrix()
        positionMenu()
        initNextRoundMatrix()
    }

    private func initNextRoundMatrix () {
        let nextRoundValues = game.nextRoundValues()
        nextRoundMatrix = NextRoundMatrix(cellSize: gameMatrix.cellSize(),
                                          cellsPerRow: Game.numbersPerRow,
                                          startIndex: nextRoundStartIndex(),
                                          values: nextRoundValues,
                                          frame: gameMatrix.frame)
        nextRoundMatrix?.hidden = true
        nextRoundTriggerThreshold = calcNextRoundTriggerThreshold(nextRoundValues.count)

        view.insertSubview(nextRoundMatrix!, belowSubview: gameMatrix)
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
            handleTapNewGame()
        }
    }

    // MARK: Positioning

    private func positionMenu () {
        var menuFrame = gameMatrix.frame
        menuFrame.size.height -= (gameMatrix.frame.size.height - gameMatrix.contentInset.top)
        menu.frame = menuFrame
    }

    private func positionGameMatrix () {
        if CGRectEqualToRect(gameMatrix.frame, CGRect.zero) {
            gameMatrix.frame = CGRect(x: Play.matrixMargin,
                                      y: 0,
                                      width: view.bounds.size.width - (2 * Play.matrixMargin),
                                      height: view.bounds.size.height)
        }

        let optimalHeight = optimalMatrixHeight()

        var frame = gameMatrix.frame
        frame.size.height = optimalHeight
        frame.origin.y = (view.bounds.size.height - optimalHeight) / 2.0
        gameMatrix.frame = frame

        adjustGameMatrixInset()
        gameMatrix.toggleBounce(false)
    }

    private func adjustGameMatrixInset () {
        let currentGameHeight = CGFloat(game.totalRows()) * gameMatrix.cellSize().height
        let topInset = max(0, gameMatrix.frame.size.height - currentGameHeight)
        gameMatrix.contentInset.top = topInset
    }

    private func positionNextRoundMatrix () {
        nextRoundMatrix?.frame = nextRoundMatrixFrame()
    }

    private func nextRoundMatrixFrame () -> CGRect {
        var nextRoundMatrixFrame = gameMatrix.frame
        nextRoundMatrixFrame.origin.y += gameMatrix.bottomEdgeY() - gameMatrix.cellSize().height
        return nextRoundMatrixFrame
    }

    private func calcNextRoundTriggerThreshold (numberOfItemsInNextRound: Int) -> CGFloat {
        let rowHeight = gameMatrix.cellSize().height
        let threshold = CGFloat(Matrix.singleton.totalRows(numberOfItemsInNextRound)) * rowHeight
        return min(threshold, Play.maxNextRoundTriggerThreshold)
    }

    private func optimalMatrixHeight () -> CGFloat {
        let cellHeight = gameMatrix.cellSize().height
        let availableHeight = view.bounds.size.height

        return availableHeight - (availableHeight % cellHeight)
    }

    // MARK: Menu interactions

    private func handleTapNewGame () {
        game.restart()
        gameMatrix.reloadData()
        adjustGameMatrixInset()
        updateState()
    }

    private func handleTapInstructions () {
        print("SHOW INSTRUCTIONS")
    }

    // MARK: Gameplay logic

    private func handlePairingAttempt (itemIndex: Int, otherItemIndex: Int) {
        let successfulPairing = Pairing.validate(itemIndex, otherItemIndex, inGame: game)

        if successfulPairing {
            game.crossOutPair(itemIndex, otherIndex: otherItemIndex)
            gameMatrix.crossOutPair(itemIndex, otherIndex: otherItemIndex)
            updateState()
            removeSurplusRows(containingIndeces: [itemIndex, otherItemIndex])
        } else {
            gameMatrix.dismissSelection()
        }
    }

    // Instead of calling reloadData on the entire matrix, dynamically add the next round
    // This function assumes that the state of the game has diverged from the state of
    // the collectionView.
    private func loadNextRound () -> Bool {
        let nextRoundStartIndex = game.totalNumbers()
        let nextRoundNumbers = game.nextRoundNumbers()

        if game.makeNextRound(usingNumbers: nextRoundNumbers) {
            let nextRoundEndIndex = nextRoundStartIndex + nextRoundNumbers.count - 1
            let nextRoundIndeces = Array(nextRoundStartIndex...nextRoundEndIndex)
            gameMatrix.loadNextRound(atIndeces: nextRoundIndeces,
                                     completion: { _ in
                self.adjustGameMatrixInset()
            })

            updateState()
            return true
        } else {
            return false
        }
    }

    private func nextRoundStartIndex () -> Int {
        return game.lastNumberColumn() + 1
    }

    private func removeSurplusRows (containingIndeces indeces: Array<Int>) {
        var surplusIndeces: Array<Int> = []

        for index in indeces {
            let rowIndeces = game.indecesOnRow(containingIndex: index)
            if game.allCrossedOut(rowIndeces) {
                surplusIndeces += rowIndeces
            }
        }

        removeNumbers(atIndeces: surplusIndeces)
    }

    private func removeNumbers (atIndeces indeces: Array<Int>) {
        game.removeNumbers(atIndeces: indeces)

        let indexPaths = indeces.map({ NSIndexPath(forItem: $0, inSection: 0) })
        gameMatrix.deleteItemsAtIndexPaths(indexPaths)
        adjustGameMatrixInset()
        updateState()
    }

    private func updateState () {
        let nextRoundValues = game.nextRoundValues()
        nextRoundMatrix!.update(startIndex: nextRoundStartIndex(),
                                values: nextRoundValues)
        nextRoundTriggerThreshold = calcNextRoundTriggerThreshold(nextRoundValues.count)
        StorageService.saveGame(game)
    }

    // MARK: Scrolling interactions

    // NOTE this does not take into account content insets
    private func handleDraggingEnd () {
        if gameMatrix.pullUpDistanceExceeds(nextRoundTriggerThreshold!) {
            nextRoundMatrix?.hidden = true
            loadNextRound()
        }
    }

    private func handleScroll () {
        if gameMatrix.pullUpInProgress() {
            positionNextRoundMatrix()
            nextRoundMatrix?.hidden = false

            let pullUpRatio = gameMatrix.pullUpPercentage(ofThreshold: nextRoundTriggerThreshold!)
            let proportionVisible = min(1, pullUpRatio)

            if proportionVisible == 1 {
                if !passedNextRoundThreshold {
                    blimpPlayer?.play()
                    passedNextRoundThreshold = true
                }
            } else {
                passedNextRoundThreshold = false
            }

            nextRoundMatrix?.proportionVisible = proportionVisible
        } else {
            nextRoundMatrix?.hidden = true
            passedNextRoundThreshold = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
