//
//  GameGrid+ScrollViewDelegate.swift
//  Tenfold
//
//  Created by Elise Hein on 29/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

extension GameGrid: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        toggleBounce(true)
        currentScrollCycleHandled = false
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if pullDownDistanceExceeds(snapToStartingPositionThreshold!) {
            adjustTopInset(enforceStartingPosition: true)
            decelerationRate = UIScrollViewDecelerationRateFast
            targetContentOffset.memory.y = -contentInset.top
            snappingInProgress = true
            onWillSnapToStartingPosition?()
            currentScrollCycleHandled = true
        }
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        bouncingInProgress = pullUpInProgress() || pullDownInProgress()

        guard !currentScrollCycleHandled else { return }

        if pullUpDistanceExceeds(pullUpThreshold!) {
            onPullUpThresholdExceeded?()
            return
        }

        guard prematurePullUpInProgress() else { return }

        if prematurePullUpDistanceExceeds(snapToGameplayPositionThreshold!) {
            ensureGridPositionedForGameplay()
            return
        }

        bounceBack()
    }

    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if !bouncingInProgress {
            toggleBounce(false)
        }

        if !currentScrollCycleHandled && prematurePullUpInProgress() {
            bounceBack()
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        snappingInProgress = false
        toggleBounce(false)
        decelerationRate = UIScrollViewDecelerationRateNormal
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if prematurePullUpInProgress() {
            interjectBounce(scrollView)
        }

        if !snappingInProgress &&
           snapToStartingPositionThreshold != nil &&
           snapToGameplayPositionThreshold != nil {
            if pullDownInProgress() {
                let pullDownFraction = distancePulledDown() / snapToStartingPositionThreshold!
                onPullingDown?(withFraction: min(1, pullDownFraction))
            } else if pullUpFromStartingPositionInProgress() {
                let distance = pullUpDistanceFromStartingPosition()
                let pullUpFraction = distance / snapToGameplayPositionThreshold!
                onPullingUpFromStartingPosition?(withFraction: min(1, pullUpFraction))
            }
        }

        // The only reason we are guarding here is because somehow the scroll view reports a pull up
        // in progress in response to us tweaking the offsets and insets during row insertion
        // (see GameGrid.swift), which in turn causes the next round grid to show up during row insertion.
        // Tried for some time to make pullUpInProgress() more solid, but it did my
        // head in, so this is the easy way out.
        guard rowInsertionInProgressWithIndeces == nil else { return }
        onScroll?()
    }
}

// MARK: ScrollViewDelegate helpers

private extension GameGrid {

    func interjectBounce (scrollView: UIScrollView) {
        let currentOffset = round(contentOffset.y + contentInset.top)
        guard currentOffset > 0 else { return }

        if currentOffset >= prevPrematureBounceOffset {
            totalPrematureBounceDistance += currentOffset - prevPrematureBounceOffset
            prevPrematureBounceOffset = round(GameGrid.scaleFactor
                                              * totalPrematureBounceDistance
                                              * GameGrid.prematureBounceReductionFactor)
                                        / GameGrid.scaleFactor
            let y = prevPrematureBounceOffset - contentInset.top
            contentOffset.y = y
        } else {
            totalPrematureBounceDistance = currentOffset / GameGrid.prematureBounceReductionFactor
            prevPrematureBounceOffset = currentOffset
        }
    }

    func bounceBack() {
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
    }

    func pullUpFromStartingPositionInProgress() -> Bool {
        return gridAtStartingPosition && (pullUpInProgress() || prematurePullUpInProgress())
    }

    func pullUpDistanceFromStartingPosition() -> CGFloat {
        return prematurePullUpInProgress() ? contentDistanceFromTopEdge() : distancePulledUp()
    }

    func prematurePullUpDistanceExceeds(threshold: CGFloat) -> Bool {
        return prematurePullUpInProgress() && contentDistanceFromTopEdge() > threshold
    }

    // This refers to whether we disallow scrolling beyond what is visible on the screen,
    // and show a bounce effect instead. This essentially allows a bounce effect to happen
    // even though we haven't reached the bottom of the content yet.
    // http://stackoverflow.com/questions/20437657/increasing-uiscrollview-rubber-banding-resistance
    func prematurePullUpInProgress() -> Bool {
        // We only want to create a simulated bounce if we would see extra content underneath
        // the "fold". If the current content size isn't big enough to show anything
        // extra, we would get a native bounce anyway.
        return !pullDownInProgress() &&
               gridAtStartingPosition &&
               contentSize.height > (frame.size.height - contentInset.top)
    }
}
