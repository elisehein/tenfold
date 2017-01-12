//
//  Array.swift
//  Tenfold
//
//  Created by Elise Hein on 12/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

// swiftlint:disable:next line_length
// http://supereasyapps.com/blog/2015/9/22/how-to-remove-an-array-of-objects-from-a-swift-2-array-removeobjectsinarray
extension Array where Element: Equatable {
    mutating func removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }

    mutating func removeObjects(_ array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }

    func randomElement() -> Element {
        let randomIndex = Int(arc4random_uniform(UInt32(count)))
        return self[randomIndex]
    }
}
