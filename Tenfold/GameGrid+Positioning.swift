//
//  GameGrid+Positioning.swift
//  Tenfold
//
//  Created by Elise Hein on 15/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

extension GameGrid {

    // Empty space visible should be capped to depend on the initial game height (3 rows);
    // it should still account for three game rows even if the actual game is only 1 or two
    // This is why we don't simply call topInset() – top inset may be different than empty space
    // visible at starting position
    func emptySpaceVisible(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        return atStartingPosition ?
               frame.size.height - initialGameHeight() :
               -contentOffset.y
    }

    func scrolledToTop() -> Bool {
        return contentOffset.y <= -spaceForScore
    }

    func scrollToTopIfPossible() {
        guard contentInset.top == spaceForScore && !scrolledToTop() else { return }
        setContentOffset(CGPoint(x: 0, y: -spaceForScore), animated: true)
    }

    func adjustTopInset(enforceStartingPosition enforceStartingPosition: Bool = false) {
        contentInset.top = topInset(atStartingPosition: enforceStartingPosition)
        gridAtStartingPosition = enforceStartingPosition
        toggleBounce(contentInset.top > spaceForScore)
    }

    func initialGameHeight() -> CGFloat {
        let initialRows = Matrix.singleton.totalRows(Game.initialNumberValues.count)
        return heightForGame(withTotalRows: initialRows)
    }

    func ensureGridPositionedForGameplay() {
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
            self.toggleBounce(self.contentInset.top > self.spaceForScore)
            self.gridAtStartingPosition = false
            self.onDidSnapToGameplayPosition?()
        })
    }

}

// MARK: Positioning helpers

private extension GameGrid {

    func currentGameHeight() -> CGFloat {
        return heightForGame(withTotalRows: game.totalRows())
    }

    func topInset(atStartingPosition atStartingPosition: Bool = false) -> CGFloat {
        if atStartingPosition {
            return frame.size.height - min(initialGameHeight(), currentGameHeight())
        } else {
            return max(spaceForScore, frame.size.height - currentGameHeight())
        }
    }
}
