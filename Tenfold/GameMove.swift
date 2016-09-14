//
//  GameMove.swift
//  Tenfold
//
//  Created by Elise Hein on 12/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum GameMoveType {
    case CrossingOutPair
    case LoadingNextRound
}

class GameMove: NSObject, NSCoding {
    private static let pairCoderKey = "gameMovePairCoderKey"
    private static let rowsRemovedCoderKey = "gameMoveRowsRemovedCoderKey"
    private static let placeholdersCoderKey = "gameMovePlaceholdersForRowsRemovedCoderKey"
    private static let numbersAddedCoderKey = "gameMoveNumbersAddedCoderKey"

    var crossedOutPair: [Int]? = nil
    var rowsRemoved: [[Number]] = []
    var placeholdersForRowsRemoved: [Int] = []
    var numbersAdded: Int = 0

    init(crossedOutPair: [Int]) {
        self.crossedOutPair = crossedOutPair
        super.init()
    }

    init(numbersAdded: Int) {
        self.numbersAdded = numbersAdded
    }

    func type() -> GameMoveType? {
        if numbersAdded > 0 {
            return .LoadingNextRound
        } else if crossedOutPair != nil {
            return .CrossingOutPair
        } else {
            return nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.crossedOutPair = aDecoder.decodeObjectForKey(GameMove.pairCoderKey) as? [Int]
        self.rowsRemoved = (aDecoder.decodeObjectForKey(GameMove.rowsRemovedCoderKey) as? [[Number]])!
        self.placeholdersForRowsRemoved = (aDecoder.decodeObjectForKey(GameMove.placeholdersCoderKey) as? [Int])!
        self.numbersAdded = aDecoder.decodeIntegerForKey(GameMove.numbersAddedCoderKey)
        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(crossedOutPair, forKey: GameMove.pairCoderKey)
        aCoder.encodeObject(rowsRemoved, forKey: GameMove.rowsRemovedCoderKey)
        aCoder.encodeObject(placeholdersForRowsRemoved, forKey: GameMove.placeholdersCoderKey)
        aCoder.encodeInteger(numbersAdded, forKey: GameMove.numbersAddedCoderKey)
    }
}
