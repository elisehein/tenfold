//
//  SlidingStrikethroughButton.swift
//  Tenfold
//
//  Created by Elise Hein on 06/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum SlidingStrikethroughButtonOption: Int {
    case Left
    case Right

    mutating func toggle() {
        self = self == .Left ? .Right : .Left
    }
}

class SlidingStrikethroughButton: Button {

    private static let gapSize: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 50 : 40
    }()

    private let lineLayer = CAShapeLayer()
    var struckthroughOption: SlidingStrikethroughButtonOption = .Left

    var options: [String] = [] {
        didSet {
            configure()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        lineLayer.strokeColor = UIColor.themeColor(.OffBlack).CGColor
        lineLayer.lineWidth = 1
        layer.addSublayer(lineLayer)
    }

    func toggle() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startingPathWhenSlidingFrom(struckthroughOption)
        animation.toValue = fullWidthLinePath()

        animation.duration = 0.3
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.fillMode = kCAFillModeBoth
        animation.removedOnCompletion = false
        lineLayer.addAnimation(animation, forKey: "startAnimation")
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard anim == lineLayer.animationForKey("startAnimation") else { return }
        lineLayer.removeAllAnimations()

        struckthroughOption.toggle()
        configure()

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = fullWidthLinePath()
        animation.toValue = startingPathWhenSlidingFrom(struckthroughOption)

        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        lineLayer.addAnimation(animation, forKey: "endAnimation")
    }

    private func configure() {
        let titleString = NSMutableAttributedString()

        let gap = NSTextAttachment()
        gap.bounds = CGRect(x: 0, y: 0, width: SlidingStrikethroughButton.gapSize, height: 0)
        let gapString = NSAttributedString(attachment: gap)

        for option in options {
            let attrString = constructAttributedString(withText: option,
                                                       color: UIColor.themeColor(.OffBlack))

            if options.indexOf(option) == struckthroughOption.rawValue {
                attrString.addAttributes([NSStrikethroughStyleAttributeName: 1],
                                         range: NSRange(location: 0, length: option.characters.count))
            }

            titleString.appendAttributedString(attrString)

            if options.indexOf(option) < options.count - 1 {
                titleString.appendAttributedString(gapString)
            }
        }

        setAttributedTitle(titleString, forState: .Normal)
    }

    private func startingPathWhenSlidingFrom(option: SlidingStrikethroughButtonOption) -> CGPath {
        let textWidth = attributedTitleForState(.Normal)?.size().width
        let textStartX = (bounds.size.width - textWidth!) / 2
        let textEndX = textStartX + textWidth!
        let point = CGPoint(x: option == .Left ? textStartX : textEndX, y: linePathY())
        let path = UIBezierPath()
        path.moveToPoint(point)
        path.addLineToPoint(point)
        return path.CGPath
    }

    private func fullWidthLinePath() -> CGPath {
        let textWidth = attributedTitleForState(.Normal)?.size().width
        let textStartX = (bounds.size.width - textWidth!) / 2
        let textEndX = textStartX + textWidth!
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: textStartX, y: linePathY()))
        path.addLineToPoint(CGPoint(x: textEndX, y: linePathY()))
        return path.CGPath
    }

    private func linePathY() -> CGFloat {
        return bounds.size.height / 2 + 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
