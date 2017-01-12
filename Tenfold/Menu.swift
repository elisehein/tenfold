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
    case `default`
    case onboarding
}

class Menu: UIView {

    static let buttonHeight: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40
    }()

    fileprivate static let logoWidth: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 180 : 120
    }()

    fileprivate static let centerPointOffset: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? -20 : 0
    }()

    fileprivate static let logoHeightFactor: CGFloat = 0.75

    fileprivate let logoContainer = UIView()
    fileprivate let logo = UIImageView()
    fileprivate let newGameButton = Button()
    fileprivate let instructionsButton = Button()
    fileprivate let optionsButton = Button()
    fileprivate let showMenuTip = Pill(type: .text)
    let onboardingSteps = OnboardingSteps()

    fileprivate var hasLoadedConstraints = false
    fileprivate let state: MenuState
    fileprivate var firstLaunch: Bool

    fileprivate var newFeatureLabel = UILabel()

    var anchorFrame: CGRect = CGRect.zero {
        didSet {
            position()
        }
    }

    var emptySpaceAvailable: ((_ atDefaultPosition: Bool) -> CGFloat)?
    var onTapNewGame: (() -> Void)?
    var onTapInstructions: (() -> Void)?
    var onTapOptions: (() -> Void)?

    var animationInProgress = false

    init(state: MenuState, firstLaunch: Bool) {
        self.state = state
        self.firstLaunch = firstLaunch

        super.init(frame: CGRect.zero)

        if firstLaunch {
            showMenuTip.text = "Pull down to see menu"
        }

        logo.image = UIImage(named: "tenfold-logo")
        logo.contentMode = .scaleAspectFit

        if state == .onboarding {
            addSubview(onboardingSteps)
        } else {
            configureNewFeatureLabel()

            newGameButton.isHidden = true
            newGameButton.setTitle("Start over", for: UIControlState())
            newGameButton.addTarget(self,
                                    action: #selector(Menu.didTapNewGame),
                                    for: .touchUpInside)

            instructionsButton.isHidden = true
            instructionsButton.setTitle("How to play", for: UIControlState())
            instructionsButton.addTarget(self,
                                         action: #selector(Menu.didTapInstructions),
                                         for: .touchUpInside)

            optionsButton.isHidden = true
            optionsButton.setTitle("Options", for: UIControlState())
            optionsButton.addTarget(self,
                                  action: #selector(Menu.didTapOptions),
                                  for: .touchUpInside)

            addSubview(newGameButton)
            addSubview(instructionsButton)
            addSubview(optionsButton)
            addSubview(newFeatureLabel)
        }

        addSubview(logoContainer)
        logoContainer.addSubview(logo)

        setNeedsUpdateConstraints()
    }

    func configureNewFeatureLabel() {
        guard !StorageService.hasSeenFeatureAnnouncement(.Options) && !firstLaunch else {
            StorageService.markFeatureAnnouncementSeen(.Options)
            return
        }

        var attrs = NSMutableAttributedString.attributes(forTextStyle: .pill)
        attrs[NSForegroundColorAttributeName] = UIColor.themeColor(.tan)
        attrs[NSFontAttributeName] = UIFont.themeFontWithSize(12)
        newFeatureLabel.attributedText = NSAttributedString(string: "👈🏻 New!", attributes: attrs)

        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.newFeatureLabel.transform = CGAffineTransform.identity.translatedBy(x: 10, y: 0)
        }, completion: nil)
    }

    override func updateConstraints() {
        if !hasLoadedConstraints {
            if state == .onboarding {
                loadOnboardingStateConstraints()
            } else {
                loadDefaultStateConstraints()
            }

            logoContainer.autoPinEdge(toSuperviewEdge: .top)
            logoContainer.autoMatch(.width, to: .width, of: self)
            logoContainer.autoAlignAxis(toSuperviewAxis: .vertical)

            logo.autoCenterInSuperview()
            logo.autoSetDimension(.width, toSize: Menu.logoWidth)
            logo.autoSetDimension(.height, toSize: Menu.logoWidth * Menu.logoHeightFactor)

            hasLoadedConstraints = true
        }

        super.updateConstraints()
    }

    fileprivate func loadOnboardingStateConstraints() {
        logoContainer.autoPinEdge(.bottom, to: .top, of: onboardingSteps)

        onboardingSteps.autoAlignAxis(toSuperviewAxis: .vertical)
        onboardingSteps.autoConstrainAttribute(.top,
                                               to: .horizontal,
                                               of: self,
                                               withOffset: Menu.centerPointOffset)
        onboardingSteps.autoMatch(.width, to: .width, of: self)
        onboardingSteps.autoPinEdge(toSuperviewEdge: .bottom)
    }

    fileprivate func loadDefaultStateConstraints() {
        logoContainer.autoPinEdge(.bottom, to: .top, of: newGameButton)

        for button in [newGameButton, instructionsButton, optionsButton] {
            button.autoSetDimension(.height, toSize: Menu.buttonHeight)
        }

        newGameButton.autoConstrainAttribute(.top,
                                             to: .horizontal,
                                             of: self,
                                             withOffset: Menu.centerPointOffset)
        instructionsButton.autoPinEdge(.top, to: .bottom, of: newGameButton)
        optionsButton.autoPinEdge(.top, to: .bottom, of: instructionsButton)

        ([logo, newGameButton, instructionsButton, optionsButton] as NSArray).autoAlignViews(to: .vertical)

        let newFeatureOffset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 90 : 70
        newFeatureLabel.autoAlignAxis(.horizontal, toSameAxisOf: optionsButton)
        newFeatureLabel.autoAlignAxis(.vertical, toSameAxisOf: optionsButton, withOffset: newFeatureOffset)
    }

    func didTapNewGame() {
        onTapNewGame!()
    }

    func didTapInstructions() {
        onTapInstructions!()
    }

    func didTapOptions() {
        StorageService.markFeatureAnnouncementSeen(.Options)
        newFeatureLabel.isHidden = true
        onTapOptions!()
    }

    func showDefaultView() {
        for button in [newGameButton, instructionsButton, optionsButton] {
            button.alpha = 0
            button.isHidden = false

            UIView.animate(withDuration: 0.2, animations: {
                button.alpha = 1
            })
        }
    }

    func hideTipsIfNeeded() {
        showMenuTip.isHidden = true
    }

    fileprivate func showTipsIfNeeded() {
        if firstLaunch {
            UIApplication.shared.delegate?.window??.addSubview(showMenuTip)
            let windowFrame = showMenuTip.superview?.bounds
            showMenuTip.anchorEdge = .top
            showMenuTip.toggle(inFrame: windowFrame!, showing: false)
            showMenuTip.popup(forSeconds: 4, inFrame: windowFrame!)
            firstLaunch = false
        }
    }

    func hideIfNeeded(animated: Bool = true) {
        guard !isHidden else { return }
        animationInProgress = true

        let lockedFrame = frame
        UIView.animate(withDuration: animated ? 0.25 : 0,
                                   delay: 0,
                                   options: .curveEaseIn,
                                   animations: {
            self.frame = self.offScreenFrame(givenFrame: lockedFrame)
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            self.animationInProgress = false
            self.showTipsIfNeeded()
        })
    }

    func showIfNeeded(atDefaultPosition: Bool) {
        guard isHidden else { return }
        isHidden = false
        let endPosition = visibleFrame(atDefaultPosition: atDefaultPosition)
        animatePosition(withEndPosition: endPosition)
    }

    func nudgeToDefaultPositionIfNeeded() {
        let defaultFrame = visibleFrame(atDefaultPosition: true)

        if !isHidden && !frame.equalTo(defaultFrame) {
            animatePosition(withEndPosition: defaultFrame)
        }
    }

    func animatePosition(withEndPosition endPosition: CGRect) {
        animationInProgress = true

        UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   options: .curveEaseOut,
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
        guard !animationInProgress && !isHidden else { return }
        frame = visibleFrame()
    }

    fileprivate func visibleFrame(atDefaultPosition: Bool = false) -> CGRect {
        var menuFrame = anchorFrame
        let maxHeight = emptySpaceAvailable!(true)

        if atDefaultPosition {
            menuFrame.size.height = maxHeight
        } else {
            let availableHeight = emptySpaceAvailable!(false)
            menuFrame.size.height = min(maxHeight, availableHeight)
        }

        return menuFrame
    }

    fileprivate func offScreenFrame(givenFrame rect: CGRect) -> CGRect {
        var offScreenRect = rect
        offScreenRect.origin.y = -rect.size.height
        return offScreenRect
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitCapturingViews = [newGameButton,
                                 instructionsButton,
                                 optionsButton,
                                 onboardingSteps.buttonsContainer]

        for view in hitCapturingViews {
            let absoluteFrame = convert(view.frame, from: view.superview)
            if absoluteFrame.contains(point) {
                return super.hitTest(point, with: event)
            }
        }

        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
