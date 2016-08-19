//
//  RuleHeader.swift
//  Numbers
//
//  Created by Elise Hein on 18/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class RuleHeader: UICollectionReusableView {

    private let label = UILabel()
    private static let widthFactor: CGFloat = 0.85

    var text: String? {
        didSet {
            if let text = text {
                // swiftlint:disable:next line_length
                label.attributedText = RuleHeader.constructAttributedString(withText: text)
            }
        }
    }

    class func sizeOccupied(forAvailableWidth availableWidth: CGFloat,
                            usingText text: String) -> CGSize {
        let width = RuleHeader.widthFactor * availableWidth
        let availableSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let label = UILabel()
        label.attributedText = constructAttributedString(withText: text)
        label.numberOfLines = 0
        var size = label.sizeThatFits(availableSize)
        size.width = min(width, availableSize.width)
        return size
    }


    class func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        paragraphStyle.alignment = .Center

        let font = UIFont.themeFontWithSize(15, weight: .Bold)

        let attrString = NSMutableAttributedString(string: text)

        attrString.addAttribute(NSParagraphStyleAttributeName,
                                value:paragraphStyle,
                                range:NSRange(location: 0, length: attrString.length))

        attrString.addAttribute(NSFontAttributeName,
                                value:font,
                                range:NSRange(location: 0, length: attrString.length))

        return attrString
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.textColor = UIColor.themeColor(.OffBlack)
        label.numberOfLines = 0

        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let labelSize = RuleHeader.sizeOccupied(forAvailableWidth: bounds.size.width,
                                                           usingText: text!)

        let x = bounds.size.width * 0.5 * (1 - RuleHeader.widthFactor)
        label.frame = CGRect(origin: CGPoint(x: x, y : 0),
                             size: labelSize)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        text = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
