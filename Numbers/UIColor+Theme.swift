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
    case OffBlack
}

extension UIColor {
    class func themeColor (themeColor: ThemeColor) -> UIColor {
        switch (themeColor) {
        case .OffWhite:
            return UIColor(hex: "#FFFEF1")
        case .OffBlack:
            return UIColor(hex: "#20201E")
        }
    }
    
    class func themeColorHighlighted(themeColor: ThemeColor) -> UIColor {
        switch (themeColor) {
        case .OffWhite:
            return UIColor(hex: "#E6E4D0")
        case .OffBlack:
            return UIColor.grayColor()
        }
    }
}
