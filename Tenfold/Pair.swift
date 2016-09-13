//
//  Pair.swift
//  Tenfold
//
//  Created by Elise Hein on 13/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

struct Pair {
    let first: Int
    let second: Int

    init(_ index: Int, _ otherIndex: Int) {
        if index > otherIndex {
            self.first = otherIndex
            self.second = index
        } else {
            self.first = index
            self.second = otherIndex
        }
    }

    init(_ indeces: [Int]) {
        self.init(indeces[0], indeces[1])
    }

    func asArray() -> [Int] {
       return [first, second]
    }
}
