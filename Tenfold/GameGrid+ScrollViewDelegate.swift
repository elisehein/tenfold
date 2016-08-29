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
            positionGridForGameplay()
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

        onScroll?()
    }
}
