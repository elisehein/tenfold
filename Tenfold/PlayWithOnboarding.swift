//
//  PlayWithOnboarding.swift
//  Tenfold
//
//  Created by Elise Hein on 02/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class PlayWithOnboarding: Play {

    var flashTimer: NSTimer?
    var indecesToFlash: Array<Int> = []

    var onWillFinishWithGame: ((game: Game) -> Void)?

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
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func handleBeginTransitionToStep(onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .LastTips:
            gameGrid.userInteractionEnabled = false
            gameGrid.scrollEnabled = false
            onWillFinishWithGame?(game: game)

            // swiftlint:disable:next line_length
            NSTimer.scheduledTimerWithTimeInterval(4.5, target: self, selector: #selector(PlayWithOnboarding.handleDismissal), userInfo: nil, repeats: false)
        default:
            return
        }
    }
    private func handleEndTransitionToStep(onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .CrossOutIdentical:
            hintAtPairing([10, 19])
        case .CrossOutSummandsOfTen:
            hintAtPairing([8, 17])
        case .PullUP:
            gameGrid.automaticallySnapToGameplayPosition = true
            gameGrid.indecesPermittedForSelection = []
            gameGrid.userInteractionEnabled = true
            gameGrid.scrollEnabled = true
        default:
            return
        }
    }

    private func hintAtPairing(pairIndeces: Array<Int>) {
        gameGrid.indecesPermittedForSelection = pairIndeces
        gameGrid.userInteractionEnabled = true
        gameGrid.scrollEnabled = false
        indecesToFlash = pairIndeces

        flashNumbers()
        // swiftlint:disable:next line_length
        flashTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(PlayWithOnboarding.flashNumbers), userInfo: nil, repeats: true)
    }

    func flashNumbers() {
        gameGrid.flashNumbers(atIndeces: indecesToFlash)
    }

    override func handleSuccessfulPairing(index: Int, otherIndex: Int) {
        flashTimer?.invalidate()
        super.handleSuccessfulPairing(index, otherIndex: otherIndex)

        if menu.onboardingSteps.currentStep == .CrossOutIdentical &&
           game.totalNumbers() - game.numbersRemaining() <= 2 {
            hintAtPairing([9, 11])
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
