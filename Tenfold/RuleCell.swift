//
//  RuleCell.swift
//  Tenfold
//
//  Created by Elise Hein on 18/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class RuleCell: UICollectionViewCell {

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
                label.attributedText = NSAttributedString.styled(as: .Paragraph, usingText: text)
            }
        }
    }

    var gridValues: [Int?] = [] {
        didSet {
            exampleGrid.values = gridValues
        }
    }

    var gridCrossedOutIndeces: [Int] = [] {
        didSet {
            exampleGrid.crossedOutIndeces = gridCrossedOutIndeces
        }
    }

    var gridPairs: [[Int]] = [] {
        didSet {
            exampleGrid.pairs = gridPairs
        }
    }

    var gridAnimationType: RuleGridAnimationType = .Pairings {
        didSet {
            exampleGrid.animationType = gridAnimationType
        }
    }

    private let label = RuleCell.labelWithAttributedText()
    private let exampleGrid = RuleGrid()

    class func sizeOccupiedByLabel(forAvailableWidth availableWidth: CGFloat,
                                   usingText text: String) -> CGSize {
        let width = RuleCell.widthFactor * availableWidth
        let availableSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let label = RuleCell.labelWithAttributedText(text)
        var size = label.sizeThatFits(availableSize)
        size.width = min(width, availableSize.width)

        return size
    }

    class func sizeOccupied(forAvailableWidth availableWidth: CGFloat,
                            usingText givenText: String,
                            numberOfGridValues: Int) -> CGSize {
        var size = RuleCell.sizeOccupiedByLabel(forAvailableWidth: availableWidth,
                                                       usingText: givenText)

        let gridWidth = RuleCell.widthFactor * availableWidth
        size.height += Grid.size(forAvailableWidth: gridWidth, cellCount: numberOfGridValues).height
        size.height += RuleCell.textGridSpacing

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

        let labelSize = RuleCell.sizeOccupiedByLabel(forAvailableWidth: availableWidth,
                                                            usingText: text!)

        let x = contentView.bounds.size.width * 0.5 * (1 - RuleCell.widthFactor)
        label.frame = CGRect(origin: CGPoint(x: x, y : 0), size: labelSize)

        let gridWidth = RuleCell.widthFactor * availableWidth
        let gridSize = Grid.size(forAvailableWidth: gridWidth, cellCount: gridValues.count)

        let frameForGrid = CGRect(x: (availableWidth - gridSize.width) / 2,
                                  y: labelSize.height + RuleCell.textGridSpacing,
                                  width: gridSize.width,
                                  height: gridSize.height)

        exampleGrid.initialisePositionWithinFrame(frameForGrid,
                                                  withInsets: UIEdgeInsetsZero)
    }

    func prepareGrid() {
        exampleGrid.prepareForReuse()
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

    class func labelWithAttributedText(text: String? = nil) -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.attributedText = NSAttributedString.styled(as: .Paragraph, usingText: text == nil ? "" : text!)
        return l

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
