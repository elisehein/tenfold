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

        nextRoundNumbers.last?.marksEndOfRound = true
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

    func indecesOverlapTailIndeces(_ indeces: [Int]) -> Bool {
        let tailIndeces = Array(numbers.count - indeces.count..<numbers.count)
        return Set(tailIndeces).union(Set(indeces)).count == tailIndeces.count
    }

    func indecesOnRow(containingIndex index: Int) -> [Int] {
        return Matrix.singleton.indecesOnRow(containingIndex: index, lastGameIndex: numberCount() - 1)
    }

    func valueAtIndex(_ index: Int) -> Int? {
        return numbers[index].value
    }

    func marksEndOfRound(_ index: Int) -> Bool {
        return numbers[index].marksEndOfRound
    }

    func isCrossedOut(_ index: Int) -> Bool {
        return numbers[index].crossedOut
    }

    func allCrossedOut(_ indeces: [Int]) -> Bool {
        return indeces.filter({ numbers[$0].crossedOut }).count == indeces.count
    }

    func allCrossedOutBetween(_ pair: Pair, withIncrement increment: Int = 1) -> Bool {
        if pair.first + increment >= pair.second {
            return false
        }

        for i in stride(from: (pair.first + increment), to: pair.second, by: increment) {
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

    func potentialPairs() -> [Pair] {
        var pairs = [Pair]()

        for number in remainingNumbers() {
            let index = numbers.index(of: number)
            let potentialPartners = potentialPartnerIndeces(forIndex: index!)

            for partnerIndex in potentialPartners {
                let pair = Pair(index!, partnerIndex)
                if Pairing.validate(pair, inGame: self) {
                    pairs.append(pair)
                }
            }
        }

        return pairs
    }
}

// MARK: Querying helpers

fileprivate extension Game {

    func remainingNumbers() -> [Number] {
        return numbers.filter({ !$0.crossedOut })
    }

    func potentialPartnerIndeces(forIndex index: Int) -> [Int] {
        var potentialIndeces = [Int]()

        guard !numbers[index].crossedOut else { return potentialIndeces }

        // By only checking the ahead and not backwards, we don't end up with duplicate pairs,
        // And can bypass checking later.
        if let partnerAfter = nextAvailable(to: index, step: 1) {
            potentialIndeces.append(partnerAfter)
        }

        if let partnerDown = nextAvailable(to: index, step: 9) {
            potentialIndeces.append(partnerDown)
        }

        return potentialIndeces
    }

    func nextAvailable(to index: Int, step: Int) -> Int? {
        var siblingIndex = index + step

        if siblingIndex < numbers.count && siblingIndex >= 0 {
            while siblingIndex + step < numbers.count &&
                siblingIndex + step > 0 &&
                numbers[siblingIndex].crossedOut {
                    siblingIndex = siblingIndex + step
            }

            if !numbers[siblingIndex].crossedOut {
                return siblingIndex
            }
        }

        return nil
    }
}
