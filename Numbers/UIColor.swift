//
//  UIColor.swift
//  Numbers
//
//  Created by Elise Hein on 15/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
extension UIColor {
    // Initialiser for strings of format '#_RED_GREEN_BLUE_'
    convenience init(hex: String) {
        let redRange    = hex.startIndex.advancedBy(1)..<hex.startIndex.advancedBy(3)
        let greenRange  = hex.startIndex.advancedBy(3)..<hex.startIndex.advancedBy(5)
        let blueRange   = hex.startIndex.advancedBy(5)..<hex.startIndex.advancedBy(7)
        
        var red     : UInt32 = 0
        var green   : UInt32 = 0
        var blue    : UInt32 = 0
        
        NSScanner(string: hex.substringWithRange(redRange)).scanHexInt(&red)
        NSScanner(string: hex.substringWithRange(greenRange)).scanHexInt(&green)
        NSScanner(string: hex.substringWithRange(blueRange)).scanHexInt(&blue)
        
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
    }
}
