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
            return UIColor(hex: "#ECDCB0") // Wheat
        case .OffBlack:
            return UIColor(hex: "#02293D") // Maastricht blue
        case .Accent:
            return UIColor(hex: "#FFA987") // Vivid tangerine
        case .SecondaryAccent:
            return UIColor(hex: "#D4E6B5") // Tea green
        }
    }

    class func themeColorDarker(themeColor: ThemeColor) -> UIColor {
        switch themeColor {
        case .OffWhite:
            return UIColor(hex: "#EAE3D3")
        case .OffWhiteShaded:
            return UIColor(hex: "#8A7F60")
        case .OffBlack:
            return UIColor.themeColor(.OffBlack)
        case .Accent:
           return UIColor.themeColor(.Accent)
        case .SecondaryAccent:
            return UIColor(hex: "#3D4431")
        }
    }
}
