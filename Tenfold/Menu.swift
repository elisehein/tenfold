//
//  Menu.swift
//  Tenfold
//
//  Created by Elise Hein on 13/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import PureLayout
import UIKit

enum MenuState {
    case Default
    case Onboarding
}

class Menu: UIView {

    static let buttonHeight: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 80 : 40
    }()

    private static let logoWidth: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 180 : 120
    }()

    private static let centerPointOffset: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? -20 : 0
    }()

    private static let logoHeightFactor: CGFloat = 0.75

    private let logoContainer = UIView()
    private let logo = UIImageView()
    private let newGameButton = Button()
    private let instructionsButton = Button()
    private let optionsButton = Button()
    private let showMenuTip = Pill(type: .Text)
    let onboardingSteps = OnboardingSteps()

    private var hasLoadedConstraints = false
    private let state: MenuState
    private var shouldShowTips: Bool

    var anchorFrame: CGRect = CGRect.zero {
        didSet {
            position()
        }
    }

    var emptySpaceAvailable: ((atDefaultPosition: Bool) -> CGFloat)?
    var onTapNewGame: (() -> Void)?
    var onTapInstructions: (() -> Void)?
    var onTapOptions: (() -> Void)?

    var animationInProgress = false

    init(state: MenuState, shouldShowTips: Bool) {
        self.state = state
        self.shouldShowTips = shouldShowTips

        super.init(frame: CGRect.zero)

        if shouldShowTips {
            showMenuTip.text = "Pull down to see menu"
        }

        logo.image = UIImage(named: "tenfold-logo")
        logo.contentMode = .ScaleAspectFit

        if state == .Onboarding {
            addSubview(onboardingSteps)
        } else {
            newGameButton.hidden = true
            newGameButton.setTitle("Start over", forState: .Normal)
            newGameButton.addTarget(self,
                                    action: #selector(Menu.didTapNewGame),
                                    forControlEvents: .TouchUpInside)

            instructionsButton.hidden = true
            instructionsButton.setTitle("How to play", forState: .Normal)
            instructionsButton.addTarget(self,
                                         action: #selector(Menu.didTapInstructions),
                                         forControlEvents: .TouchUpInside)

            optionsButton.hidden = true
            optionsButton.setTitle("Options", forState: .Normal)
            optionsButton.addTarget(self,
                                  action: #selector(Menu.didTapOptions),
                                  forControlEvents: .TouchUpInside)

            addSubview(newGameButton)
            addSubview(instructionsButton)
            addSubview(optionsButton)
        }

        addSubview(logoContainer)
        logoContainer.addSubview(logo)

        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        if !hasLoadedConstraints {
            if state == .Onboarding {
                loadOnboardingStateConstraints()
            } else {
                loadDefaultStateConstraints()
            }

            logoContainer.autoPinEdgeToSuperviewEdge(.Top)
            logoContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            logoContainer.autoAlignAxisToSuperviewAxis(.Vertical)

            logo.autoCenterInSuperview()
            logo.autoSetDimension(.Width, toSize: Menu.logoWidth)
            logo.autoSetDimension(.Height, toSize: Menu.logoWidth * Menu.logoHeightFactor)

            hasLoadedConstraints = true
        }

        super.updateConstraints()
    }

    private func loadOnboardingStateConstraints() {
        logoContainer.autoPinEdge(.Bottom, toEdge: .Top, ofView: onboardingSteps)

        onboardingSteps.autoAlignAxisToSuperviewAxis(.Vertical)
        onboardingSteps.autoConstrainAttribute(.Top,
                                               toAttribute: .Horizontal,
                                               ofView: self,
                                               withOffset: Menu.centerPointOffset)
        onboardingSteps.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
        onboardingSteps.autoPinEdgeToSuperviewEdge(.Bottom)
    }

    private func loadDefaultStateConstraints() {
        logoContainer.autoPinEdge(.Bottom, toEdge: .Top, ofView: newGameButton)

        for button in [newGameButton, instructionsButton, optionsButton] {
            button.autoSetDimension(.Height, toSize: Menu.buttonHeight)
        }

        newGameButton.autoConstrainAttribute(.Top,
                                             toAttribute: .Horizontal,
                                             ofView: self,
                                             withOffset: Menu.centerPointOffset)
        instructionsButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: newGameButton)
        optionsButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: instructionsButton)

        [logo, newGameButton, instructionsButton, optionsButton].autoAlignViewsToAxis(.Vertical)
    }

    func didTapNewGame() {
        onTapNewGame!()
    }

    func didTapInstructions() {
        onTapInstructions!()
    }

    func didTapOptions() {
        onTapOptions!()
    }

    func showDefaultView() {
        for button in [newGameButton, instructionsButton, optionsButton] {
            button.alpha = 0
            button.hidden = false

            UIView.animateWithDuration(0.2, animations: {
                button.alpha = 1
            })
        }
    }

    func hideTipsIfNeeded() {
        showMenuTip.hidden = true
    }

    private func showTipsIfNeeded() {
        if shouldShowTips {
            UIApplication.sharedApplication().delegate?.window??.addSubview(showMenuTip)
            let windowFrame = showMenuTip.superview?.bounds
            showMenuTip.anchorEdge = .Top
            showMenuTip.toggle(inFrame: windowFrame!, showing: false)
            showMenuTip.popup(forSeconds: 4, inFrame: windowFrame!)
            shouldShowTips = false
        }
    }

    func hideIfNeeded(animated animated: Bool = true) {
        guard !hidden else { return }
        animationInProgress = true

        let lockedFrame = frame
        UIView.animateWithDuration(animated ? 0.25 : 0,
                                   delay: 0,
                                   options: .CurveEaseIn,
                                   animations: {
            self.frame = self.offScreenFrame(givenFrame: lockedFrame)
            self.alpha = 0
        }, completion: { _ in
            self.hidden = true
            self.animationInProgress = false
            self.showTipsIfNeeded()
        })
    }

    func showIfNeeded(atDefaultPosition atDefaultPosition: Bool) {
        guard hidden else { return }
        hidden = false
        let endPosition = visibleFrame(atDefaultPosition: atDefaultPosition)
        animatePosition(withEndPosition: endPosition)
    }

    func nudgeToDefaultPositionIfNeeded() {
        let defaultFrame = visibleFrame(atDefaultPosition: true)

        if !hidden && !CGRectEqualToRect(frame, defaultFrame) {
            animatePosition(withEndPosition: defaultFrame)
        }
    }

    func animatePosition(withEndPosition endPosition: CGRect) {
        animationInProgress = true

        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
            self.frame = endPosition
            self.alpha = 1

            // This seems to only be needed when the frame animates its height,
            // not its full position. In practice, this occurs only when we tap Start Over
            // straight after onboarding, when the menu is visible, but not in its default
            // starting position.
            self.layoutIfNeeded()
        }, completion: { _ in
            self.animationInProgress = false
        })
    }

    func position() {
        guard !animationInProgress && !hidden else { return }
        frame = visibleFrame()
    }

    private func visibleFrame(atDefaultPosition atDefaultPosition: Bool = false) -> CGRect {
        var menuFrame = anchorFrame
        let maxHeight = emptySpaceAvailable!(atDefaultPosition: true)

        if atDefaultPosition {
            menuFrame.size.height = maxHeight
        } else {
            let availableHeight = emptySpaceAvailable!(atDefaultPosition: false)
            menuFrame.size.height = min(maxHeight, availableHeight)
        }

        return menuFrame
    }

    private func offScreenFrame(givenFrame rect: CGRect) -> CGRect {
        var offScreenRect = rect
        offScreenRect.origin.y = -rect.size.height
        return offScreenRect
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitCapturingViews = [newGameButton,
                                 instructionsButton,
                                 optionsButton,
                                 onboardingSteps.buttonsContainer]

        for view in hitCapturingViews {
            let absoluteFrame = convertRect(view.frame, fromView: view.superview)
            if CGRectContainsPoint(absoluteFrame, point) {
                return super.hitTest(point, withEvent: event)
            }
        }

        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
