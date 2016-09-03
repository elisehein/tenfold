//
//  ThemeColors.swift
//  Tenfold
//
//  Created by Elise Hein on 10/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum ThemeColor {
    case OffWhite
    case OffWhiteShaded
    case OffBlack
    case Accent
    case SecondaryAccent
}

extension UIColor {
    class func themeColor(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .OffWhite:
            return UIColor(hex: "#FAF5EA") // Old lace
        case .OffWhiteShaded:
            return UIColor(hex: "#F0E4C3") // Dutch white
        case .OffBlack:
            return UIColor(hex: "#02293D") // Maastricht blue
        case .Accent:
            return UIColor(hex: "#F38D68") // Atomic tangerine
        case .SecondaryAccent:
            return UIColor(hex: "#BAD4AA") // Light moss green
        }
    }

    class func themeColorDarker(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .SecondaryAccent:
            return UIColor(hex: "#2F4720") // Kombu green
        default:
            return UIColor.themeColor(themeColor)
        }
    }
}
