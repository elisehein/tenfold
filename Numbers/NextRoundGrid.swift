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
 * NextRoundGrid is a UICollectionView with 1 section and
 * totalNumbers() items (like a Grid). Its very first row is always hidden
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
 * we see a continuation of numbers on the same line. The empty cells in the beginning
 * are "spacer" cells (cell.isSpacer = true); the empty cells in the end are not
 * spacers, as they do still have a background colour.
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
            for visibleCell in visibleCells() {
                if let visibleCell = visibleCell as? NextRoundNumberCell {
                    if revealValues {
                        visibleCell.revealValue()
                    } else {
                        visibleCell.hideValue()
                    }
                }
            }
        }
    }

    init(cellsPerRow: Int, startIndex: Int, values: Array<Int?>, frame: CGRect) {

        self.cellsPerRow = cellsPerRow
        self.values = values
        self.startIndex = startIndex

        super.init(frame: frame)
        registerClass(NextRoundNumberCell.self,
                      forCellWithReuseIdentifier: self.reuseIdentifier)

        backgroundColor = UIColor.clearColor()
        dataSource = self
        delegate = self
    }

    func update(startIndex startIndex: Int, values: Array<Int?>) {
        self.startIndex = startIndex
        self.values = values
        reloadData()
    }

    func hide(animated animated: Bool) {
        if animated {
            animateAlpha(0)
        } else {
            alpha = 0
        }
    }

    func show(animated animated: Bool) {
        if animated {
            animateAlpha(1)
        } else {
            alpha = 1
        }
    }

    private func animateAlpha(value: CGFloat) {
        guard alpha != value else { return }

        UIView.animateWithDuration(0.15, animations: {
            self.alpha = value
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NextRoundGrid: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView (collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return max(NextRoundGrid.totalRows * Game.numbersPerRow, values.count)
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)
        if let cell = cell as? NextRoundNumberCell {
            cell.isSpacer = indexPath.item < startIndex
            cell.valueIsHidden = !revealValues

            if indexPath.item >= startIndex && indexPath.item < startIndex + values.count {
                cell.value = values[indexPath.item - startIndex]
            } else {
                cell.value = nil
            }
        }

        return cell
    }
}

extension NextRoundGrid: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize()
    }
}
