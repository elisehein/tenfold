//
//  GameGrid.swift
//  Numbers
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameGrid: UICollectionView {

    private static let cellAnimationDuration = 0.15
    private let reuseIdentifier = "NumberCell"

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        return l
    }()

    private let game: Game

    private var bouncingInProgress = false

    var onScroll: (() -> Void)?
    var onDraggingEnd: (() -> Void)?
    var onPairingAttempt: ((itemIndex: Int, otherItemIndex: Int) -> Void)?

    init (game: Game) {
        self.game = game

        super.init(frame: CGRect.zero, collectionViewLayout: layout)

        registerClass(NumberCell.self,
                      forCellWithReuseIdentifier: self.reuseIdentifier)
        allowsMultipleSelection = true
        backgroundColor = UIColor.clearColor()
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
    }

    func loadNextRound (completion: (Bool) -> Void ) {
        var indexPaths: Array<NSIndexPath> = []

        for index in game.currentRoundIndeces() {
           indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
        }

        insertItemsAtIndexPaths(indexPaths)
        performBatchUpdates(nil, completion: completion)
    }

    func crossOutPair (index: Int, otherIndex: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        let otherIndexPath = NSIndexPath(forItem: otherIndex, inSection: 0)
        let cell = cellForItemAtIndexPath(indexPath) as? NumberCell
        let otherCell = cellForItemAtIndexPath(otherIndexPath) as? NumberCell

        guard cell != nil && otherCell != nil else { return }

        cell!.isCrossedOut = true
        otherCell!.isCrossedOut = true

        deselectItemAtIndexPath(indexPath, animated: false)
        deselectItemAtIndexPath(otherIndexPath, animated: false)
    }

    func dismissSelection () {
        let selectedIndexPaths = indexPathsForSelectedItems()

        for indexPath in selectedIndexPaths! {
            if let cell = cellForItemAtIndexPath(indexPath) as? NumberCell {
                cell.shouldDeselectWithFailure = true
                deselectItemAtIndexPath(indexPath, animated: true)
            }
        }
    }

    func toggleBounce (shouldBounce: Bool) {
        // We should *never* disable bounce if there is a top contentInset
        // otherwise we can't pull up from the first rounds where the grid isn't full screen yet
        bounces = contentInset.top > 0 || shouldBounce
    }

    func bottomEdgeY () -> CGFloat {
        return frame.size.height - distancePulledUp()
    }

    func pullUpInProgress () -> Bool {
        let offset = contentOffset.y
        return offset > maxOffsetBeforeBounce() && contentSize.height > 0
    }

    func pullDownInProgress () -> Bool {
        return contentOffset.y < 0
    }

    func pullUpPercentage(ofThreshold threshold: CGFloat) -> CGFloat {
        return distancePulledUp() / threshold
    }

    func pullUpDistanceExceeds (threshold: CGFloat) -> Bool {
        return contentOffset.y > maxOffsetBeforeBounce() + threshold
    }

    func cellSize () -> CGSize {
        let cellWidth = bounds.size.width / CGFloat(GameRules.numbersPerLine)
        return CGSize(width: cellWidth, height: cellWidth)
    }

    private func distancePulledUp () -> CGFloat {
        return contentOffset.y - maxOffsetBeforeBounce()
    }

    private func maxOffsetBeforeBounce () -> CGFloat {
        return contentSize.height - bounds.size.height
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

        if let cell = cell as? NumberCell {
            cell.number = game.numberAtIndex(indexPath.item)
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

        if selectedIndexPaths.count == GameRules.numbersInPairing {
            onPairingAttempt!(itemIndex: selectedIndexPaths[0].item,
                              otherItemIndex: selectedIndexPaths[1].item)
        } else if selectedIndexPaths.count < GameRules.numbersInPairing {
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
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.onScroll!()
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        bouncingInProgress = pullUpInProgress() || pullDownInProgress()
        self.onDraggingEnd!()
    }
}
