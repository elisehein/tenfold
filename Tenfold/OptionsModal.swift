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

    fileprivate let soundLabel = UILabel()
    fileprivate let soundButton = BooleanStrikethroughButton()
    fileprivate let vibrationButton = BooleanStrikethroughButton()

    fileprivate let initialNumbersLabel = UILabel()
    fileprivate let initialNumbersButton = SlidingStrikethroughButton()
    fileprivate let initialNumbersDetail = UILabel()

    fileprivate let doneButton = Button()

    var hasLoadedConstraints = false

    // swiftlint:disable:next function_body_length
    init() {
        super.init(position: .center)

        soundLabel.attributedText = NSMutableAttributedString.themeString(.optionTitle, "Sound effects")

        initialNumbersLabel.attributedText = NSMutableAttributedString.themeString(.optionTitle, "Starting point")

        let detailText = "Take on the original 1-19 challenge , " +
                         "or start out with a random set of numbers every time. " +
                         "In both cases, there are endless ways for each game to unfold."

        initialNumbersDetail.numberOfLines = 0
        initialNumbersDetail.attributedText = NSMutableAttributedString.themeString(.optionDetail, detailText)

        ModalOverlay.configureModalButton(soundButton,
                                          color: UIColor.themeColor(.offWhiteShaded),
                                          shouldHighlight: false)
        ModalOverlay.configureModalButton(vibrationButton,
                                          color: UIColor.themeColor(.offWhiteShaded),
                                          shouldHighlight: false)
        ModalOverlay.configureModalButton(initialNumbersButton,
                                          color: UIColor.themeColor(.offWhiteShaded),
                                          shouldHighlight: false)
        ModalOverlay.configureModalButton(doneButton, color: UIColor.themeColor(.secondaryAccent))

        soundButton.setTitle("Sounds", for: UIControlState())
        soundButton.struckthrough = !StorageService.currentFlag(forSetting: .SoundOn)

        vibrationButton.setTitle("Vibrations", for: UIControlState())
        vibrationButton.struckthrough = !StorageService.currentFlag(forSetting: .VibrationOn)

        doneButton.setTitle("Done", for: UIControlState())

        // swiftlint:disable:next line_length
        initialNumbersButton.struckthroughOption = StorageService.currentFlag(forSetting: .RandomInitialNumbers) ? .left : .right
        initialNumbersButton.options = ["1-19 Challenge", "Random"]

        soundButton.addTarget(self, action: #selector(self.toggleSound), for: .touchUpInside)
        vibrationButton.addTarget(self, action: #selector(self.toggleVibration), for: .touchUpInside)
        initialNumbersButton.addTarget(self, action: #selector(self.toggleInitialNumbers), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(self.dismissModal), for: .touchUpInside)

        modalBox.addSubview(soundLabel)
        modalBox.addSubview(soundButton)
        modalBox.addSubview(initialNumbersLabel)
        modalBox.addSubview(initialNumbersButton)
        modalBox.addSubview(initialNumbersDetail)
        modalBox.addSubview(doneButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if SoundService.singleton!.forceTouchVibrationsAvailable() {
            soundLabel.attributedText = NSMutableAttributedString.themeString(.optionTitle,
                                                                              "Sound and vibration effects")
            modalBox.addSubview(vibrationButton)
        }

        view.setNeedsUpdateConstraints()
    }

    // swiftlint:disable:next function_body_length
    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            soundLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
            soundLabel.autoMatch(.width, to: .width, of: modalBox, withMultiplier: 0.9)
            soundLabel.autoAlignAxis(toSuperviewAxis: .vertical)

            soundButton.autoAlignAxis(toSuperviewAxis: .vertical)
            soundButton.autoPinEdge(.top, to: .bottom, of: soundLabel, withOffset: 10)
            soundButton.autoMatch(.width, to: .width, of: modalBox)
            soundButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)

            if SoundService.singleton!.forceTouchVibrationsAvailable() {
                vibrationButton.autoAlignAxis(toSuperviewAxis: .vertical)
                vibrationButton.autoPinEdge(.top, to: .bottom, of: soundButton, withOffset: -2)
                vibrationButton.autoMatch(.width, to: .width, of: modalBox)
                vibrationButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)
            }

            let referenceView = SoundService.singleton!.forceTouchVibrationsAvailable() ?
                                vibrationButton:
                                soundButton

            initialNumbersLabel.autoPinEdge(.top, to: .bottom, of: referenceView, withOffset: 30)
            initialNumbersLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            initialNumbersLabel.autoMatch(.width, to: .width, of: modalBox, withMultiplier: 0.9)

            initialNumbersButton.autoPinEdge(toSuperviewEdge: .left)
            initialNumbersButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)
            initialNumbersButton.autoPinEdge(.top, to: .bottom, of: initialNumbersLabel, withOffset: 10)
            initialNumbersButton.autoMatch(.width, to: .width, of: modalBox)

            initialNumbersDetail.autoPinEdge(.top, to: .bottom, of: initialNumbersButton, withOffset: 10)
            initialNumbersDetail.autoMatch(.width, to: .width, of: modalBox, withMultiplier: 0.9)
            initialNumbersDetail.autoAlignAxis(toSuperviewAxis: .vertical)

            doneButton.autoAlignAxis(toSuperviewAxis: .vertical)
            doneButton.autoPinEdge(.top, to: .bottom, of: initialNumbersDetail, withOffset: 30)
            doneButton.autoMatch(.width, to: .width, of: modalBox)
            doneButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)
            doneButton.autoPinEdge(toSuperviewEdge: .bottom)

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

    func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
