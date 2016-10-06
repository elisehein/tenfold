//
//  OptionsModal.swift
//  Tenfold
//
//  Created by Elise Hein on 06/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class OptionsModal: ModalOverlay {

    private let soundLabel = UILabel()
    private let soundButton = BooleanStrikethroughButton()

    private let initialNumbersLabel = UILabel()
    private let initialNumbersButton = SlidingStrikethroughButton()
    private let initialNumbersDetail = UILabel()

    private let doneButton = Button()

    var hasLoadedConstraints = false

    init() {
        super.init(position: .Center)

        soundLabel.attributedText = NSMutableAttributedString.themeString(.OptionTitle, "Sound effects")
        initialNumbersLabel.attributedText = NSMutableAttributedString.themeString(.OptionTitle, "Starting point")

        let detailText = "In the classic version, you always begin with the same " +
                         "27 numbers (1, 2, 3, ... 1, 9). Wheter you keep it traditional " +
                         "or go random, there are endless ways for each game to unfold."

        initialNumbersDetail.numberOfLines = 0
        initialNumbersDetail.attributedText = NSMutableAttributedString.themeString(.OptionDetail, detailText)

        ModalOverlay.configureModalButton(soundButton,
                                          color: UIColor.themeColor(.OffWhiteShaded),
                                          shouldHighlight: false)
        ModalOverlay.configureModalButton(initialNumbersButton,
                                          color: UIColor.themeColor(.OffWhiteShaded),
                                          shouldHighlight: false)
        ModalOverlay.configureModalButton(doneButton, color: UIColor.themeColor(.SecondaryAccent))

        soundButton.setTitle("Sound effects", forState: .Normal)
        soundButton.struckthrough = !StorageService.currentFlag(forSetting: .SoundOn)

        doneButton.setTitle("Done", forState: .Normal)

        // swiftlint:disable:next line_length
        initialNumbersButton.struckthroughOption = StorageService.currentFlag(forSetting: .RandomInitialNumbers) ? .Left : .Right
        initialNumbersButton.options = ["Classic 1-19", "Random"]

        soundButton.addTarget(self, action: #selector(OptionsModal.toggleSound), forControlEvents: .TouchUpInside)
        initialNumbersButton.addTarget(self,
                                    action: #selector(OptionsModal.toggleInitialNumbers),
                                    forControlEvents: .TouchUpInside)
        doneButton.addTarget(self,
                             action: #selector(OptionsModal.dismiss),
                             forControlEvents: .TouchUpInside)

        modal.addSubview(soundLabel)
        modal.addSubview(soundButton)
        modal.addSubview(initialNumbersLabel)
        modal.addSubview(initialNumbersButton)
        modal.addSubview(initialNumbersDetail)
        modal.addSubview(doneButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            soundLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 30)
            soundLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: modal, withMultiplier: 0.9)
            soundLabel.autoAlignAxisToSuperviewAxis(.Vertical)

            soundButton.autoAlignAxisToSuperviewAxis(.Vertical)
            soundButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: soundLabel, withOffset: 10)
//            soundButton.autoPinEdgeToSuperviewEdge(.Top)
            soundButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            soundButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)

            initialNumbersLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: soundButton, withOffset: 30)
            initialNumbersLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            initialNumbersLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: modal, withMultiplier: 0.9)

            initialNumbersButton.autoPinEdgeToSuperviewEdge(.Left)
            initialNumbersButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)
            initialNumbersButton.autoPinEdge(.Top,
                                          toEdge: .Bottom,
                                          ofView: initialNumbersLabel,
                                          withOffset: 10)
            initialNumbersButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)

            initialNumbersDetail.autoPinEdge(.Top,
                                             toEdge: .Bottom,
                                             ofView: initialNumbersButton,
                                             withOffset: 10)
            initialNumbersDetail.autoMatchDimension(.Width,
                                                    toDimension: .Width,
                                                    ofView: modal,
                                                    withMultiplier: 0.9)
            initialNumbersDetail.autoAlignAxisToSuperviewAxis(.Vertical)

            doneButton.autoAlignAxisToSuperviewAxis(.Vertical)
            doneButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: initialNumbersDetail, withOffset: 30)
            doneButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            doneButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)
            doneButton.autoPinEdgeToSuperviewEdge(.Bottom)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    func toggleSound() {
        StorageService.toggleFlag(forSetting: .SoundOn)
        soundButton.toggle()
    }

    func toggleInitialNumbers() {
        StorageService.toggleFlag(forSetting: .RandomInitialNumbers)
        initialNumbersButton.toggle()
    }

    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
