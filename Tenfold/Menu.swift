//
//  Menu.swift
//  Tenfold
//
//  Created by Elise Hein on 13/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import PureLayout
import UIKit

class Menu: UIView {

    private static let buttonHeight: CGFloat = {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 80
        } else {
            return 50
        }
    }()

    let logo = UIImageView()
    let newGameButton = Button()
    let instructionsButton = Button()

    var onTapNewGame: (() -> Void)?
    var onTapInstructions: (() -> Void)?

    var animationInProgress = false

    private var hasLoadedConstraints = false

    init() {
        super.init(frame: CGRect.zero)

        logo.image = UIImage(named: "tenfold-logo")
        logo.contentMode = .ScaleAspectFit

        newGameButton.setTitle("Start over", forState: .Normal)
        newGameButton.addTarget(self,
                                action: #selector(Menu.didTapNewGame),
                                forControlEvents: .TouchUpInside)

        instructionsButton.setTitle("How it works", forState: .Normal)
        instructionsButton.addTarget(self,
                                     action: #selector(Menu.didTapInstructions),
                                     forControlEvents: .TouchUpInside)

        addSubview(logo)
        addSubview(newGameButton)
        addSubview(instructionsButton)

        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        if !hasLoadedConstraints {
            var logoCenterOffset: CGFloat = -100
            var logoSize = CGSize(width: 150, height: 100)
            var buttonsTopSpacing: CGFloat = 80

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                logoCenterOffset = -180
                logoSize = CGSize(width: 180, height: 120)
                buttonsTopSpacing = 140
            }

            logo.autoAlignAxisToSuperviewAxis(.Vertical)
            logo.autoAlignAxis(.Horizontal, toSameAxisOfView: self, withOffset: logoCenterOffset)
            logo.autoSetDimensionsToSize(logoSize)

            for button in [newGameButton, instructionsButton] {
                button.autoSetDimension(.Height, toSize: Menu.buttonHeight)
            }

            newGameButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: logo, withOffset: buttonsTopSpacing)
            instructionsButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: newGameButton)

            [logo, newGameButton, instructionsButton].autoAlignViewsToAxis(.Vertical)

            hasLoadedConstraints = true
        }

        super.updateConstraints()
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
        UIView.animateWithDuration(0.25,
                                   delay: 0,
                                   options: .CurveEaseIn,
                                   animations: {
            self.frame = self.offScreen(lockedFrame)
            self.alpha = 0
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
            self.alpha = 1
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
