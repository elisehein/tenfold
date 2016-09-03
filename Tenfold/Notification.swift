//
//  GameInfo.swift
//  Tenfold
//
//  Created by Elise Hein on 23/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import PureLayout

class Notification: UIView {

    private static let margin: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 25 : 15
    }()

    private static let height: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 50 : 35
    }()

    private static let newlyUnrepresentedPhrases = JSON.initFromFile("lastNumberCrossedOutPhrases")!

    private let label = UILabel()
    private let shadowLayer = UIView()

    var text: String = "" {
        didSet {
            label.attributedText = constructAttributedString(withText: text)
            setNeedsLayout()
        }
    }

    var newlyUnrepresentedNumber: Int? {
        didSet {
            if let number = newlyUnrepresentedNumber {
                let phrases = Notification.newlyUnrepresentedPhrases.arrayValue
                let phrase = phrases.randomElement().string
                text = String(format: phrase!, number)
            }
        }
    }

    private var dismissalInProgress = false
    private var flashInProgress = false
    private var flashCompletion: (() -> Void)?
    var anchorEdge: ALEdge = .Bottom

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.backgroundColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.92)
        label.layer.masksToBounds = true

        shadowLayer.backgroundColor = UIColor.clearColor()
        shadowLayer.layer.shadowColor = UIColor.blackColor().CGColor
        shadowLayer.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowLayer.layer.shadowOpacity = 0.5
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

    func flash(forSeconds seconds: Double,
               inFrame parentFrame: CGRect,
               completion: (() -> Void)? = nil) {
        guard !flashInProgress else { return }

        flashInProgress = true
        flashCompletion = completion

        toggle(inFrame: parentFrame,
               showing: true,
               animated: true)

        let triggerTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(triggerTime,
                       dispatch_get_main_queue(), { () -> Void in
            self.toggle(inFrame: parentFrame,
                        showing: false,
                        animated: true,
                        completion: {
                self.triggerPendingFlashCompletion()
            })
        })
    }

    func toggle(inFrame parentFrame: CGRect,
                showing: Bool,
                animated: Bool = false,
                completion: (() -> Void)? = nil) {

        // In case we were interrupted before we reached the flash completion block before
        triggerPendingFlashCompletion()

        guard !dismissalInProgress else { return }
        guard !CGRectEqualToRect(frame, frameInside(frame: parentFrame,
                                                    showing: showing)) else { return }

        UIView.animateWithDuration(animated ? 0.6 : 0,
                                   delay: 0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0.3,
                                   options: [.CurveEaseIn, .BeginFromCurrentState],
                                   animations: {
            self.alpha = showing ? 1 : 0
            self.frame = self.frameInside(frame: parentFrame, showing: showing)
        }, completion: { _ in
            completion?()
        })
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

        var y: CGFloat = 0

        if showing {
            y = anchorEdge == .Bottom ?
                parentHeight - notificationFrame.size.height - Notification.margin :
                Notification.margin
        } else {
            y = anchorEdge == .Bottom ? parentHeight + 10 : -10
        }

        notificationFrame.origin.y = y
        return notificationFrame
    }

    private func triggerPendingFlashCompletion() {
        flashInProgress = false
        flashCompletion?()
        flashCompletion = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
