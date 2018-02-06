//
//  String.swift
//  Tenfold
//
//  Created by Elise Hein on 24/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

extension String {
    // http://stackoverflow.com/a/27579889/2026098
    func indexOfCharacter(_ char: Character) -> Int? {
        if let idx = self.index(of: char) {
            return self.distance(from: self.startIndex, to: idx)
        }
        return nil
    }

    // http://stackoverflow.com/a/24056932/2026098
    func indexOf(_ string: String) -> Int? {
        if let range: Range<String.Index> = self.range(of: string) {
            return self.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return nil
        }
    }
}
