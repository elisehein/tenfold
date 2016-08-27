//
//  Button.swift
//  Tenfold
//
//  Created by Elise Hein on 25/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Button: UIButton {

    var strikeThrough = false

    override func setTitle(title: String?, forState state: UIControlState) {
        super.setAttributedTitle(constructAttributedString(withText: title,
                                                           color: UIColor.themeColor(.OffBlack)),
                                 forState: state)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        setAttributedTitle(constructAttributedString(withText: titleLabel?.text,
                                                     color: UIColor.themeColor(.Accent)),
                           forState: .Normal)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        setAttributedTitle(constructAttributedString(withText: titleLabel?.text,
                                                     color: UIColor.themeColor(.OffBlack)),
                           forState: .Normal)
    }

    private func constructAttributedString(withText text: String?,
                                           color: UIColor) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center

        var font = UIFont.themeFontWithSize(14)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = font.fontWithSize(18)
        }

        let attrString = NSMutableAttributedString(string: (text?.uppercaseString)!)
        let fullRange = NSRange(location: 0, length: attrString.length)

        attrString.addAttribute(NSKernAttributeName, value: 2.2, range: fullRange)
        attrString.addAttribute(NSFontAttributeName, value: font, range: fullRange)
        attrString.addAttribute(NSForegroundColorAttributeName, value: color, range: fullRange)

        attrString.addAttribute(NSParagraphStyleAttributeName,
                                value: paragraphStyle,
                                range: fullRange)

        if strikeThrough {
            attrString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: fullRange)
        }

        return attrString
    }
}
