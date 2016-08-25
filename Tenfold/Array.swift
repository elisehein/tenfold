//
//  Array.swift
//  Tenfold
//
//  Created by Elise Hein on 12/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

extension Array {
    var last: Element {
        return self[self.endIndex - 1]
    }
}

// swiftlint:disable:next line_length
// http://supereasyapps.com/blog/2015/9/22/how-to-remove-an-array-of-objects-from-a-swift-2-array-removeobjectsinarray
extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }

    mutating func removeObjects(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}
