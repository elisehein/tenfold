//
//  Number.swift
//  Numbers
//
//  Created by Elise Hein on 12/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Number: NSObject, NSCopying, NSCoding {
    var value: Int
    var crossedOut: Bool
    var marksEndOfRound: Bool

    private static let valueCoderKey = "gameNumberValueCoderKey"
    private static let crossedOutCoderKey = "gameNumberCrossedOutCoderKey"
    private static let marksEndOfRoundCoderKey = "gameNumberMarksEndOfRoundCoderKey"

    init(value: Int, crossedOut: Bool, marksEndOfRound: Bool) {
        self.value = value
        self.crossedOut = crossedOut
        self.marksEndOfRound = marksEndOfRound
        super.init()
    }

    required init (coder aDecoder: NSCoder) {
        self.value = (aDecoder.decodeObjectForKey(Number.valueCoderKey) as? Int)!
        self.crossedOut = (aDecoder.decodeObjectForKey(Number.crossedOutCoderKey) as? Bool)!
        self.marksEndOfRound = (aDecoder.decodeObjectForKey(Number.marksEndOfRoundCoderKey) as? Bool)!
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Number(value: value, crossedOut: crossedOut, marksEndOfRound: marksEndOfRound)
        return copy
    }

    func encodeWithCoder (aCoder: NSCoder) {
        aCoder.encodeObject(value, forKey: Number.valueCoderKey)
        aCoder.encodeObject(crossedOut, forKey: Number.crossedOutCoderKey)
        aCoder.encodeObject(marksEndOfRound, forKey: Number.marksEndOfRoundCoderKey)
    }
}
