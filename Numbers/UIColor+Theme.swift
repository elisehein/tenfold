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
            return UIColor(red: 1, green: 1, blue: 0.94, alpha: 1)
        case .OffBlack:
            return UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        }
    }
    
    class func themeColorHighlighted(themeColor: ThemeColor) -> UIColor {
        switch (themeColor) {
        case .OffWhite:
            return UIColor(red: 0.8, green: 0.87, blue: 0.78, alpha: 1)
        case .OffBlack:
            return UIColor.grayColor()
        }
    }
}
