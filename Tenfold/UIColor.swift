//
//  UIColor.swift
//  Tenfold
//
//  Created by Elise Hein on 15/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    // http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
    // Initialiser for strings of format '#_RED_GREEN_BLUE_'
    convenience init(hex: String) {
        let redRange    = hex.startIndex.advancedBy(1)..<hex.startIndex.advancedBy(3)
        let greenRange  = hex.startIndex.advancedBy(3)..<hex.startIndex.advancedBy(5)
        let blueRange   = hex.startIndex.advancedBy(5)..<hex.startIndex.advancedBy(7)

        var red: UInt32 = 0
        var green: UInt32 = 0
        var blue: UInt32 = 0

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

    // http://stackoverflow.com/a/38638676/2026098
    func interpolateTo(targetColor: UIColor, fraction: CGFloat) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)
        let c1 = CGColorGetComponents(self.CGColor)
        let c2 = CGColorGetComponents(targetColor.CGColor)
        let r: CGFloat = CGFloat(c1[0] + (c2[0] - c1[0]) * f)
        let g: CGFloat = CGFloat(c1[1] + (c2[1] - c1[1]) * f)
        let b: CGFloat = CGFloat(c1[2] + (c2[2] - c1[2]) * f)
        let a: CGFloat = CGFloat(c1[3] + (c2[3] - c1[3]) * f)
        return UIColor.init(red: r, green: g, blue: b, alpha: a)
    }

    // http://stackoverflow.com/a/27387615/2026098
    func darken() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: max(r - 0.1, 0.0),
                           green: max(g - 0.1, 0.0),
                           blue: max(b - 0.1, 0.0),
                           alpha: a)
        }

        return UIColor()
    }
}
