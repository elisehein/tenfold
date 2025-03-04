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
            text = "+ \(numberCount)  TO GO"
        }
    }

    init() {
        super.init(type: .text)
    }

    override func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let attrString = super.constructAttributedString(withText: text)

        let grayedOut = "TO GO"
        if let index = text.indexOf(grayedOut) {
            let attributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.55),
                NSAttributedStringKey.font: UIFont.themeFontWithSize(Pill.detailFontSize)
            ]
            attrString.addAttributes(attributes,
                                     range: NSRange(location: index, length: grayedOut.count))
        }

        return attrString
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
