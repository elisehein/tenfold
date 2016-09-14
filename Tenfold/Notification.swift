//
//  Notification.swift
//  Tenfold
//
//  Created by Elise Hein on 23/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import PureLayout

enum NotificationType {
    case Text
    case Icon
}

class Notification: UIView {

    private static let iconSize: CGFloat = 70

    private static let margin: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 25 : 15
    }()

    private static let labelHeight: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 50 : 35
    }()

    private static let labelWidthAddition: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 50 : 30
    }()

    private let label = UILabel()
    private let iconView = UIImageView()
    private let shadowLayer = UIView()

    var iconName: String? {
        didSet {
            guard iconName != nil else { return }
            iconView.image = UIImage(named: iconName!)
        }
    }

    var text: String = "" {
        didSet {
            label.attributedText = constructAttributedString(withText: text)
            setNeedsLayout()
        }
    }

    var newlyUnrepresentedNumber: Int? {
        didSet {
            if let number = newlyUnrepresentedNumber {
                let phrases = CopyService.phrasebook(.LastNumberInstance).arrayValue
                let phrase = phrases.randomElement().string
                text = String(format: phrase!, number)
            }
        }
    }

    private var dismissalInProgress = false
    private var popupInProgress = false
    private var popupCompletion: (() -> Void)?
    private var type: NotificationType

    var anchorEdge: ALEdge = .Bottom

    init(type: NotificationType) {
        self.type = type
        super.init(frame: CGRect.zero)

        shadowLayer.backgroundColor = UIColor.clearColor()
        shadowLayer.layer.shadowColor = UIColor.blackColor().CGColor
        shadowLayer.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowLayer.layer.shadowOpacity = 0.5
        shadowLayer.layer.shadowRadius = 2
        shadowLayer.layer.masksToBounds = true
        shadowLayer.clipsToBounds = false

        addSubview(shadowLayer)

        if type == .Text {
            label.backgroundColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.92)
            label.layer.masksToBounds = true
            addSubview(label)
        } else {
            iconView.backgroundColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.8)
            iconView.contentMode = .Center
            iconView.layer.masksToBounds = true
            addSubview(iconView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if type == .Text {
            label.frame = bounds
            label.layer.cornerRadius = label.frame.size.height / 2
            shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: label.frame,
                                                        cornerRadius: label.layer.cornerRadius).CGPath
        } else {
            iconView.frame = bounds
            iconView.layer.cornerRadius = iconView.frame.size.height / 2
            shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: iconView.frame,
                                                        cornerRadius: iconView.layer.cornerRadius).CGPath
        }

        shadowLayer.frame = bounds
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

    func popup(forSeconds seconds: Double,
               inFrame parentFrame: CGRect,
               completion: (() -> Void)? = nil) {
        guard !popupInProgress else { return }

        popupInProgress = true
        popupCompletion = completion

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
                                self.triggerPendingPopupCompletion()
                        })
        })
    }

    func flash(inFrame parentFrame: CGRect) {
        alpha = 0

        frame = CGRect(x: -Notification.iconSize,
                       y: (parentFrame.height - Notification.iconSize) / 2,
                       width: Notification.iconSize,
                       height: Notification.iconSize)
        center = CGPoint(x: parentFrame.width / 2, y: parentFrame.height / 2)
        transform = CGAffineTransformMakeScale(0.001, 0.001)

        UIView.animateWithDuration(0.6,
                                   delay: 0,
                                   usingSpringWithDamping: 0.6,
                                   initialSpringVelocity: 0.3,
                                   options: [.CurveEaseIn],
                                   animations: {
            self.alpha = 1
            self.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: { _ in
            UIView.animateWithDuration(0.4, delay: 0.2, options: [], animations: {
                self.alpha = 0
            }, completion: nil)
        })
    }

    func toggle(inFrame parentFrame: CGRect,
                showing: Bool,
                animated: Bool = false,
                completion: (() -> Void)? = nil) {

        // In case we were interrupted before we reached the popup completion block before
        triggerPendingPopupCompletion()

        guard !dismissalInProgress else { return }
        guard !CGRectEqualToRect(frame, frameInside(frame: parentFrame,
            showing: showing)) else { return }


        // Ensure we begin the transition from the correct position
        frame = frameInside(frame: parentFrame, showing: !showing)

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
        let width = type == .Icon ?
            Notification.iconSize :
            label.intrinsicContentSize().width + Notification.labelWidthAddition

        let height = type == .Icon ? Notification.iconSize : Notification.labelHeight

        var y: CGFloat = 0
        var x: CGFloat = 0

        if showing {
            if anchorEdge == .Bottom {
                y = parentFrame.height - height - Notification.margin
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .Top {
                y = Notification.margin
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .Left {
                y = (parentFrame.height - height) / 2
                x = Notification.margin
            }
        } else {
            if anchorEdge == .Bottom {
                y = parentFrame.height + 10
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .Top {
                y = -10
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .Left {
                y = (parentFrame.height - height) / 2
                x = -10
            }
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func triggerPendingPopupCompletion() {
        popupInProgress = false
        popupCompletion?()
        popupCompletion = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
