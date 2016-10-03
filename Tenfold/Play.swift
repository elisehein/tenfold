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

    private var panTriggered: Bool = false

    private static let defaultBGColor = UIColor.themeColor(.OffWhite)
    private static let gameplayBGColor = UIColor.themeColor(.OffWhiteShaded)

    private static let maxNextRoundPullUpThreshold: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 140 : 120
    }()

    var game: Game

    let menu: Menu
    let gameGrid: GameGrid
    private var nextRoundGrid: NextRoundGrid?
    private let nextRoundNotification = Notification(type: .Text)
    private let gamePlayMessageNotification = Notification(type: .Text)
    private let undoNotification = Notification(type: .Icon)
    private let undoErrorNotification = Notification(type: .Icon)
    private let scoreNotification = Notification(type: .Text)

    private var passedNextRoundThreshold = false

    private var viewHasLoaded = false
    private var viewHasAppeared = false
    private var shouldShowUpdatesModal: Bool
    private var shouldLaunchOnboarding: Bool
    private var isOnboarding: Bool

    init(shouldShowUpdatesModal: Bool, shouldLaunchOnboarding: Bool, isOnboarding: Bool = false) {
        let savedGame = StorageService.restoreGame()

        // If we do *somehow* have a saved game, don't mess with it and just show them
        // the regular Play screen
        self.shouldLaunchOnboarding = shouldLaunchOnboarding && savedGame == nil
        self.isOnboarding = isOnboarding && savedGame == nil
        self.shouldShowUpdatesModal = shouldShowUpdatesModal

        self.game = savedGame == nil ? Game() : savedGame!
        self.gameGrid = GameGrid(game: game)
        self.menu = Menu(state: self.isOnboarding ? .Onboarding : .Default,
                         shouldShowTips: self.shouldLaunchOnboarding)

        super.init(nibName: nil, bundle: nil)

        gameGrid.onScroll = handleScroll
        gameGrid.onPullingDown = handlePullingDown
        gameGrid.onPullingUpFromStartingPosition = handlePullingUpFromStartingPosition
        gameGrid.onScroll = handleScroll
        gameGrid.onPullUpThresholdExceeded = handlePullUpThresholdExceeded
        gameGrid.onWillSnapToStartingPosition = handleWillSnapToStartingPosition
        gameGrid.onWillSnapToGameplayPosition = handleWillSnapToGameplayPosition
        gameGrid.onDidSnapToGameplayPosition = handleDidSnapToGameplayPosition
        gameGrid.onPairingAttempt = handlePairingAttempt
        gameGrid.automaticallySnapToGameplayPosition = !isOnboarding

        menu.onTapNewGame = confirmNewGame
        menu.onTapInstructions = showInstructions

        let pan = UIPanGestureRecognizer(target: self, action: #selector(Play.detectPan))

        scoreNotification.anchorEdge = .Top
        updateScore()

        undoErrorNotification.iconName = "not-allowed"
        undoNotification.iconName = "undo"

        view.backgroundColor = Play.defaultBGColor
        view.addGestureRecognizer(pan)
        view.addSubview(gameGrid)
        view.addSubview(menu)
        view.addSubview(gamePlayMessageNotification)
        view.addSubview(nextRoundNotification)
        view.addSubview(undoNotification)
        view.addSubview(undoErrorNotification)
        view.addSubview(scoreNotification)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cap the width to 450 for larger screens
        var gameGridFrame = view.bounds
        gameGridFrame.size.width = min(540, gameGridFrame.size.width)
        gameGridFrame.origin.x = (view.bounds.size.width - gameGridFrame.size.width) / 2

        let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        gameGrid.initialisePositionWithinFrame(gameGridFrame, withInsets: insets)

        menu.emptySpaceAvailable = gameGrid.emptySpaceVisible
        menu.anchorFrame = view.bounds

        nextRoundNotification.toggle(inFrame: view.bounds, showing: false)
        gamePlayMessageNotification.toggle(inFrame: view.bounds, showing: false)
        undoErrorNotification.toggle(inFrame: view.bounds, showing: false)
        undoNotification.toggle(inFrame: view.bounds, showing: false)
        initNextRoundMatrix()

        gameGrid.snapToStartingPositionThreshold = 50
        gameGrid.snapToGameplayPositionThreshold = 50
        gameGrid.spaceForScore = Notification.margin * 2 + Notification.labelHeight - gameGrid.frame.origin.y

        viewHasLoaded = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)

        if !shouldLaunchOnboarding && !isOnboarding {
            menu.showDefaultView()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if shouldLaunchOnboarding {
            let onboarding = Onboarding()
            onboarding.onWillDismissWithGame = handleOnboardingWillDismissWithGame
            presentViewController(onboarding, animated: false, completion: nil)
            shouldLaunchOnboarding = false
            return
        }

        if shouldShowUpdatesModal {
            presentViewController(UpdatesModal(), animated: true, completion: nil)
            shouldShowUpdatesModal = false
        } else if isOnboarding {
            menu.onboardingSteps.begin()
        }

        viewHasAppeared = true
    }

    private func initNextRoundMatrix() {
        let nextRoundValues = game.nextRoundValues()
        nextRoundGrid = NextRoundGrid(cellsPerRow: Game.numbersPerRow,
                                      startIndex: game.lastNumberColumn() + 1,
                                      values: nextRoundValues,
                                      frame: gameGrid.frame)
        nextRoundGrid?.hide(animated: false)

        updateNextRoundNotificationText()
        gameGrid.pullUpThreshold = calcNextRoundPullUpThreshold(nextRoundValues.count)
        view.insertSubview(nextRoundGrid!, belowSubview: gameGrid)
    }

    // MARK: Positioning

    private func positionNextRoundGrid() {
        var nextRoundMatrixFrame = gameGrid.frame
        let cellHeight = Grid.cellSize(forAvailableWidth: nextRoundMatrixFrame.size.width).height
        nextRoundMatrixFrame.origin.y += gameGrid.bottomEdgeY() - cellHeight
        nextRoundGrid?.frame = nextRoundMatrixFrame
    }

    private func calcNextRoundPullUpThreshold(numberOfItemsInNextRound: Int) -> CGFloat {
        let rowsInNextRound = Matrix.singleton.totalRows(numberOfItemsInNextRound)
        let threshold = Grid.heightForGame(withTotalRows: rowsInNextRound,
                                           availableWidth: nextRoundGrid!.bounds.size.width)
        return min(threshold, Play.maxNextRoundPullUpThreshold)
    }

    // MARK: Menu interactions

    private func confirmNewGame() {
        let abandonGame = {
            StorageService.saveGameSnapshot(self.game)
            self.restart()
        }

        if game.currentRound > 1 && game.startTime != nil {
            let modal = ConfirmationModal(game: game)
            modal.onTapYes = abandonGame
            presentViewController(modal, animated: true, completion: nil)
        } else {
            abandonGame()
        }
    }

    private func restart(withGame newGame: Game = Game(), inGameplayPosition: Bool = false) {
        // Confusing wording: whenever we click Start Over, the menu is already visible,
        // and already in the starting position, so this is not needed, EXCEPT for one case –
        // straight after onboarding. In this case, the menu is visible, but not in the starting
        // position. We need to animate it to its starting position along with the new game
        // animation.
        if !inGameplayPosition {
            menu.nudgeToDefaultPositionIfNeeded()
        }

        game = newGame
        gameGrid.restart(withGame: game,
                         animated: !inGameplayPosition,
                         enforceStartingPosition: !inGameplayPosition,
                         completion: {
            self.updateNextRoundNotificationText()
            self.updateScore()
            self.updateState()
            self.nextRoundGrid?.hide(animated: false)
            self.menu.showIfNeeded(atDefaultPosition: !inGameplayPosition)
        })

        view.backgroundColor = inGameplayPosition ? Play.gameplayBGColor : Play.defaultBGColor
    }

    func showInstructions() {
        navigationController?.pushViewController(Rules(), animated: true)
    }

    // MARK: Gameplay logic

    private func handlePairingAttempt(pair: Pair) {
        let successfulPairing = Pairing.validate(pair, inGame: game)

        if successfulPairing {
            handleSuccessfulPairing(pair)
        } else {
            gameGrid.dismissSelection()
        }
    }

    func handleSuccessfulPairing(pair: Pair) {
        game.crossOut(pair)
        gameGrid.crossOut(pair)
        updateNextRoundNotificationText()
        updateScore()
        updateState()

        if removeSurplusRows(containingItemsFrom: pair) {
            playSound(.CrossOutRow)
        } else {
            playSound(.CrossOut)
        }

        checkForNewlyUnrepresentedValues()
    }

    func detectPan(recognizer: UIPanGestureRecognizer) {
        guard recognizer.state == .Changed else {
            panTriggered = recognizer.state == .Ended
            return
        }

        guard !panTriggered else { return }
        guard abs(recognizer.translationInView(view).x) > 70 else { return }

        if recognizer.velocityInView(view).x > 0 {
           undoLatestMove()
        } else {
           showInstructions()
        }

        panTriggered = true
    }

    func undoLatestMove() {
        guard !gameGrid.gridAtStartingPosition else { return }
        guard !gameGrid.rowRemovalInProgress else { return }
        guard game.latestMoveType() != nil else {
            undoErrorNotification.flash(inFrame: view.bounds)
            return
        }

        menu.hideIfNeeded() // This only applies when returning from onboarding

        if game.latestMoveType() == .CrossingOutPair {
            undoLatestPairing()
        } else if game.latestMoveType() == .LoadingNextRound {
            undoNewRound()
        }

        undoNotification.flash(inFrame: view.bounds)
    }

    func undoNewRound() {
        if let indeces = game.undoNewRound() {
            gameGrid.removeRows(withNumberIndeces: indeces, completion: {
                self.updateNextRoundNotificationText()
                self.updateScore()
                self.updateState()
            })
        }
    }

    func undoLatestPairing() {
        let undoPairing: ((delay: Double) -> Void) = { delay in
            if let pair = self.game.undoLatestPairing() {
                self.gameGrid.unCrossOut(pair, withDelay: delay)
                self.updateNextRoundNotificationText()
                self.updateScore()
                self.updateState()
            }
        }

        if let newRowIndeces = game.undoRowRemoval() {
            gameGrid.addRows(atIndeces: newRowIndeces, completion: {
                undoPairing(delay: 0.3)
            })
        } else {
            undoPairing(delay: 0)
        }
    }

    // Instead of calling reloadData on the entire matrix, dynamically add the next round
    // This function assumes that the state of the game has diverged from the state of
    // the collectionView.
    private func loadNextRound() {
        let nextRoundStartIndex = game.numberCount()
        let nextRoundNumbers = game.nextRoundNumbers()

        if game.makeNextRound(usingNumbers: nextRoundNumbers) {
            let nextRoundEndIndex = nextRoundStartIndex + nextRoundNumbers.count - 1
            let nextRoundIndeces = Array(nextRoundStartIndex...nextRoundEndIndex)
            gameGrid.loadNextRound(atIndeces: nextRoundIndeces, completion: nil)
            updateState()
        }
    }

    private func removeSurplusRows(containingItemsFrom pair: Pair) -> Bool {
        let surplusIndeces = game.removeRowsIfNeeded(containingItemsFrom: pair)

        if surplusIndeces.count > 0 {
            gameGrid.removeRows(withNumberIndeces: surplusIndeces, completion: {
                if self.game.ended() {
                    StorageService.saveGameSnapshot(self.game, forced: true)
                    self.presentViewController(GameFinished(game: self.game),
                                               animated: true,
                                               completion: { _ in
                        self.restart()
                    })
                } else {
                    self.updateState()
                }
            })

            return true
        } else {
            return false
        }
    }

    private func checkForNewlyUnrepresentedValues() {
        let unrepresented = game.unrepresentedValues()

        if unrepresented.count > 0 && game.numbersRemaining() > 10 {
            gamePlayMessageNotification.newlyUnrepresentedNumber = unrepresented[0]
            gamePlayMessageNotification.popup(forSeconds: 3,
                                              inFrame: view.bounds,
                                              completion: {
                self.game.pruneValueCounts()
            })
        } else {
            game.pruneValueCounts()
        }
    }

    private func updateState() {
        let nextRoundValues = game.nextRoundValues()
        nextRoundGrid!.update(startIndex: game.lastNumberColumn() + 1, values: nextRoundValues)
        gameGrid.pullUpThreshold = calcNextRoundPullUpThreshold(nextRoundValues.count)
        StorageService.saveGame(game)
    }

    private func updateNextRoundNotificationText() {
        nextRoundNotification.text = "ROUND \(game.currentRound + 1)   |   + \(game.numbersRemaining())  nums"
    }

    private func updateScore() {
        scoreNotification.text = "\(game.numbersRemaining()) to go"
    }

    private func playSound(sound: Sound) {
        if !isOnboarding {
            SoundService.singleton!.playIfAllowed(sound)
        }
    }

    // MARK: Scrolling interactions

    private func handleWillSnapToStartingPosition() {
        view.backgroundColor = Play.defaultBGColor
        scoreNotification.toggle(inFrame: view.frame, showing: false, animated: true)
        menu.showIfNeeded(atDefaultPosition: true)
    }

    func handleWillSnapToGameplayPosition() {
        view.backgroundColor = Play.gameplayBGColor

        if !isOnboarding {
            menu.hideIfNeeded()
        }
    }

    func handleDidSnapToGameplayPosition() {
        scoreNotification.toggle(inFrame: view.frame, showing: true, animated: true)
    }

    func handlePullUpThresholdExceeded() {
        nextRoundGrid?.hide(animated: false)
        nextRoundNotification.dismiss(inFrame: view.bounds, completion: {
            self.updateNextRoundNotificationText()
        })
        loadNextRound()

        if !isOnboarding {
            menu.hideIfNeeded()
        }
    }

    private func handleScroll() {
        guard viewHasLoaded && viewHasAppeared else { return }

        if gameGrid.pullUpInProgress() {
            positionNextRoundGrid()
            nextRoundGrid?.show(animated: true)

            let proportionVisible = min(1, gameGrid.distancePulledUp() / gameGrid.pullUpThreshold!)

            if proportionVisible == 1 {
                if !passedNextRoundThreshold {
                    playSound(.NextRound)
                    passedNextRoundThreshold = true
                    gamePlayMessageNotification.toggle(inFrame: view.bounds, showing: false)
                    nextRoundNotification.toggle(inFrame: view.bounds, showing: true, animated: true)
                }
            } else {
                nextRoundNotification.toggle(inFrame: view.bounds, showing: false, animated: true)
                passedNextRoundThreshold = false
            }

            nextRoundGrid?.proportionVisible = proportionVisible
        } else {
            nextRoundGrid?.hide(animated: true)
            passedNextRoundThreshold = false
        }

        menu.position()
    }

    private func handlePullingDown(withFraction fraction: CGFloat) {
        guard menu.hidden else { return }
        view.backgroundColor = Play.gameplayBGColor.interpolateTo(Play.defaultBGColor, fraction: fraction)
    }

    private func handlePullingUpFromStartingPosition(withFraction fraction: CGFloat) {
        view.backgroundColor = Play.defaultBGColor.interpolateTo(Play.gameplayBGColor, fraction: fraction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Onboarding ended

    private func handleOnboardingWillDismissWithGame(onboardingGame: Game) {
        view.backgroundColor = Play.gameplayBGColor
        restart(withGame: onboardingGame, inGameplayPosition: true)

        // Don't know why... Possibly because we don't call handleScroll()
        menu.position()
    }
}
