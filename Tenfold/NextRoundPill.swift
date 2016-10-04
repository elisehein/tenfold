//
//  NextRoundPill.swift
//  Tenfold
//
//  Created by Elise Hein on 04/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class NextRoundPill: Pill {

    var numberCount: Int = 0 {
        didSet {
            text = "+ \(numberCount) NUMS"
        }
    }

    init() {
        super.init(type: .Text)
    }

    override func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let attrString = super.constructAttributedString(withText: text)

        let grayedOut = "NUMS"
        if let index = text.indexOf(grayedOut) {
            let attributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.55),
                NSFontAttributeName: UIFont.themeFontWithSize(10)
            ]
            attrString.addAttributes(attributes,
                                     range: NSRange(location: index, length: grayedOut.characters.count))
        }

        return attrString
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
