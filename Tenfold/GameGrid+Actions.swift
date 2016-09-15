//
//  GameGrid+Actions.swift
//  Tenfold
//
//  Created by Elise Hein on 15/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

// MARK: Restart game

extension GameGrid {
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

    private func loadNewGame(newGame: Game, enforceStartingPosition: Bool) {
        self.game = newGame
        self.reloadData()
        self.adjustTopInset(enforceStartingPosition: enforceStartingPosition)
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
}

// MARK: Game moves
extension GameGrid {

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

    func flashNumbers(atIndeces indeces: [Int],
                      withColor color: UIColor) {
        performActionOnCells(withIndeces: indeces, { cell in
            cell.flash(withColor: color)
        })
    }
}

// MARK: Row removal and insertion

extension GameGrid {

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

    private func prepareForRemoval(indexPaths: [NSIndexPath], completion: (() -> Void)) {
        for indexPath in indexPaths {
            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
                cell.prepareForRemoval(completion: completion)
            } else {
                completion()
            }
        }
    }

    private func revealCellsAtIndeces(indeces: [Int]) {
        rowInsertionInProgressWithIndeces = nil

        performActionOnCells(withIndeces: indeces, { cell in
            cell.aboutToBeRevealed = false
        })
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
}
