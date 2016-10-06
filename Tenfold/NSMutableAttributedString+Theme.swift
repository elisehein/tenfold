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

struct TextStyleProperties {
    private static let isIPad: Bool = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }()

    static let fontSize: [TextStyle: CGFloat] = {
        return [
            .Title:        isIPad ? 22 : 16,
            .Paragraph:    isIPad ? 18 : 14,
            .Pill:         isIPad ? 16 : 13,
            .Tip:          isIPad ? 14 : 13,
            .OptionTitle:  isIPad ? 14 : 13,
            .OptionDetail: isIPad ? 14 : 12
        ]
    }()

    private static let fontWeight: [TextStyle: FontWeight] = {
        return [
            .Title:        .Bold,
            .Paragraph:    .Regular,
            .Pill:         .Regular,
            .Tip:          .Italic,
            .OptionTitle:  .Bold,
            .OptionDetail: .Regular
        ]
    }()

    private static let lineSpacing: [TextStyle: CGFloat] = {
        return [
            .Title:        7,
            .Paragraph:    isIPad ? 7 : 4,
            .Pill:         0,
            .Tip:          isIPad ? 5 : 4,
            .OptionTitle:  isIPad ? 7 : 4,
            .OptionDetail: isIPad ? 7 : 4
        ]
    }()
}

extension NSMutableAttributedString {

    class func themeString(textStyle: TextStyle, _ string: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string, attributes: attributes(forTextStyle: textStyle))
    }

    class func attributes(forTextStyle textStyle: TextStyle) -> [String: AnyObject] {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = TextStyleProperties.lineSpacing[textStyle]!
        paragraphStyle.alignment = textStyle == .OptionTitle || textStyle == .OptionDetail ?
                                   .Left :
                                   .Center

        let font = UIFont.themeFontWithSize(TextStyleProperties.fontSize[textStyle]!,
                                            weight: TextStyleProperties.fontWeight[textStyle]!)

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
}
