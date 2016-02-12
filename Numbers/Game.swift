//
//  File.swift
//  Numbers
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Game: NSObject {
    private var numbers: Array<Int>
    private var crossedOut: Array<Bool>
    private var endOfRound: Array<Bool>
    
    override init() {
        numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                   1, 1, 1, 2, 1, 3, 1, 4, 1,
                   5, 1, 6, 1, 7, 1, 8, 1, 9];
        
        crossedOut = [Bool](count: numbers.count, repeatedValue: false)
        endOfRound = [Bool](count: numbers.count, repeatedValue: false)
        endOfRound[endOfRound.count - 1] = true
        
        super.init()
    }
    
    func crossOutIndex (index: Int) {
        crossedOut[index] = true
    }
    
    func makeNextRound () {
        var nextRoundNumbers: Array<Int> = []
        
        for var index = 0; index < numbers.count; index++ {
            if (!crossedOut[index]) {
                nextRoundNumbers.append(numbers[index])
            }
        }
        
        numbers += nextRoundNumbers
        
        let nextRoundCrossedOut = [Bool](count: nextRoundNumbers.count, repeatedValue: false)
        crossedOut += nextRoundCrossedOut
        
        var nextRoundEndOfRound = [Bool](count: nextRoundNumbers.count, repeatedValue: false)
        nextRoundEndOfRound[nextRoundEndOfRound.count - 1] = true
        endOfRound += nextRoundEndOfRound
    }
    
    func numbersRemaining () -> Int {
        return crossedOut.filter({ !$0 }).count
    }
    
    func totalNumbers () -> Int {
        return numbers.count
    }
    
    func numberAtIndex (index: Int) -> Int {
        return numbers[index]
    }
    
    func isCrossedOut (index: Int) -> Bool {
        return crossedOut[index]
    }
    
    func marksEndOfRound (index: Int) -> Bool {
        return endOfRound[index]
    }
}