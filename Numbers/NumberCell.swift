//
//  NumberCell.swift
//  Numbers
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class NumberCell: UICollectionViewCell {
    private let numberLabel = UILabel()
    private let endOfRoundMarker = CAShapeLayer()
    
    override var selected: Bool {
        didSet {
            contentView.backgroundColor = self.selected ? UIColor.themeColorHighlighted(.OffWhite) : UIColor.clearColor()
        }
    }
    
    var number: Int? {
        didSet {
            if let number = number {
                numberLabel.text = String(number)
            }
        }
    }
    
    var marksEndOfRound: Bool = false {
        didSet {
            endOfRoundMarker.hidden = !marksEndOfRound
        }
    }
    
    // ????? why does this only work on reloadData?
    var isCrossedOut: Bool = false {
        didSet {
            if self.isCrossedOut {
                print("Setting crossed out...")
                endOfRoundMarker.fillColor = UIColor.themeColor(.OffWhite).CGColor
                contentView.backgroundColor = UIColor.themeColor(.OffBlack)
            } else {
                print("Setting not crossed out")
                endOfRoundMarker.fillColor = UIColor.themeColor(.OffBlack).CGColor
                contentView.backgroundColor = UIColor.themeColor(.OffWhite)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        numberLabel.textAlignment = .Center
        numberLabel.font = UIFont.themeFontWithSize(16)
        numberLabel.backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(numberLabel)
        contentView.layer.addSublayer(endOfRoundMarker)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        marksEndOfRound = false
        isCrossedOut = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.frame = contentView.bounds
        
        let markerPath = CGPathCreateMutable();
        let markerMargin: CGFloat = 3
        let markerDepth: CGFloat = 4
        let markerLength: CGFloat = 10
        let totalWidth: CGFloat = contentView.bounds.size.width
        let totalHeight: CGFloat = contentView.bounds.size.height
        
        CGPathMoveToPoint(markerPath, nil,
                          totalWidth - markerMargin,
                          totalHeight - markerMargin);
        CGPathAddLineToPoint(markerPath, nil, totalWidth - markerMargin, totalHeight - markerMargin - markerLength);
        CGPathAddLineToPoint(markerPath, nil, totalWidth - markerMargin - markerDepth, totalHeight - markerMargin - markerLength);
        CGPathAddLineToPoint(markerPath, nil, totalWidth - markerMargin - markerDepth, totalHeight - markerMargin - markerDepth);
        CGPathAddLineToPoint(markerPath, nil, totalWidth - markerMargin - markerLength, totalHeight - markerMargin - markerDepth);
        CGPathAddLineToPoint(markerPath, nil, totalWidth - markerMargin - markerLength, totalHeight - markerMargin);
        CGPathCloseSubpath(markerPath);
        endOfRoundMarker.path = markerPath
    }
    
    func indicatePairingFail () {
        print("Indicating fail...")
        self.numberLabel.text = "F"
//
//        UIView.animateWithDuration(1.0, animations: {
//        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}