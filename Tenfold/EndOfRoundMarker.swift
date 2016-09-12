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

    private static let margin: CGFloat = 3.5
    private static let depth: CGFloat = 3
    private static let length: CGFloat = 8.5

    override init(layer: AnyObject) {
        super.init(layer: layer)
        needsDisplayOnBoundsChange = true
    }

    override init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }

    override func display() {
        super.display()

        let markerPath = CGPathCreateMutable()
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
        CGPathCloseSubpath(markerPath)

        path = markerPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
