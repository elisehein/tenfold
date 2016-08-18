//
//  Pairing.swift
//  Numbers
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Pairing: NSObject {
    private static let matrix = Matrix.singleton

    static func validate(index: Int, _ otherIndex: Int, inGame game: Game) -> Bool {
        if game.isCrossedOut(index) || game.isCrossedOut(otherIndex) || index == otherIndex {
            NSException(name: "Invalid pairing",
                        reason: "These numbers cannot be attempted for pairing",
                        userInfo: nil).raise()
            return false
        }

        return true
//        return valuesCanPair (index, otherIndex: otherIndex, inGame: game) &&
//               positionsCanPair(index, otherIndex: otherIndex, inGame: game)
    }

    static private func valuesCanPair(index: Int, otherIndex: Int, inGame game: Game) -> Bool {
        let value = game.valueAtIndex(index)
        let otherValue = game.valueAtIndex(otherIndex)

        return (value == otherValue) || (value + otherValue == 10)
    }

    static private func positionsCanPair(index: Int, otherIndex: Int, inGame game: Game) -> Bool {
        if (matrix.backToBack(index, otherIndex: otherIndex)) {
            return true
        } else {
            let orderedIndeces = [index, otherIndex].sort { return $0 < $1 }
            return enclosingCrossedOutNumbers(orderedIndeces[0], orderedIndeces[1], inGame: game) ||
                   beginningAndEndOfRow(orderedIndeces[0], orderedIndeces[1], inGame: game)
        }
    }

    static private func enclosingCrossedOutNumbers(start: Int,
                                                   _ end: Int,
                                                   inGame game: Game) -> Bool {
        let enclosingHorizontally = game.allCrossedOutBetween(index: start, laterIndex: end)
        let enclosingVertically = matrix.sameColumn(start, end) &&
                                  game.allCrossedOutBetween(index: start,
                                                            laterIndex: end,
                                                            withIncrement: Game.numbersPerRow)

        return enclosingHorizontally || enclosingVertically
    }

    // This makes the game pretty easy. Could enable in easy mode
    static private func beginningAndEndOfRow(index: Int,
                                             _ laterIndex: Int,
                                             inGame game: Game) -> Bool {
        if !matrix.sameRow(index, laterIndex) {
            return false
        }

        let firstIndexOfRow = matrix.firstIndexOfRow(containingIndex: index)
        let lastIndexOfRow = matrix.lastIndexOfRow(containingIndex: index)

        let firstIsBeginning = matrix.isFirstOnRow(index) ||
                               game.allCrossedOutBetween(index: firstIndexOfRow - 1,
                                                         laterIndex: index)

        let secondIsEnd = matrix.isLastOnRow(laterIndex) ||
                          game.allCrossedOutBetween(index: laterIndex,
                                                    laterIndex: lastIndexOfRow + 1)

        return firstIsBeginning && secondIsEnd
    }
}
