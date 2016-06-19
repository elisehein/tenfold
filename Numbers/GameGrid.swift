//
//  GameGrid.swift
//  Numbers
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameGrid: UIViewController {
    
    private static let cellAnimationDuration = 0.15
    private static let nextRoundTriggerThreshold: CGFloat = 50
    
    let game: Game
    let rules: GameRules
    
    let collectionView: UICollectionView
    
    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        return l
    }()
    
    private let reuseIdentifier = "NumberCell"
    private let maxSelectedItems: Int
    
    private var bouncingInProgress = false
    
    init(game: Game) {
        self.game = game
        self.rules = GameRules(game: game)
        self.maxSelectedItems = rules.numbersInPairing
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.registerClass(NumberCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        toggleBounce(false)
    
        view.addSubview(collectionView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var frame = view.bounds
        frame.size.height = optimalGridHeight()
        frame.origin.y += (view.bounds.size.height - frame.size.height) / 2
        collectionView.frame = frame
    }
    
    func attemptItemPairing (item: Int, otherItem: Int) {
        let successfulPairing = rules.attemptPairing(item, otherIndex: otherItem)
        
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        let otherIndexPath = NSIndexPath(forItem: otherItem, inSection: 0)
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! NumberCell
        let otherCell = self.collectionView.cellForItemAtIndexPath(otherIndexPath) as! NumberCell
        
        if successfulPairing {
            game.crossOutPair(item, otherIndex: otherItem)
            cell.isCrossedOut = true
            otherCell.isCrossedOut = true
        } else {
            cell.shouldDeselectWithFailure = true
            otherCell.shouldDeselectWithFailure = true
        }
        
        self.collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        self.collectionView.deselectItemAtIndexPath(otherIndexPath, animated: false)
    }
    
    // Instead of calling reloadData on the entire grid, dynamically add the next round
    // This function assumes that the state of the game has diverged from the state of
    // the collectionView.
    func loadNextRound (whileAtScrollOffset scrollOffset: CGPoint) -> Bool {
        let hypotheticalNextRound = game.hypotheticalNextRound()
        
        if (hypotheticalNextRound.count == 0) {
            return false
        }
        
        game.makeNextRound(usingNumbers: hypotheticalNextRound)
        
        var indexPaths: Array<NSIndexPath> = []
        
        for index in game.currentRoundIndeces() {
           indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
        }
        
        collectionView.insertItemsAtIndexPaths(indexPaths)
        collectionView.performBatchUpdates(nil, completion: { _ in
            // This runs when item insertion has finished, and removes momentum
            // from the scrollview so the user always stays at the exact point
            // they released the pull-up-to-load-next-round widget
            // http://stackoverflow.com/a/30668519/2026098
            self.collectionView.setContentOffset(scrollOffset, animated: false)
        })
        return true
    }
    
    func toggleBounce (bounces: Bool) {
        collectionView.bounces = bounces
        collectionView.alwaysBounceVertical = bounces
    }
    
    func optimalGridHeight () -> CGFloat {
        let cellHeight = cellSize().height
        let availableHeight = view.bounds.size.height
        
        return availableHeight - (availableHeight % cellHeight)
    }
    
    func cellSize () -> CGSize {
        let cellWidth = view.bounds.size.width / CGFloat(rules.numbersPerLine)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension GameGrid: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.totalNumbers()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
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
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !game.isCrossedOut(indexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems()!
        let latestSelectedIndexPath = indexPath
        
        if selectedIndexPaths.count == maxSelectedItems {
            attemptItemPairing(selectedIndexPaths[0].item, otherItem: selectedIndexPaths[1].item)
        } else if selectedIndexPaths.count < maxSelectedItems {
            return
        }
        
        for selectedIndexPath in selectedIndexPaths {
            if selectedIndexPath != latestSelectedIndexPath {
                collectionView.deselectItemAtIndexPath(selectedIndexPath, animated: false)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize()
    }
}

extension GameGrid: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == collectionView {
            toggleBounce(true)
        }
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if scrollView == collectionView && !bouncingInProgress {
            toggleBounce(false)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == collectionView {
            toggleBounce(false)
        }
    }
    
    // NOTE this does not take into account content insets
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView != collectionView {
            return
        }
        
        let offset = scrollView.contentOffset.y
        let maxOffsetWithoutBounce = scrollView.contentSize.height - scrollView.bounds.size.height
        
        bouncingInProgress = offset > maxOffsetWithoutBounce
        
        if offset > maxOffsetWithoutBounce + GameGrid.nextRoundTriggerThreshold {
            loadNextRound(whileAtScrollOffset: scrollView.contentOffset)
        }
    }
}