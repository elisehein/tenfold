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

    private static let numbersCoderKey = "gameNumbersCoderKey"
    private static let latestPairCoderKey = "gameLatestPairCoderKey"
    private static let historicNumberCountCoderKey = "gameHistoricNumberCountCoderKey"
    private static let currentRoundCoderKey = "gameCurrentRoundCoderKey"
    private static let valueCountsCoderKey = "gameValueCountsCoderKey"
    private static let startTimeCoderKey = "gameStartTimeCoderKey"

    static let initialNumberValues = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                                      1, 1, 1, 2, 1, 3, 1, 4, 1,
                                      5, 1, 6, 1, 7, 1, 8, 1, 9]

    // swiftlint:disable:next line_length
    private static let initialValueCounts: [Int: Int] = [1: 11, 2: 2, 3: 2, 4: 2, 5: 2, 6: 2, 7: 2, 8: 2, 9: 2]

    private var numbers: Array<Number> = []
    private var valueCounts: [Int: Int]

    var historicNumberCount: Int = 0
    var currentRound: Int = 1
    var startTime: NSDate? = nil

    var latestPair: Array<Int> = []

    class func initialNumbers() -> Array<Number> {
        let initialNumbers: Array<Number> = initialNumberValues.map({ value in
            return Number(value: value, crossedOut: false, marksEndOfRound: false)
        })

        initialNumbers.last.marksEndOfRound = true
        return initialNumbers
    }

    override init() {
        self.numbers = Game.initialNumbers()
        self.valueCounts = Game.initialValueCounts
        self.historicNumberCount = self.numbers.count
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        if let storedNumbers = aDecoder.decodeObjectForKey(Game.numbersCoderKey) as? Array<Number> {
            self.numbers = Game.removeSurplusRows(from: storedNumbers)
        }

        if let latestPair = aDecoder.decodeObjectForKey(Game.latestPairCoderKey) as? Array<Int> {
            self.latestPair = latestPair
        }

        // swiftlint:disable:next line_length
        self.historicNumberCount = (aDecoder.decodeObjectForKey(Game.historicNumberCountCoderKey) as? Int)!
        self.currentRound = (aDecoder.decodeObjectForKey(Game.currentRoundCoderKey) as? Int)!
        self.valueCounts = (aDecoder.decodeObjectForKey(Game.valueCountsCoderKey) as? [Int: Int])!
        self.startTime = (aDecoder.decodeObjectForKey(Game.startTimeCoderKey) as? NSDate?)!

        if self.numbers.count == 0 {
            self.numbers = Game.initialNumbers()
            self.latestPair = []
            self.valueCounts = Game.initialValueCounts
            self.historicNumberCount = self.numbers.count
            self.startTime = nil
            self.currentRound = 1
        }
    }

    // MARK: Manipulate game

    func crossOutPair(index: Int, otherIndex: Int) {
        startTime = NSDate()
        numbers[index].crossedOut = true
        numbers[otherIndex].crossedOut = true
        valueCounts[numbers[index].value!]! -= 1
        valueCounts[numbers[otherIndex].value!]! -= 1
    }

    func makeNextRound() -> Bool {
        return makeNextRound(usingNumbers: nextRoundNumbers())
    }

    func makeNextRound(usingNumbers nextRoundNumbers: Array<Number>) -> Bool {
        if nextRoundNumbers.count > 0 {
            numbers += nextRoundNumbers
            historicNumberCount += nextRoundNumbers.count
            currentRound += 1

            for (value, _) in valueCounts {
                valueCounts[value] = valueCounts[value]! * 2
            }

            return true
        } else {
            return false
        }
    }

    func removeNumbers(atIndeces indeces: Array<Int>) {
        let numbersToRemove = numbers.filter({ indeces.contains(numbers.indexOf($0)!) })
        numbers.removeObjects(numbersToRemove)
        if numbers.count > 0 {
            numbers.last.marksEndOfRound = true
        }
    }

    func pruneValueCounts() {
        let unrepresentedValueCounts = valueCounts.filter({ $1 == 0 })

        for (value, _) in unrepresentedValueCounts {
            valueCounts.removeValueForKey(value)
        }
    }

    // MARK: Query game

    func nextRoundNumbers() -> Array<Number> {
        let nextRoundNumbers: Array<Number> = remainingNumbers().map({ number in
            let newNumber = number.copy() as? Number
            newNumber!.marksEndOfRound = false
            return newNumber!
        })

        nextRoundNumbers.last.marksEndOfRound = true
        return nextRoundNumbers
    }

    func nextRoundValues() -> Array<Int?> {
        return remainingNumbers().map({ $0.value })
    }

    func unrepresentedValues() -> Array<Int> {
        return valueCounts.filter({ $1 == 0 }).map({ $0.0 })
    }

    func numberOfUniqueValues() -> Int {
        pruneValueCounts()
        return valueCounts.keys.count
    }

    func ended() -> Bool {
        return numbersRemaining() == 0
    }

    func numbersRemaining() -> Int {
        return remainingNumbers().count
    }

    func numbersCrossedOut() -> Int {
        return totalNumbers() - numbersRemaining()
    }

    func historicNumbersCrossedOut() -> Int {
        return historicNumberCount - numbersRemaining()
    }

    func totalNumbers() -> Int {
        return numbers.count
    }

    func totalRows() -> Int {
        return Matrix.singleton.totalRows(totalNumbers())
    }

    func lastNumberColumn() -> Int {
        return Matrix.singleton.columnOfItem(atIndex: totalNumbers() - 1)
    }

    func indecesOnRow(containingIndex index: Int) -> Array<Int> {
        return Matrix.singleton.indecesOnRow(containingIndex: index,
                                             lastGameIndex: totalNumbers() - 1)
    }

    func valueAtIndex(index: Int) -> Int? {
        return numbers[index].value
    }

    func marksEndOfRound(index: Int) -> Bool {
        return numbers[index].marksEndOfRound
    }

    func isCrossedOut(index: Int) -> Bool {
        return numbers[index].crossedOut
    }

    func allCrossedOut(indeces: Array<Int>) -> Bool {
        return indeces.filter({ numbers[$0].crossedOut }).count == indeces.count
    }

    func allCrossedOutBetween(index index: Int,
                              laterIndex: Int,
                              withIncrement increment: Int = 1) -> Bool {
        if index + increment >= laterIndex {
            return false
        }

        for i in (index + increment).stride(to: laterIndex, by: increment) {
            if numbers.count > i && !isCrossedOut(i) {
                return false
            }
        }

        return true
    }

    func surplusIndecesOnRows(containingIndeces indeces: Array<Int>) -> Array<Int> {
        var surplusIndeces: Array<Int> = []

        for index in indeces {
            let rowIndeces = indecesOnRow(containingIndex: index)
            if allCrossedOut(rowIndeces) &&
               !Set(rowIndeces).isSubsetOf(Set(surplusIndeces)) {
                surplusIndeces += rowIndeces
            }
        }

        return surplusIndeces
    }

    class func removeSurplusRows(from givenNumbers: Array<Number>) -> Array<Number> {
        var filtered: Array<Number> = []

        for firstIndexOnRow in 0.stride(to: givenNumbers.count, by: Game.numbersPerRow) {
            // swiftlint:disable:next line_length
            let lastIndexOnRow = min(firstIndexOnRow + Game.numbersPerRow, givenNumbers.count) - 1
            let row = givenNumbers[firstIndexOnRow...lastIndexOnRow]

            if row.filter({ return !$0.crossedOut }).count > 0 {
                filtered += row
            }
        }

        return filtered
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(numbers, forKey: Game.numbersCoderKey)
        aCoder.encodeObject(latestPair, forKey: Game.latestPairCoderKey)
        aCoder.encodeObject(historicNumberCount, forKey: Game.historicNumberCountCoderKey)
        aCoder.encodeObject(currentRound, forKey: Game.currentRoundCoderKey)
        aCoder.encodeObject(startTime, forKey: Game.startTimeCoderKey)
        aCoder.encodeObject(valueCounts, forKey: Game.valueCountsCoderKey)
    }

    private func remainingNumbers() -> Array<Number> {
        return numbers.filter({ !$0.crossedOut })
    }
}
