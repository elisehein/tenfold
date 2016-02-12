//
//  Number.swift
//  Numbers
//
//  Created by Elise Hein on 12/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class Number: NSObject, NSCopying {
    var value: Int
    var crossedOut: Bool
    var marksEndOfRound: Bool
    
    init(value: Int, crossedOut: Bool, marksEndOfRound: Bool) {
        self.value = value
        self.crossedOut = crossedOut
        self.marksEndOfRound = marksEndOfRound
        super.init()
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Number(value: value, crossedOut: crossedOut, marksEndOfRound: marksEndOfRound)
        return copy
    }
}
