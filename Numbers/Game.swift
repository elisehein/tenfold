//
//  File.swift
//  Numbers
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Game: NSObject {
    
    private let initialNumberValues = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                                       1, 1, 1, 2, 1, 3, 1, 4, 1,
                                       5, 1, 6, 1, 7, 1, 8, 1, 9];
    
    private var numbers: Array<Number> = []
    
    override init() {
        for value in initialNumberValues {
            let number = Number(value: value, crossedOut: false, marksEndOfRound: false)
            numbers.append(number)
        }
        
        numbers.last.marksEndOfRound = true
        
        super.init()
    }
    
    func crossOutIndex (index: Int) {
        numbers[index].crossedOut = true
    }
    
    func makeNextRound () {
        var nextRound: Array<Number> = []
        
        for number in numbers {
            if (!number.crossedOut) {
                let newNumber = number.copy() as! Number
                newNumber.marksEndOfRound = false
                nextRound.append(newNumber)
            }
        }
        
        nextRound.last.marksEndOfRound = true
        numbers += nextRound
    }
    
    func numbersRemaining () -> Int {
        return numbers.filter({ !$0.crossedOut }).count
    }
    
    func totalNumbers () -> Int {
        return numbers.count
    }
    
    func numberAtIndex (index: Int) -> Int {
        return numbers[index].value
    }
    
    func isCrossedOut (index: Int) -> Bool {
        return numbers[index].crossedOut
    }
    
    func marksEndOfRound (index: Int) -> Bool {
        return numbers[index].marksEndOfRound
    }
}