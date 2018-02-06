//
//  ConfirmationModal.swift
//  Tenfold
//
//  Created by Elise Hein on 27/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import PureLayout

class ConfirmationModal: ModalOverlay {

    private let game: Game

    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let yesButton = Button()
    private let cancelButton = Button()

    var onTapYes: (() -> Void)?

    var hasLoadedConstraints = false

    init(game: Game) {
        self.game = game
        super.init(position: .bottom)

        titleLabel.attributedText = NSMutableAttributedString.themeString(.title, "Are you sure?")
        titleLabel.textColor = UIColor.themeColor(.offBlack)
        titleLabel.textAlignment = .center

        setText()
        textLabel.numberOfLines = 0

        ModalOverlay.configureModalButton(yesButton, color: UIColor.themeColor(.offWhiteShaded))
        yesButton.setTitle("Start over", for: UIControlState())
        yesButton.addTarget(self,
                            action: #selector(ConfirmationModal.didTapYes),
                            for: .touchUpInside)

        ModalOverlay.configureModalButton(cancelButton, color: UIColor.themeColor(.secondaryAccent))
        cancelButton.setTitle("Keep going", for: UIControlState())
        cancelButton.addTarget(self,
                               action: #selector(ConfirmationModal.didTapCancel),
                               for: .touchUpInside)

        modalBox.addSubview(titleLabel)
        modalBox.addSubview(textLabel)
        modalBox.addSubview(yesButton)
        modalBox.addSubview(cancelButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            titleLabel.autoMatch(.width, to: .width, of: modalBox)
            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: ModalOverlay.contentPadding)

            textLabel.autoPinEdge(toSuperviewEdge: .left, withInset: ModalOverlay.horizontalInset)
            textLabel.autoPinEdge(toSuperviewEdge: .right, withInset: ModalOverlay.horizontalInset)
            textLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: ModalOverlay.titleTextSpacing)
            textLabel.autoPinEdge(.bottom, to: .top, of: yesButton, withOffset: -ModalOverlay.contentPadding)

            yesButton.autoAlignAxis(toSuperviewAxis: .vertical)
            yesButton.autoPinEdge(.bottom, to: .top, of: cancelButton, withOffset: 2)
            yesButton.autoMatch(.width, to: .width, of: modalBox)
            yesButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)

            cancelButton.autoAlignAxis(toSuperviewAxis: .vertical)
            cancelButton.autoPinEdge(toSuperviewEdge: .bottom)
            cancelButton.autoMatch(.width, to: .width, of: modalBox)
            cancelButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    private func setText() {
        let numbersRemaining = game.numbersRemaining()
        let historicNumbersCrossedOut = game.historicNumbersCrossedOut()
        let uniqueValues = game.numberOfUniqueValues()

        var text: String

        if uniqueValues < 6 {
            text = "You've got only \(uniqueValues) unique numbers left. Really quit now?"
        } else if numbersRemaining == 1 {
            text = "You've got ONE number left – finish it!"
        } else if numbersRemaining <= 20 {
            text = "You've only got \(numbersRemaining) numbers to go. " +
                   randomMotivationalQuote()
        } else if RankingService.singleton.gameIsLongerThanCurrentLongest(game) {
           text = "This is your longest game to date. Do you really want to quit now?"
        } else if historicNumbersCrossedOut > 10 {
            text = "You've got \(numbersRemaining) numbers left. " + randomMotivationalQuote()
        } else {
            text = "You've only been playing for \(game.currentRound) rounds. " +
                   randomMotivationalQuote()
        }

        textLabel.attributedText = NSMutableAttributedString.themeString(.paragraph, text)
    }

    @objc func didTapYes() {
        dismiss(animated: true, completion: { self.onTapYes!() })
    }

    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }

    private func randomMotivationalQuote() -> String {
        return CopyService.phrasebook(.motivational).arrayValue.randomElement().string!
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
