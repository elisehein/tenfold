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
    case crossingOutPair
    case loadingNextRound
}

class GameMove: NSObject, NSCoding {
    fileprivate static let pairCoderKey = "gameMovePairCoderKey"
    fileprivate static let rowsRemovedCoderKey = "gameMoveRowsRemovedCoderKey"
    fileprivate static let placeholdersCoderKey = "gameMovePlaceholdersForRowsRemovedCoderKey"
    fileprivate static let numbersAddedCoderKey = "gameMoveNumbersAddedCoderKey"

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
            return .loadingNextRound
        } else if crossedOutPair != nil {
            return .crossingOutPair
        } else {
            return nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.crossedOutPair = aDecoder.decodeObject(forKey: GameMove.pairCoderKey) as? [Int]
        self.rowsRemoved = (aDecoder.decodeObject(forKey: GameMove.rowsRemovedCoderKey) as? [[Number]])!
        self.placeholdersForRowsRemoved = (aDecoder.decodeObject(forKey: GameMove.placeholdersCoderKey) as? [Int])!
        self.numbersAdded = aDecoder.decodeInteger(forKey: GameMove.numbersAddedCoderKey)
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(crossedOutPair as Any?, forKey: GameMove.pairCoderKey)
        aCoder.encode(rowsRemoved as Any?, forKey: GameMove.rowsRemovedCoderKey)
        aCoder.encode(placeholdersForRowsRemoved as Any?, forKey: GameMove.placeholdersCoderKey)
        aCoder.encode(numbersAdded, forKey: GameMove.numbersAddedCoderKey)
    }
}
