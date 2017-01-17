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
    case offWhite
    case offWhiteShaded
    case offBlack
    case tan
    case accent
    case secondaryAccent
}

extension UIColor {
    class func themeColor(_ themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .offWhite:
            return UIColor(hex: "#FAF5EA") // Old lace
        case .offWhiteShaded:
            return UIColor(hex: "#F0E4C3") // Dutch white
        case .offBlack:
            return UIColor(hex: "#02293D") // Maastricht blue
        case .tan:
            return UIColor(hex: "#94855D") // Gold fusion
        case .accent:
            return UIColor(hex: "#F38D68") // Atomic tangerine
        case .secondaryAccent:
            return UIColor(hex: "#BAD4AA") // Light moss green
        }
    }

    class func themeColorDarker(_ themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .secondaryAccent:
            return UIColor(hex: "#2F4720") // Kombu green
        case .tan:
            return UIColor(hex: "#5A491B") // Liver
        default:
            return UIColor.themeColor(themeColor)
        }
    }

    class func themeColor(forTextStyle textStyle: TextStyle) -> UIColor {
        switch textStyle {
        case .pill:
            return UIColor.white.withAlphaComponent(0.95)
        default:
            return UIColor.themeColor(.offBlack)
        }
    }
}
