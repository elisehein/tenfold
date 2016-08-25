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
    static private let cellSpacing: Int = 1

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

        frame = CGRect(origin: CGPoint(x: givenFrame.origin.x + x, y: givenFrame.origin.y + y),
                       size: size)
    }

    func heightForGame(withTotalRows totalRows: Int) -> CGFloat {
        let heightForSpacing = CGFloat(totalRows - 1) * layout.minimumLineSpacing
        return CGFloat(totalRows) * cellSize().height + heightForSpacing
    }

    func widthForSpacing() -> Int {
        return Int(layout.minimumInteritemSpacing) * (Game.numbersPerRow - 1)
    }

    func cellSize(forAvailableWidth availableWidth: CGFloat? = nil) -> CGSize {
        let fullWidth = availableWidth == nil ? bounds.size.width : availableWidth
        let widthForNumbers = fullWidth! - CGFloat(widthForSpacing())
        let cellWidth = floor(widthForNumbers / CGFloat(Game.numbersPerRow))
        return CGSize(width: cellWidth, height: cellWidth)
    }

    private func sizeSnappedToPixel(inAvailableSize availableSize: CGSize) -> CGSize {
        // We want to get a width that is exactly divisible by the number of items per row,
        // taking into account also spacing, so that we don't get any unequal spacing or cell widths
        let widthForNumbers = availableSize.width - CGFloat(widthForSpacing())
        let widthRemainder = widthForNumbers % CGFloat(Game.numbersPerRow)
        let integerWidth = availableSize.width - widthRemainder

        let cellHeight = cellSize(forAvailableWidth: availableSize.width).height
        let heightRemainder = availableSize.height % cellHeight
        let integerHeight = availableSize.height - heightRemainder
        return CGSize(width: integerWidth, height: integerHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
