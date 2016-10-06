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
    case OptionTitle
    case OptionDetail
}

extension NSMutableAttributedString {
    class func themeString(textStyle: TextStyle, _ string: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string, attributes: attributes(forTextStyle: textStyle))
    }

    class func attributes(forTextStyle textStyle: TextStyle) -> [String: AnyObject] {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = themeLineSpacing(forTextStyle: textStyle)
        paragraphStyle.alignment = textStyle == .OptionTitle || textStyle == .OptionDetail ?
                                   .Left :
                                   .Center

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
            case .Pill:
                return 0
            case .Tip:
                return 5
            default:
                return 7
            }

        } else {

            switch textStyle {
            case .Pill:
                return 0
            case .Title:
                return 7
            default:
                return 4
            }
        }
    }

    class func themeFontSize(forTextStyle textStyle: TextStyle) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {

            switch textStyle {
            case .Pill:
                return 16
            case .Title:
                return 22
            case .Tip:
                return 14
            case .OptionDetail:
                return 14
            default:
                return 18
            }

        } else {

            switch textStyle {
            case .Paragraph:
                return 14
            case .Title:
                return 16
            case .OptionDetail:
                return 12
            default:
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
        case .OptionTitle:
            return .Bold
        default:
            return .Regular
        }
    }
}
