//
//  InstructionItemCell.swift
//  Tenfold
//
//  Created by Elise Hein on 18/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class RuleExampleCell: UICollectionViewCell {

    private static let widthFactor: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 0.5
        } else {
            return 0.75
        }
    }()

    private static let textGridSpacing: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 40
        } else {
            return 30
        }

    }()

    var text: String? {
        didSet {
            if let text = text {
                label.attributedText = RuleExampleCell.constructAttributedString(withText: text)
            }
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

    var gridAnimationType: String = RuleExampleGrid.animationTypePairings {
        didSet {
            exampleGrid.animationType = gridAnimationType
        }
    }

    private let label = RuleExampleCell.labelWithAttributedText()
    private let exampleGrid = RuleExampleGrid()

    class func sizeOccupiedByLabel(forAvailableWidth availableWidth: CGFloat,
                                   usingText text: String) -> CGSize {
        let width = RuleExampleCell.widthFactor * availableWidth
        let availableSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let label = RuleExampleCell.labelWithAttributedText(text)
        var size = label.sizeThatFits(availableSize)
        size.width = min(width, availableSize.width)

        return size
    }

    class func sizeOccupied(forAvailableWidth availableWidth: CGFloat,
                            usingText givenText: String,
                            numberOfGridValues: Int) -> CGSize {
        var size = RuleExampleCell.sizeOccupiedByLabel(forAvailableWidth: availableWidth,
                                                       usingText: givenText)

        let gridWidth = RuleExampleCell.widthFactor * availableWidth
        size.height += RuleExampleCell.gridSize(forAvailableWidth: gridWidth,
                                                gridValueCount: numberOfGridValues).height
        size.height += RuleExampleCell.textGridSpacing

        return size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        contentView.addSubview(exampleGrid)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let availableWidth = contentView.bounds.size.width

        let labelSize = RuleExampleCell.sizeOccupiedByLabel(forAvailableWidth: availableWidth,
                                                            usingText: text!)

        let x = contentView.bounds.size.width * 0.5 * (1 - RuleExampleCell.widthFactor)
        label.frame = CGRect(origin: CGPoint(x: x, y : 0), size: labelSize)

        let gridWidth = RuleExampleCell.widthFactor * availableWidth
        let gridSize = RuleExampleCell.gridSize(forAvailableWidth: gridWidth,
                                                gridValueCount: gridValues.count)

        let frameForGrid = CGRect(x: (availableWidth - gridSize.width) / 2,
                                  y: labelSize.height + RuleExampleCell.textGridSpacing,
                                  width: gridSize.width,
                                  height: gridSize.height)

        exampleGrid.initialisePositionWithinFrame(frameForGrid,
                                                  withInsets: UIEdgeInsetsZero)
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
        super.prepareForReuse()
        stopExampleLoop()
    }

    class func gridSize(forAvailableWidth availableWidth: CGFloat, gridValueCount: Int) -> CGSize {
        let totalRows = Matrix.singleton.totalRows(gridValueCount)
        let height = Grid.heightForGame(withTotalRows: totalRows, availableWidth: availableWidth)
        return CGSize(width: availableWidth, height: height)
    }

    class func labelWithAttributedText(text: String? = nil) -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.attributedText = constructAttributedString(withText: text)
        return l

    }

    class func constructAttributedString(withText text: String?) -> NSAttributedString {
        let isIPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        paragraphStyle.lineSpacing = isIPad ? 7 : 4

        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: UIColor.themeColor(.OffBlack),
            NSFontAttributeName: UIFont.themeFontWithSize(isIPad ? 18 : 14)
        ]

        return NSAttributedString(string: text != nil ? text! : "", attributes: attributes)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
