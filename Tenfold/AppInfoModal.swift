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
import SwiftyJSON

class AppInfoModal: ModalOverlay {

    private static let modalInset: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 80 : 50
    }()

    private static let paragraphSpacing: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 45 : 30
    }()

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

        specialThanksLabel.numberOfLines = 0
        let specialThanksText = CopyService.phrasebook(.AppInfo)["specialThanks"].string!
        specialThanksLabel.attributedText = NSAttributedString(string: specialThanksText,
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
        // swiftlint:disable:next line_length
        UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id1149410716")!)
    }

    func didTapFeedback() {
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto:hello@tenfoldapp.com")!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        guard !hasLoadedConstraints else {
            super.updateViewConstraints()
            return
        }

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            modal.autoSetDimension(.Width, toSize: 460)
        } else {
            modal.autoPinEdgeToSuperviewEdge(.Left, withInset: 10)
            modal.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
        }

        modal.autoCenterInSuperview()

        logo.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
        logo.autoAlignAxisToSuperviewAxis(.Vertical)
        logo.autoPinEdgeToSuperviewEdge(.Top, withInset: AppInfoModal.modalInset)

        appNameLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: logo, withOffset: 20)
        appVersionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: appNameLabel, withOffset: 5)
        developerNameLabel.autoPinEdge(.Top,
                                       toEdge: .Bottom,
                                       ofView: appVersionLabel,
                                       withOffset: AppInfoModal.paragraphSpacing)

        specialThanksLabel.autoMatchDimension(.Width,
                                              toDimension: .Width,
                                              ofView: modal,
                                              withMultiplier: 0.8)
        let labelTopSpacing = specialThanksLabel.text == nil ? 0 : AppInfoModal.paragraphSpacing
        specialThanksLabel.autoPinEdge(.Top,
                                       toEdge: .Bottom,
                                       ofView: developerNameLabel,
                                       withOffset: CGFloat(labelTopSpacing))

        feedbackButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
        feedbackButton.autoPinEdge(.Top,
                                   toEdge: .Bottom,
                                   ofView: specialThanksLabel,
                                   withOffset: AppInfoModal.modalInset)
        feedbackButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)

        rateButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
        rateButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: feedbackButton, withOffset: -2)
        rateButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)
        rateButton.autoPinEdgeToSuperviewEdge(.Bottom)

        // swiftlint:disable:next line_length
        [logo, appNameLabel, appVersionLabel, developerNameLabel, specialThanksLabel, feedbackButton, rateButton].autoAlignViewsToAxis(.Vertical)

        hasLoadedConstraints = true
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
