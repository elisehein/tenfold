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

    fileprivate static let valueCoderKey = "gameNumberValueCoderKey"
    fileprivate static let crossedOutCoderKey = "gameNumberCrossedOutCoderKey"
    fileprivate static let marksEndOfRoundCoderKey = "gameNumberMarksEndOfRoundCoderKey"

    init(value: Int?, crossedOut: Bool, marksEndOfRound: Bool) {
        self.value = value
        self.crossedOut = crossedOut
        self.marksEndOfRound = marksEndOfRound
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        value = Int(aDecoder.decodeCInt(forKey: Number.valueCoderKey))
        crossedOut = aDecoder.decodeBool(forKey: Number.crossedOutCoderKey)
        marksEndOfRound = aDecoder.decodeBool(forKey: Number.marksEndOfRoundCoderKey)
    }

    func copy(with zone: NSZone?) -> Any {
        let copy = Number(value: value, crossedOut: crossedOut, marksEndOfRound: marksEndOfRound)
        return copy
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encodeCInt(Int32(value!), forKey: Number.valueCoderKey)
        aCoder.encode(crossedOut, forKey: Number.crossedOutCoderKey)
        aCoder.encode(marksEndOfRound, forKey: Number.marksEndOfRoundCoderKey)
    }
}
