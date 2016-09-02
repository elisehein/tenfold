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
    case IntroducePlayingField = 1
    case CrossOutIdentical = 2
    case CrossOutSummandsOfTen = 3
    case PullUP = 4
    case LastTips = 5
}

class OnboardingSteps: UIView {

    private static let steps = JSON.initFromFile("onboardingSteps")!

    private static let animationDelay: Double = 1
    private static let animationDuration: Double = 0.8

    private let topLabel = UILabel()
    private let bottomLabel = UILabel()
    private let downArrow = UIImageView(image: UIImage(named: "chevron-down"))

    let buttonsContainer = UIView()
    private let okButton = Button()
    private let dismissButton = Button()

    private let labelBaseAttributes: [String: AnyObject] = {
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        paragraphStyle.lineSpacing = 4

        let attributes = [
            NSForegroundColorAttributeName: UIColor.themeColor(.OffBlack),
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.themeFontWithSize(14)
        ]

        return attributes
    }()

    private var hasLoadedConstraints = false

    var currentStep: OnboardingStep = .Welcome

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

    func transitionToStep(onboardingStep: OnboardingStep) {
        onBeginTransitionToStep?(onboardingStep: onboardingStep)

        let firstStep = OnboardingSteps.steps[onboardingStep.rawValue][0].string!
        topLabel.attributedText = NSAttributedString(string: firstStep,
                                                     attributes: labelBaseAttributes)

        UIView.animateWithDuration(OnboardingSteps.animationDuration, animations: {
           self.topLabel.alpha = 1
        })

        if OnboardingSteps.steps[onboardingStep.rawValue].count > 1 {
            let secondStep = OnboardingSteps.steps[onboardingStep.rawValue][1].string!
            bottomLabel.attributedText = NSAttributedString(string: secondStep,
                                                            attributes: labelBaseAttributes)
            UIView.animateWithDuration(OnboardingSteps.animationDuration,
                                       delay: bottomLabelAppearanceDelayForStep(onboardingStep),
                                       options: [],
                                       animations: {
                self.bottomLabel.alpha = 1
            }, completion: { _ in
                self.onEndTransitionToStep?(onboardingStep: onboardingStep)
            })
        } else {
            onEndTransitionToStep?(onboardingStep: onboardingStep)
        }

        registerStepExtras(onboardingStep)
    }

    func transitionToNextStep() {
        UIView.animateWithDuration(0.3, animations: {
            self.topLabel.alpha = 0
            self.bottomLabel.alpha = 0
            self.removeStepExtras(self.currentStep)
        }, completion: { _ in
            self.currentStep = OnboardingStep(rawValue: self.currentStep.rawValue + 1)!
            self.transitionToStep(self.currentStep)
        })
    }

    private func bottomLabelAppearanceDelayForStep(onboardingStep: OnboardingStep) -> Double {
        switch onboardingStep {
        case .IntroducePlayingField:
            return 0
        case .CrossOutIdentical:
            return 2
        default:
            return OnboardingSteps.animationDelay
        }

    }

    private func registerStepExtras(onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .Welcome:
            displayButtons()
        case .IntroducePlayingField:
            showDownArrow()
            // swiftlint:disable:next line_length
            NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(OnboardingSteps.transitionToNextStep), userInfo: nil, repeats: false)

        default:
            return
        }
    }

    private func removeStepExtras(onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .Welcome:
            removeButtons()
        case .IntroducePlayingField:
            removeDownArrow()
        default:
            return
        }
    }

    private func displayButtons() {
        buttonsContainer.alpha = 0
        buttonsContainer.hidden = false

        UIView.animateWithDuration(OnboardingSteps.animationDuration,
                                   delay: 2 * OnboardingSteps.animationDelay,
                                   options: [],
                                   animations: {
            self.buttonsContainer.alpha = 1
        }, completion: nil)
    }

    private func showDownArrow() {
        downArrow.hidden = false
        downArrow.alpha = 0

        var arrowFrame = CGRect(x: 0,
                                y: bounds.size.height - 100,
                                width: bounds.size.width,
                                height: 30)
        downArrow.frame = arrowFrame

        UIView.animateWithDuration(OnboardingSteps.animationDuration, animations: {
            self.downArrow.alpha = 1
        })
        UIView.animateWithDuration(1,
                                   delay: 0,
                                   options: [.CurveEaseInOut,
                                             .Autoreverse,
                                             .Repeat,
                                             .AllowUserInteraction],
                                   animations: {
            arrowFrame.origin.y += 20
            self.downArrow.frame = arrowFrame
        }, completion: nil)
    }

    private func removeButtons() {
        UIView.animateWithDuration(0.3, animations: {
            self.buttonsContainer.alpha = 0
        }, completion: { _ in
            self.buttonsContainer.removeFromSuperview()
        })
    }

    private func removeDownArrow() {
        UIView.animateWithDuration(0.3, animations: {
            self.downArrow.alpha = 0
        }, completion: { _ in
            self.downArrow.removeFromSuperview()
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
