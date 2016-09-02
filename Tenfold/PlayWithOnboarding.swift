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
        menu.onboardingSteps.onEndTransitionToStep =
            handleEndTransitionToStep

        gameGrid.userInteractionEnabled = false
        gameGrid.scrollEnabled = false
    }

    private func handleDismissal() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func handleEndTransitionToStep(stepIndex: Int) {
        switch stepIndex {
        case 2:
            hintAtPairing([10, 19])
        case 3:
            hintAtPairing([8, 17])
        case 4:
            gameGrid.automaticallySnapToGameplayPosition = true
            gameGrid.indecesPermittedForSelection = []
            gameGrid.userInteractionEnabled = true
            gameGrid.scrollEnabled = true
        case 5:
            gameGrid.userInteractionEnabled = false
            gameGrid.scrollEnabled = false
            onWillFinishWithGame?(game: game)
            dismissViewControllerAnimated(false, completion: nil)
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

        if menu.onboardingSteps.currentStepIndex == 2 &&
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
