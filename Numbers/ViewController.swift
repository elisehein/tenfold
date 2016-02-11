//
//  ViewController.swift
//  Numbers
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import PureLayout

class ViewController: UIViewController {
    
    let gridMargin: CGFloat = 10
    
    let titleLabel = UILabel()
    let grid: GameGrid
    
    var hasLoadedConstraints = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let game = Game()
        grid = GameGrid(game: game)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        titleLabel.text = "Numbers"
        titleLabel.font = UIFont.themeFontWithSize(20)
        titleLabel.textColor = UIColor.themeColor(.OffBlack)
        view.addSubview(titleLabel)
        
        addChildViewController(grid)
        view.addSubview(grid.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.themeColor(.OffWhite)
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if (!hasLoadedConstraints) {
            titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 100)
            grid.view.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 20)
            grid.view.autoPinEdgeToSuperviewEdge(.Left, withInset: gridMargin)
            grid.view.autoPinEdgeToSuperviewEdge(.Right, withInset: gridMargin)
            grid.view.autoPinEdgeToSuperviewEdge(.Bottom, withInset: gridMargin)
            hasLoadedConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

