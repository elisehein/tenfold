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
    private let vibrationButton = BooleanStrikethroughButton()

    private let initialNumbersLabel = UILabel()
    private let initialNumbersButton = SlidingStrikethroughButton()
    private let initialNumbersDetail = UILabel()

    private let doneButton = Button()

    var hasLoadedConstraints = false

    // swiftlint:disable:next function_body_length
    init() {
        super.init(position: .Center)

        soundLabel.attributedText = NSMutableAttributedString.themeString(.OptionTitle, "Sound effects")

        initialNumbersLabel.attributedText = NSMutableAttributedString.themeString(.OptionTitle, "Starting point")

        let detailText = "Take on the original 1-19 challenge , " +
                         "or start out with a random set of numbers every time. " +
                         "In both cases, there are endless ways for each game to unfold."

        initialNumbersDetail.numberOfLines = 0
        initialNumbersDetail.attributedText = NSMutableAttributedString.themeString(.OptionDetail, detailText)

        ModalOverlay.configureModalButton(soundButton,
                                          color: UIColor.themeColor(.OffWhiteShaded),
                                          shouldHighlight: false)
        ModalOverlay.configureModalButton(vibrationButton,
                                          color: UIColor.themeColor(.OffWhiteShaded),
                                          shouldHighlight: false)
        ModalOverlay.configureModalButton(initialNumbersButton,
                                          color: UIColor.themeColor(.OffWhiteShaded),
                                          shouldHighlight: false)
        ModalOverlay.configureModalButton(doneButton, color: UIColor.themeColor(.SecondaryAccent))

        soundButton.setTitle("Sounds", forState: .Normal)
        soundButton.struckthrough = !StorageService.currentFlag(forSetting: .SoundOn)

        vibrationButton.setTitle("Vibrations", forState: .Normal)
        vibrationButton.struckthrough = !StorageService.currentFlag(forSetting: .VibrationOn)

        doneButton.setTitle("Done", forState: .Normal)

        // swiftlint:disable:next line_length
        initialNumbersButton.struckthroughOption = StorageService.currentFlag(forSetting: .RandomInitialNumbers) ? .Left : .Right
        initialNumbersButton.options = ["1-19 Challenge", "Random"]

        soundButton.addTarget(self, action: #selector(OptionsModal.toggleSound), forControlEvents: .TouchUpInside)
        vibrationButton.addTarget(self,
                                  action: #selector(OptionsModal.toggleVibration),
                                  forControlEvents: .TouchUpInside)
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

        if SoundService.singleton!.forceTouchVibrationsAvailable() {
            soundLabel.attributedText = NSMutableAttributedString.themeString(.OptionTitle,
                                                                              "Sound and vibration effects")
            modal.addSubview(vibrationButton)
        }

        view.setNeedsUpdateConstraints()
    }

    // swiftlint:disable:next function_body_length
    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            soundLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 30)
            soundLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: modal, withMultiplier: 0.9)
            soundLabel.autoAlignAxisToSuperviewAxis(.Vertical)

            soundButton.autoAlignAxisToSuperviewAxis(.Vertical)
            soundButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: soundLabel, withOffset: 10)
            soundButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            soundButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)

            if SoundService.singleton!.forceTouchVibrationsAvailable() {
                vibrationButton.autoAlignAxisToSuperviewAxis(.Vertical)
                vibrationButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: soundButton, withOffset: -2)
                vibrationButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
                vibrationButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)
            }

            let referenceView = SoundService.singleton!.forceTouchVibrationsAvailable() ?
                                vibrationButton:
                                soundButton

            initialNumbersLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: referenceView, withOffset: 30)
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

    func toggleVibration() {
        StorageService.toggleFlag(forSetting: .VibrationOn)
        vibrationButton.toggle()
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
