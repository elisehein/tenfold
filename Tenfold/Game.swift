//
//  File.swift
//  Tenfold
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Game: NSObject, NSCoding {

    static let numbersPerRow = 9
    static let initialNumberCount = 27

    // Take care not to rename the actual literals, as they are used as storage keys on
    // devices that already have the game installed
    private static let numbersCoderKey = "gameNumbersCoderKey"
    private static let historicNumberCountCoderKey = "gameHistoricNumberCountCoderKey"
    private static let latestMoveCoderKey = "gameLatestMoveCoderKey"
    private static let currentRoundCoderKey = "gameCurrentRoundCoderKey"
    private static let valueCountsCoderKey = "gameValueCountsCoderKey"
    private static let startTimeCoderKey = "gameStartTimeCoderKey"

    static let defaultInitialNumberValues = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                                             1, 1, 1, 2, 1, 3, 1, 4, 1,
                                             5, 1, 6, 1, 7, 1, 8, 1, 9]

    var numbers: [Number] = []
    var valueCounts: [Int: Int]
    var latestMove: GameMove? = nil

    var historicNumberCount: Int = 0
    var currentRound: Int = 1
    var startTime: NSDate? = nil

    override init() {
        numbers = Game.initialNumbers()
        historicNumberCount = numbers.count
        valueCounts = Game.valueCounts(inNumbers: numbers)
        super.init()
    }

    private class func initialNumbers() -> [Number] {
        let initialNumbers: [Number] = initialNumberValues().map({ value in
            return Number(value: value, crossedOut: false, marksEndOfRound: false)
        })

        initialNumbers.last.marksEndOfRound = true
        return initialNumbers
    }

    private class func initialNumberValues() -> [Int] {
        var numberValues = [Int]()

        if StorageService.currentFlag(forSetting: .RandomInitialNumbers) {
            for _ in 0..<(Game.initialNumberCount) {
                numberValues.append(Int(arc4random_uniform(9) + 1))
            }
        } else {
            numberValues = Game.defaultInitialNumberValues
        }

        return numberValues
    }

    private class func valueCounts(inNumbers givenNumbers: Array<Number>) -> [Int: Int] {
        var counts = [Int: Int]()
        for number in givenNumbers {
            if counts[number.value!] == nil {
                counts[number.value!] = 1
            } else {
                counts[number.value!]! += 1
            }
        }
        return counts
    }

    class func removeSurplusRows(from givenNumbers: [Number]) -> [Number] {
        var filtered: [Number] = []

        for firstIndexOnRow in 0.stride(to: givenNumbers.count, by: Game.numbersPerRow) {
            let lastIndexOnRow = min(firstIndexOnRow + Game.numbersPerRow, givenNumbers.count) - 1
            let row = givenNumbers[firstIndexOnRow...lastIndexOnRow]

            if row.filter({ return !$0.crossedOut }).count > 0 {
                filtered += row
            }
        }

        return filtered
    }

    required init(coder aDecoder: NSCoder) {
        if let storedNumbers = aDecoder.decodeObjectForKey(Game.numbersCoderKey) as? [Number] {
            self.numbers = Game.removeSurplusRows(from: storedNumbers)
        }

        if let latestMove = aDecoder.decodeObjectForKey(Game.latestMoveCoderKey) as? GameMove {
            self.latestMove = latestMove
        }

        self.historicNumberCount = (aDecoder.decodeObjectForKey(Game.historicNumberCountCoderKey) as? Int)!
        self.currentRound = (aDecoder.decodeObjectForKey(Game.currentRoundCoderKey) as? Int)!
        self.valueCounts = (aDecoder.decodeObjectForKey(Game.valueCountsCoderKey) as? [Int: Int])!
        self.startTime = (aDecoder.decodeObjectForKey(Game.startTimeCoderKey) as? NSDate?)!
    }

    func pruneValueCounts() {
        let unrepresentedValueCounts = valueCounts.filter({ $1 == 0 })

        for (value, _) in unrepresentedValueCounts {
            valueCounts.removeValueForKey(value)
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(numbers, forKey: Game.numbersCoderKey)
        aCoder.encodeObject(historicNumberCount, forKey: Game.historicNumberCountCoderKey)
        aCoder.encodeObject(currentRound, forKey: Game.currentRoundCoderKey)
        aCoder.encodeObject(startTime, forKey: Game.startTimeCoderKey)
        aCoder.encodeObject(valueCounts, forKey: Game.valueCountsCoderKey)
        aCoder.encodeObject(latestMove, forKey: Game.latestMoveCoderKey)
    }
}
