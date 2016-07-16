//
//  UIScrollView.swift
//  Numbers
//
//  Created by Elise Hein on 16/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func pullUpInProgress() -> Bool {
        let offset = contentOffset.y
        return offset > maxOffsetBeforeBounce() && contentSize.height > 0
    }

    func pullUpPercentage(ofThreshold threshold: CGFloat) -> CGFloat {
        return distancePulledUp() / threshold
    }

    func pullUpDistanceExceeds(threshold: CGFloat) -> Bool {
        return contentOffset.y > maxOffsetBeforeBounce() + threshold
    }

    func bottomEdgeY() -> CGFloat {
        return frame.size.height - distancePulledUp()
    }

    func distancePulledUp() -> CGFloat {
        return contentOffset.y - maxOffsetBeforeBounce()
    }

    func pullDownInProgress() -> Bool {
        return distancePulledDown() > 0
    }

    func pullDownDistanceExceeds(threshold: CGFloat) -> Bool {
        return distancePulledDown() > threshold
    }

    func distancePulledDown() -> CGFloat {
        return -(contentOffset.y + contentInset.top)
    }

    private func maxOffsetBeforeBounce() -> CGFloat {
        return contentSize.height - bounds.size.height
    }
}
