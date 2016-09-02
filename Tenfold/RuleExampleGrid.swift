//
//  RuleExampleGrid.swift
//  Tenfold
//
//  Created by Elise Hein on 19/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class RuleExampleGrid: Grid {

    private static let pairingLoopDuration: Double = 2.2

    private var timers: Array<NSTimer> = []
    private let reuseIdentifier = "GameGridCell"

    var values: Array<Int?> = []

    var crossedOutIndeces: Array<Int> = []
    var pairs: Array<[Int]> = []

    // These must match the vocabulary used in instructions.json
    static let animationTypePairings = "PAIRINGS"
    static let animationTypePullUp = "PULL_UP"

    var animationType: String = RuleExampleGrid.animationTypePairings

    init() {
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.clearColor()
        delegate = self
        dataSource = self
        userInteractionEnabled = false
        clipsToBounds = true

        registerClass(GameGridCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
    }

    func playLoop() {
        if animationType == RuleExampleGrid.animationTypePairings {
            // Because the timer interval doesn't allow for the first loop to run immediately,
            // we fire the first one ourselves, and then set an interval for the rest.
            // (We only care about this in the case of pairing animations)
            positionGridForPairing()
            performPairings()
            after(seconds: Double(pairs.count) * RuleExampleGrid.pairingLoopDuration,
                  performSelector: #selector(RuleExampleGrid.performPairings),
                  repeats: true)
        } else {
            positionGridForPullUp()
            after(seconds: 3,
                  performSelector: #selector(RuleExampleGrid.pullUp),
                  repeats: true)
        }
    }

    func invalidateLoop() {
        for timer in timers {
            timer.invalidate()
        }

        timers = []
    }

    func pullUp() {
        setContentOffset(CGPoint(x: 0, y: Grid.cellSpacing), animated: true)
        after(seconds: 2, performSelector: #selector(RuleExampleGrid.releasePullUp))
    }

    func releasePullUp() {
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
    }

    private func positionGridForPullUp() {
        let cellHeight = Grid.cellSize(forAvailableWidth: bounds.size.width).height
        contentInset.top = cellHeight
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: false)
    }

    private func positionGridForPairing() {
        contentInset.top = 0
        setContentOffset(CGPoint.zero, animated: false)
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
        let timer = NSTimer.scheduledTimerWithTimeInterval(seconds,
                                                           target: self,
                                                           selector: selector,
                                                           userInfo: userInfo,
                                                           repeats: repeats)

        // This ensures timers are fired while scrolling
        // http://stackoverflow.com/a/2742275/2026098
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

        timers.append(timer)
        return timer
    }

    private func selectCell(index: Int) {
       let indexPath = NSIndexPath(forItem: index, inSection: 0)

        if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
            cell.indicateSelection()
        }
    }

    private func crossOutPair(index: Int, _ otherIndex: Int, reverse: Bool = false) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        let otherIndexPath = NSIndexPath(forItem: otherIndex, inSection: 0)

        for indexPath in [indexPath, otherIndexPath] {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
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

        if let cell = cell as? GameGridCell {
            cell.value = values[indexPath.item]
            cell.crossedOut = crossedOutIndeces.contains(indexPath.item)
            cell.marksEndOfRound = false
            cell.defaultBackgroundColor = UIColor.themeColor(.OffWhiteShaded)

            // We are dependent on the fact that Pairing animation type example values
            // always has three rows, and PullUp animation type example always has four.
            if animationType == RuleExampleGrid.animationTypePullUp {
                if indexPath.item == 26 {
                   cell.marksEndOfRound = true
                } else if indexPath.item > 26 {
                   cell.defaultBackgroundColor = UIColor.themeColor(.SecondaryAccent)
                }
            }

            cell.resetColors()
        }

        return cell
    }

}

extension RuleExampleGrid: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Grid.cellSize(forAvailableWidth: bounds.size.width)
    }
}
