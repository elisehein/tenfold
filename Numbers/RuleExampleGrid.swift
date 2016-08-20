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

    private static let pairingLoopDuration: Double = 3

    private var loopTimer: NSTimer?
    private let reuseIdentifier = "GameNumberCell"

    var values: Array<Int?> = []
    var crossedOutIndeces: Array<Int> = []
    var pairs: Array<[Int]> = []

    init() {
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.clearColor()
        delegate = self
        dataSource = self
        userInteractionEnabled = false

        registerClass(GameNumberCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
    }

    // Because the timer interval doesn't allow for the first loop to run immediately,
    // we fire the first one ourselves, and then set an interval for the rest.
    func playLoop() {
        performPairings()
        loopTimer = after(seconds: Double(pairs.count) * RuleExampleGrid.pairingLoopDuration,
                          performSelector: #selector(RuleExampleGrid.performPairings),
                          repeats: true)
    }

    func invalidateLoop() {
        loopTimer?.invalidate()
    }

    func performPairings() {
        var delay = 0.5

        for pair in pairs {
            crossOutPair(pair[0], pair[1], reverse: true)

            let userInfo: [String: Int] = ["index": pair[0], "otherIndex": pair[1]]
            after(seconds: delay,
                  performSelector: #selector(RuleExampleGrid.selectAndCrossOutPair(_:)),
                  withUserInfo: userInfo)

            delay += RuleExampleGrid.pairingLoopDuration
        }
    }

    func selectAndCrossOutPair(timer: NSTimer) {
        if let userInfo = timer.userInfo! as? [String: Int] {
            selectCell(userInfo["index"]!)
            after(seconds: 0.7,
                  performSelector: #selector(RuleExampleGrid.crossOutPairWithUserInfo(_:)),
                  withUserInfo: userInfo)
        }
    }

    func crossOutPairWithUserInfo(timer: NSTimer) {
        if let userInfo = timer.userInfo! as? [String: Int] {
            crossOutPair(userInfo["index"]!, userInfo["otherIndex"]!)
        }
    }

    func after(seconds seconds: Double,
               performSelector selector: Selector,
               withUserInfo userInfo: [String: Int]? = nil,
               repeats: Bool = false) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(seconds,
                                                      target: self,
                                                      selector: selector,
                                                      userInfo: userInfo,
                                                      repeats: repeats)

    }

    private func selectCell(index: Int) {
       let indexPath = NSIndexPath(forItem: index, inSection: 0)

        if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
            cell.indicateSelection()
        }
    }

    private func crossOutPair(index: Int, _ otherIndex: Int, reverse: Bool = false) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        let otherIndexPath = NSIndexPath(forItem: otherIndex, inSection: 0)

        for indexPath in [indexPath, otherIndexPath] {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameNumberCell {
                if reverse {
                    cell.unCrossOut()
                } else {
                    cell.crossOut()
                }
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
            cell.crossedOut = crossedOutIndeces.contains(indexPath.item)
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
