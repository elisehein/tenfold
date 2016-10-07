//
//  BooleanStrikethroughButton.swift
//  Tenfold
//
//  Created by Elise Hein on 06/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class BooleanStrikethroughButton: Button {

    private let lineLayer = CAShapeLayer()

    var struckthrough: Bool = false

    init() {
        super.init(frame: CGRect.zero)
        lineLayer.strokeColor = UIColor.themeColor(.OffBlack).CGColor
        lineLayer.lineWidth = 1
        layer.addSublayer(lineLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.path = endPath()
    }

    func toggle() {
        struckthrough = !struckthrough
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startingPath()
        animation.toValue = endPath()
        animation.duration = 0.2

        if struckthrough {
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        } else {
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        }

        animation.fillMode = kCAFillModeBoth
        animation.removedOnCompletion = false
        lineLayer.addAnimation(animation, forKey: "startAnimation")
    }

    private func startingPath() -> CGPath {
        if struckthrough {
            return midPointPath()
        } else {
            return fullWidthLinePath()
        }
    }

    private func endPath() -> CGPath {
        if struckthrough {
            return fullWidthLinePath()
        } else {
            return midPointPath()
        }
    }

    private func midPointPath() -> CGPath {
        let y = bounds.size.height / 2 + 2
        let path = UIBezierPath()
        let point = CGPoint(x: bounds.size.width / 2, y: y)
        path.moveToPoint(point)
        path.addLineToPoint(point)
        return path.CGPath
    }

    private func fullWidthLinePath() -> CGPath {
        if let textWidth = attributedTitleForState(.Normal)?.size().width {
            let startX = (bounds.size.width - textWidth) / 2
            let endX = startX + textWidth
            let y = bounds.size.height / 2 + 2
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: startX, y: y))
            path.addLineToPoint(CGPoint(x: endX, y: y))
            return path.CGPath
        } else {
            return UIBezierPath().CGPath
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
