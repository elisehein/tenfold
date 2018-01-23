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
        lineLayer.strokeColor = UIColor.themeColor(.offBlack).cgColor
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
        animation.isRemovedOnCompletion = false
        lineLayer.add(animation, forKey: "startAnimation")
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
        path.move(to: point)
        path.addLine(to: point)
        return path.cgPath
    }

    private func fullWidthLinePath() -> CGPath {
        if let textWidth = attributedTitle(for: UIControlState())?.size().width {
            let startX = (bounds.size.width - textWidth) / 2
            let endX = startX + textWidth
            let y = bounds.size.height / 2 + 2
            let path = UIBezierPath()
            path.move(to: CGPoint(x: startX, y: y))
            path.addLine(to: CGPoint(x: endX, y: y))
            return path.cgPath
        } else {
            return UIBezierPath().cgPath
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
