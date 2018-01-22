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
    case title
    case paragraph
    case pill
    case tip
    case optionTitle
    case optionDetail
}

struct TextStyleProperties {
    fileprivate static let isIPad: Bool = {
        return UIDevice.current.userInterfaceIdiom == .pad
    }()

    // swiftlint:disable colon

    static let fontSize: [TextStyle: CGFloat] = {
        return [
            .title:        isIPad ? 22 : 16,
            .paragraph:    isIPad ? 18 : 14,
            .pill:         isIPad ? 16 : 13,
            .tip:          isIPad ? 14 : 13,
            .optionTitle:  isIPad ? 14 : 13,
            .optionDetail: isIPad ? 14 : 12
        ]
    }()

    fileprivate static let fontWeight: [TextStyle: FontWeight] = {
        return [
            .title:        .bold,
            .paragraph:    .regular,
            .pill:         .regular,
            .tip:          .italic,
            .optionTitle:  .bold,
            .optionDetail: .regular
        ]
    }()

    fileprivate static let lineSpacing: [TextStyle: CGFloat] = {
        return [
            .title:        7,
            .paragraph:    isIPad ? 7 : 4,
            .pill:         0,
            .tip:          isIPad ? 5 : 4,
            .optionTitle:  isIPad ? 7 : 4,
            .optionDetail: isIPad ? 7 : 4
        ]
    }()

    // swiftlint:enable colon
}

extension NSMutableAttributedString {

    class func themeString(_ textStyle: TextStyle, _ string: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string, attributes: attributes(forTextStyle: textStyle))
    }

    class func attributes(forTextStyle textStyle: TextStyle) -> [NSAttributedStringKey: Any] {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = TextStyleProperties.lineSpacing[textStyle]!
        paragraphStyle.alignment = textStyle == .optionTitle || textStyle == .optionDetail ?
                                   .left :
                                   .center

        let font = UIFont.themeFontWithSize(TextStyleProperties.fontSize[textStyle]!,
                                            weight: TextStyleProperties.fontWeight[textStyle]!)

        var attributes = [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: UIColor.themeColor(forTextStyle: textStyle)
        ]

        if textStyle == .pill {
            attributes[NSAttributedStringKey.kern] = 1.2 as NSObject?
        }

        return attributes
    }
}
