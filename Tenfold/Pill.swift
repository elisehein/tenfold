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
    case text
    case icon
}

class Pill: UIView {

    static let detailFontSize: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 14 : 11

    }()

    private static let iconSize: CGFloat = 70
    private static let pulseDuration = GameGridCell.animationDuration

    static let margin: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 25 : 15
    }()

    static let labelHeight: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 50 : 38
    }()

    static let labelWidthAddition: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30
    }()

    let label = UILabel()
    let shadowLayer = UIView()
    private let iconView = UIImageView()

    var iconName: String? {
        didSet {
            guard iconName != nil else { return }
            iconView.image = UIImage(named: iconName!)
        }
    }

    var text: String = "" {
        didSet {
            label.attributedText = constructAttributedString(withText: text)
        }
    }

    var isShowing = false
    private var dismissalInProgress = false
    private var popupInProgress = false
    private var popupCompletion: (() -> Void)?
    private var type: PillType

    var anchorEdge: ALEdge = .bottom

    init(type: PillType) {
        self.type = type
        super.init(frame: CGRect.zero)

        shadowLayer.backgroundColor = UIColor.clear
        shadowLayer.layer.shadowColor = UIColor.black.cgColor
        shadowLayer.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowLayer.layer.shadowOpacity = 0.5
        shadowLayer.layer.shadowRadius = 2
        shadowLayer.layer.masksToBounds = true
        shadowLayer.clipsToBounds = false

        addSubview(shadowLayer)

        if type == .text {
            label.backgroundColor = UIColor.themeColor(.offBlack).withAlphaComponent(0.92)
            label.layer.masksToBounds = true
            addSubview(label)
        } else {
            iconView.backgroundColor = UIColor.themeColor(.offBlack).withAlphaComponent(0.8)
            iconView.contentMode = .center
            iconView.layer.masksToBounds = true
            addSubview(iconView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if type == .text {
            label.frame = bounds
            label.layer.cornerRadius = label.frame.size.height / 2
            shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: label.frame,
                                                        cornerRadius: label.layer.cornerRadius).cgPath
        } else {
            iconView.frame = bounds
            iconView.layer.cornerRadius = iconView.frame.size.height / 2
            shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: iconView.frame,
                                                        cornerRadius: iconView.layer.cornerRadius).cgPath
        }

        shadowLayer.frame = bounds
    }

    func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        return NSMutableAttributedString.themeString(.pill, text)
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

        let triggerTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: triggerTime, execute: { () -> Void in
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
        transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseIn],
                       animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 0.2, options: [], animations: {
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

        UIView.animate(withDuration: animated ? 0.6 : 0,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
            self.alpha = showing ? 1 : 0
            self.frame = self.frameInside(frame: parentFrame, showing: showing)
        }, completion: { _ in
            completion?()
        })
    }

    func dismiss(inFrame parentFrame: CGRect, completion: @escaping (() -> Void)) {
        dismissalInProgress = true

        UIView.animate(withDuration: 1,
                                   delay: 0,
                                   options: .curveEaseOut,
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
        let width = type == .icon ? Pill.iconSize : textLabelWidth()
        let height = type == .icon ? Pill.iconSize : Pill.labelHeight

        var y: CGFloat = 0
        var x: CGFloat = 0

        if showing {
            if anchorEdge == .bottom {
                y = parentFrame.height - height - Pill.margin
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .top {
                y = Pill.margin
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .left {
                y = (parentFrame.height - height) / 2
                x = Pill.margin
            }
        } else {
            if anchorEdge == .bottom {
                y = parentFrame.height + 10
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .top {
                y = -(height + 10)
                x = (parentFrame.width - width) / 2
            } else if anchorEdge == .left {
                y = (parentFrame.height - height) / 2
                x = -(width + 10)
            }
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    func textLabelWidth() -> CGFloat {
        return label.intrinsicContentSize.width + Pill.labelWidthAddition
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
