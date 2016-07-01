//
//  Matrix.swift
//  Numbers
//
//  Created by Elise Hein on 28/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Matrix: NSObject {

    private let itemsPerRow: Int

    init (itemsPerRow: Int) {
        self.itemsPerRow = itemsPerRow
        super.init()
    }

    func columnOfItem (atIndex index: Int) -> Int {
        return index % itemsPerRow
    }

    func firstIndexOfRow (containingIndex index: Int) -> Int {
        return index - columnOfItem(atIndex: index)
    }

    func lastIndexOfRow (containingIndex index: Int) -> Int {
        return index + (itemsPerRow - columnOfItem(atIndex: index)) - 1
    }

    func isFirstOnRow (index: Int) -> Bool {
        return columnOfItem(atIndex: index) == 0
    }

    func isLastOnRow (index: Int) -> Bool {
        return columnOfItem(atIndex: index) == itemsPerRow - 1
    }

    func sameRow (index: Int, _ laterIndex: Int) -> Bool {
        return (laterIndex - index < itemsPerRow &&
                columnOfItem(atIndex: laterIndex) > columnOfItem(atIndex: index))
    }

    func sameColumn (index: Int, _ laterIndex: Int) -> Bool {
        return columnOfItem(atIndex: index) == columnOfItem(atIndex: laterIndex)
    }

    func totalRows (totalItems: Int) -> Int {
        return Int(ceil(Float(totalItems) / Float(itemsPerRow)))
    }
}
