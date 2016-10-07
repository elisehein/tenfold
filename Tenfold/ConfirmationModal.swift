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
        super.init(position: .Bottom)

        titleLabel.attributedText = NSMutableAttributedString.themeString(.Title, "Are you sure?")
        titleLabel.textColor = UIColor.themeColor(.OffBlack)
        titleLabel.textAlignment = .Center

        setText()
        textLabel.numberOfLines = 0

        ModalOverlay.configureModalButton(yesButton, color: UIColor.themeColor(.OffWhiteShaded))
        yesButton.setTitle("Start over", forState: .Normal)
        yesButton.addTarget(self,
                            action: #selector(ConfirmationModal.didTapYes),
                            forControlEvents: .TouchUpInside)

        ModalOverlay.configureModalButton(cancelButton, color: UIColor.themeColor(.SecondaryAccent))
        cancelButton.setTitle("Keep going", forState: .Normal)
        cancelButton.addTarget(self,
                               action: #selector(ConfirmationModal.didTapCancel),
                               forControlEvents: .TouchUpInside)

        modal.addSubview(titleLabel)
        modal.addSubview(textLabel)
        modal.addSubview(yesButton)
        modal.addSubview(cancelButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            titleLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: ModalOverlay.contentPadding)

            textLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: ModalOverlay.horizontalInset)
            textLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: ModalOverlay.horizontalInset)
            textLabel.autoPinEdge(.Top,
                                  toEdge: .Bottom,
                                  ofView: titleLabel,
                                  withOffset: ModalOverlay.titleTextSpacing)
            textLabel.autoPinEdge(.Bottom,
                                  toEdge: .Top,
                                  ofView: yesButton,
                                  withOffset: -ModalOverlay.contentPadding)

            yesButton.autoAlignAxisToSuperviewAxis(.Vertical)
            yesButton.autoPinEdge(.Bottom, toEdge: .Top, ofView: cancelButton, withOffset: 2)
            yesButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            yesButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)

            cancelButton.autoAlignAxisToSuperviewAxis(.Vertical)
            cancelButton.autoPinEdgeToSuperviewEdge(.Bottom)
            cancelButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            cancelButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)

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

        textLabel.attributedText = NSMutableAttributedString.themeString(.Paragraph, text)
    }

    func didTapYes() {
        dismissViewControllerAnimated(true, completion: { _ in
            self.onTapYes!()
        })
    }

    func didTapCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func randomMotivationalQuote() -> String {
        return CopyService.phrasebook(.Motivational).arrayValue.randomElement().string!
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
