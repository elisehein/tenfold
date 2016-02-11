//
//  GameGrid.swift
//  Numbers
//
//  Created by Elise Hein on 11/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameGrid: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let game: Game
    let collectionView: UICollectionView
    
    private let reuseIdentifier = "NumberCell"
    
    init(game: Game) {
        self.game = game
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.registerClass(NumberCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.totalNumbers()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        if let cell = cell as? NumberCell {
            cell.number = game.numberAtIndex(indexPath.item)
            cell.isCrossedOut = game.isCrossedOut(indexPath.item)
            cell.marksEndOfRound = game.marksEndOfRound(indexPath.item)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.size.width / 9.0
        return CGSize(width: cellWidth, height: cellWidth)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NumberCell: UICollectionViewCell {
    private let numberLabel = UILabel()
    private let endOfRoundMarker = CAShapeLayer()
    
    override var selected: Bool {
        didSet {
            self.contentView.backgroundColor = self.selected ? UIColor.themeColorHighlighted(.OffWhite) : UIColor.clearColor()
        }
    }
    
    var number: Int? {
        didSet {
            if let number = number {
                numberLabel.text = String(number)
            }
        }
    }
    
    var marksEndOfRound: Bool? {
        didSet {
            if let marksEndOfRound = marksEndOfRound {
                endOfRoundMarker.hidden = !marksEndOfRound
            }
        }
    }
    
    var isCrossedOut: Bool? {
        didSet {
            if let isCrossedOut = isCrossedOut {
                self.contentView.backgroundColor = isCrossedOut ? UIColor.blackColor() : UIColor.clearColor()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        numberLabel.textAlignment = .Center
        numberLabel.font = UIFont.themeFontWithSize(16)
        numberLabel.backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(numberLabel)
        
        endOfRoundMarker.fillColor = UIColor.themeColor(.OffBlack).CGColor
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
