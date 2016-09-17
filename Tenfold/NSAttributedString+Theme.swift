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
    case Notification
}

extension NSAttributedString {
    class func styled(as textStyle: TextStyle, usingText text: String) -> NSMutableAttributedString {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing(forTextStyle: textStyle)
        paragraphStyle.alignment = .Center

        let font = UIFont.themeFontWithSize(fontSize(forTextStyle: textStyle),
                                            weight: textStyle == .Title ? .Bold : .Regular)

        var attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color(forTextStyle: textStyle)
        ]

        if textStyle == .Notification {
            attributes[NSKernAttributeName] = 1.2
        }

        return NSMutableAttributedString(string: text, attributes: attributes)
    }

    private class func color(forTextStyle textStyle: TextStyle) -> UIColor {
        switch textStyle {
        case .Notification:
            return UIColor.themeColor(.OffWhite)
        default:
            return UIColor.themeColor(.OffBlack)
        }
    }

    private class func lineSpacing(forTextStyle textStyle: TextStyle) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {

            switch textStyle {
            case .Paragraph:
                return 7
            case .Notification:
                return 0
            case .Title:
                return 7
            }

        } else {

            switch textStyle {
            case .Paragraph:
                return 4
            case .Notification:
                return 0
            case .Title:
                return 7
            }
        }
    }

    private class func fontSize(forTextStyle textStyle: TextStyle) -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {

            switch textStyle {
            case .Paragraph:
                return 18
            case .Notification:
                return 16
            case .Title:
                return 22
            }

        } else {

            switch textStyle {
            case .Paragraph:
                return 14
            case .Notification:
                return 13
            case .Title:
                return 16
            }
        }

    }
}
