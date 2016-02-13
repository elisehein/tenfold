//
//  ViewController.swift
//  Numbers
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import PureLayout

class Play: UIViewController {
    
    let game: Game
    
    private let gridMargin: CGFloat = 10
    
    private let titleLabel = UILabel()
    private let nextRoundButton = UIButton()
    private let grid: GameGrid
    
    private var hasLoadedConstraints = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.game = Game()
        grid = GameGrid(game: game)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        titleLabel.text = "Numbers"
        titleLabel.font = UIFont.themeFontWithSize(20)
        titleLabel.textColor = UIColor.themeColor(.OffBlack)
        view.addSubview(titleLabel)
        
        nextRoundButton.titleLabel!.font = UIFont.themeFontWithSize(14)
        nextRoundButton.setTitle("Next round!", forState: .Normal)
        nextRoundButton.setTitleColor(UIColor.themeColor(.OffBlack), forState: .Normal)
        nextRoundButton.setTitleColor(UIColor.themeColorHighlighted(.OffBlack), forState: .Highlighted)
        nextRoundButton.addTarget(self, action: Selector("makeNextRound"), forControlEvents: .TouchUpInside)
        view.addSubview(nextRoundButton)
        
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
            
            nextRoundButton.autoAlignAxisToSuperviewAxis(.Vertical)
            nextRoundButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 20)
            
            grid.view.autoPinEdge(.Top, toEdge: .Bottom, ofView: nextRoundButton, withOffset: 20)
            grid.view.autoPinEdgeToSuperviewEdge(.Left, withInset: gridMargin)
            grid.view.autoPinEdgeToSuperviewEdge(.Right, withInset: gridMargin)
            grid.view.autoPinEdgeToSuperviewEdge(.Bottom, withInset: gridMargin)
            hasLoadedConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    func makeNextRound () {
        game.makeNextRound()
        grid.loadNextRound()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

