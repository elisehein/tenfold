//
//  RuleExampleGrid.swift
//  Tenfold
//
//  Created by Elise Hein on 19/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

// These must match the vocabulary used in instructions.json
enum RuleExampleGridAnimationType: String {
    case Pairings = "PAIRINGS"
    case PairingsWithUndo = "PAIRINGS_WITH_UNDO"
    case PullUp = "PULL_UP"
}

class RuleExampleGrid: Grid {

    private static let pairingLoopDuration: Double = 2.2

    private var timers: [NSTimer] = []
    private let reuseIdentifier = "GameGridCell"

    var values: [Int?] = []

    var crossedOutIndeces: [Int] = []
    var pairs: [[Int]] = []

    var animationType: RuleExampleGridAnimationType = .Pairings

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
        if animationType == .Pairings || animationType == .PairingsWithUndo {
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

        // We don't use the Pair struct here because it seems we can't pass it
        // around inside a userInfo object (don't know). In any case, no need,
        // we get a list of indeces anyway from the JSON.
        for index in 0..<pairs.count {
            let pair = pairs[index]
            let alternatelyUndoingPairing = index % 2 != 0 && animationType == .PairingsWithUndo

            crossOutPair(pair[0], pair[1], reverse: true, animated: false)

            // Every other pairing should be an undo
            let userInfo: [String: AnyObject] = [
                "index": pair[0],
                "otherIndex": pair[1],
                "reverse": alternatelyUndoingPairing
            ]

            let selector = alternatelyUndoingPairing ?
                           #selector(RuleExampleGrid.undoPairing(_:)) :
                           #selector(RuleExampleGrid.selectAndCrossOutPair(_:))

            after(seconds: delay, performSelector: selector, withUserInfo: userInfo)
            delay += RuleExampleGrid.pairingLoopDuration
        }
    }

    func selectAndCrossOutPair(timer: NSTimer) {
        if let userInfo = timer.userInfo! as? [String: AnyObject] {
            selectCell((userInfo["index"]! as? Int)!)
            after(seconds: 0.7,
                  performSelector: #selector(RuleExampleGrid.crossOutPairWithUserInfo(_:)),
                  withUserInfo: userInfo)
        }
    }

    func undoPairing(timer: NSTimer) {
        if let userInfo = timer.userInfo! as? [String: AnyObject] {
            after(seconds: 0.7,
                  performSelector: #selector(RuleExampleGrid.crossOutPairWithUserInfo(_:)),
                  withUserInfo: userInfo)
        }
    }

    func crossOutPairWithUserInfo(timer: NSTimer) {
        if let userInfo = timer.userInfo! as? [String: AnyObject] {
            crossOutPair((userInfo["index"]! as? Int)!,
                         (userInfo["otherIndex"]! as? Int)!,
                         reverse: (userInfo["reverse"]! as? Bool)!,
                         animated: true)
        }
    }

    func after(seconds seconds: Double,
               performSelector selector: Selector,
               withUserInfo userInfo: [String: AnyObject]? = nil,
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

    private func crossOutPair(index: Int, _ otherIndex: Int, reverse: Bool = false, animated: Bool = false) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        let otherIndexPath = NSIndexPath(forItem: otherIndex, inSection: 0)

        for indexPath in [indexPath, otherIndexPath] {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
                if reverse {
                    cell.unCrossOut(animated: animated)
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
            cell.state = crossedOutIndeces.contains(indexPath.item) ? .CrossedOut : .Available
            cell.marksEndOfRound = false
            cell.lightColor = UIColor.themeColor(.OffWhiteShaded)

            if animationType == .PullUp {
                if indexPath.item == 26 {
                   cell.marksEndOfRound = true
                } else if indexPath.item > 26 {
                   cell.lightColor = UIColor.themeColor(.SecondaryAccent)
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
