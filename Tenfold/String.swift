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
    func indexOfCharacter(char: Character) -> Int? {
        if let idx = self.characters.indexOf(char) {
            return self.startIndex.distanceTo(idx)
        }
        return nil
    }

    // http://stackoverflow.com/a/24056932/2026098
    func indexOf(string: String) -> Int? {
        if let range: Range<String.Index> = self.rangeOfString(string) {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return nil
        }
    }
}
