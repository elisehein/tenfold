//
//  Menu.swift
//  Numbers
//
//  Created by Elise Hein on 13/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Menu: UIView {

    let buttonsStackView = UIStackView()
    let newGameButton = UIButton()
    let instructionsButton = UIButton()

    var defaultFrame: CGRect?

    var onTapNewGame: (() -> Void)?
    var onTapInstructions: (() -> Void)?

    var animationInProgress = false

    private static let buttonSize = CGSize(width: 100, height: 40)

    init() {
        super.init(frame: CGRect.zero)

        newGameButton.frame = CGRect(origin: CGPoint.zero, size: Menu.buttonSize)
        newGameButton.backgroundColor = UIColor.blueColor()
        newGameButton.setTitle("New game", forState: .Normal)
        newGameButton.addTarget(self,
                                action: #selector(Menu.didTapNewGame),
                                forControlEvents: .TouchUpInside)

        instructionsButton.frame = CGRect(origin: CGPoint.zero, size: Menu.buttonSize)
        instructionsButton.backgroundColor = UIColor.blueColor()
        instructionsButton.setTitle("Instructions", forState: .Normal)
        instructionsButton.addTarget(self,
                                     action: #selector(Menu.didTapInstructions),
                                     forControlEvents: .TouchUpInside)

        buttonsStackView.axis = .Vertical
        buttonsStackView.distribution = .FillEqually
        buttonsStackView.alignment = .Fill
        buttonsStackView.spacing = 5
        buttonsStackView.addArrangedSubview(newGameButton)
        buttonsStackView.addArrangedSubview(instructionsButton)

        addSubview(buttonsStackView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let totalButtons = buttonsStackView.arrangedSubviews.count
        let buttonsHeight = CGFloat(totalButtons) * Menu.buttonSize.height
        let stackHeight = buttonsHeight + (CGFloat(totalButtons - 1) * buttonsStackView.spacing)
        let stackViewFrame = CGRect(origin: CGPoint.zero,
                                    size: CGSize(width: Menu.buttonSize.width, height: stackHeight))
        buttonsStackView.frame = stackViewFrame
        buttonsStackView.center = center
    }

    func didTapNewGame() {
        onTapNewGame!()
    }

    func didTapInstructions() {
        onTapInstructions!()
    }

    func showIfNeeded(alongWithAnimationBlock animationBlock: (() -> Void)?,
                      completion: (() -> Void)? = nil) {
        guard hidden else { return }

        frame = offScreen(defaultFrame!)
        hidden = false

        animate({
            animationBlock?()
            self.frame = self.defaultFrame!
            self.alpha = 1
        }, completion: completion)
    }

    func hideIfNeeded(alongWithAnimationBlock animationBlock: (() -> Void)?,
                       completion: (() -> Void)? = nil) {
        guard !hidden else { return }

        animate({
            animationBlock?()
            self.frame = self.offScreen(self.frame)
            self.alpha = 0
        }, completion: { _ in
            self.hidden = true
            completion?()
        })
    }

    private func animate(animations: () -> Void, completion: (() -> Void)? = nil) {
        animationInProgress = true
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   options: .CurveEaseIn,
                                   animations: {
            animations()
        }, completion: { finished in
            self.animationInProgress = false
            completion?()
        })
    }

    private func offScreen(rect: CGRect) -> CGRect {
        var offScreenRect = rect
        offScreenRect.origin.y = -rect.size.height
        return offScreenRect
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
