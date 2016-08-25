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
    class func themeFontWithSize(fontSize: CGFloat) -> UIFont {
        return themeFontWithSize(fontSize, weight: .Regular)
    }

    class func themeFontWithSize(fontSize: CGFloat, weight: FontWeight) -> UIFont {
        switch weight {
        case .Regular:
            return UIFont(name: "SourceSansPro-Regular", size: fontSize)!
        case .Bold:
            return UIFont(name: "SourceSansPro-Semibold", size: fontSize)!
        }

    }

}
