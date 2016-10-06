//
//  SlidingStrikethroughButton.swift
//  Tenfold
//
//  Created by Elise Hein on 06/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class SlidingStrikethroughButton: Button {

    private let lineLayer = CAShapeLayer()
    var struckthroughIndex: Int = 0

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
        animation.fromValue = startingPathWhenChoosingOption(struckthroughIndex)
        animation.toValue = endPathWhenChoosingOption(struckthroughIndex)

        animation.duration = 0.3
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.fillMode = kCAFillModeBoth
        animation.removedOnCompletion = false
        lineLayer.addAnimation(animation, forKey: "startAnimation")
    }

    private func startingPathWhenChoosingOption(optionIndex: Int?) -> CGPath {
        let textWidth = attributedTitleForState(.Normal)?.size().width
        let y = bounds.size.height / 2 + 2
        let startX = (bounds.size.width - textWidth!) / 2
        let endX = startX + textWidth!
        let point = CGPoint(x: optionIndex == 0 ? startX : endX, y: y)
        let path = UIBezierPath()
        path.moveToPoint(point)
        path.addLineToPoint(point)
        return path.CGPath
    }

    private func endPathWhenChoosingOption(optionIndex: Int?) -> CGPath {
        return fullWidthLinePath()
    }

    private func fullWidthLinePath() -> CGPath {
        let textWidth = attributedTitleForState(.Normal)?.size().width
        let startX = (bounds.size.width - textWidth!) / 2
        let endX = startX + textWidth!
        let y = bounds.size.height / 2 + 2
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: startX, y: y))
        path.addLineToPoint(CGPoint(x: endX, y: y))
        return path.CGPath
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard anim == lineLayer.animationForKey("startAnimation") else { return }
        lineLayer.removeAllAnimations()

        // Naive toggle. Assumes only two options
        struckthroughIndex = struckthroughIndex == 0 ? 1 : 0
        configure()

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = fullWidthLinePath()
        animation.toValue = startingPathWhenChoosingOption(struckthroughIndex)

        animation.duration = 0.2
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        lineLayer.addAnimation(animation, forKey: "endAnimation")
    }

    private func configure() {
        let titleString = NSMutableAttributedString()

        let gap = NSTextAttachment()
        gap.bounds = CGRect(x: 0, y: 0, width: 40, height: 0)
        let gapString = NSAttributedString(attachment: gap)

        for option in options {
            let attrString = constructAttributedString(withText: option,
                                                       color: UIColor.themeColor(.OffBlack))

            if options.indexOf(option) == struckthroughIndex {
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
