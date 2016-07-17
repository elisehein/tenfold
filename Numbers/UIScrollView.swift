//
//  UIScrollView.swift
//  Numbers
//
//  Created by Elise Hein on 16/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//


// FOR REFERENCE
//
// contentOffset = CGPoint(x: 0.0, y: 42.0)
//
//    ############
//    #    42    #
//  __#__________#__  <------ content view's y = 42
// |  #          #  |
// |  #          #  |
// |  #          #  |
// |  #          #  |
// |  #          #  |
//  --#----------#--
//    #          #
//    ############
//
// contentOffset = CGPoint(x: 0.0, y: -66.0)
//  ________________  <------ content view's y = -66
// |                |
// |      -66       |
// |  ############  |
// |  #          #  |
// |  #          #  |
//  --# ---------#--
//    #          #
//    #          #
//    #          #
//    ############

import Foundation
import UIKit

extension UIScrollView {
    func bottomEdgeY() -> CGFloat {
        return frame.size.height - distancePulledUp()
    }

    func pullUpInProgress() -> Bool {
        return pullUpDistanceExceeds(0)
    }

    func pullUpDistanceExceeds(threshold: CGFloat) -> Bool {
        return distancePulledUp() > threshold
    }

    func distancePulledUp() -> CGFloat {
        return max(0, contentDistanceFromBottomEdge())
    }

    func pullDownInProgress() -> Bool {
        return pullDownDistanceExceeds(0)
    }

    func pullDownDistanceExceeds(threshold: CGFloat) -> Bool {
        return distancePulledDown() > threshold
    }

    // We are only pulling down if the distance from the
    // top edge is currently negative
    func distancePulledDown() -> CGFloat {
        // If the distance is positive, pull down is not currently in progress,
        // hence the pull down distance should be 0
        return -(min(0, contentDistanceFromTopEdge()))
    }

    private func contentDistanceFromTopEdge() -> CGFloat {
        return contentOffset.y + contentInset.top
    }

    //
    //                    |     ############     |
    //                    |     #          #     | contentDistanceFromTopEdge()
    //                    |   __#__________#__   |
    // totalContentHeight |  |  #          #  |      |
    //                    |  |  #          #  |      |
    //                    |  |  #          #  |      |
    //                    |  |  #          #  |      | totalAvailableHeight
    //                    |  |  ############  |      |
    //                       |       | x      |      |
    //                        ----------------
    //
    private func contentDistanceFromBottomEdge() -> CGFloat {
        let totalContentHeight = contentSize.height + contentInset.top
        let totalAvailableHeight = frame.size.height
        return totalAvailableHeight - (totalContentHeight - contentDistanceFromTopEdge())
    }
}
