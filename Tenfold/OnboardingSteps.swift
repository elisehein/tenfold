//
//  OnboardingSteps.swift
//  Tenfold
//
//  Created by Elise Hein on 02/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

enum OnboardingStep: Int {
    case Welcome = 0
    case AimOfTheGame = 1
    case CrossOutIdentical = 2
    case CrossOutSummandsOfTen = 3
    case PullUp = 4
    case LastTips = 5
    case Empty = 6
}

class OnboardingSteps: UIView {

    private static let steps = JSON.initFromFile("onboardingSteps")!

    private static let topLabelAnimationDelay: Double = 0.5
    private static let bottomLabelAnimationDelay: Double = 0.6
    private static let animationDuration: Double = 0.8

    private let topLabel = UILabel()
    private let bottomLabel = UILabel()
    private let downArrow = UIImageView(image: UIImage(named: "chevron-down"))

    let buttonsContainer = UIView()
    private let okButton = Button()
    private let dismissButton = Button()

    private let labelBaseAttributes: [String: AnyObject] = {
        let isIPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad

        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        paragraphStyle.lineSpacing = isIPad ? 7 : 4

        let attributes = [
            NSForegroundColorAttributeName: UIColor.themeColor(.OffBlack),
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.themeFontWithSize(isIPad ? 18 : 14)
        ]

        return attributes
    }()

    private var hasLoadedConstraints = false

    var currentStep: OnboardingStep?

    var onDismiss: (() -> Void)?
    var onBeginTransitionToStep: ((onboardingStep: OnboardingStep) -> Void)?
    var onEndTransitionToStep: ((onboardingStep: OnboardingStep) -> Void)?

    init() {
        super.init(frame: CGRect.zero)

        topLabel.numberOfLines = 0
        bottomLabel.numberOfLines = 0
        topLabel.alpha = 0
        bottomLabel.alpha = 0

        addSubview(topLabel)
        addSubview(bottomLabel)

        buttonsContainer.hidden = true

        okButton.setTitle("Yes", forState: .Normal)
        okButton.addTarget(self,
                           action: #selector(OnboardingSteps.transitionToNextStep),
                           forControlEvents: .TouchUpInside)

        dismissButton.setTitle("No", forState: .Normal)
        dismissButton.addTarget(self,
                           action: #selector(OnboardingSteps.didDismissOnboarding),
                           forControlEvents: .TouchUpInside)

        addSubview(buttonsContainer)
        buttonsContainer.addSubview(okButton)
        buttonsContainer.addSubview(dismissButton)

        downArrow.contentMode = .Center
        downArrow.hidden = true
        addSubview(downArrow)

        setNeedsUpdateConstraints()
    }

    func begin() {
        transitionToStep(.Welcome)
    }

    func transitionToStep(onboardingStep: OnboardingStep) {
        currentStep = onboardingStep
        onBeginTransitionToStep?(onboardingStep: onboardingStep)

        let firstStep = OnboardingSteps.steps[onboardingStep.rawValue][0].string!
        topLabel.attributedText = NSAttributedString(string: firstStep,
                                                     attributes: labelBaseAttributes)

        UIView.animateWithDuration(OnboardingSteps.animationDuration,
                                   delay: topLabelAppearanceDelay(forStep: onboardingStep),
                                   options: [],
                                   animations: {
           self.topLabel.alpha = 1
        }, completion: { _ in
            if OnboardingSteps.steps[onboardingStep.rawValue].count > 1 {
                self.showBottomLabel(forOnboardingStep: onboardingStep)
            } else {
                self.onEndTransitionToStep?(onboardingStep: onboardingStep)
            }
        })

        registerStepExtras(onboardingStep)
    }

    private func showBottomLabel(forOnboardingStep onboardingStep: OnboardingStep) {
        let secondStep = OnboardingSteps.steps[onboardingStep.rawValue][1].string!
        bottomLabel.attributedText = NSAttributedString(string: secondStep,
                                                        attributes: labelBaseAttributes)
        UIView.animateWithDuration(OnboardingSteps.animationDuration,
                                   delay: bottomLabelAppearanceDelay(forStep: onboardingStep),
                                   options: [],
                                   animations: {
            self.bottomLabel.alpha = 1
        }, completion: { _ in
            self.onEndTransitionToStep?(onboardingStep: onboardingStep)
        })
    }

    func transitionToNextStep() {
        UIView.animateWithDuration(0.3, animations: {
            self.topLabel.alpha = 0
            self.bottomLabel.alpha = 0
            self.removeStepExtras(self.currentStep!)
        }, completion: { _ in
            let nextStep = OnboardingStep(rawValue: self.currentStep!.rawValue + 1)!
            self.transitionToStep(nextStep)
        })
    }

    private func topLabelAppearanceDelay(forStep onboardingStep: OnboardingStep) -> Double {
        switch onboardingStep {
        case .PullUp:
            return 1
        default:
            return OnboardingSteps.topLabelAnimationDelay
        }
    }

    private func bottomLabelAppearanceDelay(forStep onboardingStep: OnboardingStep) -> Double {
        switch onboardingStep {
        case .CrossOutIdentical:
            return 2
        default:
            return OnboardingSteps.bottomLabelAnimationDelay
        }
    }

    private func registerStepExtras(onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .Welcome:
            displayButtons()
        case .AimOfTheGame:
            // swiftlint:disable:next line_length
            NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(OnboardingSteps.transitionToNextStep), userInfo: nil, repeats: false)
        case .LastTips:
            // swiftlint:disable:next line_length
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(OnboardingSteps.transitionToNextStep), userInfo: nil, repeats: false)
        default:
            return
        }
    }

    private func removeStepExtras(onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .Welcome:
            removeButtons()
        default:
            return
        }
    }

    private func displayButtons() {
        buttonsContainer.alpha = 0
        buttonsContainer.hidden = false

        // swiftlint:disable:next line_length
        let delay = OnboardingSteps.topLabelAnimationDelay + OnboardingSteps.animationDuration + OnboardingSteps.bottomLabelAnimationDelay
        UIView.animateWithDuration(OnboardingSteps.animationDuration,
                                   delay: delay,
                                   options: [],
                                   animations: {
            self.buttonsContainer.alpha = 1
        }, completion: nil)
    }

    private func removeButtons() {
        UIView.animateWithDuration(0.3, animations: {
            self.buttonsContainer.alpha = 0
        }, completion: { _ in
            self.buttonsContainer.removeFromSuperview()
        })
    }

    func didDismissOnboarding() {
        onDismiss?()
    }

    override func updateConstraints() {
        if !hasLoadedConstraints {

            topLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 30)
            bottomLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: topLabel, withOffset: 15)

            for label in [topLabel, bottomLabel] {
                label.autoAlignAxisToSuperviewAxis(.Vertical)
                label.autoMatchDimension(.Width,
                                         toDimension: .Width,
                                         ofView: self,
                                         withMultiplier: 0.8)
            }

            buttonsContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: bottomLabel, withOffset: 30)
            buttonsContainer.autoAlignAxisToSuperviewAxis(.Vertical)
            buttonsContainer.autoSetDimension(.Height, toSize: Menu.buttonHeight)
            buttonsContainer.autoMatchDimension(.Width,
                                                toDimension: .Width,
                                                ofView: self,
                                                withMultiplier: 0.6)

            okButton.autoPinEdgesToSuperviewMarginsExcludingEdge(.Right)
            dismissButton.autoPinEdgesToSuperviewMarginsExcludingEdge(.Left)

            for button in [okButton, dismissButton] {
                button.autoMatchDimension(.Width,
                                          toDimension: .Width,
                                          ofView: buttonsContainer, withMultiplier: 0.5)
            }

            hasLoadedConstraints = true
        }

        super.updateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
