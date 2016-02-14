//
//  GameRules.swift
//  Numbers
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class GameRules: NSObject {
    private let game: Game // TODO Figure out how to make this readonly, keeping the reference
    
    let numbersPerLine = 9
    let numbersInPairing = 2
    
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
        if (backToBack(index, otherIndex: otherIndex)) {
            return true
        } else {
            let orderedIndeces = [index, otherIndex].sort { return $0 < $1 }
            return enclosingCrossedOutNumbers(from: orderedIndeces[0], to: orderedIndeces[1]) ||
                   beginningAndEndOfLine(first: orderedIndeces[0], second: orderedIndeces[1])
        }
    }
    
    private func backToBack (index: Int, otherIndex: Int) -> Bool {
        return abs(index - otherIndex) == 1 || abs(index - otherIndex) == 9
    }
    
    private func enclosingCrossedOutNumbers (from start: Int, to end: Int) -> Bool {
        let enclosingHorizontally = allCrossedOutBetween(start: start, end: end, withIncrement: 1)
        let enclosingVertically = allCrossedOutBetween(start: start, end: end, withIncrement: 9)
        
        return enclosingHorizontally || enclosingVertically
    }
    
    // This makes the game pretty easy. Could enable in easy mode
    private func beginningAndEndOfLine (first first: Int, second: Int) -> Bool {
        let positionOfFirstOnLine = first % numbersPerLine
        
        if !sameLine(first: first, second: second, positionOfFirstOnLine: positionOfFirstOnLine) {
            return false
        }
        
        let positionOfSecondOnLine = positionOfFirstOnLine + (second - first)
        
        let startOfLine = first - positionOfFirstOnLine
        let endOfLine = first + (numbersPerLine - positionOfFirstOnLine) - 1
        
        let firstIsBeginning = positionOfFirstOnLine == 0 ||
                               allCrossedOutBetween(start: startOfLine - 1, end: first, withIncrement: 1)
        
        let secondIsEnd = positionOfSecondOnLine == (numbersPerLine - 1) ||
                          allCrossedOutBetween(start: second, end: endOfLine + 1, withIncrement: 1)
        
        return firstIsBeginning && secondIsEnd
    }
    
    private func sameLine(first first: Int, second: Int, positionOfFirstOnLine: Int) -> Bool {
        let positionsAvailableUntilEndOfLine = numbersPerLine - positionOfFirstOnLine - 1
        return second - first <= positionsAvailableUntilEndOfLine
    }
    
    private func allCrossedOutBetween (start start: Int, end: Int, withIncrement increment: Int) -> Bool {
        if (start + increment >= end) {
            return false
        }
        
        for var i = start + increment; i < end; i += increment {
            if !game.isCrossedOut(i) {
                return false
            }
        }
        
        return true
    }
}