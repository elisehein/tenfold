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

    private let gameGrid: GameGrid
    private var hasLoadedConstraints = false

    init() {
        self.game = Game()
        gameGrid = GameGrid(game: game)

        super.init(nibName: nil, bundle: nil)

        addChildViewController(gameGrid)
        view.addSubview(gameGrid.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.themeColor(.OffWhite)
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            let gameGridInsets = UIEdgeInsets(top: 0,
                                              left: Play.gridMargin,
                                              bottom: 0,
                                              right: Play.gridMargin)
            gameGrid.view.autoPinEdgesToSuperviewEdgesWithInsets(gameGridInsets)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
