//
//  Pairing.swift
//  Numbers
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Pairing: NSObject {
    private let game: Game

    init (game: Game) {
        self.game = game
        super.init()
    }

    func validate (index: Int, otherIndex: Int) -> Bool {
        if game.isCrossedOut(index) || game.isCrossedOut(otherIndex) || index == otherIndex {
            NSException(name: "Invalid pairing",
                        reason: "These numbers cannot be attempted for pairing",
                        userInfo: nil).raise()
            return false
        }

        return valuesCanPair (index, otherIndex: otherIndex) &&
               positionsCanPair(index, otherIndex: otherIndex)
    }

    private func valuesCanPair (index: Int, otherIndex: Int) -> Bool {
        let value = game.valueAtIndex(index)
        let otherValue = game.valueAtIndex(otherIndex)

        return (value == otherValue) || (value + otherValue == 10)
    }

    private func positionsCanPair (index: Int, otherIndex: Int) -> Bool {
        if (game.matrix.backToBack(index, otherIndex: otherIndex)) {
            return true
        } else {
            let orderedIndeces = [index, otherIndex].sort { return $0 < $1 }
            return enclosingCrossedOutNumbers(from: orderedIndeces[0], to: orderedIndeces[1]) ||
                   beginningAndEndOfRow(index: orderedIndeces[0], laterIndex: orderedIndeces[1])
        }
    }

    private func enclosingCrossedOutNumbers (from start: Int, to end: Int) -> Bool {
        let enclosingHorizontally = game.allCrossedOutBetween(index: start, laterIndex: end)
        let enclosingVertically = game.matrix.sameColumn(start, end) &&
                                  game.allCrossedOutBetween(index: start,
                                                            laterIndex: end,
                                                            withIncrement: Game.numbersPerRow)

        return enclosingHorizontally || enclosingVertically
    }

    // This makes the game pretty easy. Could enable in easy mode
    private func beginningAndEndOfRow (index index: Int, laterIndex: Int) -> Bool {
        if !game.matrix.sameRow(index, laterIndex) {
            return false
        }

        let firstIndexOfRow = game.matrix.firstIndexOfRow(containingIndex: index)
        let lastIndexOfRow = game.matrix.lastIndexOfRow(containingIndex: index)

        let firstIsBeginning = game.matrix.isFirstOnRow(index) ||
                               game.allCrossedOutBetween(index: firstIndexOfRow - 1,
                                                         laterIndex: index)

        let secondIsEnd = game.matrix.isLastOnRow(laterIndex) ||
                          game.allCrossedOutBetween(index: laterIndex,
                                                    laterIndex: lastIndexOfRow + 1)

        return firstIsBeginning && secondIsEnd
    }
}
