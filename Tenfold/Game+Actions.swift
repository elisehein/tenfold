//
//  Game+Actions.swift
//  Tenfold
//
//  Created by Elise Hein on 06/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension Game {
    func crossOut(_ pair: Pair) {
        startTime = Date()
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

    fileprivate func removeRow(containing index: Int) -> [Int] {
        let surplusIndeces = surplusIndecesOnRow(containingIndex: index)
        removeRow(containing: surplusIndeces)
        return surplusIndeces
    }

    fileprivate func removeRow(containing indeces: [Int]) {
        guard latestMove != nil else { return }
        guard indeces.count > 0 else { return }
        let numbersToRemove = numbers.filter({ indeces.contains(numbers.index(of: $0)!) })

        latestMove!.rowsRemoved.append(numbersToRemove)
        latestMove!.placeholdersForRowsRemoved.append(indeces[0])

        numbers.removeObjects(numbersToRemove)
    }

    func undoRowRemoval() -> [Int]? {
        guard latestMove != nil && latestMove!.rowsRemoved.count > 0 else { return nil }

        var indecesAdded: [Int] = []

        // For the placeholders to be correct, we need to bring back the rows in
        // reverse order to what they were removed in
        for rowIndex in (0..<latestMove!.rowsRemoved.count).reversed() {
            let placeholder = latestMove!.placeholdersForRowsRemoved[rowIndex]
            let removedRow = latestMove!.rowsRemoved[rowIndex]
            indecesAdded += Array(placeholder..<placeholder + removedRow.count)
            numbers.insert(contentsOf: removedRow, at: placeholder)
        }

        latestMove!.rowsRemoved.removeAll()
        latestMove!.placeholdersForRowsRemoved.removeAll()
        return indecesAdded
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
}

// MARK: Actions helpers

private extension Game {
    func incrementValueCount(_ value: Int) {
        if valueCounts.keys.contains(value) {
            valueCounts[value]! += 1
        } else {
            valueCounts[value] = 1
        }
    }
}
