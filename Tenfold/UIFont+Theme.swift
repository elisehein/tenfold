//
//  File.swift
//  Tenfold
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum FontWeight {
    case regular
    case bold
    case italic
}

extension UIFont {
    class func themeFontWithSize(_ fontSize: CGFloat) -> UIFont {
        return themeFontWithSize(fontSize, weight: .regular)
    }

    class func themeFontWithSize(_ fontSize: CGFloat, weight: FontWeight) -> UIFont {
        switch weight {
        case .regular:
            return UIFont(name: "SourceSansPro-Regular", size: fontSize)!
        case .bold:
            return UIFont(name: "SourceSansPro-Semibold", size: fontSize)!
        case .italic:
            return UIFont(name: "SourceSansPro-It", size: fontSize)!
        }

    }

}
