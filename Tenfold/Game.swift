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
    fileprivate static let numbersCoderKey = "gameNumbersCoderKey"
    fileprivate static let historicNumberCountCoderKey = "gameHistoricNumberCountCoderKey"
    fileprivate static let latestMoveCoderKey = "gameLatestMoveCoderKey"
    fileprivate static let currentRoundCoderKey = "gameCurrentRoundCoderKey"
    fileprivate static let valueCountsCoderKey = "gameValueCountsCoderKey"
    fileprivate static let startTimeCoderKey = "gameStartTimeCoderKey"

    static let defaultInitialNumberValues = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                                             1, 1, 1, 2, 1, 3, 1, 4, 1,
                                             5, 1, 6, 1, 7, 1, 8, 1, 9]

    var numbers: [Number] = []
    var valueCounts: [Int: Int]
    var latestMove: GameMove? = nil

    var historicNumberCount: Int = 0
    var currentRound: Int = 1
    var startTime: Date? = nil

    override init() {
        numbers = Game.initialNumbers()
        historicNumberCount = numbers.count
        valueCounts = Game.valueCounts(inNumbers: numbers)
        super.init()
    }

    fileprivate class func initialNumbers() -> [Number] {
        let initialNumbers: [Number] = initialNumberValues().map({ value in
            return Number(value: value, crossedOut: false, marksEndOfRound: false)
        })

        initialNumbers.last?.marksEndOfRound = true
        return initialNumbers
    }

    fileprivate class func initialNumberValues() -> [Int] {
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

    fileprivate class func valueCounts(inNumbers givenNumbers: [Number]) -> [Int: Int] {
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

        for firstIndexOnRow in stride(from: 0, to: givenNumbers.count, by: Game.numbersPerRow) {
            let lastIndexOnRow = min(firstIndexOnRow + Game.numbersPerRow, givenNumbers.count) - 1
            let row = givenNumbers[firstIndexOnRow...lastIndexOnRow]

            if row.filter({ return !$0.crossedOut }).count > 0 {
                filtered += row
            }
        }

        return filtered
    }

    required init(coder aDecoder: NSCoder) {
        if let storedNumbers = aDecoder.decodeObject(forKey: Game.numbersCoderKey) as? [Number] {
            self.numbers = Game.removeSurplusRows(from: storedNumbers)
        }

        if let latestMove = aDecoder.decodeObject(forKey: Game.latestMoveCoderKey) as? GameMove {
            self.latestMove = latestMove
        }

        self.historicNumberCount = (aDecoder.decodeObject(forKey: Game.historicNumberCountCoderKey) as? Int)!
        self.currentRound = (aDecoder.decodeObject(forKey: Game.currentRoundCoderKey) as? Int)!
        self.valueCounts = (aDecoder.decodeObject(forKey: Game.valueCountsCoderKey) as? [Int: Int])!
        self.startTime = (aDecoder.decodeObject(forKey: Game.startTimeCoderKey) as? Date?)!
    }

    func pruneValueCounts() {
        let unrepresentedValueCounts = valueCounts.filter({ $1 == 0 })

        for (value, _) in unrepresentedValueCounts {
            valueCounts.removeValue(forKey: value)
        }
    }

    func encode(with aCoder: NSCoder) {
        // Using as Any? because of Swift 3
        // http://stackoverflow.com/a/41604269/2026098
        aCoder.encode(numbers as Any?, forKey: Game.numbersCoderKey)
        aCoder.encode(historicNumberCount as Any?, forKey: Game.historicNumberCountCoderKey)
        aCoder.encode(currentRound as Any?, forKey: Game.currentRoundCoderKey)
        aCoder.encode(startTime as Any?, forKey: Game.startTimeCoderKey)
        aCoder.encode(valueCounts as Any?, forKey: Game.valueCountsCoderKey)
        aCoder.encode(latestMove as Any?, forKey: Game.latestMoveCoderKey)
    }
}
