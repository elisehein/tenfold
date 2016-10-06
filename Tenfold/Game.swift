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

    private static let initialValueCounts: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0]

    private var numbers: [Number] = []
    private var valueCounts: [Int: Int]
    private var latestMove: GameMove? = nil

    var historicNumberCount: Int = 0
    var currentRound: Int = 1
    var startTime: NSDate? = nil

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
        var counts = initialValueCounts
        for number in givenNumbers {
            counts[number.value!]! += 1
        }
        return counts
    }

    override init() {
        numbers = Game.initialNumbers()
        historicNumberCount = numbers.count
        valueCounts = Game.valueCounts(inNumbers: numbers)
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
        guard latestMove != nil && latestMove!.crossedOutPair != nil else { return nil }

        if latestMove?.crossedOutPair != nil {
            let unpair: ((Number) -> Void) = { number in
                number.crossedOut = false
                self.incrementValueCount(number.value!)
            }

            for index in latestMove!.crossedOutPair! {
                unpair(numbers[index])
            }

            let crossedOutPair = Pair(latestMove!.crossedOutPair!)
            latestMove = nil
            return crossedOutPair
        } else {
            return nil
        }
    }

    func undoNewRound() -> [Int]? {
        guard latestMove != nil && latestMove?.numbersAdded > 0 else { return [] }

        numbers.removeLast(latestMove!.numbersAdded)
        historicNumberCount -= latestMove!.numbersAdded
        currentRound -= 1
        let indecesRemoved = Array(numbers.count..<numbers.count + latestMove!.numbersAdded)
        latestMove = nil
        return indecesRemoved
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

        latestMove!.rowsRemoved.append(numbersToRemove)
        latestMove!.placeholdersForRowsRemoved.append(indeces[0])

        numbers.removeObjects(numbersToRemove)
    }

    func undoRowRemoval() -> [Int]? {
        guard latestMove != nil && latestMove!.rowsRemoved.count > 0 else { return nil }

        var indecesAdded: [Int] = []

        // For the placeholders to be correct, we need to bring back the rows in
        // reverse order to what they were removed in
        for rowIndex in (0..<latestMove!.rowsRemoved.count).reverse() {
            let placeholder = latestMove!.placeholdersForRowsRemoved[rowIndex]
            let removedRow = latestMove!.rowsRemoved[rowIndex]
            indecesAdded += Array(placeholder..<placeholder + removedRow.count)
            numbers.insertContentsOf(removedRow, at: placeholder)
        }

        latestMove!.rowsRemoved.removeAll()
        latestMove!.placeholdersForRowsRemoved.removeAll()
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
            latestMove = GameMove(numbersAdded: nextRoundNumbers.count)

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

    func latestMoveType() -> GameMoveType? {
        return latestMove?.type()
    }

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

    func indecesOverlapTailIndeces(indeces: [Int]) -> Bool {
        let tailIndeces = Array(numbers.count - indeces.count..<numbers.count)
        return Set(tailIndeces).union(Set(indeces)).count == tailIndeces.count
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
