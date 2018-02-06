//
//  Play.swift
//  Tenfold
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class Play: UIViewController {

    private var panTriggered: Bool = false

    private static let gridInset: CGFloat = 8

    private static let defaultBGColor = UIColor.themeColor(.offWhite)
    private static let gameplayBGColor = UIColor.themeColor(.offWhiteShaded)

    private static let maxNextRoundPullUpThreshold: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 140 : 120
    }()

    var game: Game

    let menu: Menu
    let gameGrid: GameGrid
    private var nextRoundGrid: NextRoundGrid?
    private let nextRoundPill = NextRoundPill()
    private let gameplayMessagePill = GameplayMessagePill()
    private let iconPill = Pill(type: .icon)

    private let overlayScorePanel = ScorePanel(appearance: .overlay)
    private let inlineScorePanel = ScorePanel(appearance: .inline)

    private var passedNextRoundThreshold = false

    private var safeFrame: CGRect = CGRect.zero

    private var viewHasLoaded = false
    private var viewHasAppeared = false
    private var shouldShowUpdatesModal: Bool
    private var shouldLaunchOnboarding: Bool
    private var isOnboarding: Bool

    init(shouldShowUpdatesModal: Bool, firstLaunch: Bool, isOnboarding: Bool = false) {
        let savedGame = StorageService.restoreGame()

        // If we do *somehow* have a saved game, don't mess with it and just show them
        // the regular Play screen
        self.shouldLaunchOnboarding = firstLaunch && savedGame == nil
        self.isOnboarding = isOnboarding && savedGame == nil
        self.shouldShowUpdatesModal = shouldShowUpdatesModal

        self.game = savedGame == nil ? Game() : savedGame!
        self.gameGrid = GameGrid(game: game)
        self.menu = Menu(state: self.isOnboarding ? .onboarding : .default, firstLaunch: firstLaunch)

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
        menu.onTapOptions = { self.present(OptionsModal(), animated: true, completion: nil) }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(Play.detectPan))

        overlayScorePanel.onTap = handleScorePillTap
        updateScore()

        view.backgroundColor = Play.defaultBGColor
        view.addGestureRecognizer(pan)
        view.addSubview(gameGrid)
        view.addSubview(menu)
        view.addSubview(gameplayMessagePill)
        view.addSubview(nextRoundPill)
        view.addSubview(iconPill)
        view.addSubview(overlayScorePanel)
        view.addSubview(inlineScorePanel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        safeFrame = view.bounds
        initialisePositions()
        viewHasLoaded = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)

        if !shouldLaunchOnboarding && !isOnboarding {
            menu.showDefaultView()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let safeInsets = view.safeAreaInsets
        let safeSize = CGSize(width: view.bounds.size.width - safeInsets.left - safeInsets.right,
                              height: view.bounds.size.height - safeInsets.top - safeInsets.bottom)
        safeFrame = CGRect(origin: CGPoint(x: safeInsets.left, y: safeInsets.top), size: safeSize)
        overlayScorePanel.topInset = safeInsets.top
        inlineScorePanel.topInset = safeInsets.top
        initialisePositions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if shouldLaunchOnboarding {
            let onboarding = Onboarding()
            onboarding.onWillDismissWithGame = handleOnboardingWillDismissWithGame
            present(onboarding, animated: false, completion: nil)
            shouldLaunchOnboarding = false
            return
        }

        if shouldShowUpdatesModal {
            present(UpdatesModal(), animated: true, completion: nil)
            shouldShowUpdatesModal = false
        } else if isOnboarding {
            menu.onboardingSteps.begin()
        }

        viewHasAppeared = true
    }

    private func initialisePositions() {
        // Cap the width for larger screens
        var gameGridFrame = safeFrame
        gameGridFrame.size.width = min(540, gameGridFrame.size.width)
        gameGridFrame.origin.x = (safeFrame.size.width - gameGridFrame.size.width) / 2

        let insets = UIEdgeInsets(top: Play.gridInset,
                                  left: Play.gridInset,
                                  bottom: Play.gridInset,
                                  right: Play.gridInset)
        gameGrid.initialisePositionWithinFrame(gameGridFrame, withInsets: insets)

        menu.emptySpaceAvailable = gameGrid.emptySpaceVisible
        menu.anchorFrame = safeFrame

        nextRoundPill.toggle(inFrame: safeFrame, showing: false)
        gameplayMessagePill.toggle(inFrame: safeFrame, showing: false)
        iconPill.toggle(inFrame: safeFrame, showing: false)
        initNextRoundMatrix()

        gameGrid.snapToStartingPositionThreshold = 70
        gameGrid.snapToGameplayPositionThreshold = 50
        gameGrid.spaceForScore = Pill.margin * 2 + Pill.labelHeight + safeFrame.origin.y - gameGrid.frame.origin.y
    }

    private func initNextRoundMatrix() {
        let nextRoundValues = game.nextRoundValues()
        nextRoundGrid = NextRoundGrid(cellsPerRow: Game.numbersPerRow,
                                      startIndex: game.lastNumberColumn() + 1,
                                      values: nextRoundValues,
                                      frame: gameGrid.frame)
        nextRoundGrid?.hide(animated: false)

        updateNextRoundPillText()
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

    private func calcNextRoundPullUpThreshold(_ numberOfItemsInNextRound: Int) -> CGFloat {
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
            present(modal, animated: true, completion: nil)
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
            self.updateNextRoundPillText()
            self.updateScore()
            self.updateState()
            self.inlineScorePanel.toggle(showing: false)
            self.overlayScorePanel.toggle(showing: false)
            self.nextRoundGrid?.hide(animated: false)
            self.menu.showIfNeeded(atDefaultPosition: !inGameplayPosition)
        })

        view.backgroundColor = inGameplayPosition ? Play.gameplayBGColor : Play.defaultBGColor
    }

    func showInstructions() {
        navigationController?.pushViewController(Rules(), animated: true)
    }

    // MARK: Gameplay logic

    private func handlePairingAttempt(_ pair: Pair) {
        let successfulPairing = Pairing.validate(pair, inGame: game)

        if successfulPairing {
            handleSuccessfulPairing(pair)
        } else {
            gameGrid.dismissSelection()
        }

        // Only really needed when we're carrying on with the onboarding game.
        // This is a silly place for now, but it works okay for now, because it doesn't really matter
        // how often we toggle the score (nothing happens if it's already visible).
        // In that case, we first see the "Pull down to see menu" pill when we make the first
        // game move, and then when we've chosen two, we ensure the score becomes visible, too.
        if !isOnboarding {
            menu.hideTipsIfNeeded()
            inlineScorePanel.toggle(showing: true, animated: true)
        }
    }

    func handleSuccessfulPairing(_ pair: Pair) {
        game.crossOut(pair)
        gameGrid.crossOut(pair)
        updateNextRoundPillText()
        updateScore()
        updateState()

        if removeSurplusRows(containingItemsFrom: pair) {
            playSound(.crossOutRow)
        } else {
            playSound(.crossOut)
        }

        checkForNewlyUnrepresentedValues()
    }

    @objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
        guard recognizer.state == .changed else {
            panTriggered = recognizer.state == .ended
            return
        }

        guard !panTriggered else { return }
        guard abs(recognizer.translation(in: view).x) > 70 else { return }

        if recognizer.velocity(in: view).x > 0 {
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
            iconPill.iconName = "not-allowed"
            iconPill.flash(inFrame: safeFrame)
            return
        }
        // These only apply when returning from onboarding
        menu.hideIfNeeded()
        inlineScorePanel.toggle(showing: true, animated: true)

        if game.latestMoveType() == .crossingOutPair {
            undoLatestPairing()
        } else if game.latestMoveType() == .loadingNextRound {
            undoNewRound()
        }

        iconPill.iconName = "undo"
        iconPill.flash(inFrame: safeFrame)
    }

    func undoNewRound() {
        if let indeces = game.undoNewRound() {
            gameGrid.removeRows(withNumberIndeces: indeces, completion: {
                self.updateNextRoundPillText()
                self.updateScore()
                self.updateState()
            })
        }
    }

    func undoLatestPairing() {
        let undoPairing: ((_ delay: Double) -> Void) = { delay in
            if let pair = self.game.undoLatestPairing() {
                self.gameGrid.unCrossOut(pair, withDelay: delay)
                self.updateNextRoundPillText()
                self.updateScore()
                self.updateState()
            }
        }

        if let newRowIndeces = game.undoRowRemoval() {
            gameGrid.addRows(atIndeces: newRowIndeces, completion: {
                undoPairing(0.3)
            })
        } else {
            undoPairing(0)
        }
    }

    private func nextRoundAllowed() -> Bool {
        return game.potentialPairs().count < 10
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
            updateScore()
            updateState()
        }
    }

    private func removeSurplusRows(containingItemsFrom pair: Pair) -> Bool {
        let surplusIndeces = game.removeRowsIfNeeded(containingItemsFrom: pair)

        if surplusIndeces.count > 0 {
            gameGrid.removeRows(withNumberIndeces: surplusIndeces, completion: {
                if self.game.ended() {
                    StorageService.saveGameSnapshot(self.game, forced: true)
                    self.present(GameFinished(game: self.game), animated: true, completion: {
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
            gameplayMessagePill.newlyUnrepresentedNumber = unrepresented[0]
            gameplayMessagePill.popup(forSeconds: 3, inFrame: safeFrame, completion: {
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

    private func updateNextRoundPillText() {
        nextRoundPill.numberCount = game.numbersRemaining()
    }

    private func updateScore() {
        overlayScorePanel.numbersRemaining = game.numbersRemaining()
        overlayScorePanel.currentRound = game.currentRound
        inlineScorePanel.numbersRemaining = game.numbersRemaining()
        inlineScorePanel.currentRound = game.currentRound
    }

    private func playSound(_ sound: Sound) {
        if !isOnboarding {
            SoundService.singleton!.playIfAllowed(sound)
        }

        SoundService.singleton!.vibrateIfAllowed(sound)
    }

    // MARK: Scrolling interactions

    private func handleScorePillTap() {
        gameGrid.scrollToTopIfPossible()
    }

    private func handleWillSnapToStartingPosition() {
        view.backgroundColor = Play.defaultBGColor
        inlineScorePanel.toggle(showing: false)
        menu.showIfNeeded(atDefaultPosition: true)
    }

    func handleWillSnapToGameplayPosition() {
        view.backgroundColor = Play.gameplayBGColor

        if !isOnboarding {
            menu.hideIfNeeded()
        }
    }

    func handleDidSnapToGameplayPosition() {
        inlineScorePanel.alpha = 1
        inlineScorePanel.toggle(showing: true, animated: true)
    }

    func handlePullUpThresholdExceeded() {
        guard nextRoundAllowed() else {
            _ = Timer.scheduledTimer(timeInterval: 1.5,
                                     target: self,
                                     selector: #selector(self.presentExplanationModalIfNeeded),
                                     userInfo: nil,
                                     repeats: false)
            return
        }

        nextRoundGrid?.hide(animated: false)
        nextRoundPill.dismiss(inFrame: safeFrame, completion: {
            self.updateNextRoundPillText()
        })
        loadNextRound()

        if !isOnboarding {
            menu.hideIfNeeded()
            inlineScorePanel.toggle(showing: true, animated: true)
        }
    }

    @objc func presentExplanationModalIfNeeded() {
        guard !StorageService.hasSeenFeatureAnnouncement(.nextRoundDisallowed) else { return }

        let modal = NextRoundDisallowedModal(potentialPairs: game.potentialPairs().count)
        modal.onTapHelp = showInstructions
        present(modal, animated: true, completion: nil)
        StorageService.markFeatureAnnouncementSeen(.nextRoundDisallowed)
    }

    private func handleScroll() {
        guard viewHasLoaded && viewHasAppeared else { return }

        if gameGrid.pullUpInProgress() {
            positionNextRoundGrid()
            nextRoundGrid?.show(animated: true)

            let proportionVisible = min(1, gameGrid.distancePulledUp() / gameGrid.pullUpThreshold!)
            let appropriatePill = nextRoundAllowed() ? nextRoundPill : iconPill
            iconPill.iconName = "not-allowed"

            if proportionVisible == 1 {
                if !passedNextRoundThreshold {
                    playSound(.nextRound)
                    passedNextRoundThreshold = true
                    gameplayMessagePill.toggle(inFrame: safeFrame, showing: false)
                    appropriatePill.toggle(inFrame: safeFrame, showing: true, animated: true)
                }
            } else {
                appropriatePill.toggle(inFrame: safeFrame, showing: false, animated: true)
                passedNextRoundThreshold = false
            }

            nextRoundGrid?.proportionVisible = proportionVisible
        } else {
            nextRoundGrid?.hide(animated: true)
            passedNextRoundThreshold = false
        }

        positionScore()
        menu.position()
    }

    private func handlePullingDown(withFraction fraction: CGFloat) {
        guard menu.isHidden else { return }
        inlineScorePanel.alpha = 1 - fraction
        view.backgroundColor = Play.gameplayBGColor.interpolateTo(Play.defaultBGColor, fraction: fraction)
    }

    private func handlePullingUpFromStartingPosition(withFraction fraction: CGFloat) {
        view.backgroundColor = Play.defaultBGColor.interpolateTo(Play.gameplayBGColor, fraction: fraction)
    }

    private func positionScore() {
        if gameGrid.contentOffset.y > -gameGrid.spaceForScore {
            overlayScorePanel.toggle(showing: true, animated: true)
            inlineScorePanel.isHidden = true
        } else {
            overlayScorePanel.toggle(showing: false, animated: true)
            inlineScorePanel.isHidden = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Onboarding ended

    private func handleOnboardingWillDismissWithGame(_ onboardingGame: Game) {
        view.backgroundColor = Play.gameplayBGColor
        inlineScorePanel.alpha = 1
        restart(withGame: onboardingGame, inGameplayPosition: true)

        // Don't know why... Possibly because we don't call handleScroll()
        menu.position()
    }
}
