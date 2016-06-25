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
                item.intensity = proportionVisible - (CGFloat(currentRow) * 0.2)
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

    private let dot = UIView()
    private let innerDot = UIView()

    private static let lineWidth: CGFloat = 1
    private static let maxRadius: CGFloat = 3.5
    private static let minRadius: CGFloat = 0

    private var didBlimp = false

    var intensity: CGFloat? {
        didSet {
            if intensity != nil {
                let radius = (NextRoundCell.maxRadius - NextRoundCell.minRadius) * intensity!

                if didBlimp {
                    animate({
                        self.redrawDot(self.innerDot, withRadius: 0)
                        self.redrawDot(self.dot, withRadius: radius)
                    })
                    didBlimp = false
                } else {
                    self.redrawDot(self.innerDot, withRadius: 0)
                    redrawDot(dot, withRadius: radius)
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        dot.backgroundColor = UIColor.themeColor(.OffWhiteDark)
        innerDot.backgroundColor = UIColor.themeColor(.OffWhite)

        addSubview(dot)
        addSubview(innerDot)
    }

    func redrawDot (givenDot: UIView, withRadius radius: CGFloat) {
        givenDot.layer.cornerRadius = radius
        givenDot.frame = CGRect(x: (bounds.size.width / 2.0) - radius,
                           y: (bounds.size.height / 2.0) - radius,
                           width: 2 * radius,
                           height: 2 * radius)
    }

    func blimp () {
        if !didBlimp {
            animate({
                self.redrawDot(self.innerDot, withRadius: 2)
                self.redrawDot(self.dot, withRadius: 4)
            })
            didBlimp = true
        }
    }

    func animate (fn: () -> Void) {
        UIView.animateWithDuration(1,
                                   delay: 0,
                                   usingSpringWithDamping: 0.35,
                                   initialSpringVelocity: 0.6,
                                   options: .CurveEaseInOut,
                                   animations: {
            fn()
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
