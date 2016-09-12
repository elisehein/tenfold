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
    func backToBack(index: Int, otherIndex: Int) -> Bool {
        return abs(index - otherIndex) == 1 || abs(index - otherIndex) == itemsPerRow
    }

    func firstIndexOfRow(containingIndex index: Int) -> Int {
        return index - columnOfItem(atIndex: index)
    }

    func lastIndexOfRow(containingIndex index: Int) -> Int {
        return index + (itemsPerRow - columnOfItem(atIndex: index)) - 1
    }

    func sameRow(index: Int, _ otherIndex: Int) -> Bool {
        let orderedIndeces = [index, otherIndex].sort { return $0 < $1 }
        return (orderedIndeces[1] - orderedIndeces[0] < itemsPerRow &&
                columnOfItem(atIndex: orderedIndeces[1]) > columnOfItem(atIndex: orderedIndeces[0]))
    }

    func sameColumn(index: Int, _ laterIndex: Int) -> Bool {
        return columnOfItem(atIndex: index) == columnOfItem(atIndex: laterIndex)
    }

    func indecesOnRow(containingIndex index: Int, lastGameIndex: Int = Int.max) -> Array<Int> {
        let first = firstIndexOfRow(containingIndex: index)
        let last = min(lastIndexOfRow(containingIndex: index), lastGameIndex)
        return Array(first...last)
    }

    func totalRows(totalItems: Int) -> Int {
        return Int(ceil(Float(totalItems) / Float(itemsPerRow)))
    }
}
