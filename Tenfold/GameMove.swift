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

    let crossedOutPair: Array<Int>
    var removedRows: Array<Array<Number>> = []
    var removedRowPlaceholders: Array<Int> = []

    init(crossedOutPair: Array<Int>) {
        self.crossedOutPair = crossedOutPair
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.crossedOutPair = (aDecoder.decodeObjectForKey(GameMove.pairCoderKey) as? Array<Int>)!
        self.removedRows = (aDecoder.decodeObjectForKey(GameMove.removedRowCoderKey) as? Array<Array<Number>>)!
        self.removedRowPlaceholders = (aDecoder.decodeObjectForKey(GameMove.removedRowPlaceholdersCoderKey)
                                       as? Array<Int>)!
        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(crossedOutPair, forKey: GameMove.pairCoderKey)
        aCoder.encodeObject(removedRows, forKey: GameMove.removedRowCoderKey)
        aCoder.encodeObject(removedRowPlaceholders, forKey: GameMove.removedRowPlaceholdersCoderKey)
    }
}
