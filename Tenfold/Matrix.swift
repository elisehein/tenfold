//
//  Matrix.swift
//  Tenfold
//
//  Created by Elise Hein on 28/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Matrix: NSObject {

    private let itemsPerRow: Int
    static let singleton = Matrix(itemsPerRow: Game.numbersPerRow)

    init (itemsPerRow: Int) {
        self.itemsPerRow = itemsPerRow
        super.init()
    }

    func columnOfItem(atIndex index: Int) -> Int {
        return index % itemsPerRow
    }

    // Back to back refers to numbers that are right next to each
    // other either horizontally (incl. last column of previous row
    // and first column of this one), or vertically.
    func backToBack(_ pair: Pair) -> Bool {
        return pair.second - pair.first == 1 || pair.second - pair.first == itemsPerRow
    }

    func firstIndexOfRow(containingIndex index: Int) -> Int {
        return index - columnOfItem(atIndex: index)
    }

    func lastIndexOfRow(containingIndex index: Int) -> Int {
        return index + (itemsPerRow - columnOfItem(atIndex: index)) - 1
    }

    func sameRow(_ pair: Pair) -> Bool {
        return (pair.second - pair.first < itemsPerRow &&
                columnOfItem(atIndex: pair.second) > columnOfItem(atIndex: pair.first))
    }

    func sameColumn(_ pair: Pair) -> Bool {
        return columnOfItem(atIndex: pair.first) == columnOfItem(atIndex: pair.second)
    }

    func indecesOnRow(containingIndex index: Int, lastGameIndex: Int = Int.max) -> [Int] {
        let first = firstIndexOfRow(containingIndex: index)
        let last = min(lastIndexOfRow(containingIndex: index), lastGameIndex)
        return Array(first...last)
    }

    func totalRows(_ totalItems: Int) -> Int {
        return Int(ceil(Float(totalItems) / Float(itemsPerRow)))
    }
}
