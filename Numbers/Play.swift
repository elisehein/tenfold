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
    private let grid: GameGrid
    
    private var hasLoadedConstraints = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.game = Game()
        grid = GameGrid(game: game)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: Selector("makeNextRound"))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        addChildViewController(grid)
        view.addSubview(grid.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO colours look different on simulator and device
        view.backgroundColor = UIColor.themeColor(.OffWhite)
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if (!hasLoadedConstraints) {
            grid.view.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: gridMargin, left: gridMargin, bottom: gridMargin, right: gridMargin))
            
            hasLoadedConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    func makeNextRound () {
        let success = grid.loadNextRound()
        if !success {
            print("GAME OVER")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

