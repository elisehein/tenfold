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
    private static let instructionGridSpacing: CGFloat = 30
    private static let gridDetailSpacing: CGFloat = 10

    var instructionText: String? {
        didSet {
            if let instructionText = instructionText {
                instructionLabel.text = instructionText
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
    private let exampleGrid = RuleExampleGrid()

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

        size.height += InstructionItemCell.gridSize(forAvailableWidth: availableWidth).height
        size.height += InstructionItemCell.instructionGridSpacing

        // The assumption is that the detail label never takes more
        // than one line of space
        if detailText != nil {
            size.height += detailLabelHeight + InstructionItemCell.gridDetailSpacing
        }

        return size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        detailLabel.textAlignment = .Center
        detailLabel.textColor = UIColor.themeColorHighlighted(.OffWhite)
        detailLabel.font = UIFont.themeFontWithSize(14)

        contentView.addSubview(instructionLabel)
        contentView.addSubview(exampleGrid)
        contentView.addSubview(detailLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let availableWidth = contentView.bounds.size.width

        // swiftlint:disable:next line_length
        let instructionLabelSize = InstructionItemCell.sizeOccupiedByInstructionLabel(forAvailableWidth: availableWidth, usingText: instructionText!)

        let x = contentView.bounds.size.width * 0.5 * (1 - InstructionItemCell.widthFactor)
        instructionLabel.frame = CGRect(origin: CGPoint(x: x, y : 0),
                                        size: instructionLabelSize)

        let gridSize = InstructionItemCell.gridSize(forAvailableWidth: availableWidth)
        let frameForGrid = CGRect(x: (availableWidth - gridSize.width) / 2,
                                  y: instructionLabelSize.height + InstructionItemCell.instructionGridSpacing,
                                  width: gridSize.width,
                                  height: gridSize.height)

        exampleGrid.initialisePositionWithinFrame(frameForGrid,
                                                  withInsets: UIEdgeInsetsZero)

        let detailLabelY = exampleGrid.frame.origin.y
                           + exampleGrid.frame.size.height
                           + InstructionItemCell.gridDetailSpacing

        detailLabel.frame = CGRect(x: 0,
                                   y: detailLabelY,
                                   width: availableWidth,
                                   height: InstructionItemCell.detailLabelHeight)
    }

    class func gridSize(forAvailableWidth availableWidth: CGFloat) -> CGSize {
        let width = InstructionItemCell.widthFactor * availableWidth
        let totalRows = Matrix(itemsPerRow: Game.numbersPerRow).totalRows(27) // TODO
        return CGSize(width: width, height: width / CGFloat(totalRows) + 5) // 5px for safety
    }

    class func labelForInstructionText () -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.themeFontWithSize(14)
        label.textAlignment = .Center
        label.textColor = UIColor.themeColor(.OffBlack)
        return label
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
