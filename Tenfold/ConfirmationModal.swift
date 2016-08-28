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

    private static var quotes: JSON = {
        var data: JSON?

        if let path = NSBundle.mainBundle().pathForResource("motivationalPhrases", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                data = JSON(data: jsonData)
            } catch {
                print("Error retrieving JSON data")
            }
        }

        return data!
    }()

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
            titleLabel.font = UIFont.themeFontWithSize(22, weight: .Bold)
        }

        titleLabel.textColor = UIColor.themeColor(.OffBlack)
        titleLabel.textAlignment = .Center

        setText()
        textLabel.numberOfLines = 0

        yesButton.setTitle("Start over", forState: .Normal)
        yesButton.backgroundColor = UIColor.themeColor(.OffWhiteShaded)
        yesButton.addTarget(self,
                            action: #selector(ConfirmationModal.didTapYes),
                            forControlEvents: .TouchUpInside)

        cancelButton.setTitle("Keep going", forState: .Normal)
        cancelButton.backgroundColor = UIColor.themeColor(.SecondaryAccent)
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

            var innerPadding: CGFloat = 30

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                innerPadding = 40
            }

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                modal.autoSetDimension(.Width, toSize: 500)
                modal.autoCenterInSuperview()
            } else {
                modal.autoPinEdgeToSuperviewEdge(.Left, withInset: 10)
                modal.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 10)
                modal.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
            }

            titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            titleLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 40)

            textLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: innerPadding)
            textLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: innerPadding)
            textLabel.autoPinEdge(.Top,
                                  toEdge: .Bottom,
                                  ofView: titleLabel,
                                  withOffset: 15)
            textLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: yesButton, withOffset: -40)

            yesButton.autoPinEdgeToSuperviewEdge(.Bottom)
            yesButton.autoPinEdgeToSuperviewEdge(.Left)
            yesButton.autoSetDimension(.Height, toSize: 60)
            yesButton.autoMatchDimension(.Width,
                                         toDimension: .Width,
                                         ofView: modal,
                                         withMultiplier: 0.5)

            cancelButton.autoPinEdgeToSuperviewEdge(.Bottom)
            cancelButton.autoPinEdgeToSuperviewEdge(.Right)
            cancelButton.autoSetDimension(.Height, toSize: 60)
            cancelButton.autoPinEdge(.Left, toEdge: .Right, ofView: yesButton, withOffset: -2)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    private func setText() {
        let numbersRemaining = game.numbersRemaining()
        let numbersCrossedOut = game.historicNumberCount - numbersRemaining

        var text = ""

        if game.numbersRemaining() <= 20 {
            text = "You've only got \(numbersRemaining) numbers to go. " + randomMotivationalQuote()
        } else if numbersCrossedOut > 10 {
            // swiftlint:disable:next line_length
            text = "You've gotten rid of \(game.historicNumberCount - game.numbersRemaining()) numbers already. " + randomMotivationalQuote()
        } else {
            text = "You're only on round \(game.currentRound). " + randomMotivationalQuote()
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
        paragraphStyle.lineSpacing = 4
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

    private func randomMotivationalQuote() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(ConfirmationModal.quotes.count)))
        return ConfirmationModal.quotes.arrayValue[randomIndex].string!
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
