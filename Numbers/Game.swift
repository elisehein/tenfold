//
//  File.swift
//  Numbers
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Game: NSObject, NSCoding {

    private static let numbersCoderKey = "gameNumbersCoderKey"

    private static let initialNumberValues = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                                              1, 1, 1, 2, 1, 3, 1, 4, 1,
                                              5, 1, 6, 1, 7, 1, 8, 1, 9]

    private var numbers: Array<Number> = []

    class func initialNumbers () -> Array<Number> {
        var initialNumbers = Array<Number>()

        for value in initialNumberValues {
            let number = Number(value: value, crossedOut: false, marksEndOfRound: false)
            initialNumbers.append(number)
        }

        initialNumbers.last.marksEndOfRound = true
        return initialNumbers
    }

    override init () {
        numbers = Game.initialNumbers()
        super.init()
    }

    required init (coder aDecoder: NSCoder) {
        self.numbers = (aDecoder.decodeObjectForKey(Game.numbersCoderKey) as? Array<Number>)!
    }

    func restart () {
        numbers = Game.initialNumbers()
    }

    func crossOutPair (index: Int, otherIndex: Int) {
        numbers[index].crossedOut = true
        numbers[otherIndex].crossedOut = true
    }

    func nextRoundNumbers () -> Array<Number> {
        var nextRound: Array<Number> = []

        for number in numbers {
            if !number.crossedOut {
                let newNumber = number.copy() as? Number
                newNumber!.marksEndOfRound = false
                nextRound.append(newNumber!)
            }
        }

        return nextRound
    }

    func nextRoundValues () -> Array<Int> {
        var nextRoundValues: Array<Int> = []

        for number in numbers {
            if !number.crossedOut {
                nextRoundValues.append(number.value)
            }
        }

        return nextRoundValues
    }

    func makeNextRound () -> Bool {
        return makeNextRound(usingNumbers: nextRoundNumbers())
    }

    func makeNextRound (usingNumbers nextRoundNumbers: Array<Number>) -> Bool {
        if nextRoundNumbers.count > 0 {
            nextRoundNumbers.last.marksEndOfRound = true
            numbers += nextRoundNumbers
            return true
        } else {
            return false
        }
    }

    func currentRoundIndeces () -> Array<Int> {
        let indeces: [Int] = Array(currentRoundStartIndex()...numbers.count - 1)
        return indeces
    }

    func currentRoundStartIndex () -> Int {
        let roundEndings = numbers.filter({ $0.marksEndOfRound })
        let previousRoundEnding = roundEndings[roundEndings.count - 2]
        return numbers.indexOf(previousRoundEnding)! + 1
    }

    func numbersRemaining () -> Int {
        return numbers.filter({ !$0.crossedOut }).count
    }

    func totalNumbers () -> Int {
        return numbers.count
    }

    func totalRows () -> Int {
        return Int(ceil(Float(numbers.count) / Float(GameRules.numbersPerLine)))
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

    func encodeWithCoder (aCoder: NSCoder) {
        aCoder.encodeObject(numbers, forKey: Game.numbersCoderKey)
    }
}
