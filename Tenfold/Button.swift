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
                                                         color: UIColor.themeColor(.offBlack)),
                               for: UIControlState())
        }
    }

    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setAttributedTitle(constructAttributedString(withText: title,
                                                           color: UIColor.themeColor(.offBlack)),
                                 for: state)
    }

    override func setBackgroundImage(_ image: UIImage?, for state: UIControlState) {
        super.setBackgroundImage(image, for: state)
        highlightText = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard highlightText else { return }

        setAttributedTitle(constructAttributedString(withText: titleLabel?.text,
                                                     color: UIColor.themeColor(.accent)),
                           for: UIControlState())
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard highlightText else { return }

        setAttributedTitle(constructAttributedString(withText: titleLabel?.text,
                                                     color: UIColor.themeColor(.offBlack)),
                           for: UIControlState())
    }

    func constructAttributedString(withText text: String?,
                                           color: UIColor) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        var font = UIFont.themeFontWithSize(14)

        if UIDevice.current.userInterfaceIdiom == .pad {
            font = font.withSize(18)
        }

        let attributes = [
            NSKernAttributeName: 2.2 as AnyObject,
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSStrikethroughStyleAttributeName: (strikeThrough ? 1 : 0) as AnyObject
        ] as [String : AnyObject]

        return NSMutableAttributedString(string: (text?.uppercased())!, attributes: attributes)
    }
}
