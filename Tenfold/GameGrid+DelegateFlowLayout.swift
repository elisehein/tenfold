//
//  GameGrid+DelegateFlowLayout.swift
//  Tenfold
//
//  Created by Elise Hein on 29/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

extension GameGrid: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indecesPermittedForSelection != nil &&
           !indecesPermittedForSelection!.contains(indexPath.item) {
           return false
        } else {
            let undoable = game.latestPair.contains(indexPath.item)
            return !game.isCrossedOut(indexPath.item) || undoable
        }
    }

    func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let numberCell = cellForItemAtIndexPath(indexPath) as? GameGridCell
        guard numberCell != nil else { return }

        ensureGridPositionedForGameplay()

        if game.isCrossedOut(indexPath.item) {
            onUndoLatestPairing!()
        } else if selectedIndexPaths.contains(indexPath) {
            numberCell!.indicateDeselection()
            selectedIndexPaths.removeAll()
        } else if selectedIndexPaths.count == 1 {
            selectedIndexPaths.append(indexPath)
            onPairingAttempt!(itemIndex: selectedIndexPaths[0].item,
                              otherItemIndex: selectedIndexPaths[1].item)
            selectedIndexPaths.removeAll()
        } else {
            selectedIndexPaths.append(indexPath)
            numberCell!.indicateSelection()
        }
    }

    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Grid.cellSize(forAvailableWidth: bounds.size.width)
    }
}
