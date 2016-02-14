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
    private let maxSelectedItems = 2
    
    init(game: Game) {
        self.game = game
        self.rules = GameRules(game: game)
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.registerClass(NumberCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        view.addSubview(collectionView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func attemptItemPairing (item: Int, otherItem: Int) {
        let successfulPairing = rules.attemptPairing(item, otherIndex: otherItem)
        
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        let otherIndexPath = NSIndexPath(forItem: otherItem, inSection: 0)
        
        if successfulPairing {
            game.crossOutPair(item, otherIndex: otherItem)
            self.collectionView.reloadItemsAtIndexPaths([indexPath, otherIndexPath])
        } else {
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! NumberCell
            let otherCell = self.collectionView.cellForItemAtIndexPath(otherIndexPath) as! NumberCell
            cell.shouldDeselectWithFailure = true
            otherCell.shouldDeselectWithFailure = true
            self.collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            self.collectionView.deselectItemAtIndexPath(otherIndexPath, animated: false)
        }
    }
    
    // Instead of calling reloadData on the entire grid, dynamically add the next round
    // This function assumes that the state of the game has diverged from the state of
    // the collectionView.
    func loadNextRound () {
        var indexPaths: Array<NSIndexPath> = []
        
        for index in game.currentRoundIndeces() {
           indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
        }
        
        collectionView.insertItemsAtIndexPaths(indexPaths)
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
        }
        
        return cell
    }
}

extension GameGrid:  UICollectionViewDelegateFlowLayout {
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
        let cellWidth = collectionView.bounds.size.width / 9.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
}