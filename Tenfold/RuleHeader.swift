//
//  RuleHeader.swift
//  Tenfold
//
//  Created by Elise Hein on 18/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class RuleHeader: UICollectionReusableView {

    private let label = UILabel()
    private static let widthFactor: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 0.6
        } else {
            return 0.85
        }
    }()

    var text: String? {
        didSet {
            if let text = text {
                // swiftlint:disable:next line_length
                label.attributedText = NSAttributedString.styled(as: .Title, usingText: text)
            }
        }
    }

    class func sizeOccupied(forAvailableWidth availableWidth: CGFloat,
                            usingText text: String) -> CGSize {
        let width = RuleHeader.widthFactor * availableWidth
        let availableSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let label = UILabel()
        label.attributedText = NSAttributedString.styled(as: .Title, usingText: text)
        label.numberOfLines = 0
        var size = label.sizeThatFits(availableSize)
        size.width = min(width, availableSize.width)
        return size
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

        // Ensure the label is always pushed to the bottom of the frame.
        // See header size calculations in Rules.swift for more details
        let y = bounds.size.height - labelSize.height

        label.frame = CGRect(origin: CGPoint(x: x, y : y),
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
