//
//  GameGrid.swift
//  Tenfold
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameGrid: Grid {

    internal let reuseIdentifier = "GameGridCell"

    internal var game: Game

    var gridAtStartingPosition = true
    var snappingInProgress = false
    var automaticallySnapToGameplayPosition = true

    internal var bouncingInProgress = false
    internal var currentScrollCycleHandled = false

    var pullUpThreshold: CGFloat?
    var snapToStartingPositionThreshold: CGFloat?
    var snapToGameplayPositionThreshold: CGFloat?

    var onScroll: (() -> Void)?
    var onPullUpThresholdExceeded: (() -> Void)?
    var onWillSnapToGameplayPosition: (() -> Void)?
    var onWillSnapToStartingPosition: (() -> Void)?
    var onPairingAttempt: ((itemIndex: Int, otherItemIndex: Int) -> Void)?

    private static let scaleFactor = UIScreen.mainScreen().scale
    private static let prematureBounceReductionFactor: CGFloat = 0.2

    internal var prevPrematureBounceOffset: CGFloat = 0
    internal var totalPrematureBounceDistance: CGFloat = 0

    // Selection and deselection are the core of the game. But because a UICollectionView
    // cannot deselect items that are not currently visible (which can often be required for us,
    // say when pairing two items so far from each other that they cannot be seen on screen
    // at the same time), it's easier to keep track of selection ourselves, rather than natively
    internal var selectedIndexPaths: Array<NSIndexPath> = []

    var indecesPermittedForSelection: Array<Int>? = nil

    init(game: Game) {
        self.game = game

        super.init(frame: CGRect.zero)

        registerClass(GameGridCell.self,
                      forCellWithReuseIdentifier: self.reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
    }

    override func initialisePositionWithinFrame(givenFrame: CGRect,
                                                withInsets insets: UIEdgeInsets) {
        super.initialisePositionWithinFrame(givenFrame, withInsets: insets)

        // Whatever the game state, we initially start with 3 rows showing
        // in the bottom of the view
        adjustTopInset(enforceStartingPosition: true)
    }

    // MARK: Gameplay logic

    func restart(withGame newGame: Game, animated: Bool = true, completion: (() -> Void)? = nil) {
        UIView.animateWithDuration(animated ? 0.2 : 0,
                                   delay: 0,
                                   options: .CurveEaseIn,
                                   animations: {
            self.alpha = 0
            self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
                                                        0,
                                                        self.initialGameHeight() * 0.3)
        }, completion: { _ in
            self.game = newGame
            self.reloadData()
            self.transform = CGAffineTransformIdentity
            self.adjustTopInset(enforceStartingPosition: true)

            UIView.animateWithDuration(0.15, delay: 0.2, options: .CurveEaseIn, animations: {
                self.alpha = 1
            }, completion: { _ in
                completion?()
            })
        })
    }

    func loadNextRound(atIndeces indeces: Array<Int>, completion: ((Bool) -> Void)?) {
        var indexPaths: Array<NSIndexPath> = []

        for index in indeces {
           indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
        }

        insertItemsAtIndexPaths(indexPaths)
        performBatchUpdates(nil, completion: { finished in
            self.adjustTopInset()
            completion?(finished)
        })
    }

    func crossOutPair(index: Int, otherIndex: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        let otherIndexPath = NSIndexPath(forItem: otherIndex, inSection: 0)
        let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell
        let otherCell = cellForItemAtIndexPath(otherIndexPath) as? GameGridCell

        // These need to be checked separately, as one cell may be visible
        // while the other is not (in which case it is nil). We still want to
        // cross out the visible one
        if cell != nil { cell!.crossOut() }
        if otherCell != nil { otherCell!.crossOut() }
    }

    func dismissSelection() {
        for indexPath in selectedIndexPaths {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
                if indexPath == selectedIndexPaths.last {
                    cell.indicateSelection()
                }
                cell.indicateSelectionFailure()
            }
        }
    }

    func removeNumbers(atIndexPaths indexPaths: Array<NSIndexPath>, completion: (() -> Void)) {
        guard indexPaths.count > 0 else { return }

        adjustTopInset()
        if contentInset.top > 0 {
            setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
        }

        var removalHandled = false
        prepareForRemoval(indexPaths, completion: {
            if !removalHandled {
                self.deleteItemsAtIndexPaths(indexPaths)

                if self.game.totalNumbers() > 0 {
                    let lastIndexPath = NSIndexPath(forItem: self.game.totalNumbers() - 1,
                        inSection: 0)
                    self.reloadItemsAtIndexPaths([lastIndexPath])
                }

                removalHandled = true
                completion()
            }
        })
    }

    private func prepareForRemoval(indexPaths: Array<NSIndexPath>, completion: (() -> Void)) {
        for indexPath in indexPaths {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
                cell.prepareForRemoval(completion: completion)
            } else {
                completion()
            }
        }
    }

    func flashNumbers(atIndeces indeces: Array<Int>) {
        for index in indeces {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
                cell.flash()
            }
        }
    }

    // MARK: Top insets and visible space considering scroll state

    // Empty space visible should be capped to depend on the initial game height (3 rows);
    // it should still account for three game rows even if the actual game is only 1 or two
    // This is why we don't simply call topInset() – top inset may be different than empty space
    // visible at starting position
    func emptySpaceVisible(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        return atStartingPosition ?
               frame.size.height - initialGameHeight() :
               -contentOffset.y
    }

    func pullUpFromStartingPositionInProgress() -> Bool {
        return gridAtStartingPosition && (pullUpInProgress() || prematurePullUpInProgress())
    }

    func pullUpDistanceFromStartingPosition() -> CGFloat {
        return prematurePullUpInProgress() ? contentDistanceFromTopEdge() : distancePulledUp()
    }

    internal func adjustTopInset(enforceStartingPosition enforceStartingPosition: Bool = false) {
        contentInset.top = topInset(atStartingPosition: enforceStartingPosition)
        gridAtStartingPosition = enforceStartingPosition
        toggleBounce(contentInset.top > 0)
    }

    private func topInset(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        if atStartingPosition {
            return frame.size.height - min(initialGameHeight(), currentGameHeight())
        } else {
            return max(0, frame.size.height - currentGameHeight())
        }
    }

    private func initialGameHeight() -> CGFloat {
        return Grid.heightForGame(withTotalRows: 3, availableWidth: bounds.size.width)
    }

    private func currentGameHeight() -> CGFloat {
        return Grid.heightForGame(withTotalRows: game.totalRows(),
                                  availableWidth: bounds.size.width)
    }

    internal func ensureGridPositionedForGameplay() {
        guard gridAtStartingPosition else { return }
        positionGridForGameplay()
    }

    func positionGridForGameplay() {
        guard automaticallySnapToGameplayPosition else { return }

        // This handler needs to be called *before* the animation block,
        // otherwise it will for some reason push it to a later thread
        onWillSnapToGameplayPosition?()

        // We're not calling toggleBounce here because it overrides false
        // whenever there is a top inset – which is always true in startingPosition.
        // We simply want to disable bounce for the duration of the animation
        // so that we don't flash the next round grid in the bottom of the screen.
        bounces = false
        snappingInProgress = true

        // The reason this looks so obscure is because scroll views are SHIT.
        // This specific combination of setting an inset and offset is the only one
        // that results in an animation that STOPS when it reaches the top of the view
        let nextTopInset = self.topInset()
        UIView.animateWithDuration(0.3, animations: {
            self.contentInset.top = nextTopInset
            self.setContentOffset(CGPoint(x: 0, y: -nextTopInset), animated: false)
        }, completion: { _ in
            self.snappingInProgress = false
            self.toggleBounce(self.contentInset.top > 0)
            self.gridAtStartingPosition = false
        })
    }

    internal func prematurePullUpDistanceExceeds(threshold: CGFloat) -> Bool {
        return prematurePullUpInProgress() && contentDistanceFromTopEdge() > threshold
    }

    internal func toggleBounce(shouldBounce: Bool) {
        guard !snappingInProgress else { return }

        // We should *never* disable bounce if there is a top contentInset
        // otherwise we can't pull up from the first rounds where the grid isn't full screen yet
        bounces = contentInset.top > 0 || shouldBounce
    }

    internal func interjectBounce (scrollView: UIScrollView) {
        let currentOffset = round(contentOffset.y + contentInset.top)
        guard currentOffset > 0 else { return }

        if currentOffset >= prevPrematureBounceOffset {
            totalPrematureBounceDistance += currentOffset - prevPrematureBounceOffset
            prevPrematureBounceOffset = round(GameGrid.scaleFactor
                                              * totalPrematureBounceDistance
                                              * GameGrid.prematureBounceReductionFactor)
                                        / GameGrid.scaleFactor
            let y = prevPrematureBounceOffset - contentInset.top
            contentOffset.y = y
        } else {
            totalPrematureBounceDistance = currentOffset / GameGrid.prematureBounceReductionFactor
            prevPrematureBounceOffset = currentOffset
        }
    }

    internal func bounceBack() {
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
    }

    // This refers to whether we disallow scrolling beyond what is visible on the screen,
    // and show a bounce effect instead. This essentially allows a bounce effect to happen
    // even though we haven't reached the bottom of the content yet.
    // http://stackoverflow.com/questions/20437657/increasing-uiscrollview-rubber-banding-resistance
    internal func prematurePullUpInProgress() -> Bool {
        // We only want to create a simulated bounce if we would see extra content underneath
        // the "fold". If the current content size isn't big enough to show anything
        // extra, we would get a native bounce anyway.
        return !pullDownInProgress() &&
               gridAtStartingPosition &&
               contentSize.height > (frame.size.height - contentInset.top)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
