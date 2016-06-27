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

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        return l
    }()

    var proportionVisible: CGFloat = 0 {
        didSet {
            if proportionVisible == 1 {
                shouldBlimp = true
                reloadData()
            }
        }
    }

    private let cellSize: CGSize
    private let cellsPerRow: Int

    private var values: Array<Int>
    private var startIndex: Int
    private var shouldBlimp: Bool = false

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
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return NextRoundGrid.totalRows * cellsPerRow
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        let cellIndex = indexPath.item

        if let cell = cell as? NextRoundNumberCell {
            if cellIndex >= startIndex && cellIndex < startIndex + values.count {
                cell.value = values[cellIndex - startIndex]
            } else {
                cell.value = nil
            }

            cell.shouldBlimp = shouldBlimp
        }

        return cell
    }
}

extension NextRoundGrid: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
}
