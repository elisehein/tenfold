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

    var onTapNewGame: (() -> Void)?
    var onTapInstructions: (() -> Void)?

    private var animationInProgress = false

    private static let buttonSize = CGSize(width: 100, height: 40)

    var locked: Bool {
        get {
            return animationInProgress || hidden
        }
    }

    init() {
        super.init(frame: CGRect.zero)

        newGameButton.frame = CGRect(origin: CGPoint.zero, size: Menu.buttonSize)
        newGameButton.setTitle("Start over", forState: .Normal)
        newGameButton.titleLabel!.font = UIFont.themeFontWithSize(16)
        newGameButton.setTitleColor(UIColor.themeColor(.OffBlack), forState: .Normal)
        newGameButton.addTarget(self,
                                action: #selector(Menu.didTapNewGame),
                                forControlEvents: .TouchUpInside)

        instructionsButton.frame = CGRect(origin: CGPoint.zero, size: Menu.buttonSize)
        instructionsButton.setTitle("How it works", forState: .Normal)
        instructionsButton.titleLabel!.font = UIFont.themeFontWithSize(16)
        instructionsButton.setTitleColor(UIColor.themeColor(.OffBlack), forState: .Normal)
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

    func hideIfNeeded() {
        guard !hidden else { return }
        animationInProgress = true

        let lockedFrame = frame
        UIView.animateWithDuration(0.2,
                                   delay: 0,
                                   options: .CurveEaseIn,
                                   animations: {
            self.frame = self.offScreen(lockedFrame)
        }, completion: { _ in
            self.hidden = true
            self.animationInProgress = false
        })
    }

    func showIfNeeded(atEndPosition endPosition: CGRect) {
        guard hidden else { return }
        hidden = false
        animationInProgress = true

        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
            self.frame = endPosition
        }, completion: { _ in
            self.animationInProgress = false
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
