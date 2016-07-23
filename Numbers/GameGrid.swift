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
    var onPullUpThresholdExceeded: (() -> Void)?
    var onWillSnapToGameplayPosition: (() -> Void)?
    var onWillSnapToStartingPosition: (() -> Void)?
    var onPairingAttempt: ((itemIndex: Int, otherItemIndex: Int) -> Void)?

    var pullUpThreshold: CGFloat?
    var snapToStartingPositionThreshold: CGFloat?
    var snapToGameplayPositionThreshold: CGFloat?

    var gridAtStartingPosition = true
    var currentScrollCycleHandled = false

    private static let scaleFactor = UIScreen.mainScreen().scale
    private static let prematureBounceReductionFactor: CGFloat = 0.2

    private var prevPrematureBounceOffset: CGFloat = 0
    private var totalPrematureBounceDistance: CGFloat = 0

    private var latestSelectedIndexPath: NSIndexPath?

    init(game: Game) {
        self.game = game

        super.init(frame: CGRect.zero)

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
        gridAtStartingPosition = enforceStartingPosition
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

        deselectItemAtIndexPath(indexPath, animated: false)
        cell!.crossOut()

        deselectItemAtIndexPath(otherIndexPath, animated: false)
        otherCell!.crossOut()
    }

    func removeNumbers(atIndexPaths indexPaths: Array<NSIndexPath>) {
        // TODO should still work without this line
        guard indexPaths.count > 0 else { return }

        adjustTopInset()
        if contentInset.top > 0 {
            setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
        }

        deleteItemsAtIndexPaths(indexPaths)
        reloadItemsAtIndexPaths([NSIndexPath(forItem: game.totalNumbers() - 1, inSection: 0)])
    }

    func dismissSelection() {
        let selectedIndexPaths = indexPathsForSelectedItems()

        for indexPath in selectedIndexPaths! {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
                self.deselectItemAtIndexPath(indexPath, animated: false)
                if indexPath == latestSelectedIndexPath {
                    cell.indicateSelection()
                }
                cell.indicateSelectionFailure()
            }
        }
    }

    func initialisePositionWithinFrame(givenFrame: CGRect, withInsets insets: UIEdgeInsets) {
        let availableSize = CGSize(width: givenFrame.width - insets.left - insets.right,
                                   height: givenFrame.height - insets.top - insets.bottom)
        let size = sizeSnappedToPixel(inAvailableSize: availableSize)
        let x = floor(insets.left + (availableSize.width - size.width) / 2.0)
        let y = floor(insets.top + (availableSize.height - size.height) / 2.0)

        frame = CGRect(origin: CGPoint(x: x, y: y), size: size)

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

    private func topInset(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        if atStartingPosition {
            return frame.size.height - initialGameHeight()
        } else {
            return max(0, frame.size.height - currentGameHeight())
        }
    }

    private func sizeSnappedToPixel(inAvailableSize availableSize: CGSize) -> CGSize {
        // We want to get a width that is exactly divisible by the number of items per row,
        // taking into account also spacing, so that we don't get any unequal spacing or cell widths
        let widthForNumbers = availableSize.width - CGFloat(widthForSpacing())
        let widthRemainder = widthForNumbers % CGFloat(Game.numbersPerRow)
        let integerWidth = availableSize.width - widthRemainder

        let cellHeight = cellSize(forAvailableWidth: availableSize.width).height
        let heightRemainder = availableSize.height % cellHeight
        let integerHeight = availableSize.height - heightRemainder
        return CGSize(width: integerWidth, height: integerHeight)
    }

    private func initialGameHeight() -> CGFloat {
        return heightForGame(withTotalRows: 3)
    }

    private func currentGameHeight() -> CGFloat {
        return heightForGame(withTotalRows: game.totalRows())
    }

    private func ensureGridPositionedForGameplay() {
        guard gridAtStartingPosition else { return }
        positionGridForGameplay()
    }

    private func positionGridForGameplay() {
        // This handler needs to be called *before* the animation block,
        // otherwise it will for some reason push it to a later thread
        onWillSnapToGameplayPosition?()

        // The reason this looks so obscure is because scroll views are SHIT.
        // This specific combination of setting an inset and offset is the only one
        // that results in an animation that STOPS when it reaches the top of the view
        let nextTopInset = self.topInset()
        UIView.animateWithDuration(0.3, animations: {
            self.contentInset.top = nextTopInset
            self.setContentOffset(CGPoint(x: 0, y: -nextTopInset), animated: false)
        }, completion: { _ in
            self.gridAtStartingPosition = false
        })
    }

    private func prematurePullUpDistanceExceeds(threshold: CGFloat) -> Bool {
        return shouldBouncePrematurely() && contentDistanceFromTopEdge() > threshold
    }

    private func toggleBounce(shouldBounce: Bool) {
        // We should *never* disable bounce if there is a top contentInset
        // otherwise we can't pull up from the first rounds where the grid isn't full screen yet
        bounces = contentInset.top > 0 || shouldBounce
    }

    private func interjectBounce (scrollView: UIScrollView) {
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

    private func bounceBack() {
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
    }

    // This refers to whether we disallow scrolling beyond what is visible on the screen,
    // and show a bounce effect instead. This essentially allows a bounce effect to happen
    // even though we haven't reached the bottom of the content yet.
    // http://stackoverflow.com/questions/20437657/increasing-uiscrollview-rubber-banding-resistance
    private func shouldBouncePrematurely () -> Bool {
        // We only want to create a simulated bounce if we would see extra content underneath
        // the "fold". If the current content size isn't big enough to show anything
        // extra, we would get a native bounce anyway.
        return !pullDownInProgress() &&
               gridAtStartingPosition &&
               contentSize.height > (frame.size.height - contentInset.top)
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
            cell.crossedOut = game.isCrossedOut(indexPath.item)
            cell.marksEndOfRound = game.marksEndOfRound(indexPath.item)
            cell.resetColors()
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
        ensureGridPositionedForGameplay()

        let selectedIndexPaths = collectionView.indexPathsForSelectedItems()!
        latestSelectedIndexPath = indexPath

        if selectedIndexPaths.count == 2 {
            onPairingAttempt!(itemIndex: selectedIndexPaths[0].item,
                              otherItemIndex: selectedIndexPaths[1].item)
        } else if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
            cell.indicateSelection()
        }
    }

    func collectionView(collectionView: UICollectionView,
                        didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
            cell.indicateDeselection()
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
        currentScrollCycleHandled = false
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if pullDownDistanceExceeds(snapToStartingPositionThreshold!) {
            adjustTopInset(enforceStartingPosition: true)
            decelerationRate = UIScrollViewDecelerationRateFast
            targetContentOffset.memory.y = -contentInset.top
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

        guard shouldBouncePrematurely() else { return }

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

        if !currentScrollCycleHandled && shouldBouncePrematurely() {
            bounceBack()
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
}
