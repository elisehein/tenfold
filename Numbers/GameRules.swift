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
    
    static let numbersPerLine = 9
    static let numbersInPairing = 2
    
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
        let enclosingVertically = sameColumn(start, end) &&
                                  allCrossedOutBetween(start: start, end: end, withIncrement: 9)
        
        return enclosingHorizontally || enclosingVertically
    }
    
    // This makes the game pretty easy. Could enable in easy mode
    private func beginningAndEndOfLine (first first: Int, second: Int) -> Bool {
        if !sameLine(first, second) {
            return false
        }
        
        let positionOfFirstOnLine = positionOnLine(first)
        let positionOfSecondOnLine = positionOnLine(second)
        
        let startOfLine = first - positionOfFirstOnLine
        let endOfLine = first + (GameRules.numbersPerLine - positionOfFirstOnLine) - 1
        
        let firstIsBeginning = positionOfFirstOnLine == 0 ||
                               allCrossedOutBetween(start: startOfLine - 1, end: first, withIncrement: 1)
        
        let secondIsEnd = positionOfSecondOnLine == (GameRules.numbersPerLine - 1) ||
                          allCrossedOutBetween(start: second, end: endOfLine + 1, withIncrement: 1)
        
        return firstIsBeginning && secondIsEnd
    }
    
    private func sameLine(first: Int, _ second: Int) -> Bool {
        return second - first < GameRules.numbersPerLine && positionOnLine(second) > positionOnLine(first)
    }
    
    private func sameColumn(index: Int, _ otherIndex: Int) -> Bool {
        return positionOnLine(index) == positionOnLine(otherIndex)
    }
    
    private func positionOnLine(index: Int) -> Int {
        return index % GameRules.numbersPerLine
    }
    
    private func allCrossedOutBetween (start start: Int, end: Int, withIncrement increment: Int) -> Bool {
        if (start + increment >= end) {
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