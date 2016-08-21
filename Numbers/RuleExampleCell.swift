//
//  InstructionItemCell.swift
//  Numbers
//
//  Created by Elise Hein on 18/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class RuleExampleCell: UICollectionViewCell {

    private static let widthFactor: CGFloat = 0.75
    private static let detailLabelHeight: CGFloat = 20
    private static let textGridSpacing: CGFloat = 30
    private static let gridDetailSpacing: CGFloat = 10

    var text: String? {
        didSet {
            if let text = text {
                label.text = text
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

    var gridValues: Array<Int?> = [] {
        didSet {
            exampleGrid.values = gridValues
        }
    }

    var gridCrossedOutIndeces: Array<Int> = [] {
        didSet {
            exampleGrid.crossedOutIndeces = gridCrossedOutIndeces
        }
    }

    var gridPairs: Array<[Int]> = [] {
        didSet {
            exampleGrid.pairs = gridPairs
        }
    }

    private let label = RuleExampleCell.labelForText()
    private let detailLabel = UILabel()
    private let exampleGrid = RuleExampleGrid()

    class func sizeOccupiedByLabel(forAvailableWidth availableWidth: CGFloat,
                                   usingText text: String) -> CGSize {
        let width = RuleExampleCell.widthFactor * availableWidth
        let availableSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let label = RuleExampleCell.labelForText()
        label.text = text
        var size = label.sizeThatFits(availableSize)
        size.width = min(width, availableSize.width)

        return size
    }

    class func sizeOccupied(forAvailableWidth availableWidth: CGFloat,
                            usingText givenText: String,
                            detailText: String?) -> CGSize {

        var size = sizeOccupiedByLabel(forAvailableWidth: availableWidth,
                                       usingText: givenText)

        size.height += RuleExampleCell.gridSize(forAvailableWidth: availableWidth).height
        size.height += RuleExampleCell.textGridSpacing

        // The assumption is that the detail label never takes more
        // than one line of space
        if detailText != nil {
            size.height += detailLabelHeight + RuleExampleCell.gridDetailSpacing
        }

        return size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        detailLabel.textAlignment = .Center
        detailLabel.textColor = UIColor.themeColorHighlighted(.OffWhite)
        detailLabel.font = UIFont.themeFontWithSize(14)

        contentView.addSubview(label)
        contentView.addSubview(exampleGrid)
        contentView.addSubview(detailLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let availableWidth = contentView.bounds.size.width

        let labelSize = RuleExampleCell.sizeOccupiedByLabel(forAvailableWidth: availableWidth,
                                                            usingText: text!)

        let x = contentView.bounds.size.width * 0.5 * (1 - RuleExampleCell.widthFactor)
        label.frame = CGRect(origin: CGPoint(x: x, y : 0), size: labelSize)

        let gridSize = RuleExampleCell.gridSize(forAvailableWidth: availableWidth)
        let frameForGrid = CGRect(x: (availableWidth - gridSize.width) / 2,
                                  y: labelSize.height + RuleExampleCell.textGridSpacing,
                                  width: gridSize.width,
                                  height: gridSize.height)

        exampleGrid.initialisePositionWithinFrame(frameForGrid,
                                                  withInsets: UIEdgeInsetsZero)

        let detailLabelY = exampleGrid.frame.origin.y
                           + exampleGrid.frame.size.height
                           + RuleExampleCell.gridDetailSpacing

        detailLabel.frame = CGRect(x: 0,
                                   y: detailLabelY,
                                   width: availableWidth,
                                   height: RuleExampleCell.detailLabelHeight)
    }

    func prepareGrid() {
        exampleGrid.reloadData()
    }

    func playExampleLoop() {
        exampleGrid.playLoop()
    }

    func stopExampleLoop() {
        exampleGrid.invalidateLoop()
    }

    override func prepareForReuse() {
        stopExampleLoop()
    }

    class func gridSize(forAvailableWidth availableWidth: CGFloat) -> CGSize {
        let width = RuleExampleCell.widthFactor * availableWidth
        let totalRows = Matrix(itemsPerRow: Game.numbersPerRow).totalRows(27) // TODO
        return CGSize(width: width, height: width / CGFloat(totalRows) + 5) // 5px for safety
    }

    class func labelForText () -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = UIFont.themeFontWithSize(14)
        l.textAlignment = .Center
        l.textColor = UIColor.themeColor(.OffBlack)
        return l
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
