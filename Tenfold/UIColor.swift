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
        let redRange    = hex.index(hex.startIndex, offsetBy: 1)..<hex.index(hex.startIndex, offsetBy: 3)
        let greenRange  = hex.index(hex.startIndex, offsetBy: 3)..<hex.index(hex.startIndex, offsetBy: 5)
        let blueRange   = hex.index(hex.startIndex, offsetBy: 5)..<hex.index(hex.startIndex, offsetBy: 7)

        var red: UInt32 = 0
        var green: UInt32 = 0
        var blue: UInt32 = 0

        Scanner(string: String(hex[redRange])).scanHexInt32(&red)
        Scanner(string: String(hex[greenRange])).scanHexInt32(&green)
        Scanner(string: String(hex[blueRange])).scanHexInt32(&blue)

        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
    }

    // http://stackoverflow.com/a/38638676/2026098
    func interpolateTo(_ targetColor: UIColor, fraction: CGFloat) -> UIColor {
        var f = max(0, fraction)
        f = CGFloat(min(1, fraction))
        let c1 = self.cgColor.components
        let c2 = targetColor.cgColor.components
        let r: CGFloat = CGFloat(CGFloat(c1![0]) + CGFloat((c2![0]) - CGFloat(c1![0])) * f)
        let g: CGFloat = CGFloat(CGFloat(c1![1]) + (CGFloat(c2![1]) - CGFloat(c1![1])) * f)
        let b: CGFloat = CGFloat(CGFloat(c1![2]) + (CGFloat(c2![2]) - CGFloat(c1![2])) * f)
        let a: CGFloat = CGFloat(CGFloat(c1![3]) + (CGFloat(c2![3]) - CGFloat(c1![3])) * f)
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
