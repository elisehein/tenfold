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
                self.transform = CGAffineTransform.identity
                self.loadNewGame(newGame, enforceStartingPosition: enforceStartingPosition)
                self.showCurrentGame(completion)
            })
        } else {
            loadNewGame(newGame, enforceStartingPosition: enforceStartingPosition)
            completion?()
        }
    }

    fileprivate func loadNewGame(_ newGame: Game, enforceStartingPosition: Bool) {
        self.game = newGame
        self.reloadData()
        self.adjustTopInset(enforceStartingPosition: enforceStartingPosition)
    }

    fileprivate func hideCurrentGame(_ completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.2,
                                   delay: 0,
                                   options: .curveEaseIn,
                                   animations: {
            self.alpha = 0
            self.transform = CGAffineTransform.identity.translatedBy(x: 0,
                                                        y: self.initialGameHeight() * 0.3)
        }, completion: { _ in
            completion()
        })
    }

    fileprivate func showCurrentGame(_ completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.15, delay: 0.2, options: .curveEaseIn, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }
}

// MARK: Game moves
extension GameGrid {

    func loadNextRound(atIndeces indeces: [Int], completion: ((Bool) -> Void)?) {
        var indexPaths: [IndexPath] = []

        for index in indeces {
           indexPaths.append(IndexPath(item: index, section: 0))
        }

        insertItems(at: indexPaths)
        performBatchUpdates(nil, completion: { finished in
            self.adjustTopInset()
            // In case our end of round marker got lost with row removals, ensure
            // it's there just before adding the next round
            self.reloadItems(at: [IndexPath(item: indeces[0] - 1, section: 0)])
            completion?(finished)
        })
    }

    func crossOut(_ pair: Pair) {
        performActionOnCells(withIndeces: pair.asArray(), { cell in
            cell.crossOut()
        })
    }

    func unCrossOut(_ pair: Pair, withDelay delay: Double) {
        performActionOnCells(withIndeces: pair.asArray(), { cell in
            cell.unCrossOut(withDelay: delay, animated: true)
        })
    }

    func dismissSelection() {
        for indexPath in selectedIndexPaths {
            if let cell = cellForItem(at: indexPath as IndexPath) as? GameGridCell {
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

    func removeRows(withNumberIndeces indeces: [Int], completion: @escaping (() -> Void)) {
        guard indeces.count > 0 else { return }
        rowRemovalInProgress = true

        let indexPaths = indeces.map({ IndexPath(item: $0, section: 0) })

        adjustTopInset()
        adjustTopOffsetInAnticipationOfCellCountChange(indeces)

        prepareForRemoval(indexPaths, completion: {
            if self.rowRemovalInProgress {
                self.deleteItems(at: indexPaths)

                if self.contentInset.top > self.spaceForScore {
                    self.setContentOffset(CGPoint(x: 0, y: -self.contentInset.top), animated: true)
                }

                self.rowRemovalInProgress = false
                completion()
            }
        })
    }

    func addRows(atIndeces indeces: [Int], completion: @escaping (() -> Void)) {
        guard indeces.count > 0 else { return }
        rowInsertionInProgressWithIndeces = indeces

        let indexPaths = indeces.map({ IndexPath(item: $0, section: 0) })
        adjustTopOffsetInAnticipationOfCellCountChange(indeces)

        performBatchUpdates({
            self.insertItems(at: indexPaths)
        }, completion: { finished in
            self.adjustTopInset()
            self.revealCellsAtIndeces(indeces)
            completion()
        })
    }

    fileprivate func prepareForRemoval(_ indexPaths: [IndexPath], completion: @escaping (() -> Void)) {
        for indexPath in indexPaths {
            if let cell = cellForItem(at: indexPath) as? GameGridCell {
                cell.prepareForRemoval(completion: completion)
            } else {
                completion()
            }
        }
    }

    fileprivate func revealCellsAtIndeces(_ indeces: [Int]) {
        rowInsertionInProgressWithIndeces = nil

        performActionOnCells(withIndeces: indeces, { cell in
            cell.aboutToBeRevealed = false
        })
    }

    fileprivate func adjustTopOffsetInAnticipationOfCellCountChange(_ indeces: [Int]) {
        // For some reason something funky happens when we're adding stuff
        // to the very end of the game... in this case, adjusting top offset
        // just makes it behave oddly
        if game.indecesOverlapTailIndeces(indeces) {
            return
        }

        if contentInset.top > spaceForScore {
            let rowDelta = Matrix.singleton.totalRows(indeces.count)
            let gameHeightDelta = heightForGame(withTotalRows: rowDelta)
            setContentOffset(CGPoint(x: 0, y: -contentInset.top + gameHeightDelta), animated: true)
        }
    }
}
