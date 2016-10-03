//
//  Pill.swift
//  Tenfold
//
//  Created by Elise Hein on 23/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import PureLayout

enum PillType {
    case Text
    case Icon
}

class Pill: UIView {

    private static let iconSize: CGFloat = 70
    private static let pulseDuration = GameGridCell.animationDuration

    static let margin: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 25 : 15
    }()

    static let labelHeight: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 50 : 38
    }()

    static let labelWidthAddition: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 50 : 30
    }()

    let label = UILabel()
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

            // This is our substitute for setNeedsLayout() for when the text changes the size
            // of the label. Because in our case the entire view bounds is dependent on the text
            // size, we need to reset the frame (and we shouldn't do that in layoutSubviews())
            guard isShowing else { return }
            if let superview = superview {
                frame = frameInside(frame: superview.bounds, showing: isShowing)
            }
        }
    }

    private var isShowing = false
    private var dismissalInProgress = false
    private var popupInProgress = false
    private var popupCompletion: (() -> Void)?
    private var type: PillType

    var anchorEdge: ALEdge = .Bottom

    init(type: PillType) {
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

    func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let attrString = NSAttributedString.styled(as: .Pill, usingText: text)

        let grayedOutSubstrings = ["|", "to go"]

        for substring in grayedOutSubstrings {
            if let index = text.indexOf(substring) {
                attrString.addAttribute(NSForegroundColorAttributeName,
                                        value: UIColor.whiteColor().colorWithAlphaComponent(0.55),
                                        range: NSRange(location: index, length: substring.characters.count))
            }
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

        frame = CGRect(x: -Pill.iconSize,
                       y: (parentFrame.height - Pill.iconSize) / 2,
                       width: Pill.iconSize,
                       height: Pill.iconSize)
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
        guard isShowing != showing else { return }

        // We need to toggle this flag straight away (not during completion) so that it automatically
        // takes care of cases where the toggling is still in progress
        self.isShowing = showing

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

    func pulse() {
        guard isShowing else { return }

        UIView.animateWithDuration(Pill.pulseDuration,
                                   delay: 0,
                                   options: [.CurveEaseOut],
                                   animations: {
            self.transform = CGAffineTransformScale(self.transform, 1.15, 1.15)
        }, completion: { _ in
            UIView.animateWithDuration(0.15, delay: 0, options: [.CurveEaseIn], animations: {
                self.transform = CGAffineTransformIdentity
            }, completion: nil)
        })
    }

    private func frameInside(frame parentFrame: CGRect, showing: Bool) -> CGRect {
        let width = type == .Icon ? Pill.iconSize : textLabelWidth()

        let height = type == .Icon ? Pill.iconSize : Pill.labelHeight

        var y: CGFloat = 0
        var x: CGFloat = 0

        if showing {
            if anchorEdge == .Bottom {
                y = parentFrame.height - height - Pill.margin
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .Top {
                y = Pill.margin
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .Left {
                y = (parentFrame.height - height) / 2
                x = Pill.margin
            }
        } else {
            if anchorEdge == .Bottom {
                y = parentFrame.height + 10
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .Top {
                y = -(height + 10)
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .Left {
                y = (parentFrame.height - height) / 2
                x = -(width + 10)
            }
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    func textLabelWidth() -> CGFloat {
        return label.intrinsicContentSize().width + Pill.labelWidthAddition
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
