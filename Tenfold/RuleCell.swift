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

    fileprivate static let textWidthFactor: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 0.5
        } else {
            return 0.88
        }
    }()

    fileprivate static let gridWidthFactor: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 0.5
        } else {
            return 0.75
        }
    }()

    fileprivate static let textGridSpacing: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 40
        } else {
            return 30
        }

    }()

    var text: String? {
        didSet {
            if let text = text {
                label.attributedText = NSMutableAttributedString.themeString(.paragraph, text)
            }
        }
    }

    var detailText: String? {
        didSet {
            if let detailText = detailText {
                detailLabel.attributedText = NSMutableAttributedString.themeString(.tip, detailText)
            } else {
                detailLabel.text = ""
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

    var gridAnimationType: RuleGridAnimationType = .pairings {
        didSet {
            exampleGrid.animationType = gridAnimationType
        }
    }

    fileprivate let label = RuleCell.labelWithAttributedText()
    fileprivate let detailLabel = UILabel()
    fileprivate let exampleGrid = RuleGrid()

    class func sizeOccupiedByLabel(forAvailableWidth availableWidth: CGFloat,
                                   usingText text: String) -> CGSize {
        let width = RuleCell.textWidthFactor * availableWidth
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

        let gridWidth = RuleCell.gridWidthFactor * availableWidth
        size.height += Grid.size(forAvailableWidth: gridWidth, cellCount: numberOfGridValues).height
        size.height += RuleCell.textGridSpacing

        return size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        detailLabel.numberOfLines = 0
        detailLabel.alpha = 0.8

        contentView.addSubview(label)
        contentView.addSubview(detailLabel)
        contentView.addSubview(exampleGrid)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let availableWidth = contentView.bounds.size.width

        let labelSize = RuleCell.sizeOccupiedByLabel(forAvailableWidth: availableWidth,
                                                     usingText: text!)

        let x = contentView.bounds.size.width * 0.5 * (1 - RuleCell.textWidthFactor)
        label.frame = CGRect(origin: CGPoint(x: x, y: 0), size: labelSize)

        var detailLabelFrame = contentView.bounds
        detailLabelFrame.size.width *= RuleCell.textWidthFactor
        detailLabel.frame = detailLabelFrame
        detailLabel.sizeToFit()
        detailLabelFrame = detailLabel.frame
        detailLabelFrame.origin.y = contentView.bounds.size.height + RuleCell.textGridSpacing
        detailLabelFrame.origin.x = (contentView.bounds.size.width - detailLabelFrame.size.width) / 2
        detailLabel.frame = detailLabelFrame

        let gridWidth = RuleCell.gridWidthFactor * availableWidth
        let gridSize = Grid.size(forAvailableWidth: gridWidth, cellCount: gridValues.count)

        let frameForGrid = CGRect(x: (availableWidth - gridSize.width) / 2,
                                  y: labelSize.height + RuleCell.textGridSpacing,
                                  width: gridSize.width,
                                  height: gridSize.height)

        exampleGrid.initialisePositionWithinFrame(frameForGrid,
                                                  withInsets: UIEdgeInsets.zero)
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

    class func labelWithAttributedText(_ text: String? = nil) -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.attributedText = NSMutableAttributedString.themeString(.paragraph, text == nil ? "" : text!)
        return l

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
