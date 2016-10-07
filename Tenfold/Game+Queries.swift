//
//  Game+Queries.swift
//  Tenfold
//
//  Created by Elise Hein on 06/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

extension Game {
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
}
