//
//  InstructionItemCell.swift
//  Numbers
//
//  Created by Elise Hein on 18/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class InstructionItemCell: UICollectionViewCell {

    private static let widthFactor: CGFloat = 0.85
    private static let detailLabelHeight: CGFloat = 20

    var instructionText: String? {
        didSet {
            if let instructionText = instructionText {
                instructionLabel.text = instructionText
            } else {
                instructionLabel.text = ""
            }
        }
    }

    var detailText: String? {
        didSet {
            if let detailText = detailText {
                detailLabel.text = detailText
            }

            detailLabel.hidden = detailText == nil
        }
    }

    private let instructionLabel = InstructionItemCell.labelForInstructionText()
    private let detailLabel = UILabel()

    class func sizeOccupiedByInstructionLabel(forAvailableWidth availableWidth: CGFloat,
                                              usingText text: String) -> CGSize {
        let width = InstructionItemCell.widthFactor * availableWidth
        let availableSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let label = InstructionItemCell.labelForInstructionText()
        label.text = text
        var size = label.sizeThatFits(availableSize)
        size.width = min(width, availableSize.width)

        return size
    }

    class func sizeOccupied(forAvailableWidth availableWidth: CGFloat,
                            usingInstructionText instructionText: String,
                            detailText: String?) -> CGSize {

        var size = sizeOccupiedByInstructionLabel(forAvailableWidth: availableWidth,
                                                  usingText: instructionText)

        print("Size just for instruction is", size)
        // The assumption is that the detail label never takes more
        // than one line of space
        if detailText != nil {
            print("But we also have detail, whose size is 20")
            size.height += detailLabelHeight
        }

        print(size)

        return size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        detailLabel.textAlignment = .Center
        detailLabel.textColor = UIColor.themeColorHighlighted(.OffWhite)
        detailLabel.font = UIFont.themeFontWithSize(14)
        detailLabel.backgroundColor = UIColor.blueColor()

        contentView.addSubview(instructionLabel)
        contentView.addSubview(detailLabel)
        contentView.backgroundColor = UIColor.grayColor()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // swiftlint:disable:next line_length
        let instructionLabelSize = InstructionItemCell.sizeOccupiedByInstructionLabel(forAvailableWidth: bounds.size.width, usingText: instructionText!)

        let x = bounds.size.width * 0.5 * (1 - InstructionItemCell.widthFactor)
        instructionLabel.frame = CGRect(origin: CGPoint(x: x, y : 0),
                                        size: instructionLabelSize)

        detailLabel.frame = CGRect(x: 0,
                                   y: instructionLabelSize.height,
                                   width: contentView.frame.size.width,
                                   height: InstructionItemCell.detailLabelHeight)
    }

    class func labelForInstructionText () -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.themeFontWithSize(14)
        label.textAlignment = .Center
        label.textColor = UIColor.themeColor(.OffBlack)
        label.backgroundColor = UIColor.redColor()
        return label
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
