//
//  Grid.swift
//  Numbers
//
//  Created by Elise Hein on 28/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Grid: NSObject {

    static let singleton = Grid(itemsPerRow: GameRules.numbersPerLine)

    private let itemsPerRow: Int

    private init (itemsPerRow: Int) {
        self.itemsPerRow = itemsPerRow
        super.init()
    }

    func firstIndexOfRow (containingIndex index: Int) -> Int {
        return index - positionOnRow(index)
    }

    func lastIndexOfRow (containingIndex index: Int) -> Int {
        return index + (itemsPerRow - positionOnRow(index)) - 1
    }

    func isFirstOnRow (index: Int) -> Bool {
        return positionOnRow(index) == 0
    }

    func isLastOnRow (index: Int) -> Bool {
        return positionOnRow(index) == itemsPerRow - 1
    }

    func sameRow (index: Int, _ laterIndex: Int) -> Bool {
        return (laterIndex - index < itemsPerRow &&
                positionOnRow(laterIndex) > positionOnRow(index))
    }

    func sameColumn (index: Int, _ laterIndex: Int) -> Bool {
        return positionOnRow(index) == positionOnRow(laterIndex)
    }

    func positionOnRow (index: Int) -> Int {
        return index % itemsPerRow
    }

}
