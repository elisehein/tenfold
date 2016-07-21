//
//  ThemeColors.swift
//  Numbers
//
//  Created by Elise Hein on 10/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum ThemeColor {
    case Accent   // Mint green
    case OffWhite // Sand
    case OffBlack // Dark blue
}

extension UIColor {
    class func themeColor(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .Accent:
            return UIColor(hex: "#90D1AC")
        case .OffWhite:
//            return UIColor(hex: "#FFFEF1")
//            return UIColor(hex: "#EDE6D2")
            return UIColor(hex: "#FAF5EA")
        case .OffBlack:
//            return UIColor(hex: "#20201E")
//            return UIColor(hex: "#090809")
            return UIColor(hex: "#02293D")
        }
    }

    class func themeColorHighlighted(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .Accent:
           return UIColor.themeColor(.Accent)
        case .OffWhite:
//            return UIColor(hex: "#E6E4D0")
//            return UIColor(hex: "#CFC1AC")
            return UIColor(hex: "#90D1AC")
        case .OffBlack:
            return UIColor.grayColor()
        }
    }
}
