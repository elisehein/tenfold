//
//  NSAttributedString.swift
//  Tenfold
//
//  Created by Elise Hein on 17/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum TextStyle {
    case Title
    case Paragraph
}

extension NSAttributedString {
    class func themeAttrString(textStyle: TextStyle, usingText text: String) -> NSAttributedString {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing(forTextStyle: textStyle)
        paragraphStyle.alignment = .Center

        let font = UIFont.themeFontWithSize(fontSize(forTextStyle: textStyle))

        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.themeColor(.OffBlack)
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    private class func lineSpacing(forTextStyle textStyle: TextStyle) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 7
        } else {
            return 5
        }
    }

    private class func fontSize(forTextStyle textStyle: TextStyle) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 18
        } else {
            return 14
        }

    }
}
