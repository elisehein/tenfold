//
//  NextRoundGrid.swift
//  Numbers
//
//  Created by Elise Hein on 26/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class NextRoundGrid: UICollectionView {

    private static let totalRows = 7

    private let reuseIdentifier = "NextRoundNumberCell"

    private let cellSize: CGSize
    private let cellsPerRow: Int

    private var values: Array<Int>
    private var startIndex: Int
    private var revealValues: Bool = false

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumLineSpacing = 0
        l.minimumInteritemSpacing = 0
        return l
    }()

    var proportionVisible: CGFloat = 0 {
        didSet {
            if proportionVisible == 1 && !revealValues {
                print("SHOW NUMBERS")
                revealValues = true
            } else if proportionVisible < 1 && revealValues {
                print("HIDE NUMBERS")
                revealValues = false
            }

            collectionViewLayout.invalidateLayout()
        }
    }

    init (cellSize: CGSize,
          cellsPerRow: Int,
          startIndex: Int,
          values: Array<Int>,
          frame: CGRect) {

        self.cellSize = cellSize
        self.cellsPerRow = cellsPerRow
        self.values = values
        self.startIndex = startIndex

        super.init(frame: frame, collectionViewLayout: layout)
        registerClass(NextRoundNumberCell.self,
                      forCellWithReuseIdentifier: self.reuseIdentifier)

        backgroundColor = UIColor.clearColor()
        dataSource = self
        delegate = self
    }

    func update (startIndex startIndex: Int, values: Array<Int>) {
        self.startIndex = startIndex
        self.values = values
        reloadData()
    }

    required init? (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NextRoundGrid: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView (collectionView: UICollectionView) -> Int {
        return NextRoundGrid.totalRows
    }

    func collectionView (collectionView: UICollectionView,
                         numberOfItemsInSection section: Int) -> Int {
        return cellsPerRow
    }

    func collectionView (collectionView: UICollectionView,
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
}

extension NextRoundGrid: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView (collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(section) * 10, right: 0)
    }


    func collectionView (collectionView: UICollectionView,
                         layout: UICollectionViewLayout,
                         sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
}
