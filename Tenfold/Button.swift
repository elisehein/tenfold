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

    var highlightText = true
    var strikeThrough = false {
        didSet {
            setAttributedTitle(constructAttributedString(withText: titleLabel?.text,
                                                         color: UIColor.themeColor(.OffBlack)),
                               forState: .Normal)
        }
    }

    override func setTitle(title: String?, forState state: UIControlState) {
        super.setAttributedTitle(constructAttributedString(withText: title,
                                                           color: UIColor.themeColor(.OffBlack)),
                                 forState: state)
    }

    override func setBackgroundImage(image: UIImage?, forState state: UIControlState) {
        super.setBackgroundImage(image, forState: state)
        highlightText = false
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        guard highlightText else { return }

        setAttributedTitle(constructAttributedString(withText: titleLabel?.text,
                                                     color: UIColor.themeColor(.Accent)),
                           forState: .Normal)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)

        guard highlightText else { return }

        setAttributedTitle(constructAttributedString(withText: titleLabel?.text,
                                                     color: UIColor.themeColor(.OffBlack)),
                           forState: .Normal)
    }

    func constructAttributedString(withText text: String?,
                                           color: UIColor) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center

        var font = UIFont.themeFontWithSize(14)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = font.fontWithSize(18)
        }

        let attributes = [
            NSKernAttributeName: 2.2,
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSStrikethroughStyleAttributeName: strikeThrough ? 1 : 0
        ]

        return NSMutableAttributedString(string: (text?.uppercaseString)!, attributes: attributes)
    }
}
