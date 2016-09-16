//
//  Grid.swift
//  Tenfold
//
//  Created by Elise Hein on 17/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Grid: UICollectionView {
    static let cellSpacing: Int = 1

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = CGFloat(Grid.cellSpacing)
        l.minimumLineSpacing = CGFloat(Grid.cellSpacing)
        return l
    }()

    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    func initialisePositionWithinFrame(givenFrame: CGRect, withInsets insets: UIEdgeInsets) {
        let availableSize = CGSize(width: givenFrame.width - insets.left - insets.right,
                                   height: givenFrame.height - insets.top - insets.bottom)
        let size = sizeSnappedToPixel(inAvailableSize: availableSize)
        let x = floor(insets.left + (availableSize.width - size.width) / 2.0)
        let y = floor(insets.top + (availableSize.height - size.height) / 2.0)

        frame = CGRect(origin: CGPoint(x: ceil(givenFrame.origin.x) + x,
                                       y: ceil(givenFrame.origin.y) + y),
                       size: size)
    }

    private func sizeSnappedToPixel(inAvailableSize availableSize: CGSize) -> CGSize {
        // We want to get a width that is exactly divisible by the number of items per row,
        // taking into account also spacing, so that we don't get any unequal spacing or cell widths
        let widthForNumbers = availableSize.width - CGFloat(Grid.widthForSpacing())
        let widthRemainder = widthForNumbers % CGFloat(Game.numbersPerRow)
        let integerWidth = availableSize.width - widthRemainder

        // Because the Grid is vertically scrolling, subpixel rendering is not an issue when it
        // comes to the height
        return CGSize(width: integerWidth, height: availableSize.height)
    }

    func heightForGame(withTotalRows totalRows: Int) -> CGFloat {
        return Grid.heightForGame(withTotalRows: totalRows, availableWidth: bounds.size.width)
    }

    // Each cell's existence need to be checked separately, as one cell may
    // be visible while the other is not (in which case it is nil). We still
    // want to
    // cross out the visible one
    internal func performActionOnCells(withIndeces indeces: [Int],
                                       _ action: ((GameGridCell) -> Void)) {
        for index in indeces {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)

            if let cell = cellForItemAtIndexPath(indexPath) as? GameGridCell {
                action(cell)
            }
        }
    }

    class func heightForGame(withTotalRows totalRows: Int, availableWidth: CGFloat) -> CGFloat {
        let heightForSpacing = CGFloat(totalRows - 1) * CGFloat(Grid.cellSpacing)
        let cellHeight = Grid.cellSize(forAvailableWidth: availableWidth).height
        return CGFloat(totalRows) * cellHeight + heightForSpacing
    }

    class func cellSize(forAvailableWidth availableWidth: CGFloat) -> CGSize {
        let widthForNumbers = availableWidth - CGFloat(widthForSpacing())
        let cellWidth = floor(widthForNumbers / CGFloat(Game.numbersPerRow))
        return CGSize(width: cellWidth, height: cellWidth)
    }

    class func widthForSpacing() -> Int {
        return Grid.cellSpacing * (Game.numbersPerRow - 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
