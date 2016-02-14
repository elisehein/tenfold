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
        return backToBack(index, otherIndex: otherIndex) ||
               enclosingCrossedOutNumbers(index, otherIndex: otherIndex)
    }
    
    private func backToBack (index: Int, otherIndex: Int) -> Bool {
        return abs(index - otherIndex) == 1 || abs(index - otherIndex) == 9
    }
    
    private func enclosingCrossedOutNumbers (index: Int, otherIndex: Int) -> Bool {
        let orderedIndeces = [index, otherIndex].sort { return $0 < $1 }
        
        for var i = orderedIndeces[0] + 1; i < orderedIndeces[1]; i++ {
            if !game.isCrossedOut(i) {
                return false
            }
        }
        
        return true
    }
    
    private func enclosingCrossedOutNumbersVertically (index: Int, otherIndex: Int) -> Bool {
        return true
        
    }
    
    private func beginningAndEndOfLine (index: Int, otherIndex: Int) -> Bool {
        return true
    }
}