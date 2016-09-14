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

    // Take care not to rename the actual literals, as they are used as storage keys on
    // devices that already have the game installed
    private static let numbersCoderKey = "gameNumbersCoderKey"
    private static let historicNumberCountCoderKey = "gameHistoricNumberCountCoderKey"
    private static let latestMoveCoderKey = "gameLatestMoveCoderKey"
    private static let currentRoundCoderKey = "gameCurrentRoundCoderKey"
    private static let valueCountsCoderKey = "gameValueCountsCoderKey"
    private static let startTimeCoderKey = "gameStartTimeCoderKey"

    static let initialNumberValues = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                                      1, 1, 1, 2, 1, 3, 1, 4, 1,
                                      5, 1, 6, 1, 7, 1, 8, 1, 9]

    private static let initialValueCounts: [Int: Int] = [1: 11, 2: 2, 3: 2, 4: 2, 5: 2, 6: 2, 7: 2, 8: 2, 9: 2]

    private var numbers: [Number] = []
    private var valueCounts: [Int: Int]
    private var latestMove: GameMove? = nil

    var historicNumberCount: Int = 0
    var currentRound: Int = 1
    var startTime: NSDate? = nil

    class func initialNumbers() -> [Number] {
        let initialNumbers: [Number] = initialNumberValues.map({ value in
            return Number(value: value, crossedOut: false, marksEndOfRound: false)
        })

        initialNumbers.last.marksEndOfRound = true
        return initialNumbers
    }

    override init() {
        numbers = Game.initialNumbers()
        historicNumberCount = numbers.count
        valueCounts = Game.initialValueCounts
        super.init()
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

    // MARK: Manipulate game

    func crossOut(pair: Pair) {
        startTime = NSDate()
        latestMove = GameMove(crossedOutPair: pair.asArray())

        let crossOut: ((Number) -> Void) = { number in
            number.crossedOut = true
            self.valueCounts[number.value!]! -= 1
        }

        for index in pair.asArray() {
            crossOut(numbers[index])
        }
    }

    func undoLatestPairing() -> Pair? {
        guard latestMove != nil else { return nil }

        let unpair: ((Number) -> Void) = { number in
            number.crossedOut = false
            self.incrementValueCount(number.value!)
        }

        for index in latestMove!.crossedOutPair {
            unpair(numbers[index])
        }

        let crossedOutPair = Pair(latestMove!.crossedOutPair)
        latestMove = nil
        return crossedOutPair
    }

    func removeRowsIfNeeded(containingItemsFrom pair: Pair) -> [Int] {
        var surplusIndeces: [Int] = []

        surplusIndeces += removeRow(containing: pair.second)

        if !Matrix.singleton.sameRow(pair) {
            surplusIndeces += removeRow(containing: pair.first)
        }

        return surplusIndeces
    }

    private func removeRow(containing index: Int) -> [Int] {
        let surplusIndeces = surplusIndecesOnRow(containingIndex: index)
        removeRow(containing: surplusIndeces)
        return surplusIndeces
    }

    private func removeRow(containing indeces: [Int]) {
        guard latestMove != nil else { return }
        guard indeces.count > 0 else { return }
        let numbersToRemove = numbers.filter({ indeces.contains(numbers.indexOf($0)!) })

        latestMove!.removedRows.append(numbersToRemove)
        latestMove!.removedRowPlaceholders.append(indeces[0])

        numbers.removeObjects(numbersToRemove)
    }

    func undoRowRemoval() -> [Int]? {
        guard latestMove != nil else { return nil }
        guard latestMove!.removedRows.count > 0 else { return nil }

        var indecesAdded: [Int] = []

        // For the placeholders to be correct, we need to bring back the rows in
        // reverse order to what they were removed in
        for rowIndex in (0..<latestMove!.removedRows.count).reverse() {
            let placeholder = latestMove!.removedRowPlaceholders[rowIndex]
            let removedRow = latestMove!.removedRows[rowIndex]
            indecesAdded += Array(placeholder..<placeholder + removedRow.count)
            numbers.insertContentsOf(removedRow, at: placeholder)
        }

        latestMove!.removedRows.removeAll()
        latestMove!.removedRowPlaceholders.removeAll()
        return indecesAdded
    }

    func makeNextRound() -> Bool {
        return makeNextRound(usingNumbers: nextRoundNumbers())
    }

    func makeNextRound(usingNumbers nextRoundNumbers: [Number]) -> Bool {
        if nextRoundNumbers.count > 0 {
            numbers.last.marksEndOfRound = true // In case this was lost with row removals
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

    func pruneValueCounts() {
        let unrepresentedValueCounts = valueCounts.filter({ $1 == 0 })

        for (value, _) in unrepresentedValueCounts {
            valueCounts.removeValueForKey(value)
        }
    }

    func incrementValueCount(value: Int) {
        if valueCounts.keys.contains(value) {
            valueCounts[value]! += 1
        } else {
            valueCounts[value] = 1
        }
    }

    // MARK: Query game

    func nextRoundNumbers() -> [Number] {
        let nextRoundNumbers: [Number] = remainingNumbers().map({ number in
            let newNumber = number.copy() as? Number
            newNumber!.marksEndOfRound = false
            return newNumber!
        })

        nextRoundNumbers.last.marksEndOfRound = true
        return nextRoundNumbers
    }

    func nextRoundValues() -> [Int?] {
        return remainingNumbers().map({ $0.value })
    }

    func unrepresentedValues() -> [Int] {
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
        return numberCount() - numbersRemaining()
    }

    func historicNumbersCrossedOut() -> Int {
        return historicNumberCount - numbersRemaining()
    }

    func numberCount() -> Int {
        return numbers.count
    }

    func totalRows() -> Int {
        return Matrix.singleton.totalRows(numberCount())
    }

    func lastNumberColumn() -> Int {
        return Matrix.singleton.columnOfItem(atIndex: numberCount() - 1)
    }

    func indecesOnRow(containingIndex index: Int) -> [Int] {
        return Matrix.singleton.indecesOnRow(containingIndex: index, lastGameIndex: numberCount() - 1)
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

    func allCrossedOut(indeces: [Int]) -> Bool {
        return indeces.filter({ numbers[$0].crossedOut }).count == indeces.count
    }

    func allCrossedOutBetween(pair: Pair, withIncrement increment: Int = 1) -> Bool {
        if pair.first + increment >= pair.second {
            return false
        }

        for i in (pair.first + increment).stride(to: pair.second, by: increment) {
            if numberCount() > i && !isCrossedOut(i) {
                return false
            }
        }

        return true
    }

    func surplusIndecesOnRow(containingIndex index: Int) -> [Int] {
        let rowIndeces = indecesOnRow(containingIndex: index)

        if allCrossedOut(rowIndeces) {
            return rowIndeces
        } else {
            return []
        }
    }

    private func remainingNumbers() -> [Number] {
        return numbers.filter({ !$0.crossedOut })
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

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(numbers, forKey: Game.numbersCoderKey)
        aCoder.encodeObject(historicNumberCount, forKey: Game.historicNumberCountCoderKey)
        aCoder.encodeObject(currentRound, forKey: Game.currentRoundCoderKey)
        aCoder.encodeObject(startTime, forKey: Game.startTimeCoderKey)
        aCoder.encodeObject(valueCounts, forKey: Game.valueCountsCoderKey)
        aCoder.encodeObject(latestMove, forKey: Game.latestMoveCoderKey)
    }
}
