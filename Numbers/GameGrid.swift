//
//  GameGrid.swift
//  Numbers
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameGrid: Grid {

    private static let cellAnimationDuration = 0.15
    private let reuseIdentifier = "GameNumberCell"

    private var game: Game

    private var bouncingInProgress = false

    var onScroll: (() -> Void)?
    var onPullDownThresholdExceeded: (() -> Void)?
    var onPullUpThresholdExceeded: (() -> Void)?
    var onPrematurePullUpThresholdExceeded: (() -> Void)?
    var onPairingAttempt: ((itemIndex: Int, otherItemIndex: Int) -> Void)?

    // This refers to whether we disallow scrolling beyond what is visible on the screen,
    // and show a bounce effect instead. This essentially allows a bounce effect to happen
    // even though we haven't reached the bottom of the content yet.
    // http://stackoverflow.com/questions/20437657/increasing-uiscrollview-rubber-banding-resistance
    var prematureBottomBounceEnabled = true

    private static let scaleFactor = UIScreen.mainScreen().scale
    private static let prematureBounceReductionFactor: CGFloat = 0.2

    private var prevPrematureBounceOffset: CGFloat = 0
    private var totalPrematureBounceDistance: CGFloat = 0

    var pullUpThreshold: CGFloat?
    var pullDownThreshold: CGFloat?
    var prematurePullUpThreshold: CGFloat?

    init(game: Game) {
        self.game = game

        super.init()

        registerClass(GameNumberCell.self,
                      forCellWithReuseIdentifier: self.reuseIdentifier)
        allowsMultipleSelection = true
        backgroundColor = UIColor.clearColor()
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
    }

    func restart(withGame newGame: Game, completion: (() -> Void)?) {
        let originalFrame = frame

        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseIn, animations: {
            self.alpha = 0
            var offScreenFrame = self.frame
            offScreenFrame.origin.y += self.initialGameHeight() * 0.3
            self.frame = offScreenFrame
        }, completion: { _ in
            self.game = newGame
            self.reloadData()
            self.frame = originalFrame
            self.adjustTopInset()

            UIView.animateWithDuration(0.15, delay: 0.2, options: .CurveEaseIn, animations: {
                self.alpha = 1
            }, completion: { _ in
                completion?()
            })
        })
    }

    private func adjustTopInset(enforceStartingPosition enforceStartingPosition: Bool = false) {
        contentInset.top = topInset(atStartingPosition: enforceStartingPosition)
        prematureBottomBounceEnabled = enforceStartingPosition
    }

    func loadNextRound(atIndeces indeces: Array<Int>, completion: ((Bool) -> Void)?) {
        var indexPaths: Array<NSIndexPath> = []

        for index in indeces {
           indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
        }

        insertItemsAtIndexPaths(indexPaths)
        performBatchUpdates(nil, completion: { finished in
            self.adjustTopInset()
            completion?(finished)
        })
    }

    func crossOutPair(index: Int, otherIndex: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        let otherIndexPath = NSIndexPath(forItem: otherIndex, inSection: 0)
        let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell
        let otherCell = cellForItemAtIndexPath(otherIndexPath) as? GameNumberCell

        guard cell != nil && otherCell != nil else { return }

        cell!.isCrossedOut = true
        otherCell!.isCrossedOut = true

        deselectItemAtIndexPath(indexPath, animated: false)
        deselectItemAtIndexPath(otherIndexPath, animated: false)
    }

    func removeNumbers(atIndexPaths indexPaths: Array<NSIndexPath>) {
        deleteItemsAtIndexPaths(indexPaths)
        adjustTopInset()
    }

    func dismissSelection() {
        let selectedIndexPaths = indexPathsForSelectedItems()

        for indexPath in selectedIndexPaths! {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
                cell.shouldDeselectWithFailure = true
                deselectItemAtIndexPath(indexPath, animated: true)
            }
        }
    }

    private func prematurePullUpDistanceExceeds(threshold: CGFloat) -> Bool {
        // NOTE there is a bug here which causes contentDistanceFromTopEdge()
        // to evaluate to zero, even though it is not zero. Forcing an evaluation
        // of the current content insets & offsets using shouldBouncePrematurely()
        // makes the later evaluation succeed, too (good thing we should be doing
        // that check anyway)
        return shouldBouncePrematurely() &&
               contentDistanceFromTopEdge() > threshold
    }

    private func toggleBounce(shouldBounce: Bool) {
        // We should *never* disable bounce if there is a top contentInset
        // otherwise we can't pull up from the first rounds where the grid isn't full screen yet
        bounces = contentInset.top > 0 || shouldBounce
    }

    func initialisePositionWithinFrame(givenFrame: CGRect, withInsets insets: UIEdgeInsets) {
        let availableSize = CGSize(width: givenFrame.width - insets.left - insets.right,
                                   height: givenFrame.height - insets.top - insets.bottom)
        let size = optimalSize(forAvailableSize: availableSize)
        let y = insets.top + (givenFrame.size.height - size.height) / 2.0

        frame = CGRect(x: insets.left, y: y, width: size.width, height: size.height)

        // Whatever the game state, we initially start with 3 rows showing
        // in the bottom of the view
        adjustTopInset(enforceStartingPosition: true)
        toggleBounce(true)
    }

    func emptySpaceVisible(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        return atStartingPosition ?
               topInset(atStartingPosition: true) :
               -contentOffset.y
    }

    func topInset(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        if atStartingPosition {
            return frame.size.height - initialGameHeight()
        } else {
            return max(0, frame.size.height - currentGameHeight())
        }
    }

    private func optimalSize(forAvailableSize availableSize: CGSize) -> CGSize {
        let cellHeight = cellSize(forAvailableWidth: availableSize.width).height
        let remainder = availableSize.height % cellHeight
        let height = availableSize.height - remainder
        return CGSize(width: availableSize.width, height: height)
    }

    private func initialGameHeight() -> CGFloat {
        return heightForGame(withTotalRows: 3)
    }

    private func currentGameHeight() -> CGFloat {
        return heightForGame(withTotalRows: game.totalRows())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameGrid: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return game.totalNumbers()
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        if let cell = cell as? GameNumberCell {
            cell.value = game.valueAtIndex(indexPath.item)
            cell.isCrossedOut = game.isCrossedOut(indexPath.item)
            cell.marksEndOfRound = game.marksEndOfRound(indexPath.item)
            cell.animationDuration = GameGrid.cellAnimationDuration
        }

        return cell
    }
}

extension GameGrid: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !game.isCrossedOut(indexPath.item)
    }

    func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems()!
        let latestSelectedIndexPath = indexPath

        if selectedIndexPaths.count == 2 {
            onPairingAttempt!(itemIndex: selectedIndexPaths[0].item,
                              otherItemIndex: selectedIndexPaths[1].item)
        } else if selectedIndexPaths.count < 2 {
            return
        }

        for selectedIndexPath in selectedIndexPaths {
            if selectedIndexPath != latestSelectedIndexPath {
                collectionView.deselectItemAtIndexPath(selectedIndexPath, animated: false)
            }
        }
    }

    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize()
    }
}

extension GameGrid: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        toggleBounce(true)
    }

    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if !bouncingInProgress {
            toggleBounce(false)
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        toggleBounce(false)
        decelerationRate = UIScrollViewDecelerationRateNormal
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if shouldBouncePrematurely() {
            interjectBounce(scrollView)
        }
        onScroll?()
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        bouncingInProgress = pullUpInProgress() || pullDownInProgress()

        if pullDownDistanceExceeds(pullDownThreshold!) {
            adjustTopInset(enforceStartingPosition: true)
            decelerationRate = UIScrollViewDecelerationRateFast
            targetContentOffset.memory.y = -contentInset.top
            onPullDownThresholdExceeded?()
            return
        }

        if pullUpDistanceExceeds(pullUpThreshold!) {
            onPullUpThresholdExceeded?()
            return
        }

        if prematurePullUpDistanceExceeds(prematurePullUpThreshold!) {
            onPrematurePullUpThresholdExceeded?()
            return
        }

        // TODO test whether this should actually be called in DidBegin...
        // Sometimes bounces to the wrong position
        bounceBackIfNeeded()
    }

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

    func bounceBackIfNeeded () {
        if shouldBouncePrematurely() {
            setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
        }
    }

    // We only want to create a simulated bounce if we would see extra content underneath
    // the "fold". If the current content size isn't big enough to show anything
    // extra, we would get a native bounce anyway.
    func shouldBouncePrematurely () -> Bool {
        return prematureBottomBounceEnabled &&
               contentSize.height > (frame.size.height - contentInset.top)
    }
}
