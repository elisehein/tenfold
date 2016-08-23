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
    case OffWhite // Sand
    case OffBlack // Dark blue
    case Accent   // Mint green
    case NeutralAccent // Dark dand
}

extension UIColor {
    class func themeColor(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .OffWhite:
            return UIColor(hex: "#FAF5EA") // Old lace
        case .OffBlack:
            return UIColor(hex: "#02293D") // Maastricht blue
        case .Accent:
//            return UIColor(hex: "#90D1AC") // Green
            return UIColor(hex: "#FFA987") // Vivid tangerine
        case .NeutralAccent:
            return UIColor(hex: "#ECDCB0") // Wheat
        }
    }

    class func themeColorDarker(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .OffWhite:
            return UIColor(hex: "#EAE3D3")
        case .OffBlack:
            return UIColor.themeColor(.OffBlack)
        case .Accent:
           return UIColor.themeColor(.Accent)
        case .NeutralAccent:
            return UIColor(hex: "#8A7F60")
        }

    }
}
