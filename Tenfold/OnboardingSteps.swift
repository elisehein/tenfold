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

class OnboardingSteps: UIView {

    private static let steps = JSON.initFromFile("onboardingSteps")!

    private let topLabel = UILabel()
    private let bottomLabel = UILabel()
    private let buttonsContainer = UIView()

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

    var onDismiss: (() -> Void)?

    init() {
        super.init(frame: CGRect.zero)

        topLabel.numberOfLines = 0
        bottomLabel.numberOfLines = 0
        topLabel.alpha = 0
        bottomLabel.alpha = 0

        buttonsContainer.hidden = true

        okButton.setTitle("Yes", forState: .Normal)
        okButton.addTarget(self,
                           action: #selector(OnboardingSteps.didAgreeToOnboarding),
                           forControlEvents: .TouchUpInside)

        dismissButton.setTitle("No", forState: .Normal)
        dismissButton.addTarget(self,
                           action: #selector(OnboardingSteps.didDismissOnboarding),
                           forControlEvents: .TouchUpInside)

        addSubview(topLabel)
        addSubview(bottomLabel)

        addSubview(buttonsContainer)
        buttonsContainer.addSubview(okButton)
        buttonsContainer.addSubview(dismissButton)

        setNeedsUpdateConstraints()
    }

    func transitionToStep(stepIndex: Int) {
        let firstStep = OnboardingSteps.steps[stepIndex][0].string!
        topLabel.attributedText = NSAttributedString(string: firstStep,
                                                     attributes: labelBaseAttributes)

        UIView.animateWithDuration(0.8, animations: {
            self.topLabel.alpha = 1
        })

        if OnboardingSteps.steps[stepIndex].count > 1 {
            let secondStep = OnboardingSteps.steps[stepIndex][1].string!
            bottomLabel.attributedText = NSAttributedString(string: secondStep,
                                                            attributes: labelBaseAttributes)
            UIView.animateWithDuration(0.8,
                                       delay: 0.8,
                                       options: [],
                                       animations: {
                self.bottomLabel.alpha = 1
            }, completion: nil)

            handleStepExtras(stepIndex)
        }
    }

    private func handleStepExtras(stepIndex: Int) {
        switch stepIndex {
        case 0:
            displayButtons()
        default:
            return
        }
    }

    private func displayButtons() {
        buttonsContainer.alpha = 0
        buttonsContainer.hidden = false

        UIView.animateWithDuration(0.8,
                                   delay: 1.6,
                                   options: [],
                                   animations: {
            self.buttonsContainer.alpha = 1
        }, completion: nil)
    }

    func didAgreeToOnboarding() {

    }

    func didDismissOnboarding() {
        onDismiss?()
    }

    override func updateConstraints() {
        if !hasLoadedConstraints {

            topLabel.autoPinEdgeToSuperviewEdge(.Top)
            topLabel.autoAlignAxisToSuperviewAxis(.Vertical)

            bottomLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: topLabel, withOffset: 10)
            bottomLabel.autoAlignAxisToSuperviewAxis(.Vertical)

            buttonsContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: bottomLabel, withOffset: 40)
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
