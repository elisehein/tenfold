//
//  Onboarding.swift
//  Tenfold
//
//  Created by Elise Hein on 02/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Onboarding: Play {

    var flashTimer: Timer?
    var indecesToFlash: [Int] = []

    var onWillDismissWithGame: ((_ game: Game) -> Void)?

    init() {
        super.init(shouldShowUpdatesModal: false, firstLaunch: false, isOnboarding: true)

        modalTransitionStyle = .crossDissolve

        menu.onboardingSteps.onDismiss = handleDismissal
        menu.onboardingSteps.onBeginTransitionToStep = handleBeginTransitionToStep
        menu.onboardingSteps.onEndTransitionToStep = handleEndTransitionToStep

        gameGrid.isUserInteractionEnabled = false
        gameGrid.isScrollEnabled = false
    }

    func handleDismissal() {
        dismiss(animated: menu.onboardingSteps.currentStep == .welcome, completion: nil)
    }

    fileprivate func handleBeginTransitionToStep(_ onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .lastTips:
            gameGrid.isUserInteractionEnabled = false
            gameGrid.isScrollEnabled = false
            onWillDismissWithGame?(game)
        default:
            return
        }
    }
    fileprivate func handleEndTransitionToStep(_ onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .aimOfTheGame:
            // swiftlint:disable:next line_length
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Onboarding.flashGrid), userInfo: nil, repeats: false)

            // swiftlint:disable:next line_length
            Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(Onboarding.transitionToNextStep), userInfo: nil, repeats: false)
        case .crossOutIdentical:
            hintAtPairing([10, 19])
        case .crossOutSummandsOfTen:
            hintAtPairing([8, 17])
        case .pullUp:
            gameGrid.automaticallySnapToGameplayPosition = true
            gameGrid.indecesPermittedForSelection = []
            gameGrid.isUserInteractionEnabled = true
            gameGrid.isScrollEnabled = true
        case .lastTips:
            // swiftlint:disable:next line_length
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(Onboarding.transitionToNextStep), userInfo: nil, repeats: false)
        case .empty:
            handleDismissal()
        default:
            return
        }
    }

    fileprivate func hintAtPairing(_ pairIndeces: [Int]) {
        gameGrid.indecesPermittedForSelection = pairIndeces
        gameGrid.isUserInteractionEnabled = true
        gameGrid.isScrollEnabled = false
        indecesToFlash = pairIndeces

        flashPairing()
        // swiftlint:disable:next line_length
        flashTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(Onboarding.flashPairing), userInfo: nil, repeats: true)
    }

    func flashPairing() {
        gameGrid.flashNumbers(atIndeces: indecesToFlash,
                              withColor: UIColor.themeColor(.accent))
    }

    func flashGrid() {
        gameGrid.flashNumbers(atIndeces: Array(0..<27),
                              withColor: UIColor.themeColor(.offWhiteShaded))
    }

    func transitionToNextStep() {
        menu.onboardingSteps.transitionToNextStep()
    }

    override func handleSuccessfulPairing(_ pair: Pair) {
        flashTimer?.invalidate()
        super.handleSuccessfulPairing(pair)

        if menu.onboardingSteps.currentStep == .crossOutIdentical &&
           game.numbersCrossedOut() <= 2 {
            hintAtPairing([9, 11])
        } else if menu.onboardingSteps.currentStep == .crossOutSummandsOfTen &&
                  game.numbersCrossedOut() <= 6 {
           hintAtPairing([25, 26])
        } else {
            menu.onboardingSteps.transitionToNextStep()
        }
    }

    override func detectPan(_ recognizer: UIPanGestureRecognizer) {
        // Do nothing
    }

    override func handlePullUpThresholdExceeded() {
        super.handlePullUpThresholdExceeded()
        menu.onboardingSteps.transitionToNextStep()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
