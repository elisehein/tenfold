//
//  RuleExampleGrid.swift
//  Numbers
//
//  Created by Elise Hein on 19/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class RuleExampleGrid: Grid {

    private var timer: NSTimer?
    private let reuseIdentifier = "GameNumberCell"

    private let values: Array<Int?> = [nil, nil, nil, nil, nil, nil, nil, nil, nil,
                                       nil, nil, 5, nil, nil, nil, nil, nil, nil,
                                       nil, nil, 5, nil, nil, nil, nil, nil, nil]

    init() {
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.clearColor()
        delegate = self
        dataSource = self
        userInteractionEnabled = false

        registerClass(GameNumberCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
    }

    func playLoop() {
        timer = NSTimer.scheduledTimerWithTimeInterval(3,
                                                       target: self,
                                                       selector: #selector(RuleExampleGrid.actions),
                                                       userInfo: nil,
                                                       repeats: true)
    }

    func invalidateLoop() {
        timer?.invalidate()
    }

    func actions() {
        print("Reload and run loop")

        let indexPathInPair = NSIndexPath(forItem: 11, inSection: 0)
        let otherIndexPathInPair = NSIndexPath(forItem: 20, inSection: 0)

        for indexPath in [indexPathInPair, otherIndexPathInPair] {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
                cell.unCrossOut()
            }
        }

        NSTimer.scheduledTimerWithTimeInterval(1,
                                               target: self,
                                               selector: #selector(RuleExampleGrid.selectFirstCell),
                                               userInfo: nil,
                                               repeats: false)

        NSTimer.scheduledTimerWithTimeInterval(2,
                                               target: self,
                                               selector: #selector(RuleExampleGrid.crossOutPair),
                                               userInfo: nil,
                                               repeats: false)
    }

    func selectFirstCell() {
        let indexPathInPair = NSIndexPath(forItem: 11, inSection: 0)

        if let cell = cellForItemAtIndexPath(indexPathInPair) as? GameNumberCell {
            print("Indicating selection")
            cell.indicateSelection()
        }
    }

    func crossOutPair() {
        print("Crossing out both in pair")
        let indexPathInPair = NSIndexPath(forItem: 11, inSection: 0)
        let otherIndexPathInPair = NSIndexPath(forItem: 20, inSection: 0)

        for indexPath in [indexPathInPair, otherIndexPathInPair] {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
                cell.crossOut()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RuleExampleGrid: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return values.count
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        if let cell = cell as? GameNumberCell {
            cell.value = values[indexPath.item]
            cell.crossedOut = false
            cell.marksEndOfRound = false
            cell.defaultBackgroundColor = UIColor.themeColorHighlighted(.OffWhite)
            cell.resetColors()
        }

        return cell
    }

}

extension RuleExampleGrid: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize()
    }
}
