//
//  GameGrid+DataSource.swift
//  Tenfold
//
//  Created by Elise Hein on 29/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

extension GameGrid: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return game.numberCount()
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        if let cell = cell as? GameGridCell {
            cell.value = game.valueAtIndex(indexPath.item)
            cell.state = cellState(forCellAtIndexPath: indexPath)
            cell.marksEndOfRound = game.marksEndOfRound(indexPath.item)
            cell.useClearBackground = true

            if indecesAboutToBeRevealed != nil &&
               indecesAboutToBeRevealed!.contains(indexPath.item) {
                cell.aboutToBeRevealed = true
            }

            cell.resetColors()
        }

        return cell
    }
}
