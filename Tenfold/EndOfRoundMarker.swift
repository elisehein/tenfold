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

        markerPath.move(to: CGPoint(x: totalWidth - EndOfRoundMarker.margin,
                                    y: totalHeight - EndOfRoundMarker.margin))
        markerPath.addLine(to: CGPoint(x: totalWidth - EndOfRoundMarker.margin,
                                       y: totalHeight - EndOfRoundMarker.margin - EndOfRoundMarker.length))
        markerPath.addLine(to: CGPoint(x: totalWidth - EndOfRoundMarker.margin - EndOfRoundMarker.depth,
                                       y: totalHeight - EndOfRoundMarker.margin - EndOfRoundMarker.length))
        markerPath.addLine(to: CGPoint(x: totalWidth - EndOfRoundMarker.margin - EndOfRoundMarker.depth,
                                       y: totalHeight - EndOfRoundMarker.margin - EndOfRoundMarker.depth))
        markerPath.addLine(to: CGPoint(x: totalWidth - EndOfRoundMarker.margin - EndOfRoundMarker.length,
                                       y: totalHeight - EndOfRoundMarker.margin - EndOfRoundMarker.depth))
        markerPath.addLine(to: CGPoint(x: totalWidth - EndOfRoundMarker.margin - EndOfRoundMarker.length,
                                       y: totalHeight - EndOfRoundMarker.margin))
        markerPath.closeSubpath()

        path = markerPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
