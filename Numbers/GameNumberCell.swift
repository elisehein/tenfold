//
//  GameNumberCell.swift
//  Numbers
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameNumberCell: UICollectionViewCell {
    private let numberLabel = UILabel()
    private let endOfRoundMarker = CAShapeLayer()
    private let backgroundColorFiller = CAShapeLayer()

    private let defaultBackgroundColor = UIColor.themeColor(.OffWhite)
    private let crossedOutBackgroundColor = UIColor.themeColor(.OffBlack)

    private let markerMargin: CGFloat = 3.5
    private let markerDepth: CGFloat = 3
    private let markerLength: CGFloat = 8.5

    private var animationCompletionBlock: (() -> Void)?

    var animationDuration: NSTimeInterval = 0

    var crossedOut: Bool = false

    var value: Int? {
        didSet {
            if let value = value {
                numberLabel.text = String(value)
            }
        }
    }

    var marksEndOfRound: Bool = false {
        didSet {
            endOfRoundMarker.hidden = !marksEndOfRound
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        numberLabel.textAlignment = .Center
        numberLabel.backgroundColor = UIColor.clearColor()

        contentView.clipsToBounds = true

        contentView.addSubview(numberLabel)
        contentView.layer.insertSublayer(backgroundColorFiller, below: numberLabel.layer)
        contentView.layer.addSublayer(endOfRoundMarker)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColorFiller.path = circlePath(withRadius: 0).CGPath
        animationDuration = 0
        marksEndOfRound = false
        crossedOut = false
        resetColors()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.frame = contentView.bounds
        numberLabel.font = UIFont.themeFontWithSize(contentView.bounds.size.height * 0.45)
        drawBackgroundFiller()
        drawEndOfRoundMarker()
    }

    func select() {
        resetColors(animated: true)
    }

    func crossOut() {
        crossedOut = true
        resetColors(animated: true)
    }

    func indicateSelectionFailure() {
        backgroundColorFiller.fillColor = UIColor.themeColor(.Accent).CGColor
        let diagonal = ceil(bounds.size.width * sqrt(2))
        backgroundColorFiller.path = circlePath(withRadius: diagonal / 2.0).CGPath
        let animation = makeAnimation(circlePath(withRadius: 0).CGPath, delay: 3)
        backgroundColorFiller.addAnimation(animation, forKey: nil)
        animationCompletionBlock = { self.resetColors() }
    }

    func resetColors(animated animated: Bool = false, delay: Double = 0) {
        backgroundColorFiller.fillColor = UIColor.clearColor().CGColor
        fillWith(backgroundColorForState(), animated: animated, delay: delay)

        if crossedOut {
            endOfRoundMarker.fillColor = defaultBackgroundColor.CGColor
            numberLabel.textColor = UIColor.clearColor()
        } else if selected {
            endOfRoundMarker.fillColor = crossedOutBackgroundColor.CGColor
            numberLabel.textColor = crossedOutBackgroundColor
        } else {
            endOfRoundMarker.fillColor = crossedOutBackgroundColor.CGColor
            numberLabel.textColor = crossedOutBackgroundColor
        }
    }

    private func fillWith(color: UIColor, animated: Bool, delay: Double = 0) {
        if animated {
            backgroundColorFiller.fillColor = color.CGColor
            let diagonal = ceil(bounds.size.width * sqrt(2))
            let animation = makeAnimation(circlePath(withRadius: diagonal / 2.0).CGPath)
            backgroundColorFiller.addAnimation(animation, forKey: nil)
        } else {
            contentView.backgroundColor = color
        }
    }

    private func backgroundColorForState() -> UIColor {
        if crossedOut {
            return crossedOutBackgroundColor
        } else if selected {
            return UIColor.themeColor(.Accent)
        } else {
            return defaultBackgroundColor
        }
    }

    private func makeAnimation(withEndPath: CGPath, delay: Double = 0) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.2
        animation.beginTime = CACurrentMediaTime() + delay
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        let diagonal = ceil(bounds.size.width * sqrt(2))
        animation.toValue = circlePath(withRadius: diagonal / 2).CGPath
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.delegate = self
        return animation
    }

    private func drawBackgroundFiller() {
        backgroundColorFiller.lineWidth = 0
        backgroundColorFiller.path = circlePath(withRadius: 0).CGPath
    }

    private func circlePath(withRadius radius: CGFloat) -> UIBezierPath {
        let arcCenter = CGPoint(x: bounds.size.width / 2.0,
                                y: bounds.size.height / 2.0)
        return UIBezierPath(arcCenter: arcCenter,
                            radius: radius,
                            startAngle: 0,
                            endAngle:CGFloat(M_PI * 2),
                            clockwise: true)
    }

    private func drawEndOfRoundMarker() {
        let markerPath = CGPathCreateMutable()
        let totalWidth: CGFloat = contentView.bounds.size.width
        let totalHeight: CGFloat = contentView.bounds.size.height

        CGPathMoveToPoint(markerPath, nil,
                          totalWidth - markerMargin,
                          totalHeight - markerMargin)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin,
                             totalHeight - markerMargin - markerLength)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin - markerDepth,
                             totalHeight - markerMargin - markerLength)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin - markerDepth,
                             totalHeight - markerMargin - markerDepth)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin - markerLength,
                             totalHeight - markerMargin - markerDepth)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin - markerLength,
                             totalHeight - markerMargin)
        CGPathCloseSubpath(markerPath)
        endOfRoundMarker.path = markerPath
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        contentView.backgroundColor = backgroundColorForState()
        animationCompletionBlock?()
        animationCompletionBlock = nil
        backgroundColorFiller.fillColor = UIColor.clearColor().CGColor
        backgroundColorFiller.path = circlePath(withRadius: 0).CGPath
        backgroundColorFiller.removeAllAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
