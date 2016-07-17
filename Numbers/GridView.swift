//
//  GridView.swift
//  Numbers
//
//  Created by Elise Hein on 17/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GridView: UICollectionView {
    let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        return l
    }()

    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
    }

    func heightForGame(withTotalRows totalRows: Int) -> CGFloat {
        return CGFloat(totalRows) * cellSize().height
    }

    func cellSize() -> CGSize {
        let cellWidth = bounds.size.width / CGFloat(Game.numbersPerRow)
        return CGSize(width: cellWidth, height: cellWidth)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
