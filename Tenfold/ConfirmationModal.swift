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

class ConfirmationModal: UIViewController {

    private let game: Game

    private let modal = UIView()
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let yesButton = Button()
    private let cancelButton = Button()

    var onTapYes: (() -> Void)?

    var hasLoadedConstraints = false

    private static var quotes = JSON.initFromFile("motivationalPhrases")!

    init(game: Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .OverCurrentContext

        view.backgroundColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.65)

        modal.backgroundColor = UIColor.themeColor(.OffWhite)
        modal.layer.shadowColor = UIColor.themeColor(.OffBlack).CGColor
        modal.layer.shadowOffset = CGSize(width: 2, height: 2)
        modal.layer.shadowRadius = 2
        modal.layer.shadowOpacity = 0.5

        titleLabel.text = "Are you sure?"
        titleLabel.font = UIFont.themeFontWithSize(15, weight: .Bold)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            titleLabel.font = UIFont.themeFontWithSize(20, weight: .Bold)
        }

        titleLabel.textColor = UIColor.themeColor(.OffBlack)
        titleLabel.textAlignment = .Center

        setText()
        textLabel.numberOfLines = 0

        setButtonBackgroundColorWithHighlight(yesButton, color: UIColor.themeColor(.OffWhiteShaded))
        yesButton.setTitle("Start over", forState: .Normal)
        yesButton.addTarget(self,
                            action: #selector(ConfirmationModal.didTapYes),
                            forControlEvents: .TouchUpInside)

        setButtonBackgroundColorWithHighlight(cancelButton,
                                              color: UIColor.themeColor(.SecondaryAccent))
        cancelButton.setTitle("Keep going", forState: .Normal)
        cancelButton.addTarget(self,
                               action: #selector(ConfirmationModal.didTapCancel),
                               forControlEvents: .TouchUpInside)

        for button in [yesButton, cancelButton] {
            button.layer.borderColor = modal.backgroundColor?.CGColor
            button.layer.borderWidth = 2.0
        }

        view.addSubview(modal)
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
            var buttonHeight: CGFloat = 60
            var titleTextSpacing: CGFloat = 15

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                horizontalInset = 80
                contentPadding = 70
                buttonHeight = 80
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
            yesButton.autoSetDimension(.Height, toSize: buttonHeight)

            cancelButton.autoAlignAxisToSuperviewAxis(.Vertical)
            cancelButton.autoPinEdgeToSuperviewEdge(.Bottom)
            cancelButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            cancelButton.autoSetDimension(.Height, toSize: buttonHeight)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    private func setText() {
        let numbersRemaining = game.numbersRemaining()

        var text = ""

        if longestGameToDate() {
           text = "This is your longest game to date! Do you really want to give up now?"
        } else if numbersRemaining <= 20 {
            let toGoPhrase = numbersRemaining > 1 ? "numbers to go." : "number left!"
            text = "You've only got \(numbersRemaining) \(toGoPhrase) " +
                   randomMotivationalQuote()
        } else if game.historicNumberCount - numbersRemaining > 10 {
            text = "You've gotten rid of \(game.historicNumberCount - numbersRemaining) " +
                   "numbers already. " + randomMotivationalQuote()
        } else {
            text = "You're only on round \(game.currentRound.asWord()). " +
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

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)

        if touches.count == 1 {
            let touch = touches.first
            if let point = touch?.locationInView(view) {
                if !CGRectContainsPoint(modal.frame, point) {
                    dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    private func constructAttributedString(withText text: String) -> NSMutableAttributedString {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .Center

        var font = UIFont.themeFontWithSize(14)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = UIFont.themeFontWithSize(18)
            paragraphStyle.lineSpacing = 7
        }

        let attrString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: attrString.length)

        attrString.addAttribute(NSParagraphStyleAttributeName,
                                value: paragraphStyle,
                                range: fullRange)

        attrString.addAttribute(NSFontAttributeName,
                                value: font,
                                range: fullRange)

        attrString.addAttribute(NSForegroundColorAttributeName,
                                value: UIColor.themeColor(.OffBlack),
                                range: fullRange)
        return attrString
    }

    private func longestGameToDate() -> Bool {
        let stats = StorageService.restorePreviousGameStats()
        var gameLengths = stats.map({ ($0["historicNumberCount"] as? Int)! })
        gameLengths = gameLengths.sort()
        return game.historicNumberCount > gameLengths.last
    }

    private func randomMotivationalQuote() -> String {
        return ConfirmationModal.quotes.arrayValue.randomElement().string!
    }

    private func setButtonBackgroundColorWithHighlight(button: UIButton, color: UIColor) {
        button.setBackgroundImage(UIImage.imageWithColor(color), forState: .Normal)
        button.setBackgroundImage(UIImage.imageWithColor(color.darken()), forState: .Highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
