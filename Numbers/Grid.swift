//
//  Grid.swift
//  Numbers
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

    func heightForGame(withTotalRows totalRows: Int) -> CGFloat {
        let heightForSpacing = CGFloat(totalRows - 1) * layout.minimumLineSpacing
        return CGFloat(totalRows) * cellSize().height + heightForSpacing
    }

    func widthForSpacing() -> Int {
        return Int(layout.minimumInteritemSpacing) * (Game.numbersPerRow - 1)
    }

    func cellSize(forAvailableWidth availableWidth: CGFloat? = nil) -> CGSize {
        let fullWidth = availableWidth == nil ? bounds.size.width : availableWidth
        let cellWidth = floor((fullWidth! - CGFloat(widthForSpacing())) / CGFloat(Game.numbersPerRow))
        return CGSize(width: cellWidth, height: cellWidth)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
