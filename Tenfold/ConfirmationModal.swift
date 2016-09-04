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
        super.init()

        titleLabel.text = "Are you sure?"
        titleLabel.font = UIFont.themeFontWithSize(15, weight: .Bold)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            titleLabel.font = UIFont.themeFontWithSize(20, weight: .Bold)
        }

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

            var horizontalInset: CGFloat = 40
            var contentPadding: CGFloat = 40
            var titleTextSpacing: CGFloat = 15

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                horizontalInset = 80
                contentPadding = 70
                titleTextSpacing = 25

                modal.autoSetDimension(.Width, toSize: 460)
                modal.autoCenterInSuperview()
            } else {
                modal.autoPinEdgeToSuperviewEdge(.Left, withInset: 10)
                modal.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 10)
                modal.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
            }

            titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            titleLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: contentPadding)

            textLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: horizontalInset)
            textLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: horizontalInset)
            textLabel.autoPinEdge(.Top,
                                  toEdge: .Bottom,
                                  ofView: titleLabel,
                                  withOffset: titleTextSpacing)
            textLabel.autoPinEdge(.Bottom,
                                  toEdge: .Top,
                                  ofView: yesButton,
                                  withOffset: -contentPadding)

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
        } else if numbersRemaining <= 20 {
            let toGoPhrase = numbersRemaining > 1 ? "numbers to go." : "number left!"
            text = "You've only got \(numbersRemaining) \(toGoPhrase) " +
                   randomMotivationalQuote()
        } else if RankingService.singleton.gameIsLongerThanCurrentLongest(game) {
           text = "This is your longest game to date. Do you really want to quit now?"
        } else if historicNumbersCrossedOut > 10 {
            text = "You've gotten rid of \(historicNumbersCrossedOut) " +
                   "numbers already. " + randomMotivationalQuote()
        } else {
            text = "You're only on round \(game.currentRound). " +
                   randomMotivationalQuote()
        }

        textLabel.attributedText = constructAttributedString(withText: text)
    }

    func didTapYes() {
        dismissViewControllerAnimated(true, completion: { _ in
            self.onTapYes!()
        })
    }

    func didTapCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func constructAttributedString(withText text: String) -> NSAttributedString {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .Center

        var font = UIFont.themeFontWithSize(14)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = UIFont.themeFontWithSize(18)
            paragraphStyle.lineSpacing = 7
        }

        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.themeColor(.OffBlack)
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    private func randomMotivationalQuote() -> String {
        return CopyService.phrasebook(.Motivational).arrayValue.randomElement().string!
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
