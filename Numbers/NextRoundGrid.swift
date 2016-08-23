//
//  NextRoundGrid.swift
//  Numbers
//
//  Created by Elise Hein on 26/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

/*
 *
 * NextRoundGrid is a UICollectionView with totalRows sections and
 * cellsPerRow items per section. Its very first section is always hidden
 * behind the very last row of the gameGrid, so that we can show next round
 * values on the same line as the last gameGrid line. For example, if the game
 * finishes with just three numbers on a line
 *
 * | 6 | 5 | 1 |   |   |   |   |   |   |
 *
 * next round grid must produce the following, where values correspond to
 * [1, 2, 3, 4, 5, 6, 7, 8, 9, 2, 4, 5]
 *
 * |   |   |   | 1 | 2 | 3 | 4 | 5 | 6 |
 * | 7 | 8 | 9 | 2 | 4 | 5 |   |   |   |
 *
 * By putting the grid below the gameGrid with the last and first lines overlapping,
 * we see a continuation of numbers on the same line.
 *
 * Note that each section has a full set of 9 items, we simply choose which items
 * display values or not. This is because we may want the empty cells to display
 * something else, not just stop the row in a random place.
 *
 * Note also that if there are more values given than there are totalRows * 9,
 * we only add values for as long as there are cells to add them to. Because this
 * grid is what we see when we pull up the game from the bottom, we can be confident
 * that we'll never see more than a certain number of cells anyway.
 *
 */

class NextRoundGrid: Grid {

    // We should store more or as many scale series numbers as there are rows
    private static let totalRows = 8

    private let reuseIdentifier = "NextRoundNumberCell"

    private let cellsPerRow: Int
    private var values: Array<Int?>
    private var startIndex: Int

    var proportionVisible: CGFloat = 0 {
        didSet {
            // Take care not to set this continuously; it should be set to true
            // ONCE when we reach 100% visible, and set to false ONCE when we
            // no longer have 100% visible.
            if proportionVisible == 1 && !revealValues {
                revealValues = true
            } else if proportionVisible < 1 && revealValues {
                revealValues = false
            }

            collectionViewLayout.invalidateLayout()
        }
    }

    private var revealValues: Bool = false {
        didSet {
            reloadData()
        }
    }

    init(cellsPerRow: Int,
         startIndex: Int,
         values: Array<Int?>,
         frame: CGRect) {

        self.cellsPerRow = cellsPerRow
        self.values = values
        self.startIndex = startIndex

        super.init(frame: frame)
        registerClass(NextRoundNumberCell.self,
                      forCellWithReuseIdentifier: self.reuseIdentifier)

        backgroundColor = UIColor.clearColor()
        dataSource = self
    }

    func update(startIndex startIndex: Int, values: Array<Int?>) {
        self.startIndex = startIndex
        self.values = values
        reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NextRoundGrid: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView (collectionView: UICollectionView) -> Int {
        return NextRoundGrid.totalRows
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return cellsPerRow
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        let rowIndex = indexPath.section
        let itemIndex = rowIndex * cellsPerRow + indexPath.item

        if let cell = cell as? NextRoundNumberCell {

            if itemIndex >= startIndex && itemIndex < startIndex + values.count {
                cell.value = values[itemIndex - startIndex]
            } else {
                cell.value = nil
            }

            cell.shouldBlimp = revealValues
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize()
    }
}
