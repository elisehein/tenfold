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

    var flashTimer: NSTimer?
    var indecesToFlash: [Int] = []

    var onWillDismissWithGame: ((game: Game) -> Void)?

    init() {
        super.init(shouldLaunchOnboarding: false, isOnboarding: true)

        modalTransitionStyle = .CrossDissolve

        menu.onboardingSteps.onDismiss = handleDismissal
        menu.onboardingSteps.onBeginTransitionToStep = handleBeginTransitionToStep
        menu.onboardingSteps.onEndTransitionToStep = handleEndTransitionToStep

        gameGrid.userInteractionEnabled = false
        gameGrid.scrollEnabled = false
    }

    func handleDismissal() {
        dismissViewControllerAnimated(menu.onboardingSteps.currentStep == .Welcome, completion: nil)
    }

    private func handleBeginTransitionToStep(onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .LastTips:
            gameGrid.userInteractionEnabled = false
            gameGrid.scrollEnabled = false
            onWillDismissWithGame?(game: game)
        default:
            return
        }
    }
    private func handleEndTransitionToStep(onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .AimOfTheGame:
            // swiftlint:disable:next line_length
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(Onboarding.flashGrid), userInfo: nil, repeats: false)
        case .CrossOutIdentical:
            hintAtPairing([10, 19])
        case .CrossOutSummandsOfTen:
            hintAtPairing([8, 17])
        case .PullUp:
            gameGrid.automaticallySnapToGameplayPosition = true
            gameGrid.indecesPermittedForSelection = []
            gameGrid.userInteractionEnabled = true
            gameGrid.scrollEnabled = true
        case .Empty:
            handleDismissal()
        default:
            return
        }
    }

    private func hintAtPairing(pairIndeces: [Int]) {
        gameGrid.indecesPermittedForSelection = pairIndeces
        gameGrid.userInteractionEnabled = true
        gameGrid.scrollEnabled = false
        indecesToFlash = pairIndeces

        flashPairing()
        // swiftlint:disable:next line_length
        flashTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(Onboarding.flashPairing), userInfo: nil, repeats: true)
    }

    func flashPairing() {
        gameGrid.flashNumbers(atIndeces: indecesToFlash,
                              withColor: UIColor.themeColor(.Accent))
    }

    func flashGrid() {
        gameGrid.flashNumbers(atIndeces: Array(0..<27),
                              withColor: UIColor.themeColor(.OffWhiteShaded))
    }

    override func handleSuccessfulPairing(pair: Pair) {
        flashTimer?.invalidate()
        super.handleSuccessfulPairing(pair)

        if menu.onboardingSteps.currentStep == .CrossOutIdentical &&
           game.numbersCrossedOut() <= 2 {
            hintAtPairing([9, 11])
        } else if menu.onboardingSteps.currentStep == .CrossOutSummandsOfTen &&
                  game.numbersCrossedOut() <= 6 {
           hintAtPairing([25, 26])
        } else {
            menu.onboardingSteps.transitionToNextStep()
        }
    }

    override func handlePullUpThresholdExceeded() {
        super.handlePullUpThresholdExceeded()
        menu.onboardingSteps.transitionToNextStep()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
