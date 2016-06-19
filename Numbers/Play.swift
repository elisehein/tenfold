//
//  Play.swift
//  Numbers
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import PureLayout

class Play: UIViewController {
    
    private static let gridMargin: CGFloat = 10
    
    let game: Game
    
    private let grid: GameGrid
    private var hasLoadedConstraints = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.game = Game()
        grid = GameGrid(game: game)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(Play.makeNextRound))
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
            grid.view.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: Play.gridMargin, left: Play.gridMargin, bottom: 0, right: Play.gridMargin))
            
            hasLoadedConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    func makeNextRound () {
        let success = grid.loadNextRound(whileAtScrollOffset: CGPoint.zero)
        if !success {
            print("GAME OVER")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

