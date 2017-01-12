//
//  EndOfRoundMarker.swift
//  Tenfold
//
//  Created by Elise Hein on 12/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class EndOfRoundMarker: CAShapeLayer {

    fileprivate static let margin: CGFloat = 3.5
    fileprivate static let depth: CGFloat = 3
    fileprivate static let length: CGFloat = 8.5

    override init(layer: Any) {
        super.init(layer: layer)
        needsDisplayOnBoundsChange = true
    }

    override init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }

    override func display() {
        super.display()

        let markerPath = CGMutablePath()
        let totalWidth: CGFloat = bounds.size.width
        let totalHeight: CGFloat = bounds.size.height

        CGPathMoveToPoint(markerPath, nil,
                          totalWidth - EndOfRoundMarker.margin,
                          totalHeight - EndOfRoundMarker.margin)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - EndOfRoundMarker.margin,
                             totalHeight - EndOfRoundMarker.margin - EndOfRoundMarker.length)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - EndOfRoundMarker.margin - EndOfRoundMarker.depth,
                             totalHeight - EndOfRoundMarker.margin - EndOfRoundMarker.length)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - EndOfRoundMarker.margin - EndOfRoundMarker.depth,
                             totalHeight - EndOfRoundMarker.margin - EndOfRoundMarker.depth)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - EndOfRoundMarker.margin - EndOfRoundMarker.length,
                             totalHeight - EndOfRoundMarker.margin - EndOfRoundMarker.depth)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - EndOfRoundMarker.margin - EndOfRoundMarker.length,
                             totalHeight - EndOfRoundMarker.margin)
        markerPath.closeSubpath()

        path = markerPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
