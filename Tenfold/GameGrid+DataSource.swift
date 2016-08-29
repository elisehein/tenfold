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
        return game.totalNumbers()
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        if let cell = cell as? GameGridCell {
            cell.value = game.valueAtIndex(indexPath.item)
            cell.crossedOut = game.isCrossedOut(indexPath.item)
            cell.marksEndOfRound = game.marksEndOfRound(indexPath.item)
            cell.useClearBackground = true
            cell.selectedForPairing = selectedIndexPaths.contains(indexPath)
            cell.resetColors()
        }

        return cell
    }
}
