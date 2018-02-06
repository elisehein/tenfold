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
    case left
    case right

    mutating func toggle() {
        self = self == .left ? .right : .left
    }
}

class SlidingStrikethroughButton: Button, CAAnimationDelegate {

    private static let gapSize: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40
    }()

    private let lineLayer = CAShapeLayer()
    var struckthroughOption: SlidingStrikethroughButtonOption = .left

    var options: [String] = [] {
        didSet {
            configure()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        lineLayer.strokeColor = UIColor.themeColor(.offBlack).cgColor
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
        animation.isRemovedOnCompletion = false
        lineLayer.add(animation, forKey: "startAnimation")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard anim == lineLayer.animation(forKey: "startAnimation") else { return }
        lineLayer.removeAllAnimations()

        struckthroughOption.toggle()
        configure()

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = fullWidthLinePath()
        animation.toValue = startingPathWhenSlidingFrom(struckthroughOption)

        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        lineLayer.add(animation, forKey: "endAnimation")
    }

    private func configure() {
        let titleString = NSMutableAttributedString()

        let gap = NSTextAttachment()
        gap.bounds = CGRect(x: 0, y: 0, width: SlidingStrikethroughButton.gapSize, height: 0)
        let gapString = NSAttributedString(attachment: gap)

        for option in options {
            let attrString = constructAttributedString(withText: option,
                                                       color: UIColor.themeColor(.offBlack))

            if options.index(of: option) == struckthroughOption.rawValue {
                attrString.addAttributes([NSAttributedStringKey.strikethroughStyle: 1],
                                         range: NSRange(location: 0, length: option.count))
            }

            titleString.append(attrString)

            if options.index(of: option)! < options.count - 1 {
                titleString.append(gapString)
            }
        }

        setAttributedTitle(titleString, for: UIControlState())
    }

    private func startingPathWhenSlidingFrom(_ option: SlidingStrikethroughButtonOption) -> CGPath {
        let textWidth = attributedTitle(for: UIControlState())?.size().width
        let textStartX = (bounds.size.width - textWidth!) / 2
        let textEndX = textStartX + textWidth!
        let point = CGPoint(x: option == .left ? textStartX : textEndX, y: linePathY())
        let path = UIBezierPath()
        path.move(to: point)
        path.addLine(to: point)
        return path.cgPath
    }

    private func fullWidthLinePath() -> CGPath {
        let textWidth = attributedTitle(for: UIControlState())?.size().width
        let textStartX = (bounds.size.width - textWidth!) / 2
        let textEndX = textStartX + textWidth!
        let path = UIBezierPath()
        path.move(to: CGPoint(x: textStartX, y: linePathY()))
        path.addLine(to: CGPoint(x: textEndX, y: linePathY()))
        return path.cgPath
    }

    private func linePathY() -> CGFloat {
        return bounds.size.height / 2 + 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
