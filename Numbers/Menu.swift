//
//  Menu.swift
//  Numbers
//
//  Created by Elise Hein on 13/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Menu: UIViewController {

    let buttonsStackView = UIStackView()

    init () {
        super.init(nibName: nil, bundle: nil)

        let newGameButton = UIButton()
        newGameButton.setTitle("New game", forState: .Normal)
        newGameButton.addTarget(self,
                                selector: #selector(Menu.startNewGame(_:)),
                                forControlEvents: .TouchUpInside)

        let instructionsButton = UIButton()
        instructionsButton.setTitle("Instructions", forState: .Normal)
        instructionsButton.addTarget(self,
                                     selector: #selector(Menu.displayInstructions(_:)),
                                     forControlEvents: .TouchUpInside)

        buttonsStackView.addArrangedSubview(newGameButton)
        buttonsStackView.addArrangedSubview(instructionsButton)

        view.addSubview(buttonsStackView)
    }

    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        buttonsStackView.frame = view.bounds
    }

    private func startNewGame () {
    }

    private func displayInstructions () {
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}