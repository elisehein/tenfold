//
//  Play.swift
//  Tenfold
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import AVFoundation

class Play: UIViewController {

    private static let defaultBGColor = UIColor.themeColor(.OffWhite)
    private static let gameplayBGColor = UIColor.themeColor(.OffWhiteShaded)

    private static let gridInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    private static let hideMenuPullUpThreshold: CGFloat = 50
    private static let showMenuPullDownThreshold: CGFloat = 70

    private static let maxNextRoundPullUpThreshold: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 160 : 120
    }()

    private var game: Game

    private let menu = Menu()
    private let gameGrid: GameGrid
    private let notification: Notification
    private var nextRoundGrid: NextRoundGrid?

    private var passedNextRoundThreshold = false
    private var notificationDismissalInProgress = false

    private var viewHasLoaded = false

    init() {
        let savedGame = StorageService.restoreGame()

        self.game = savedGame == nil ? Game() : savedGame!
        self.gameGrid = GameGrid(game: game)
        self.notification = Notification()

        super.init(nibName: nil, bundle: nil)

        gameGrid.onScroll = handleScroll
        gameGrid.onPullUpThresholdExceeded = handlePullUpThresholdExceeded
        gameGrid.onWillSnapToStartingPosition = handleWillSnapToStartingPosition
        gameGrid.onWillSnapToGameplayPosition = handleWillSnapToGameplayPosition
        gameGrid.onPairingAttempt = handlePairingAttempt

        menu.onTapNewGame = confirmNewGame
        menu.onTapInstructions = showInstructions

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(Play.showInstructions))
        swipe.direction = .Left

        view.backgroundColor = Play.defaultBGColor
        view.addGestureRecognizer(swipe)
        view.addSubview(gameGrid)
        view.addSubview(menu)
        view.addSubview(notification)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cap the width to 450 for larger screens
        var gameGridFrame = view.bounds
        gameGridFrame.size.width = min(500, gameGridFrame.size.width)
        gameGridFrame.origin.x = (view.bounds.size.width - gameGridFrame.size.width) / 2
        gameGrid.initialisePositionWithinFrame(gameGridFrame, withInsets: Play.gridInsets)

        positionMenu()
        positionNotification()
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
        nextRoundGrid?.hide(animated: false)

        updateNotificationText()

        gameGrid.pullUpThreshold = calcNextRoundPullUpThreshold(nextRoundValues.count)

        view.insertSubview(nextRoundGrid!, belowSubview: gameGrid)
    }

    // MARK: Positioning

    private func positionMenu() {
        guard !menu.animationInProgress && !menu.hidden else { return }
        menu.frame = menuFrame()
    }

    private func positionNotification(showing showing: Bool = false, animated: Bool = false) {
        guard !notificationDismissalInProgress else { return }
        let screenHeight = view.bounds.size.height
        var notificationFrame = view.bounds
        notificationFrame.size.height = Notification.height

        if showing {
            let y = screenHeight - notificationFrame.size.height - Notification.preferredMargin
            notificationFrame.origin.y += y
        } else {
            notificationFrame.origin.y += screenHeight + 10
        }

        UIView.animateWithDuration(animated ? 0.6 : 0,
                                   delay: 0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0.3,
                                   options: .CurveEaseIn,
                                   animations: {
            self.notification.alpha = showing ? 1 : 0
            self.notification.frame = notificationFrame
        }, completion: nil)
    }

    private func dismissNotification(completion: (() -> Void)) {
        notificationDismissalInProgress = true
        UIView.animateWithDuration(1.0,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
            self.notification.alpha = 0
            var dismissedFrame = self.notification.frame
            dismissedFrame.origin.y -= 100
            self.notification.frame = dismissedFrame
        }, completion: { _ in
            self.notificationDismissalInProgress = false
            self.positionNotification(showing: false, animated: false)
            completion()
        })
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
        var nextRoundMatrixFrame = gameGrid.frame
        nextRoundMatrixFrame.origin.y += gameGrid.bottomEdgeY() - gameGrid.cellSize().height
        nextRoundGrid?.frame = nextRoundMatrixFrame
    }

    private func calcNextRoundPullUpThreshold(numberOfItemsInNextRound: Int) -> CGFloat {
        let rowsInNextRound = Matrix.singleton.totalRows(numberOfItemsInNextRound)
        let threshold = nextRoundGrid?.heightForGame(withTotalRows: rowsInNextRound)
        return min(threshold!, Play.maxNextRoundPullUpThreshold)
    }

    // MARK: Menu interactions

    private func confirmNewGame() {
        if game.currentRound > 1 && game.playingSince != nil {
            let modal = ConfirmationModal(game: game)
            modal.onTapYes = {
                self.restartGame()
            }

            presentViewController(modal, animated: true, completion: nil)
        } else {
            restartGame()
        }
    }

    private func restartGame() {
        game = Game()
        gameGrid.restart(withGame: game, completion: {
            self.updateNotificationText()
            self.updateState()
            self.nextRoundGrid?.hide(animated: false)
            self.menu.showIfNeeded(atEndPosition: self.menuFrame(atStartingPosition: true))
            self.view.backgroundColor = Play.defaultBGColor
        })
    }

    func showInstructions() {
        navigationController?.pushViewController(Instructions(), animated: true)
    }

    // MARK: Gameplay logic

    private func handlePairingAttempt(index: Int, otherIndex: Int) {
        let successfulPairing = Pairing.validate(index, otherIndex, inGame: game)

        if successfulPairing {
            game.crossOutPair(index, otherIndex: otherIndex)
            gameGrid.crossOutPair(index, otherIndex: otherIndex)
            updateNotificationText()
            updateState()
            let surplusIndeces = surplusIndecesOnRows(containingIndeces: [index, otherIndex])

            if surplusIndeces.count > 0 {
                SoundService.sharedService.playIfAllowed(.CrossOutRow)
                removeNumbers(atIndeces: surplusIndeces)
            } else {
                SoundService.sharedService.playIfAllowed(.CrossOut)
            }
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

    private func surplusIndecesOnRows(containingIndeces indeces: Array<Int>) -> Array<Int> {
        var surplusIndeces: Array<Int> = []

        for index in indeces {
            let rowIndeces = game.indecesOnRow(containingIndex: index)
            if game.allCrossedOut(rowIndeces) &&
               !Set(rowIndeces).isSubsetOf(Set(surplusIndeces)) {
                surplusIndeces += rowIndeces
            }
        }

        return surplusIndeces
    }

    private func removeNumbers(atIndeces indeces: Array<Int>) {
        game.removeNumbers(atIndeces: indeces)
        let indexPaths = indeces.map({ NSIndexPath(forItem: $0, inSection: 0) })

        gameGrid.removeNumbers(atIndexPaths: indexPaths, completion: {
            if self.game.ended() {
                self.presentViewController(GameFinished(game: self.game),
                                      animated: true,
                                      completion: { _ in
                    self.restartGame()
                })
            } else {
                self.updateState()
            }
        })
    }

    private func updateState() {
        let nextRoundValues = game.nextRoundValues()
        nextRoundGrid!.update(startIndex: nextRoundStartIndex(), values: nextRoundValues)
        gameGrid.pullUpThreshold = calcNextRoundPullUpThreshold(nextRoundValues.count)
        StorageService.saveGame(game)
    }

    private func updateNotificationText() {
        notification.text = "ROUND \(game.currentRound + 1)   |   + \(game.numbersRemaining())"
    }

    // MARK: Scrolling interactions

    private func handleWillSnapToStartingPosition() {
        view.backgroundColor = Play.defaultBGColor
        menu.showIfNeeded(atEndPosition: menuFrame(atStartingPosition: true))
    }

    private func handleWillSnapToGameplayPosition() {
        view.backgroundColor = Play.gameplayBGColor
        menu.hideIfNeeded()
    }

    private func handlePullUpThresholdExceeded() {
        nextRoundGrid?.hide(animated: false)
        dismissNotification({ self.updateNotificationText() })
        loadNextRound()
        menu.hideIfNeeded()
    }

    private func handleScroll() {
        guard viewHasLoaded else { return }

        interpolateBackgroundColour()

        if gameGrid.pullUpInProgress() {
            positionNextRoundMatrix()
            nextRoundGrid?.show(animated: true)

            let proportionVisible = min(1, gameGrid.distancePulledUp() / gameGrid.pullUpThreshold!)

            if proportionVisible == 1 {
                if !passedNextRoundThreshold {
                    SoundService.sharedService.playIfAllowed(.NextRound)
                    passedNextRoundThreshold = true
                    positionNotification(showing: true, animated: true)
                }
            } else {
                positionNotification(showing: false, animated: true)
                passedNextRoundThreshold = false
            }

            nextRoundGrid?.proportionVisible = proportionVisible
        } else {
            nextRoundGrid?.hide(animated: true)
            passedNextRoundThreshold = false
        }

        positionMenu()
    }

    private func interpolateBackgroundColour() {
        guard !gameGrid.snappingInProgress else { return }

        if gameGrid.pullDownInProgress() && !gameGrid.gridAtStartingPosition {
            view.backgroundColor = interpolatedColor(from: Play.gameplayBGColor,
                                                     to: Play.defaultBGColor,
                                                     distance: gameGrid.distancePulledDown(),
                                                     threshold: Play.showMenuPullDownThreshold)
        } else if gameGrid.pullUpFromStartingPositionInProgress() {
            // swiftlint:disable:next line_length
            view.backgroundColor = interpolatedColor(from: Play.defaultBGColor, to: Play.gameplayBGColor, distance: gameGrid.pullUpDistanceFromStartingPosition(), threshold: Play.hideMenuPullUpThreshold)
        }
    }

    private func interpolatedColor(from sourceColor: UIColor,
                                   to targetColor: UIColor,
                                   distance: CGFloat,
                                   threshold: CGFloat) -> UIColor {
        let fraction = min(1, distance / threshold)
        return sourceColor.interpolateTo(targetColor, fraction: fraction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
