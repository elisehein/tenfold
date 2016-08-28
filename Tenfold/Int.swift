//
//  Int.swift
//  Tenfold
//
//  Created by Elise Hein on 28/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

extension Int {
    func asWord() -> String {
        switch self {
        case 1:
            return "1"
        case 2:
            return "two"
        case 3:
            return "three"
        case 4:
            return "four"
        case 5:
            return "five"
        case 6:
            return "six"
        case 7:
            return "seven"
        case 8:
            return "eight"
        case 9:
            return "nine"
        default:
            return String(self)
        }
    }
}
