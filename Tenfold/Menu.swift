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
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 80 : 40
    }()

    private let logo = UIImageView()
    private let newGameButton = Button()
    private let instructionsButton = Button()
    private let soundButton = Button()

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

        instructionsButton.setTitle("How to play", forState: .Normal)
        instructionsButton.addTarget(self,
                                     action: #selector(Menu.didTapInstructions),
                                     forControlEvents: .TouchUpInside)

        soundButton.strikeThrough = !StorageService.currentSoundPreference()
        soundButton.setTitle("Sound", forState: .Normal)
        soundButton.addTarget(self,
                              action: #selector(Menu.didTapSound),
                              forControlEvents: .TouchUpInside)

        addSubview(logo)
        addSubview(newGameButton)
        addSubview(instructionsButton)
        addSubview(soundButton)

        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        if !hasLoadedConstraints {
            var logoWidth: CGFloat = 140
            var centerPointOffset: CGFloat = 60

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                logoWidth = 180
                centerPointOffset = 100
            }

            for button in [newGameButton, instructionsButton, soundButton] {
                button.autoSetDimension(.Height, toSize: Menu.buttonHeight)
            }

            instructionsButton.autoAlignAxis(.Horizontal,
                                             toSameAxisOfView: self,
                                             withOffset: centerPointOffset)
            newGameButton.autoPinEdge(.Bottom, toEdge: .Top, ofView: instructionsButton)
            soundButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: instructionsButton)

            logo.autoPinEdgeToSuperviewEdge(.Top)
            logo.autoPinEdge(.Bottom, toEdge: .Top, ofView: newGameButton)
            logo.autoAlignAxisToSuperviewAxis(.Vertical)
            logo.autoSetDimension(.Width, toSize: logoWidth)

            [logo, newGameButton, instructionsButton, soundButton].autoAlignViewsToAxis(.Vertical)

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

    func didTapSound() {
        StorageService.toggleSoundPreference()
        soundButton.strikeThrough = !StorageService.currentSoundPreference()
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
