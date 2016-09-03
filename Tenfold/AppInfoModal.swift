//
//  AppInfoModal.swift
//  Tenfold
//
//  Created by Elise Hein on 03/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit
import PureLayout
import StoreKit

class AppInfoModal: ModalOverlay, SKStoreProductViewControllerDelegate {

    let logo = UIImageView(image: UIImage(named: "tenfold-logo-small"))
    let appNameLabel = UILabel()
    let appVersionLabel = UILabel()
    let developerNameLabel = UILabel()
    let specialThanksLabel = UILabel()

    let feedbackButton = Button()
    let rateButton = Button()

    var hasLoadedConstraints = false

    override init() {
        super.init()

        let boldAttributes = labelAttributes(withBoldText: true)
        appNameLabel.attributedText = NSAttributedString(string: "Tenfold App",
                                                         attributes: boldAttributes)

        let attributes = labelAttributes(withBoldText: false)

        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let build = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]
        appVersionLabel.attributedText = NSAttributedString(string: "Version \(version!).\(build!)",
                                                            attributes: attributes)

        developerNameLabel.attributedText = NSAttributedString(string: "by Elise Hein",
                                                               attributes: attributes)

        let specialThanksLabelText = "Special thanks to Karl Sutt, Jesse Williams, " +
                                     "and the class of 2010 at TEC, where this game of " +
                                     "numbers proliferated."
        specialThanksLabel.numberOfLines = 0
        specialThanksLabel.attributedText = NSAttributedString(string: specialThanksLabelText,
                                                               attributes: attributes)

        ModalOverlay.configureModalButton(feedbackButton,
                                          color: UIColor.themeColor(.SecondaryAccent))
        feedbackButton.setTitle("Send feedback", forState: .Normal)
        feedbackButton.addTarget(self,
                                 action: #selector(AppInfoModal.didTapFeedback),
                                 forControlEvents: .TouchUpInside)

        ModalOverlay.configureModalButton(rateButton,
                                          color: UIColor.themeColor(.SecondaryAccent))
        rateButton.setTitle("Rate Tenfold", forState: .Normal)
        rateButton.addTarget(self,
                             action: #selector(AppInfoModal.didTapRate),
                             forControlEvents: .TouchUpInside)

        modal.addSubview(logo)
        modal.addSubview(appNameLabel)
        modal.addSubview(appVersionLabel)
        modal.addSubview(developerNameLabel)
        modal.addSubview(specialThanksLabel)
        modal.addSubview(feedbackButton)
        modal.addSubview(rateButton)
    }

    func didTapRate() {
        let ratingViewController = SKStoreProductViewController()
        ratingViewController.delegate = self
        let dict = [SKStoreProductParameterITunesItemIdentifier: "1149410716"]
        ratingViewController.loadProductWithParameters(dict, completionBlock: nil)
        presentViewController(ratingViewController, animated: true, completion: nil)
    }

    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

    func didTapFeedback() {
        print("Feedback")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {

            modal.autoPinEdgeToSuperviewEdge(.Left, withInset: 10)
            modal.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
            modal.autoCenterInSuperview()

            logo.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
            logo.autoAlignAxisToSuperviewAxis(.Vertical)
            logo.autoPinEdgeToSuperviewEdge(.Top, withInset: 50)

            appNameLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: logo, withOffset: 20)
            appVersionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: appNameLabel, withOffset: 5)
            developerNameLabel.autoPinEdge(.Top,
                                           toEdge: .Bottom,
                                           ofView: appVersionLabel,
                                           withOffset: 30)

            specialThanksLabel.autoMatchDimension(.Width,
                                                  toDimension: .Width,
                                                  ofView: modal,
                                                  withMultiplier: 0.8)
            specialThanksLabel.autoPinEdge(.Top,
                                           toEdge: .Bottom,
                                           ofView: developerNameLabel,
                                           withOffset: 30)

            feedbackButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            feedbackButton.autoPinEdge(.Top,
                                       toEdge: .Bottom,
                                       ofView: specialThanksLabel,
                                       withOffset: 50)
            feedbackButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)

            rateButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            rateButton.autoPinEdge(.Top,
                                   toEdge: .Bottom,
                                   ofView: feedbackButton,
                                   withOffset: -2)
            rateButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)
            rateButton.autoPinEdgeToSuperviewEdge(.Bottom)

            // swiftlint:disable:next line_length
            [logo, appNameLabel, appVersionLabel, developerNameLabel, specialThanksLabel, feedbackButton, rateButton].autoAlignViewsToAxis(.Vertical)
            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    private func labelAttributes(withBoldText boldText: Bool) -> [String: AnyObject] {
        let isIPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        paragraphStyle.lineSpacing = isIPad ? 7 : 4

        return [
            NSForegroundColorAttributeName: UIColor.themeColor(.OffBlack),
            NSFontAttributeName: UIFont.themeFontWithSize(isIPad ? 18 : 14,
                                                          weight: boldText ? .Bold : .Regular),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
