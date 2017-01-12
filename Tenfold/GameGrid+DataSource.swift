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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return game.numberCount()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                                         for: indexPath)

        if let cell = cell as? GameGridCell {
            cell.value = game.valueAtIndex(indexPath.item)
            cell.state = cellState(forCellAtIndexPath: indexPath)
            cell.marksEndOfRound = game.marksEndOfRound(indexPath.item)
            cell.useClearBackground = true

            if rowInsertionInProgressWithIndeces != nil &&
               rowInsertionInProgressWithIndeces!.contains(indexPath.item) {
                cell.aboutToBeRevealed = true
            }

            cell.resetColors()
        }

        return cell
    }
}

// MARK: DataSource helpers

private extension GameGrid {
    func cellState(forCellAtIndexPath indexPath: IndexPath) -> GameGridCellState {
        if game.isCrossedOut(indexPath.item) {
            return .crossedOut
        } else if selectedIndexPaths.contains(indexPath) {
            return .pendingPairing
        } else {
            return .available
        }
    }
}
