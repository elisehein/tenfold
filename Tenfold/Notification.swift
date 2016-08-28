//
//  GameInfo.swift
//  Tenfold
//
//  Created by Elise Hein on 23/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Notification: UIView {

    static let bottomMargin: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 25 : 15
    }()

    static let height: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 50 : 35
    }()

    private let label = UILabel()
    private let shadowLayer = UIView()

    var text: String = "" {
        didSet {
            label.attributedText = constructAttributedString(withText: text)
        }
    }

    private var dismissalInProgress = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.backgroundColor = UIColor.themeColor(.OffBlack)
        label.layer.masksToBounds = true

        shadowLayer.backgroundColor = UIColor.clearColor()
        shadowLayer.layer.shadowColor = UIColor.blackColor().CGColor
        shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer.layer.shadowOpacity = 0.2
        shadowLayer.layer.shadowRadius = 2
        shadowLayer.layer.masksToBounds = true
        shadowLayer.clipsToBounds = false

        addSubview(shadowLayer)
        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var widthAddition: CGFloat = 30

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            widthAddition = 50
        }

        var labelFrame = bounds
        labelFrame.size.width = label.intrinsicContentSize().width + widthAddition
        labelFrame.origin.x += (bounds.size.width - labelFrame.size.width) / 2
        label.frame = labelFrame
        label.layer.cornerRadius = label.frame.size.height / 2

        shadowLayer.frame = bounds
        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: labelFrame,
                                                    cornerRadius: label.layer.cornerRadius).CGPath
    }

    private func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center

        let textColor = UIColor.themeColor(.OffWhite)
        var font = UIFont.themeFontWithSize(13)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = font.fontWithSize(16)
        }

        let attrString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: attrString.length)

        attrString.addAttribute(NSKernAttributeName, value: 1.2, range: fullRange)
        attrString.addAttribute(NSFontAttributeName, value: font, range: fullRange)
        attrString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: fullRange)

        attrString.addAttribute(NSParagraphStyleAttributeName,
                                value: paragraphStyle,
                                range: fullRange)

        if let barIndex = text.indexOfCharacter("|") {
            attrString.addAttribute(NSForegroundColorAttributeName,
                                    value: textColor.colorWithAlphaComponent(0.4),
                                    range: NSRange(location: barIndex, length: 1))
        }

        return attrString
    }

    func toggle(inFrame parentFrame: CGRect, showing: Bool = false, animated: Bool = false) {
        guard !dismissalInProgress else { return }

        UIView.animateWithDuration(animated ? 0.6 : 0,
                                   delay: 0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0.3,
                                   options: .CurveEaseIn,
                                   animations: {
            self.alpha = showing ? 1 : 0
            self.frame = self.frameInside(frame: parentFrame, showing: showing)
        }, completion: nil)
    }

    func dismiss(inFrame parentFrame: CGRect, completion: (() -> Void)) {
        dismissalInProgress = true

        UIView.animateWithDuration(1.0,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
            self.alpha = 0
            var dismissedFrame = self.frame
            dismissedFrame.origin.y -= 100
            self.frame = dismissedFrame
        }, completion: { _ in
            self.dismissalInProgress = false
            self.toggle(inFrame: parentFrame, showing: false)
            completion()
        })
    }

    private func frameInside(frame parentFrame: CGRect, showing: Bool) -> CGRect {
        let parentHeight = parentFrame.size.height
        var notificationFrame = parentFrame
        notificationFrame.size.height = Notification.height

        if showing {
            let y = parentHeight - notificationFrame.size.height - Notification.bottomMargin
            notificationFrame.origin.y += y
        } else {
            notificationFrame.origin.y += parentHeight + 10
        }

        return notificationFrame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
