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
            if proportionVisible != nil {
                adjustItemIntensity(proportionVisible!)
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

    private func adjustItemIntensity (proportionVisible: CGFloat) {
        for item in subviews {
            if let item = item as? NextRoundCell {
                item.intensity = proportionVisible
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NextRoundCell: UIView {

    private let dotLayer = CAShapeLayer()

    private static let maxRadius: CGFloat = 4
    private static let minRadius: CGFloat = 0

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

        dotLayer.fillColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.7).CGColor
        dotLayer.lineWidth = 0

        layer.addSublayer(dotLayer)
    }

    func redrawDot (withRadius radius: CGFloat) {
        let arcCenter = CGPoint(x: bounds.size.width / 2.0,
                                y: bounds.size.height / 2.0)
        let circlePath = UIBezierPath(arcCenter: arcCenter,
                                      radius: radius,
                                      startAngle: 0,
                                      endAngle:CGFloat(M_PI * 2),
                                      clockwise: true)

        dotLayer.path = circlePath.CGPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
