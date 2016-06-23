//
//  NextRoundGrid.swift
//  Numbers
//
//  Created by Elise Hein on 19/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class NextRoundGrid: UIView {
    
    private static let numberOfRows = 10
    
    var itemSize: CGSize
    var itemsPerRow: Int
    
    init(cellSize: CGSize, cellsPerRow: Int, frame: CGRect) {
        itemSize = cellSize
        itemsPerRow = cellsPerRow
        
        super.init(frame: frame)
        
        for i in 0..<NextRoundGrid.numberOfRows {
            let indexInRow = i % NextRoundGrid.numberOfRows
            let rowIndex = i / NextRoundGrid.numberOfRows
            let x = CGFloat(indexInRow) * itemSize.width
            let y = CGFloat(rowIndex) * itemSize.height
            let cellFrame = CGRect(x: x,
                                   y: y,
                                   width: itemSize.width,
                                   height: itemSize.height)
            let cell = NextRoundCell(frame: cellFrame)
            addSubview(cell)
        }
        
    }
    
    func heightRequired () -> CGFloat {
        return CGFloat(NextRoundGrid.numberOfRows) * itemSize.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NextRoundCell: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bubble = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        bubble.backgroundColor = UIColor.blueColor()
        addSubview(bubble)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
