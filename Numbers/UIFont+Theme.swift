//
//  File.swift
//  Numbers
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum FontWeight {
    case Regular
    case Bold
}

extension UIFont {
    class func themeFontWithSize (fontSize: CGFloat) -> UIFont {
        return themeFontWithSize(fontSize, weight: .Regular)
    }

    class func themeFontWithSize (fontSize: CGFloat, weight: FontWeight) -> UIFont {
//        return UIFont(name: "Lucida Sans Unicode", size: fontSize)!
//        return UIFont(name: "Montserrat", size: fontSize)!

        switch weight {
        case .Regular:
            return UIFont(name: "Avenir Next LT Pro", size: fontSize)!
        case .Bold:
            return UIFont(name: "AvenirNextLTPro-Demi", size: fontSize)!
        }

    }

}
