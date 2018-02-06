//
//  NextRoundDisallowedModal.swift
//  Tenfold
//
//  Created by Elise Hein on 13/01/2017.
//  Copyright © 2017 Elise Hein. All rights reserved.
//

import Foundation

//
//  UpdatesModal.swift
//  Tenfold
//
//  Created by Elise Hein on 17/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class NextRoundDisallowedModal: ModalOverlay {

    var onTapHelp: (() -> Void)?

    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let tipLabel = UILabel()
    private let okButton = Button()
    private let helpButton = Button()

    private var hasLoadedConstraints = false

    init(potentialPairs: Int) {
        super.init(position: .bottom)

        let titleText = "Why can't I add the next round of numbers?"
        titleLabel.attributedText = NSMutableAttributedString.themeString(.title, titleText)
        titleLabel.textColor = UIColor.themeColor(.offBlack)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let explanationText = "The more numbers you have in the game, the harder it will be to win. " +
                              "Try finding a few more pairs before adding the next round."
        textLabel.attributedText = NSMutableAttributedString.themeString(.paragraph, explanationText)
        textLabel.numberOfLines = 0

        let tipText = "TIP! The current game has still got \(potentialPairs) possible pairings."
        tipLabel.attributedText = NSMutableAttributedString.themeString(.tip, tipText)
        tipLabel.numberOfLines = 0

        ModalOverlay.configureModalButton(helpButton, color: UIColor.themeColor(.offWhiteShaded))
        helpButton.setTitle("How do I find more pairs?", for: UIControlState())
        helpButton.addTarget(self, action: #selector(self.didTapHelp), for: .touchUpInside)

        ModalOverlay.configureModalButton(okButton, color: UIColor.themeColor(.secondaryAccent))
        okButton.setTitle("Back to the game", for: UIControlState())
        okButton.addTarget(self, action: #selector(self.didTapOk), for: .touchUpInside)

        modalBox.addSubview(titleLabel)
        modalBox.addSubview(textLabel)
        modalBox.addSubview(tipLabel)
        modalBox.addSubview(helpButton)
        modalBox.addSubview(okButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: ModalOverlay.horizontalInset)
            titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: ModalOverlay.horizontalInset)
            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: ModalOverlay.contentPadding)

            textLabel.autoPinEdge(toSuperviewEdge: .left, withInset: ModalOverlay.horizontalInset)
            textLabel.autoPinEdge(toSuperviewEdge: .right, withInset: ModalOverlay.horizontalInset)
            textLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: ModalOverlay.titleTextSpacing)

            tipLabel.autoPinEdge(toSuperviewEdge: .left, withInset: ModalOverlay.horizontalInset)
            tipLabel.autoPinEdge(toSuperviewEdge: .right, withInset: ModalOverlay.horizontalInset)
            tipLabel.autoPinEdge(.top, to: .bottom, of: textLabel, withOffset: ModalOverlay.contentPadding)
            tipLabel.autoPinEdge(.bottom, to: .top, of: helpButton, withOffset: -ModalOverlay.contentPadding)

            helpButton.autoAlignAxis(toSuperviewAxis: .vertical)
            helpButton.autoPinEdge(.bottom, to: .top, of: okButton, withOffset: 2)
            helpButton.autoMatch(.width, to: .width, of: modalBox)
            helpButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)

            okButton.autoAlignAxis(toSuperviewAxis: .vertical)
            okButton.autoPinEdge(toSuperviewEdge: .bottom)
            okButton.autoMatch(.width, to: .width, of: modalBox)
            okButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)

            hasLoadedConstraints = true
        }
        super.updateViewConstraints()
    }

    @objc func didTapOk() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didTapHelp() {
        dismiss(animated: true, completion: {
            self.onTapHelp?()
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
