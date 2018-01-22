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
    let reuseIdentifier = "GameGridCell"

    var game: Game
    var snappingInProgress = false
    var bouncingInProgress = false
    var currentScrollCycleHandled = false

    var gridAtStartingPosition = true
    var automaticallySnapToGameplayPosition = true

    var pullUpThreshold: CGFloat?
    var snapToStartingPositionThreshold: CGFloat?
    var snapToGameplayPositionThreshold: CGFloat?

    var spaceForScore: CGFloat = 0

    var onScroll: (() -> Void)?
    var onPullingDown: ((_ withFraction: CGFloat) -> Void)?
    var onPullingUpFromStartingPosition: ((_ withFraction: CGFloat) -> Void)?
    var onPullUpThresholdExceeded: (() -> Void)?
    var onWillSnapToGameplayPosition: (() -> Void)?
    var onDidSnapToGameplayPosition: (() -> Void)?
    var onWillSnapToStartingPosition: (() -> Void)?
    var onPairingAttempt: ((Pair) -> Void)?

    static let scaleFactor = UIScreen.main.scale
    static let prematureBounceReductionFactor: CGFloat = 0.2

    var prevPrematureBounceOffset: CGFloat = 0
    var totalPrematureBounceDistance: CGFloat = 0

    // Selection and deselection are the core of the game. But because a UICollectionView
    // cannot deselect items that are not currently visible (which can often be required for us,
    // say when pairing two items so far from each other that they cannot be seen on screen
    // at the same time), it's easier to keep track of selection ourselves, rather than natively
    var selectedIndexPaths: [IndexPath] = []
    var indecesPermittedForSelection: [Int]?

    // When you scroll while row insertion or removal is in progress, cellForItemWithIndexPath will
    // for some reason get corrupt data. We can disable user interaction completely to also
    // capture cases where selections happen too fast.
    var rowRemovalInProgress = false {
        didSet {
            isUserInteractionEnabled = !rowRemovalInProgress
        }
    }

    var rowInsertionInProgressWithIndeces: [Int]? = nil {
        didSet {
            isUserInteractionEnabled = rowInsertionInProgressWithIndeces == nil
        }
    }

    init(game: Game) {
        self.game = game

        super.init(frame: CGRect.zero)

        register(GameGridCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        backgroundColor = UIColor.clear
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
    }

    override func initialisePositionWithinFrame(_ givenFrame: CGRect, withInsets insets: UIEdgeInsets) {
        super.initialisePositionWithinFrame(givenFrame, withInsets: insets)

        // Whatever the game state, we initially start with 3 rows showing
        // in the bottom of the view
        adjustTopInset(enforceStartingPosition: true)
    }

    func toggleBounce(_ shouldBounce: Bool) {
        guard !snappingInProgress else { return }

        // We should *never* disable bounce if there is more space above the grid than is needed for the score
        // otherwise we can't pull up from the first rounds where the grid isn't full screen yet
        bounces = contentInset.top > spaceForScore || shouldBounce
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
