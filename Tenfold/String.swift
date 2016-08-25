//
//  String.swift
//  Tenfold
//
//  Created by Elise Hein on 24/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

// Adapted from http://stackoverflow.com/a/27579889/2026098

import Foundation

extension String {
    public func indexOfCharacter(char: Character) -> Int? {
        if let idx = self.characters.indexOf(char) {
            return self.startIndex.distanceTo(idx)
        }
        return nil
    }
}
