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
    case pairings = "PAIRINGS"
    case pairingsWithUndo = "PAIRINGS_WITH_UNDO"
    case pullUp = "PULL_UP"
}

class RuleGrid: Grid {

    private static let pairingLoopDuration: Double = 2.2
    private static let pairingLoopReloadDuration: Double = 2

    private var timers: [Timer] = []
    private let reuseIdentifier = "GameGridCell"
    private var firstPairingDone: Bool = false

    var values: [Int?] = []

    var crossedOutIndeces: [Int] = []
    var pairs: [[Int]] = []
    var gesture = Gesture(type: .swipeRight)

    var animationType: RuleGridAnimationType = .pairings {
        didSet {
            gesture.isHidden = animationType == .pairings

            switch animationType {
            case .pairings:
                return
            case .pairingsWithUndo:
                gesture.type = .swipeRight
            case .pullUp:
                gesture.type = .swipeUpAndHold
            }

        }
    }

    init() {
        super.init(frame: CGRect.zero)

        register(GameGridCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)

        backgroundColor = UIColor.clear
        delegate = self
        dataSource = self
        isUserInteractionEnabled = false
        clipsToBounds = true
        layer.addSublayer(gesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        switch animationType {
        case .pairingsWithUndo:
            gesture.frame = CGRect(origin: CGPoint(x: (bounds.size.width - gesture.totalWidth()) / 2,
                                                   y: (bounds.size.height - Gesture.fingerDiameter) / 2 + 8),
                                   size: CGSize.zero)
        case .pullUp:
            gesture.frame = CGRect(origin: CGPoint(x: (bounds.size.width - Gesture.fingerDiameter) / 2,
                                                   y: bounds.size.height - 30),
                                   size: CGSize.zero)
        default:
            return
        }
    }

    func playLoop() {
        switch animationType {
        case .pairings,
             .pairingsWithUndo:
            // Because the timer interval doesn't allow for the first loop to run immediately,
            // we fire the first one ourselves, and then set an interval for the rest.
            // (We only care about this in the case of pairing animations)
            positionGridForPairing()
            performPairings()

            // swiftlint:disable:next line_length
            _ = after(seconds: Double(pairs.count) * RuleGrid.pairingLoopDuration + RuleGrid.pairingLoopReloadDuration,
                      performSelector: #selector(RuleGrid.performPairings),
                      repeats: true)
        default:
            positionGridForPullUp()

            // We are delaying the first pull up because for some reason the initial offset will
            // be corrupt if we position the grid and immediately pull up.
            _ = after(seconds: 0.1,
                      performSelector: #selector(RuleGrid.pullUp))
            _ = after(seconds: 6,
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

    @objc func pullUp() {
        gesture.perform(withDelay: 1, completion: {
            guard self.animationType == .pullUp else { return }
            self.performActionOnCells(withIndeces: Array(36..<self.values.count), { cell in
                UIView.animate(withDuration: 0.15, delay: 0.4, options: [], animations: {
                    cell.contentView.backgroundColor = UIColor.themeColor(.offWhiteShaded)
                }, completion: nil)
            })
        })

        UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut, animations: {
            self.contentOffset = CGPoint(x: 0, y: -Grid.cellSpacing)
        }, completion: nil)

        _ = after(seconds: 5, performSelector: #selector(RuleGrid.releasePullUp))
    }

    @objc func releasePullUp() {
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

    @objc func performPairings() {
        var delay = RuleGrid.pairingLoopReloadDuration + 0.5

        let resetPairs: (() -> Void) = {
            for pair in self.pairs {
                self.crossOutPair(pair[0], pair[1], reverse: true, animated: false)
            }
        }

        if firstPairingDone {
            prepareToStartOver(completion: resetPairs)
        } else {
            resetPairs()
            firstPairingDone = true
        }

        // We don't use the Pair struct here because it seems we can't pass it
        // around inside a userInfo object (don't know). In any case, no need,
        // we get a list of indeces anyway from the JSON.
        for index in 0..<pairs.count {
            let pair = pairs[index]
            let alternatelyUndoingPairing = index % 2 != 0 && animationType == .pairingsWithUndo

            // Every other pairing should be an undo
            let userInfo: [String: AnyObject] = [
                "index": pair[0] as AnyObject,
                "otherIndex": pair[1] as AnyObject,
                "reverse": alternatelyUndoingPairing as AnyObject
            ]

            let selector = alternatelyUndoingPairing ?
                           #selector(RuleGrid.undoPairing(_:)) :
                           #selector(RuleGrid.selectAndCrossOutPair(_:))

            _ = after(seconds: delay, performSelector: selector, withUserInfo: userInfo)
            delay += RuleGrid.pairingLoopDuration
        }
    }

    private func prepareToStartOver(completion: @escaping (() -> Void)) {
        var dirtyCells = Array(Set(pairs.joined()))
        dirtyCells += crossedOutIndeces

        performActionOnCells(withIndeces: dirtyCells, { cell in
            cell.fadeOutContentMomentarily(forSeconds: 1, whileInvisible: completion)
        })
    }

    @objc func selectAndCrossOutPair(_ timer: Timer) {
        if let userInfo = timer.userInfo! as? [String: AnyObject] {
            selectCell((userInfo["index"]! as? Int)!)
            _ = after(seconds: 0.7,
                      performSelector: #selector(RuleGrid.crossOutPairWithUserInfo(_:)),
                      withUserInfo: userInfo)
        }
    }

    @objc func undoPairing(_ timer: Timer) {
        if let userInfo = timer.userInfo! as? [String: AnyObject] {
            gesture.perform(completion: {
                self.crossOutPair((userInfo["index"]! as? Int)!,
                                  (userInfo["otherIndex"]! as? Int)!,
                                  reverse: (userInfo["reverse"]! as? Bool)!,
                                  animated: true)
            })
        }
    }

    @objc func crossOutPairWithUserInfo(_ timer: Timer) {
        if let userInfo = timer.userInfo! as? [String: AnyObject] {
            crossOutPair((userInfo["index"]! as? Int)!,
                         (userInfo["otherIndex"]! as? Int)!,
                         reverse: (userInfo["reverse"]! as? Bool)!,
                         animated: true)
        }
    }

    func after(seconds: Double,
               performSelector selector: Selector,
               withUserInfo userInfo: [String: AnyObject]? = nil,
               repeats: Bool = false) -> Timer {
        let timer = Timer.scheduledTimer(timeInterval: seconds,
                                                           target: self,
                                                           selector: selector,
                                                           userInfo: userInfo,
                                                           repeats: repeats)

        // This ensures timers are fired while scrolling
        // http://stackoverflow.com/a/2742275/2026098
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)

        timers.append(timer)
        return timer
    }

    private func selectCell(_ index: Int) {
       let indexPath = IndexPath(item: index, section: 0)

        if let cell = cellForItem(at: indexPath) as? GameGridCell {
            cell.indicateSelection()
        }
    }

    private func crossOutPair(_ index: Int, _ otherIndex: Int, reverse: Bool = false, animated: Bool = false) {
        let indexPath = IndexPath(item: index, section: 0)
        let otherIndexPath = IndexPath(item: otherIndex, section: 0)

        for indexPath in [indexPath, otherIndexPath] {
            if let cell = cellForItem(at: indexPath) as? GameGridCell {
                if reverse {
                    cell.unCrossOut(animated: animated)
                } else {
                    cell.crossOut()
                }
            }
        }
    }

    func prepareForReuse() {
        firstPairingDone = false
        gesture.isHidden = animationType == .pairings
        reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RuleGrid: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return values.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                                         for: indexPath)

        if let cell = cell as? GameGridCell {
            cell.value = values[indexPath.item]
            cell.state = crossedOutIndeces.contains(indexPath.item) ? .crossedOut : .available
            cell.marksEndOfRound = false
            cell.lightColor = UIColor.themeColor(.offWhiteShaded)

            if animationType == .pullUp {
                if indexPath.item == 35 {
                   cell.marksEndOfRound = true
                } else if indexPath.item > 35 {
                   cell.lightColor = UIColor.themeColor(.secondaryAccent)
                }
            }

            cell.resetColors()
        }

        return cell
    }

}

extension RuleGrid: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Grid.cellSize(forAvailableWidth: bounds.size.width)
    }
}
