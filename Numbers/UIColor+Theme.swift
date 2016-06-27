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
    case OffWhite
    case OffWhiteDark
    case OffBlack
}

extension UIColor {
    class func themeColor (themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .OffWhite:
//            return UIColor(hex: "#FFFEF1")
            return UIColor(hex: "#EDE6D2")
        case .OffWhiteDark:
//            return UIColor(hex: "#CBC9B0")
            return UIColor(hex: "#B78837")
        case .OffBlack:
//            return UIColor(hex: "#20201E")
            return UIColor(hex: "#090809")
        }
    }

    class func themeColorHighlighted(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .OffWhite:
            return UIColor(hex: "#E6E4D0")
        case .OffWhiteDark:
            return UIColor.themeColor(.OffWhite)
        case .OffBlack:
            return UIColor.grayColor()
        }
    }
}
