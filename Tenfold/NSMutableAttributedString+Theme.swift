//
//  NSMutableAttributedString+Theme.swift
//  Tenfold
//
//  Created by Elise Hein on 06/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum TextStyle {
    case Title
    case Paragraph
    case Pill
    case Tip
}

extension NSMutableAttributedString {
    class func themeString(textStyle: TextStyle, _ string: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string, attributes: attributes(forTextStyle: textStyle))
    }

    class func attributes(forTextStyle textStyle: TextStyle) -> [String: AnyObject] {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = themeLineSpacing(forTextStyle: textStyle)
        paragraphStyle.alignment = .Center

        let font = UIFont.themeFontWithSize(themeFontSize(forTextStyle: textStyle),
                                            weight: themeFontWeight(forTextStyle: textStyle))

        var attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.themeColor(forTextStyle: textStyle)
        ]

        if textStyle == .Pill {
            attributes[NSKernAttributeName] = 1.2
        }

        return attributes
    }

    private class func themeLineSpacing(forTextStyle textStyle: TextStyle) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {

            switch textStyle {
            case .Paragraph:
                return 7
            case .Pill:
                return 0
            case .Title:
                return 7
            case .Tip:
                return 5
            }

        } else {

            switch textStyle {
            case .Paragraph:
                return 4
            case .Pill:
                return 0
            case .Title:
                return 7
            case .Tip:
                return 4
            }
        }
    }

    class func themeFontSize(forTextStyle textStyle: TextStyle) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {

            switch textStyle {
            case .Paragraph:
                return 18
            case .Pill:
                return 16
            case .Title:
                return 22
            case .Tip:
                return 14
            }

        } else {

            switch textStyle {
            case .Paragraph:
                return 14
            case .Pill:
                return 13
            case .Title:
                return 16
            case .Tip:
                return 13
            }
        }

    }

    private class func themeFontWeight(forTextStyle textStyle: TextStyle) -> FontWeight {
        switch textStyle {
        case .Title:
            return .Bold
        case .Tip:
            return .Italic
        default:
            return .Regular
        }
    }
}
