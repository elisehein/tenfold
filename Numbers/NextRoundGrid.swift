//
//  NextRoundGrid.swift
//  Numbers
//
//  Created by Elise Hein on 19/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class NextRoundGrid: UIView {

    private static let numberOfRows = 7

    var itemsPerRow: Int

    var itemSize: CGSize? {
        didSet {
            if itemSize != nil {
                drawItems()
            }
        }
    }

    var proportionVisible: CGFloat? {
        didSet {
            guard proportionVisible != nil else { return }

            if proportionVisible == 1 {
                blimp()
            } else {
                adjustItemsIntensity(proportionVisible!)
            }
        }
    }

    init(cellsPerRow: Int, frame: CGRect) {
        itemsPerRow = cellsPerRow
        super.init(frame: frame)
    }

    func drawItems () {
        subviews.forEach({ $0.removeFromSuperview() })

        for row in 0..<NextRoundGrid.numberOfRows {
            for item in 0..<itemsPerRow {
                let x = CGFloat(item) * itemSize!.width
                let y = CGFloat(row) * itemSize!.height
                let cellFrame = CGRect(x: x,
                                       y: y,
                                       width: itemSize!.width,
                                       height: itemSize!.height)
                let cell = NextRoundCell(frame: cellFrame)
                addSubview(cell)
            }
        }
    }

    func heightRequired () -> CGFloat {
        return CGFloat(NextRoundGrid.numberOfRows) * itemSize!.height
    }

    private func adjustItemsIntensity (proportionVisible: CGFloat) {
        for i in 0..<subviews.count {
            if let item = subviews[i] as? NextRoundCell {
                let currentRow = i / itemsPerRow
                // Each row of items becomes less intense as we move further along
                item.intensity = proportionVisible// - (CGFloat(currentRow) * 0.2)
            }
        }
    }

    private func blimp () {
        for item in subviews {
            (item as? NextRoundCell)!.blimp()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NextRoundCell: UIView {

    private let dotLayer = CAShapeLayer()

    private static let lineWidth: CGFloat = 1
    private static let maxRadius: CGFloat = 4
    private static let minRadius: CGFloat = 0

    private var didBlimp = false

    var intensity: CGFloat? {
        didSet {
            if intensity != nil {
                let radius = (NextRoundCell.maxRadius - NextRoundCell.minRadius) * intensity!
                redrawDot(withRadius: radius)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let strokeColor = UIColor.themeColor(.OffWhiteDark).colorWithAlphaComponent(0.7).CGColor

        dotLayer.fillColor = UIColor.themeColor(.OffWhite).CGColor
        dotLayer.strokeColor = strokeColor
        dotLayer.lineWidth = NextRoundCell.lineWidth

        redrawDot(withRadius: 3)

        layer.addSublayer(dotLayer)
    }

    func redrawDot (withRadius radius: CGFloat) {
        let newPath = dotPath(withRadius: radius)

        if didBlimp {
            dotLayer.removeAllAnimations()
//            animate(1, path: newPath)
            didBlimp = false
        } else {
            dotLayer.lineWidth = 1
            dotLayer.path = newPath.CGPath
        }

    }

    func dotPath (withRadius radius: CGFloat) -> UIBezierPath {
        let arcCenter = CGPoint(x: bounds.size.width / 2.0,
                                y: bounds.size.height / 2.0)
        return UIBezierPath(arcCenter: arcCenter,
                            radius: radius,
                            startAngle: 0,
                            endAngle:CGFloat(M_PI * 2),
                            clockwise: true)
    }

    func blimp () {
        if !didBlimp {
            animate(6, path: dotPath(withRadius: 4))
            didBlimp = true
        }
    }

    func animate (lineWith: CGFloat, path: UIBezierPath) {
        dotLayer.removeAllAnimations()

        let lineAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineAnimation.toValue = 6
        lineAnimation.duration = 0.3
        lineAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        lineAnimation.fillMode = kCAFillModeBoth
        lineAnimation.removedOnCompletion = false
        dotLayer.addAnimation(lineAnimation, forKey: lineAnimation.keyPath)

        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.toValue = path
        pathAnimation.duration = 0.3
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        pathAnimation.fillMode = kCAFillModeBoth
        pathAnimation.removedOnCompletion = false
        dotLayer.addAnimation(pathAnimation, forKey: pathAnimation.keyPath)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
