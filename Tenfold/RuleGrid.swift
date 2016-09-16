//
//  RuleGrid.swift
//  Tenfold
//
//  Created by Elise Hein on 19/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

// These must match the vocabulary used in instructions.json
enum RuleGridAnimationType: String {
    case Pairings = "PAIRINGS"
    case PairingsWithUndo = "PAIRINGS_WITH_UNDO"
    case PullUp = "PULL_UP"
}

class RuleGrid: Grid {

    private static let pairingLoopDuration: Double = 2.2
    private static let pairingLoopReloadDuration: Double = 2

    private var timers: [NSTimer] = []
    private let reuseIdentifier = "GameGridCell"

    var values: [Int?] = []

    var crossedOutIndeces: [Int] = []
    var pairs: [[Int]] = []
    var gesture: Gesture?

    var animationType: RuleGridAnimationType = .Pairings {
        didSet {
            guard animationType != .Pairings else { return }

            if animationType == .PairingsWithUndo {
                gesture = Gesture(type: .SwipeRight)
            } else if animationType == .PullUp {
                gesture = Gesture(type: .SwipeUpAndHold)
            }

            layer.addSublayer(gesture!)
            gesture!.hidden = animationType == .Pairings
        }
    }

    init() {
        super.init(frame: CGRect.zero)

        registerClass(GameGridCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)

        backgroundColor = UIColor.clearColor()
        delegate = self
        dataSource = self
        userInteractionEnabled = false
        clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if animationType == .PairingsWithUndo {
            gesture!.frame = CGRect(origin: CGPoint(x: (bounds.size.width - Gesture.totalWidth) / 2,
                                                    y: (bounds.size.height - Gesture.totalHeight) / 2 + 8),
                                   size: CGSize.zero)
        } else if animationType == .PullUp {
            gesture!.frame = CGRect(origin: CGPoint(x: bounds.size.width * 0.75,
                                                    y: bounds.size.height - 30),
                                   size: CGSize.zero)
        }
    }

    func playLoop() {
        if animationType == .Pairings || animationType == .PairingsWithUndo {
            // Because the timer interval doesn't allow for the first loop to run immediately,
            // we fire the first one ourselves, and then set an interval for the rest.
            // (We only care about this in the case of pairing animations)
            positionGridForPairing()
            performPairings()

            // swiftlint:disable:next line_length
            after(seconds: Double(pairs.count) * RuleGrid.pairingLoopDuration + RuleGrid.pairingLoopReloadDuration,
                  performSelector: #selector(RuleGrid.performPairings),
                  repeats: true)
        } else {
            positionGridForPullUp()

            // We are delaying the first pull up because for some reason the initial offset will
            // be corrupt if we position the grid and immediately pull up.
            after(seconds: 0.1,
                  performSelector: #selector(RuleGrid.pullUp))
            after(seconds: 6,
                  performSelector: #selector(RuleGrid.pullUp),
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
        gesture!.perform(withDelay: 1, completion: {
            self.performActionOnCells(withIndeces: Array(36..<self.values.count), { cell in
                UIView.animateWithDuration(0.15, delay: 0.55, options: [], animations: {
                    cell.contentView.backgroundColor = UIColor.themeColor(.OffWhiteShaded)
                }, completion: nil)
            })
        })

        UIView.animateWithDuration(0.5, delay: 1, options: .CurveEaseOut, animations: {
            self.contentOffset = CGPoint(x: 0, y: -Grid.cellSpacing)
        }, completion: nil)

        after(seconds: 5, performSelector: #selector(RuleGrid.releasePullUp))
    }

    func releasePullUp() {
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
    }

    private func positionGridForPullUp() {
        let cellHeight = Grid.cellSize(forAvailableWidth: bounds.size.width).height
        contentInset.top = 2 * cellHeight + CGFloat(Grid.cellSpacing)
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: false)
    }

    private func positionGridForPairing() {
        contentInset.top = 0
        setContentOffset(CGPoint.zero, animated: false)
    }

    func performPairings() {
        var delay = RuleGrid.pairingLoopReloadDuration + 0.5

        prepareToStartOver()

        // We don't use the Pair struct here because it seems we can't pass it
        // around inside a userInfo object (don't know). In any case, no need,
        // we get a list of indeces anyway from the JSON.
        for index in 0..<pairs.count {
            let pair = pairs[index]
            let alternatelyUndoingPairing = index % 2 != 0 && animationType == .PairingsWithUndo

            // Every other pairing should be an undo
            let userInfo: [String: AnyObject] = [
                "index": pair[0],
                "otherIndex": pair[1],
                "reverse": alternatelyUndoingPairing
            ]

            let selector = alternatelyUndoingPairing ?
                           #selector(RuleGrid.undoPairing(_:)) :
                           #selector(RuleGrid.selectAndCrossOutPair(_:))

            after(seconds: delay, performSelector: selector, withUserInfo: userInfo)
            delay += RuleGrid.pairingLoopDuration
        }
    }

    private func prepareToStartOver() {
        var dirtyCells = Array(Set(pairs.flatten()))
        dirtyCells += crossedOutIndeces

        performActionOnCells(withIndeces: dirtyCells, { cell in
            cell.fadeOutContentMomentarily(forSeconds: 1,
                                           whileInvisible: {
                for pair in self.pairs {
                    self.crossOutPair(pair[0], pair[1], reverse: true, animated: false)
                }
            })
        })
    }

    func selectAndCrossOutPair(timer: NSTimer) {
        if let userInfo = timer.userInfo! as? [String: AnyObject] {
            selectCell((userInfo["index"]! as? Int)!)
            after(seconds: 0.7,
                  performSelector: #selector(RuleGrid.crossOutPairWithUserInfo(_:)),
                  withUserInfo: userInfo)
        }
    }

    func undoPairing(timer: NSTimer) {
        if let userInfo = timer.userInfo! as? [String: AnyObject] {
            gesture!.perform(completion: {
                self.crossOutPair((userInfo["index"]! as? Int)!,
                                  (userInfo["otherIndex"]! as? Int)!,
                                  reverse: (userInfo["reverse"]! as? Bool)!,
                                  animated: true)
            })
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

    func prepareForReuse() {
        reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RuleGrid: UICollectionViewDataSource {
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
                if indexPath.item == 35 {
                   cell.marksEndOfRound = true
                } else if indexPath.item > 35 {
                   cell.lightColor = UIColor.themeColor(.SecondaryAccent)
                }
            }

            cell.resetColors()
        }

        return cell
    }

}

extension RuleGrid: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Grid.cellSize(forAvailableWidth: bounds.size.width)
    }
}
