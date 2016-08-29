//
//  GameGrid.swift
//  Tenfold
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameGrid: Grid {

    private let reuseIdentifier = "GameNumberCell"

    private var game: Game

    private var bouncingInProgress = false
    var snappingInProgress = false
    var gridAtStartingPosition = true
    var currentScrollCycleHandled = false

    var pullUpThreshold: CGFloat?
    var snapToStartingPositionThreshold: CGFloat?
    var snapToGameplayPositionThreshold: CGFloat?

    var onScroll: (() -> Void)?
    var onPullUpThresholdExceeded: (() -> Void)?
    var onWillSnapToGameplayPosition: (() -> Void)?
    var onWillSnapToStartingPosition: (() -> Void)?
    var onPairingAttempt: ((itemIndex: Int, otherItemIndex: Int) -> Void)?

    private static let scaleFactor = UIScreen.mainScreen().scale
    private static let prematureBounceReductionFactor: CGFloat = 0.2

    private var prevPrematureBounceOffset: CGFloat = 0
    private var totalPrematureBounceDistance: CGFloat = 0

    private var selectedIndexPaths: Array<NSIndexPath> = []
    private var latestSelectedIndexPath: NSIndexPath?
    private var indexPathsPendingDeselection = Set<NSIndexPath>()

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
        UIView.animateWithDuration(0.2,
                                   delay: 0,
                                   options: .CurveEaseIn,
                                   animations: {
            self.alpha = 0
            self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
                                                        0,
                                                        self.initialGameHeight() * 0.3)
        }, completion: { _ in
            self.game = newGame
            self.reloadData()
            self.transform = CGAffineTransformIdentity
            self.adjustTopInset(enforceStartingPosition: true)

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
        toggleBounce(contentInset.top > 0)
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

        // These need to be checked separately, as one cell may be visible
        // while the other is not (in which case it is nil). We still want to
        // cross out the visible one
        if cell != nil {
            deselectItemAtIndexPath(indexPath, animated: false)
            cell!.crossOut()
        } else {
            indexPathsPendingDeselection.insert(indexPath)
        }

        if otherCell != nil {
            deselectItemAtIndexPath(otherIndexPath, animated: false)
            otherCell!.crossOut()
        } else {
            indexPathsPendingDeselection.insert(otherIndexPath)
        }
    }

    func removeNumbers(atIndexPaths indexPaths: Array<NSIndexPath>, completion: (() -> Void)) {
        guard indexPaths.count > 0 else { return }

        adjustTopInset()
        if contentInset.top > 0 {
            setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
        }

        var removalHandled = false
        for indexPath in indexPaths {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
                cell.prepareForRemoval(completion: {
                    if !removalHandled {
                        self.deleteItemsAtIndexPaths(indexPaths)

                        if self.game.totalNumbers() > 0 {
                            let lastIndexPath = NSIndexPath(forItem: self.game.totalNumbers() - 1,
                                                            inSection: 0)
                            self.reloadItemsAtIndexPaths([lastIndexPath])
                        }

                        removalHandled = true
                        completion()
                    }
                })
            }
        }
    }

    func dismissSelection() {
        let selectedIndexPaths = indexPathsForSelectedItems()

        for indexPath in selectedIndexPaths! {
            // If the cell is currently visible, deselect it visibly, otherwise
            // store indexpath for later deselection (it's impossible to deselect invisible cells)
            if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
                self.deselectItemAtIndexPath(indexPath, animated: false)
                if indexPath == latestSelectedIndexPath {
                    cell.indicateSelection()
                }
                cell.indicateSelectionFailure()
            } else {
                print("Adding", indexPath, "to pending deselection")
                indexPathsPendingDeselection.insert(indexPath)
            }
        }
    }

    override func initialisePositionWithinFrame(givenFrame: CGRect,
                                                withInsets insets: UIEdgeInsets) {
        super.initialisePositionWithinFrame(givenFrame, withInsets: insets)

        // Whatever the game state, we initially start with 3 rows showing
        // in the bottom of the view
        adjustTopInset(enforceStartingPosition: true)
    }

    // Empty space visible should be capped to depend on the initial game height (3 rows);
    // it should still account for three game rows even if the actual game is only 1 or two
    // This is why we don't simply call topInset() – top inset may be different than empty space
    // visible at starting position
    func emptySpaceVisible(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        return atStartingPosition ?
               frame.size.height - initialGameHeight() :
               -contentOffset.y
    }

    func pullUpFromStartingPositionInProgress() -> Bool {
        return gridAtStartingPosition && (pullUpInProgress() || prematurePullUpInProgress())
    }

    func pullUpDistanceFromStartingPosition() -> CGFloat {
        return prematurePullUpInProgress() ? contentDistanceFromTopEdge() : distancePulledUp()
    }

    private func topInset(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        if atStartingPosition {
            return frame.size.height - min(initialGameHeight(), currentGameHeight())
        } else {
            return max(0, frame.size.height - currentGameHeight())
        }
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

        // We're not calling toggleBounce here because it overrides false
        // whenever there is a top inset – which is always true in startingPosition.
        // We simply want to disable bounce for the duration of the animation
        // so that we don't flash the next round grid in the bottom of the screen.
        bounces = false
        snappingInProgress = true

        // The reason this looks so obscure is because scroll views are SHIT.
        // This specific combination of setting an inset and offset is the only one
        // that results in an animation that STOPS when it reaches the top of the view
        let nextTopInset = self.topInset()
        UIView.animateWithDuration(0.3, animations: {
            self.contentInset.top = nextTopInset
            self.setContentOffset(CGPoint(x: 0, y: -nextTopInset), animated: false)
        }, completion: { _ in
            self.snappingInProgress = false
            self.toggleBounce(self.contentInset.top > 0)
            self.gridAtStartingPosition = false
        })
    }

    private func prematurePullUpDistanceExceeds(threshold: CGFloat) -> Bool {
        return prematurePullUpInProgress() && contentDistanceFromTopEdge() > threshold
    }

    private func toggleBounce(shouldBounce: Bool) {
        guard !snappingInProgress else { return }

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
    private func prematurePullUpInProgress() -> Bool {
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
            cell.useClearBackground = true
            cell.resetColors()
        }

        print("Cell for item..", indexPath)

        return cell
    }

    // We can't deselect cells while they're invisible, which leaves us in a situation
    // where sometimes crossed out cells remain selected. If this is the case,
    // deselect them immediately when they become visible
    func collectionView(collectionView: UICollectionView,
                        willDisplayCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? GameNumberCell {
            if indexPathsPendingDeselection.contains(indexPath) {
                print("Deselecting, because it needed to be deselected earlier", indexPath)
                deselectItemAtIndexPath(indexPath, animated: false)
                indexPathsPendingDeselection.remove(indexPath)
                print("Selected index paths now", collectionView.indexPathsForSelectedItems())
                cell.resetColors()
            }
        }
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

        // Filter crossed out items from selected index paths (see above; cells not
        // currently visible cannot be deselected). They will be periodically pruned
        // when they become visible
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems()!
        var prunedSelectedIndexPaths: Array<NSIndexPath> = []

        for selectedIndexPath in selectedIndexPaths {
            if !game.isCrossedOut(selectedIndexPath.item) ||
               !indexPathsPendingDeselection.contains(selectedIndexPath) {
                prunedSelectedIndexPaths.append(selectedIndexPath)
            } else {
                print("Pruning", selectedIndexPath, "because it was already dismissed")
            }
        }

        latestSelectedIndexPath = indexPath

        if prunedSelectedIndexPaths.count == 2 {
            onPairingAttempt!(itemIndex: prunedSelectedIndexPaths[0].item,
                              otherItemIndex: prunedSelectedIndexPaths[1].item)
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
