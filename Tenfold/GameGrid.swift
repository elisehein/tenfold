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
    internal var snappingInProgress = false
    internal var bouncingInProgress = false
    internal var currentScrollCycleHandled = false

    var gridAtStartingPosition = true
    var automaticallySnapToGameplayPosition = true

    internal var pullUpThreshold: CGFloat?
    var snapToStartingPositionThreshold: CGFloat?
    var snapToGameplayPositionThreshold: CGFloat?

    var onScroll: (() -> Void)?
    var onPullingDown: ((withFraction: CGFloat) -> Void)?
    var onPullingUpFromStartingPosition: ((withFraction: CGFloat) -> Void)?
    var onPullUpThresholdExceeded: (() -> Void)?
    var onWillSnapToGameplayPosition: (() -> Void)?
    var onWillSnapToStartingPosition: (() -> Void)?
    var onPairingAttempt: ((Pair) -> Void)?

    private static let scaleFactor = UIScreen.mainScreen().scale
    private static let prematureBounceReductionFactor: CGFloat = 0.2

    internal var prevPrematureBounceOffset: CGFloat = 0
    internal var totalPrematureBounceDistance: CGFloat = 0

    // Selection and deselection are the core of the game. But because a UICollectionView
    // cannot deselect items that are not currently visible (which can often be required for us,
    // say when pairing two items so far from each other that they cannot be seen on screen
    // at the same time), it's easier to keep track of selection ourselves, rather than natively
    internal var selectedIndexPaths: [NSIndexPath] = []
    internal var indecesPermittedForSelection: [Int]? = nil

    // When you scroll while row insertion or removal is in progress, cellForItemWithIndexPath will
    // for some reason get corrupt data. We can disable user interaction completely to also
    // capture cases where selections happen too fast.
    var rowRemovalInProgress = false {
        didSet {
            userInteractionEnabled = !rowRemovalInProgress
        }
    }

    internal var rowInsertionInProgressWithIndeces: [Int]? = nil {
        didSet {
            userInteractionEnabled = rowInsertionInProgressWithIndeces == nil
        }
    }

    init(game: Game) {
        self.game = game

        super.init(frame: CGRect.zero)

        registerClass(GameGridCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
    }

    override func initialisePositionWithinFrame(givenFrame: CGRect, withInsets insets: UIEdgeInsets) {
        super.initialisePositionWithinFrame(givenFrame, withInsets: insets)

        // Whatever the game state, we initially start with 3 rows showing
        // in the bottom of the view
        adjustTopInset(enforceStartingPosition: true)
    }

    // MARK: Gameplay logic

    func restart(withGame newGame: Game,
                 animated: Bool = true,
                 enforceStartingPosition: Bool = true,
                 completion: (() -> Void)? = nil) {
        selectedIndexPaths.removeAll()

        if animated {
            hideCurrentGame({
                self.transform = CGAffineTransformIdentity
                self.loadNewGame(newGame, enforceStartingPosition: enforceStartingPosition)
                self.showCurrentGame(completion)
            })
        } else {
            loadNewGame(newGame, enforceStartingPosition: enforceStartingPosition)
            completion?()
        }
    }

    private func hideCurrentGame(completion: (() -> Void)) {
        UIView.animateWithDuration(0.2,
                                   delay: 0,
                                   options: .CurveEaseIn,
                                   animations: {
            self.alpha = 0
            self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
                                                        0,
                                                        self.initialGameHeight() * 0.3)
        }, completion: { _ in
            completion()
        })
    }

    private func showCurrentGame(completion: (() -> Void)?) {
        UIView.animateWithDuration(0.15, delay: 0.2, options: .CurveEaseIn, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }

    private func loadNewGame(newGame: Game, enforceStartingPosition: Bool) {
        self.game = newGame
        self.reloadData()
        self.adjustTopInset(enforceStartingPosition: enforceStartingPosition)
    }

    func loadNextRound(atIndeces indeces: [Int], completion: ((Bool) -> Void)?) {
        var indexPaths: [NSIndexPath] = []

        for index in indeces {
           indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
        }

        insertItemsAtIndexPaths(indexPaths)
        performBatchUpdates(nil, completion: { finished in
            self.adjustTopInset()
            // In case our end of round marker got lost with row removals, ensure
            // it's there just before adding the next round
            self.reloadItemsAtIndexPaths([NSIndexPath(forItem: indeces[0] - 1, inSection: 0)])
            completion?(finished)
        })
    }

    func cellState(forCellAtIndexPath indexPath: NSIndexPath) -> GameGridCellState {
        if game.isCrossedOut(indexPath.item) {
            return .CrossedOut
        } else if selectedIndexPaths.contains(indexPath) {
            return .PendingPairing
        } else {
            return .Available
        }
    }

    func crossOut(pair: Pair) {
        performActionOnCells(withIndeces: pair.asArray(), { cell in
            cell.crossOut()
        })
    }

    func unCrossOut(pair: Pair, withDelay delay: Double) {
        performActionOnCells(withIndeces: pair.asArray(), { cell in
            cell.unCrossOut(withDelay: delay, animated: true)
        })
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

    func removeRows(withNumberIndeces indeces: [Int], completion: (() -> Void)) {
        guard indeces.count > 0 else { return }
        rowRemovalInProgress = true

        let indexPaths = indeces.map({ NSIndexPath(forItem: $0, inSection: 0) })

        adjustTopInset()
        adjustTopOffsetInAnticipationOfCellCountChange(indeces)

        prepareForRemoval(indexPaths, completion: {
            if self.rowRemovalInProgress {
                self.deleteItemsAtIndexPaths(indexPaths)

                if self.contentInset.top > 0 {
                    self.setContentOffset(CGPoint(x: 0, y: -self.contentInset.top), animated: true)
                }

                self.rowRemovalInProgress = false
                completion()
            }
        })
    }

    func addRows(atIndeces indeces: [Int], completion: (() -> Void)) {
        guard indeces.count > 0 else { return }
        rowInsertionInProgressWithIndeces = indeces

        let indexPaths = indeces.map({ NSIndexPath(forItem: $0, inSection: 0) })
        adjustTopOffsetInAnticipationOfCellCountChange(indeces)

        performBatchUpdates({
            self.insertItemsAtIndexPaths(indexPaths)
        }, completion: { finished in
            self.adjustTopInset()
            self.revealCellsAtIndeces(indeces)
            completion()
        })
    }

    private func revealCellsAtIndeces(indeces: [Int]) {
        rowInsertionInProgressWithIndeces = nil

        performActionOnCells(withIndeces: indeces, { cell in
            cell.aboutToBeRevealed = false
        })
    }

    private func prepareForRemoval(indexPaths: [NSIndexPath], completion: (() -> Void)) {
        for indexPath in indexPaths {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
                cell.prepareForRemoval(completion: completion)
            } else {
                completion()
            }
        }
    }

    func flashNumbers(atIndeces indeces: [Int],
                      withColor color: UIColor) {
        performActionOnCells(withIndeces: indeces, { cell in
            cell.flash(withColor: color)
        })
    }

    private func performActionOnCells(withIndeces indeces: [Int],
                                      _ action: ((GameGridCell) -> Void)) {

        // Each cell's existence need to be checked separately, as one cell may
        // be visible while the other is not (in which case it is nil). We still
        // want to
        // cross out the visible one
        for index in indeces {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)

            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
                action(cell)
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

    private func adjustTopOffsetInAnticipationOfCellCountChange(indeces: [Int]) {
        // For some reason something funky happens when we're adding stuff
        // to the very end of the game... in this case, adjusting top offset
        // just makes it behave oddly
        if game.indecesOverlapTailIndeces(indeces) {
            return
        }

        if contentInset.top > 0 {
            let rowDelta = Matrix.singleton.totalRows(indeces.count)
            let gameHeightDelta = heightForGame(withTotalRows: rowDelta)
            setContentOffset(CGPoint(x: 0, y: -contentInset.top + gameHeightDelta), animated: true)
        }
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
        let initialRows = Matrix.singleton.totalRows(Game.initialNumberValues.count)
        return heightForGame(withTotalRows: initialRows)
    }

    private func currentGameHeight() -> CGFloat {
        return heightForGame(withTotalRows: game.totalRows())
    }

    internal func ensureGridPositionedForGameplay() {
        positionGridForGameplay()
    }

    func positionGridForGameplay() {
        guard automaticallySnapToGameplayPosition else { return }

        // This handler needs to be called *before* the animation block,
        // in positionGridForGameplay() otherwise it will for some reason
        // push it to a later thread
        onWillSnapToGameplayPosition?()

        // This next guard should be before we call onWillSnapToGameplayPosition(),
        // but after returning from onboarding we have a situation where the grid
        // is *not* at the starting position, but we need to hide the menu anyway
        // (which is done in the handler).
        // For the time being there are no negative side effects to calling the handler
        // too often – it only really sets a background colour.
        guard gridAtStartingPosition else { return }

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
