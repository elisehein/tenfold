//
//  ScorePill.swift
//  Tenfold
//
//  Created by Elise Hein on 03/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class ScorePill: Pill {

    private static let circleSize: CGFloat = 16
    private static let indent: CGFloat = ScorePill.circleSize + 10

    let circleLayer = CAShapeLayer()

    var score: Int = 0 {
        didSet {
            text = "\(score) to go"
        }
    }

    init() {
        super.init(type: .Text)

        circleLayer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.55).CGColor
        circleLayer.fillColor = UIColor.clearColor().CGColor

        label.layer.addSublayer(circleLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let circleRect = CGRect(x: Pill.labelWidthAddition / 2,
                                y: (Pill.labelHeight - ScorePill.circleSize) / 2,
                                width: ScorePill.circleSize,
                                height: ScorePill.circleSize)
        circleLayer.path = UIBezierPath(ovalInRect: circleRect).CGPath
    }

    override func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let attrString = super.constructAttributedString(withText: text)
        var fullRange = NSRange(location: 0, length: text.characters.count)
        let maybeParagraphStyle = attrString.attribute(NSParagraphStyleAttributeName,
                                                       atIndex: 0,
                                                       effectiveRange: &fullRange)
        if let paragraphStyle = maybeParagraphStyle as? NSMutableParagraphStyle {
            paragraphStyle.firstLineHeadIndent = ScorePill.indent
            attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: fullRange)
        }

        return attrString
    }

    override func textLabelWidth() -> CGFloat {
        let width = super.textLabelWidth()
        return width + ScorePill.indent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
