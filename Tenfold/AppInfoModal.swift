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

    fileprivate static let modalInset: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 80 : 50
    }()

    fileprivate static let paragraphSpacing: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 45 : 30
    }()

    let logo = UIImageView(image: UIImage(named: "tenfold-logo-small"))
    let appNameLabel = UILabel()
    let appVersionLabel = UILabel()
    let developerNameLabel = UILabel()
    let emailLabel = UILabel()
    let specialThanksLabel = UILabel()

    let feedbackButton = Button()
    let rateButton = Button()

    var hasLoadedConstraints = false

    init() {
        super.init(position: .center)

        let boldAttributes = labelAttributes(withBoldText: true)
        appNameLabel.attributedText = NSAttributedString(string: "Tenfold App",
                                                         attributes: boldAttributes)

        let attributes = labelAttributes(withBoldText: false)

        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        let build = Bundle.main.infoDictionary!["CFBundleVersion"]
        appVersionLabel.attributedText = NSAttributedString(string: "Version \(version!).\(build!)",
                                                            attributes: attributes)

        developerNameLabel.attributedText = NSAttributedString(string: "by Elise Hein",
                                                               attributes: attributes)

        emailLabel.attributedText = NSAttributedString(string: "hello@tenfoldapp.com",
                                                       attributes: labelAttributes(withBoldText: false))

        specialThanksLabel.numberOfLines = 0
        let specialThanksText = CopyService.phrasebook(.appInfo)["specialThanks"].string!
        specialThanksLabel.attributedText = NSAttributedString(string: specialThanksText,
                                                               attributes: attributes)

        ModalOverlay.configureModalButton(feedbackButton,
                                          color: UIColor.themeColor(.secondaryAccent))
        feedbackButton.setTitle("Help & feedback", for: UIControlState())
        feedbackButton.addTarget(self,
                                 action: #selector(AppInfoModal.didTapFeedback),
                                 for: .touchUpInside)

        ModalOverlay.configureModalButton(rateButton,
                                          color: UIColor.themeColor(.secondaryAccent))
        rateButton.setTitle("Rate Tenfold", for: UIControlState())
        rateButton.addTarget(self,
                             action: #selector(AppInfoModal.didTapRate),
                             for: .touchUpInside)

        modalBox.addSubview(logo)
        modalBox.addSubview(appNameLabel)
        modalBox.addSubview(appVersionLabel)
        modalBox.addSubview(developerNameLabel)
        modalBox.addSubview(emailLabel)
        modalBox.addSubview(specialThanksLabel)
        modalBox.addSubview(feedbackButton)
        modalBox.addSubview(rateButton)
    }

    func didTapRate() {
        UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1149410716")!)
    }

    func didTapFeedback() {
        UIApplication.shared.openURL(URL(string: "http://tenfoldapp.com/faq.html")!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        guard !hasLoadedConstraints else {
            super.updateViewConstraints()
            return
        }

        logo.autoSetDimensions(to: CGSize(width: 30, height: 30))
        logo.autoAlignAxis(toSuperviewAxis: .vertical)
        logo.autoPinEdge(toSuperviewEdge: .top, withInset: AppInfoModal.modalInset)

        appNameLabel.autoPinEdge(.top, to: .bottom, of: logo, withOffset: 20)
        appVersionLabel.autoPinEdge(.top, to: .bottom, of: appNameLabel, withOffset: 5)
        developerNameLabel.autoPinEdge(.top,
                                       to: .bottom,
                                       of: appVersionLabel,
                                       withOffset: AppInfoModal.paragraphSpacing)
        emailLabel.autoPinEdge(.top, to: .bottom, of: developerNameLabel, withOffset:5)

        specialThanksLabel.autoMatch(.width,
                                              to: .width,
                                              of: modalBox,
                                              withMultiplier: 0.8)
        let labelTopSpacing = specialThanksLabel.text == nil ? 0 : AppInfoModal.paragraphSpacing
        specialThanksLabel.autoPinEdge(.top,
                                       to: .bottom,
                                       of: emailLabel,
                                       withOffset: CGFloat(labelTopSpacing))

        feedbackButton.autoMatch(.width, to: .width, of: modalBox)
        feedbackButton.autoPinEdge(.top,
                                   to: .bottom,
                                   of: specialThanksLabel,
                                   withOffset: AppInfoModal.modalInset)
        feedbackButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)

        rateButton.autoMatch(.width, to: .width, of: modalBox)
        rateButton.autoPinEdge(.top, to: .bottom, of: feedbackButton, withOffset: -2)
        rateButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)
        rateButton.autoPinEdge(toSuperviewEdge: .bottom)

        ([logo, appNameLabel, appVersionLabel, developerNameLabel,
          emailLabel, specialThanksLabel, feedbackButton, rateButton] as NSArray).autoAlignViews(to: .vertical)

        hasLoadedConstraints = true
        super.updateViewConstraints()
    }

    fileprivate func labelAttributes(withBoldText boldText: Bool) -> [String: AnyObject] {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = isIPad ? 7 : 4

        return [
            NSForegroundColorAttributeName: UIColor.themeColor(.offBlack),
            NSFontAttributeName: UIFont.themeFontWithSize(isIPad ? 18 : 14,
                                                          weight: boldText ? .bold : .regular),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
