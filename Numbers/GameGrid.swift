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
    var onDraggingEnd: (() -> Void)?
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

    func restart(withGame newGame: Game, beforeReappearing: (() -> Void)?) {
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseIn, animations: {
            self.alpha = 0
            var offScreenFrame = self.frame
            offScreenFrame.origin.y += self.initialGameHeight() * 0.3
            self.frame = offScreenFrame
        }, completion: { _ in
            self.game = newGame
            self.reloadData()
            beforeReappearing?()

            UIView.animateWithDuration(0.15, delay: 0.2, options: .CurveEaseIn, animations: {
                self.alpha = 1
            }, completion: nil)
        })
    }

    func loadNextRound(atIndeces indeces: Array<Int>, completion: (Bool) -> Void ) {
        var indexPaths: Array<NSIndexPath> = []

        for index in indeces {
           indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
        }

        insertItemsAtIndexPaths(indexPaths)
        performBatchUpdates(nil, completion: completion)
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

    func dismissSelection() {
        let selectedIndexPaths = indexPathsForSelectedItems()

        for indexPath in selectedIndexPaths! {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
                cell.shouldDeselectWithFailure = true
                deselectItemAtIndexPath(indexPath, animated: true)
            }
        }
    }

    func prematureBounceDistanceExceeds(threshold: CGFloat) -> Bool {
        return contentOffset.y + contentInset.top > threshold
    }

    func toggleBounce(shouldBounce: Bool) {
        // We should *never* disable bounce if there is a top contentInset
        // otherwise we can't pull up from the first rounds where the grid isn't full screen yet
        bounces = contentInset.top > 0 || shouldBounce
    }

    func initialGameHeight() -> CGFloat {
        return heightForGame(withTotalRows: 3)
    }

    func currentGameHeight() -> CGFloat {
        return heightForGame(withTotalRows: game.totalRows())
    }

    func optimalHeight(forAvailableHeight availableHeight: CGFloat) -> CGFloat {
        return availableHeight - (availableHeight % cellSize().height)
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
        bounceBackIfNeeded()
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        toggleBounce(false)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if shouldBouncePrematurely() {
            interjectBounce(scrollView)
        }

        onScroll?()
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        bounceBackIfNeeded()
        bouncingInProgress = pullUpInProgress() || pullDownInProgress()
        self.onDraggingEnd?()
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
