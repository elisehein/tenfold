//
//  Pairing.swift
//  Tenfold
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Pairing: NSObject {
    private static let matrix = Matrix.singleton

    static func validate(_ proposedPair: Pair, inGame game: Game) -> Bool {
        if game.isCrossedOut(proposedPair.first) ||
           game.isCrossedOut(proposedPair.second) ||
           proposedPair.first == proposedPair.second {
            NSException(name: NSExceptionName(rawValue: "Invalid pairing"),
                        reason: "These numbers cannot be attempted for pairing",
                        userInfo: nil).raise()
            return false
        }

        return valuesCanPair (proposedPair, inGame: game) &&
               positionsCanPair(proposedPair, inGame: game)
    }

    static private func valuesCanPair(_ pair: Pair, inGame game: Game) -> Bool {
        let value = game.valueAtIndex(pair.first)
        let otherValue = game.valueAtIndex(pair.second)

        return (value == otherValue) || (value! + otherValue! == 10)
    }

    static private func positionsCanPair(_ pair: Pair, inGame game: Game) -> Bool {
        return matrix.backToBack(pair) || enclosingCrossedOutNumbers(pair, inGame: game)
    }

    static private func enclosingCrossedOutNumbers(_ pair: Pair, inGame game: Game) -> Bool {
        let enclosingHorizontally = game.allCrossedOutBetween(pair)
        let enclosingVertically = matrix.sameColumn(pair) &&
                                  game.allCrossedOutBetween(pair, withIncrement: Game.numbersPerRow)

        return enclosingHorizontally || enclosingVertically
    }
}
