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
//            return UIColor(hex: "#90D1AC") // Green
//            return UIColor(hex: "#F4AFAB") // Peachy
//            return UIColor(hex: "#F4EEA9") // Yellow
            return UIColor(hex: "#DDD92A") // Pear
        case .OffWhite:
            return UIColor(hex: "#FAF5EA")
        case .OffBlack:
            return UIColor(hex: "#02293D")
        }
    }

    class func themeColorHighlighted(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .Accent:
           return UIColor.themeColor(.Accent)
        case .OffWhite:
            return UIColor(hex: "#CFC1AC")
        case .OffBlack:
            return UIColor.themeColor(.OffBlack)
        }
    }
}
