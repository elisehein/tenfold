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
        dismissViewControllerAnimated(true, completion: nil)
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
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(PlayWithOnboarding.previewCrossedOutGrid), userInfo: nil, repeats: false)
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

    private func hintAtPairing(pairIndeces: Array<Int>) {
        gameGrid.indecesPermittedForSelection = pairIndeces
        gameGrid.userInteractionEnabled = true
        gameGrid.scrollEnabled = false
        indecesToFlash = pairIndeces

        flashPairing()
        // swiftlint:disable:next line_length
        flashTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(PlayWithOnboarding.flashPairing), userInfo: nil, repeats: true)
    }

    func flashPairing() {
        gameGrid.flashNumbers(atIndeces: indecesToFlash,
                              withColor: UIColor.themeColor(.Accent))
    }

    func previewCrossedOutGrid() {
        gameGrid.flashNumbers(atIndeces: Array(0..<27),
                              withColor: UIColor.themeColor(.OffWhiteShaded))
    }

    override func handleSuccessfulPairing(index: Int, otherIndex: Int) {
        flashTimer?.invalidate()
        super.handleSuccessfulPairing(index, otherIndex: otherIndex)

        if menu.onboardingSteps.currentStep == .CrossOutIdentical &&
           game.totalNumbers() - game.numbersRemaining() <= 2 {
            hintAtPairing([9, 11])
        } else if menu.onboardingSteps.currentStep == .CrossOutSummandsOfTen &&
                  game.totalNumbers() - game.numbersRemaining() <= 6 {
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
