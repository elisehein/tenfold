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

    internal static let scaleFactor = UIScreen.mainScreen().scale
    internal static let prematureBounceReductionFactor: CGFloat = 0.2

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

    internal func toggleBounce(shouldBounce: Bool) {
        guard !snappingInProgress else { return }

        // We should *never* disable bounce if there is a top contentInset
        // otherwise we can't pull up from the first rounds where the grid isn't full screen yet
        bounces = contentInset.top > 0 || shouldBounce
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
