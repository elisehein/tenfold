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
    let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        return l
    }()

    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    func heightForGame(withTotalRows totalRows: Int) -> CGFloat {
        return CGFloat(totalRows) * cellSize().height
    }

    func cellSize(forAvailableWidth availableWidth: CGFloat? = nil) -> CGSize {
        let width = availableWidth == nil ? bounds.size.width : availableWidth
        let cellWidth = width! / CGFloat(Game.numbersPerRow)
        return CGSize(width: cellWidth, height: cellWidth)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
