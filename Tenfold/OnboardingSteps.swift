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
    case welcome = 0
    case aimOfTheGame = 1
    case crossOutIdentical = 2
    case crossOutSummandsOfTen = 3
    case pullUp = 4
    case lastTips = 5
    case empty = 6
}

class OnboardingSteps: UIView {

    fileprivate static let steps = JSON.initFromFile("onboardingSteps")!

    fileprivate static let topLabelAnimationDelay: Double = 0.5
    fileprivate static let bottomLabelAnimationDelay: Double = 0.6
    fileprivate static let animationDuration: Double = 0.8

    fileprivate let topLabel = UILabel()
    fileprivate let bottomLabel = UILabel()
    fileprivate let downArrow = UIImageView(image: UIImage(named: "chevron-down"))

    let buttonsContainer = UIView()
    fileprivate let okButton = Button()
    fileprivate let dismissButton = Button()

    fileprivate let labelBaseAttributes: [NSAttributedStringKey: Any] = {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = isIPad ? 7 : 4

        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: UIColor.themeColor(.offBlack),
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: UIFont.themeFontWithSize(isIPad ? 18 : 14)
        ]

        return attributes
    }()

    fileprivate var hasLoadedConstraints = false

    var currentStep: OnboardingStep?

    var onDismiss: (() -> Void)?
    var onBeginTransitionToStep: ((_ onboardingStep: OnboardingStep) -> Void)?
    var onEndTransitionToStep: ((_ onboardingStep: OnboardingStep) -> Void)?

    init() {
        super.init(frame: CGRect.zero)

        topLabel.numberOfLines = 0
        bottomLabel.numberOfLines = 0
        topLabel.alpha = 0
        bottomLabel.alpha = 0

        addSubview(topLabel)
        addSubview(bottomLabel)

        buttonsContainer.isHidden = true

        okButton.setTitle("Yes", for: UIControlState())
        okButton.addTarget(self,
                           action: #selector(OnboardingSteps.transitionToNextStep),
                           for: .touchUpInside)

        dismissButton.setTitle("No", for: UIControlState())
        dismissButton.addTarget(self,
                           action: #selector(OnboardingSteps.didDismissOnboarding),
                           for: .touchUpInside)

        addSubview(buttonsContainer)
        buttonsContainer.addSubview(okButton)
        buttonsContainer.addSubview(dismissButton)

        downArrow.contentMode = .center
        downArrow.isHidden = true
        addSubview(downArrow)

        setNeedsUpdateConstraints()
    }

    func begin() {
        transitionToStep(.welcome)
    }

    func transitionToStep(_ onboardingStep: OnboardingStep) {
        currentStep = onboardingStep
        onBeginTransitionToStep?(onboardingStep)

        let firstStep = OnboardingSteps.steps[onboardingStep.rawValue][0].string!
        topLabel.attributedText = NSAttributedString(string: firstStep,
                                                     attributes: labelBaseAttributes)

        UIView.animate(withDuration: OnboardingSteps.animationDuration,
                                   delay: topLabelAppearanceDelay(forStep: onboardingStep),
                                   options: [],
                                   animations: {
           self.topLabel.alpha = 1
        }, completion: { _ in
            if OnboardingSteps.steps[onboardingStep.rawValue].count > 1 {
                self.showBottomLabel(forOnboardingStep: onboardingStep)
            } else {
                self.onEndTransitionToStep?(onboardingStep)
            }
        })

        if onboardingStep == .welcome {
            displayButtons()
        }
    }

    fileprivate func showBottomLabel(forOnboardingStep onboardingStep: OnboardingStep) {
        let secondStep = OnboardingSteps.steps[onboardingStep.rawValue][1].string!
        bottomLabel.attributedText = NSAttributedString(string: secondStep,
                                                        attributes: labelBaseAttributes)
        UIView.animate(withDuration: OnboardingSteps.animationDuration,
                                   delay: bottomLabelAppearanceDelay(forStep: onboardingStep),
                                   options: [],
                                   animations: {
            self.bottomLabel.alpha = 1
        }, completion: { _ in
            self.onEndTransitionToStep?(onboardingStep)
        })
    }

    @objc func transitionToNextStep() {
        UIView.animate(withDuration: 0.3, animations: {
            self.topLabel.alpha = 0
            self.bottomLabel.alpha = 0
            self.removeStepExtras(self.currentStep!)
        }, completion: { _ in
            let nextStep = OnboardingStep(rawValue: self.currentStep!.rawValue + 1)!
            self.transitionToStep(nextStep)
        })
    }

    fileprivate func topLabelAppearanceDelay(forStep onboardingStep: OnboardingStep) -> Double {
        switch onboardingStep {
        case .pullUp:
            return 1
        default:
            return OnboardingSteps.topLabelAnimationDelay
        }
    }

    fileprivate func bottomLabelAppearanceDelay(forStep onboardingStep: OnboardingStep) -> Double {
        switch onboardingStep {
        case .crossOutIdentical:
            return 2
        default:
            return OnboardingSteps.bottomLabelAnimationDelay
        }
    }

    fileprivate func removeStepExtras(_ onboardingStep: OnboardingStep) {
        switch onboardingStep {
        case .welcome:
            removeButtons()
        default:
            return
        }
    }

    fileprivate func displayButtons() {
        buttonsContainer.alpha = 0
        buttonsContainer.isHidden = false

        // swiftlint:disable:next line_length
        let delay = OnboardingSteps.topLabelAnimationDelay + OnboardingSteps.animationDuration + OnboardingSteps.bottomLabelAnimationDelay
        UIView.animate(withDuration: OnboardingSteps.animationDuration,
                                   delay: delay,
                                   options: [],
                                   animations: {
            self.buttonsContainer.alpha = 1
        }, completion: nil)
    }

    fileprivate func removeButtons() {
        UIView.animate(withDuration: 0.3, animations: {
            self.buttonsContainer.alpha = 0
        }, completion: { _ in
            self.buttonsContainer.removeFromSuperview()
        })
    }

    @objc func didDismissOnboarding() {
        onDismiss?()
    }

    override func updateConstraints() {
        if !hasLoadedConstraints {

            topLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
            bottomLabel.autoPinEdge(.top, to: .bottom, of: topLabel, withOffset: 15)

            for label in [topLabel, bottomLabel] {
                label.autoAlignAxis(toSuperviewAxis: .vertical)
                label.autoMatch(.width,
                                         to: .width,
                                         of: self,
                                         withMultiplier: 0.85)
            }

            buttonsContainer.autoPinEdge(.top, to: .bottom, of: bottomLabel, withOffset: 30)
            buttonsContainer.autoAlignAxis(toSuperviewAxis: .vertical)
            buttonsContainer.autoSetDimension(.height, toSize: Menu.buttonHeight)
            buttonsContainer.autoMatch(.width,
                                                to: .width,
                                                of: self,
                                                withMultiplier: 0.6)

            okButton.autoPinEdges(toSuperviewMarginsExcludingEdge: .right)
            dismissButton.autoPinEdges(toSuperviewMarginsExcludingEdge: .left)

            for button in [okButton, dismissButton] {
                button.autoMatch(.width,
                                          to: .width,
                                          of: buttonsContainer, withMultiplier: 0.5)
            }

            hasLoadedConstraints = true
        }

        super.updateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
