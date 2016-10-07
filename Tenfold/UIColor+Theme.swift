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
    case Tan
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
        case .Tan:
            return UIColor(hex: "#94855D") // Gold fusion
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
        case .Tan:
            return UIColor(hex: "#5A491B") // Liver
        default:
            return UIColor.themeColor(themeColor)
        }
    }

    class func themeColor(forTextStyle textStyle: TextStyle) -> UIColor {
        switch textStyle {
        case .Pill:
            return UIColor.whiteColor().colorWithAlphaComponent(0.95)
        default:
            return UIColor.themeColor(.OffBlack)
        }
    }
}
