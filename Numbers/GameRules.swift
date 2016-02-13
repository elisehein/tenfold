//
//  GameRules.swift
//  Numbers
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class GameRules: NSObject {
    let game: Game // Figure out how to make this readonly, keeping the reference
    
    init(game: Game) {
        self.game = game
        super.init()
    }
    
    func attemptPairing (index: Int, otherIndex: Int) -> Bool {
        return valuesCanPair(index, otherIndex: otherIndex) &&
               positionsCanPair(index, otherIndex: otherIndex)
    }
    
    private func valuesCanPair(index: Int, otherIndex: Int) -> Bool {
        let number = game.numberAtIndex(index)
        let otherNumber = game.numberAtIndex(otherIndex)
        
        return (number == otherNumber) || (number + otherNumber == 10)
    }
    
    private func positionsCanPair(index: Int, otherIndex: Int) -> Bool {
        return true
    }
}