//
//  Number.swift
//  Tenfold
//
//  Created by Elise Hein on 12/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Number: NSObject, NSCopying, NSCoding {
    var value: Int?
    var crossedOut: Bool
    var marksEndOfRound: Bool

    private static let valueCoderKey = "gameNumberValueCoderKey"
    private static let crossedOutCoderKey = "gameNumberCrossedOutCoderKey"
    private static let marksEndOfRoundCoderKey = "gameNumberMarksEndOfRoundCoderKey"

    init(value: Int?, crossedOut: Bool, marksEndOfRound: Bool) {
        self.value = value
        self.crossedOut = crossedOut
        self.marksEndOfRound = marksEndOfRound
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        value = Int(aDecoder.decodeIntForKey(Number.valueCoderKey))
        crossedOut = aDecoder.decodeBoolForKey(Number.crossedOutCoderKey)
        marksEndOfRound = aDecoder.decodeBoolForKey(Number.marksEndOfRoundCoderKey)
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Number(value: value, crossedOut: crossedOut, marksEndOfRound: marksEndOfRound)
        return copy
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(Int32(value!), forKey: Number.valueCoderKey)
        aCoder.encodeBool(crossedOut, forKey: Number.crossedOutCoderKey)
        aCoder.encodeBool(marksEndOfRound, forKey: Number.marksEndOfRoundCoderKey)
    }
}
