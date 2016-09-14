//
//  GameMove.swift
//  Tenfold
//
//  Created by Elise Hein on 12/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameMove: NSObject, NSCoding {
    private static let pairCoderKey = "gameMovePairCoderKey"
    private static let removedRowCoderKey = "gameMoveRemovedRowCoderKey"
    private static let removedRowPlaceholdersCoderKey = "gameMoveRemovedRowPlaceholdersCoderKey"

    let crossedOutPair: [Int]
    var removedRows: [[Number]] = []
    var removedRowPlaceholders: [Int] = []

    init(crossedOutPair: [Int]) {
        self.crossedOutPair = crossedOutPair
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.crossedOutPair = (aDecoder.decodeObjectForKey(GameMove.pairCoderKey) as? [Int])!
        self.removedRows = (aDecoder.decodeObjectForKey(GameMove.removedRowCoderKey) as? [[Number]])!
        self.removedRowPlaceholders = (aDecoder.decodeObjectForKey(GameMove.removedRowPlaceholdersCoderKey)
                                       as? [Int])!
        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(crossedOutPair, forKey: GameMove.pairCoderKey)
        aCoder.encodeObject(removedRows, forKey: GameMove.removedRowCoderKey)
        aCoder.encodeObject(removedRowPlaceholders, forKey: GameMove.removedRowPlaceholdersCoderKey)
    }
}
