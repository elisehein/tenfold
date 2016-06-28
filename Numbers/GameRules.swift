//
//  GameRules.swift
//  Numbers
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class GameRules: NSObject {
    private let game: Game

    static let numbersPerLine = 9
    static let numbersInPairing = 2

    init(game: Game) {
        self.game = game
        super.init()
    }

    func lastNumberPositionOnLine () -> Int {
        return Grid.singleton.positionOnRow(game.totalNumbers() - 1)
    }

    func attemptPairing (index: Int, otherIndex: Int) -> Bool {
        if game.isCrossedOut(index) || game.isCrossedOut(otherIndex) || index == otherIndex {
            NSException(name: "Invalid pairing",
                        reason: "These numbers cannot be attempted for pairing",
                        userInfo: nil).raise()
            return false
        }

        return valuesCanPair(index, otherIndex: otherIndex) &&
               positionsCanPair(index, otherIndex: otherIndex)
    }

    private func valuesCanPair(index: Int, otherIndex: Int) -> Bool {
        let number = game.numberAtIndex(index)
        let otherNumber = game.numberAtIndex(otherIndex)

        return (number == otherNumber) || (number + otherNumber == 10)
    }

    private func positionsCanPair(index: Int, otherIndex: Int) -> Bool {
        if (backToBack(index, otherIndex: otherIndex)) {
            return true
        } else {
            let orderedIndeces = [index, otherIndex].sort { return $0 < $1 }
            return enclosingCrossedOutNumbers(from: orderedIndeces[0], to: orderedIndeces[1]) ||
                   beginningAndEndOfRow(index: orderedIndeces[0], laterIndex: orderedIndeces[1])
        }
    }

    private func backToBack (index: Int, otherIndex: Int) -> Bool {
        return abs(index - otherIndex) == 1 || abs(index - otherIndex) == 9
    }

    private func enclosingCrossedOutNumbers (from start: Int, to end: Int) -> Bool {
        let enclosingHorizontally = allCrossedOutBetween(start: start, end: end, withIncrement: 1)
        let enclosingVertically = Grid.singleton.sameColumn(start, end) &&
                                  allCrossedOutBetween(start: start, end: end, withIncrement: 9)

        return enclosingHorizontally || enclosingVertically
    }

    // This makes the game pretty easy. Could enable in easy mode
    private func beginningAndEndOfRow (index index: Int, laterIndex: Int) -> Bool {
        if !Grid.singleton.sameRow(index, laterIndex) {
            return false
        }

        let firstIndexOfRow = Grid.singleton.firstIndexOfRow(containingIndex: index)
        let lastIndexOfRow = Grid.singleton.lastIndexOfRow(containingIndex: index)

        let firstIsBeginning = Grid.singleton.isFirstOnRow(index) ||
                               allCrossedOutBetween(start: firstIndexOfRow - 1,
                                                    end: index,
                                                    withIncrement: 1)

        let secondIsEnd = Grid.singleton.isLastOnRow(laterIndex) ||
                          allCrossedOutBetween(start: laterIndex,
                                               end: lastIndexOfRow + 1,
                                               withIncrement: 1)

        return firstIsBeginning && secondIsEnd
    }

    private func allCrossedOutBetween (start start: Int,
                                       end: Int,
                                       withIncrement increment: Int) -> Bool {
        if start + increment >= end {
            return false
        }

        for i in (start + increment).stride(to: end, by: increment) {
            if !game.isCrossedOut(i) {
                return false
            }
        }

        return true
    }
}
