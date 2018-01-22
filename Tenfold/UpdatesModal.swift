//
//  UpdatesModal.swift
//  Tenfold
//
//  Created by Elise Hein on 17/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import PureLayout

class UpdatesModal: ModalOverlay {

    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let okButton = Button()

    private var hasLoadedConstraints = false

    private let ruleGrid = RuleGrid()
    private static var gridData = JSON.initFromFile("rules")![4]["examples"][0]

    init() {
        super.init(position: .center)

        titleLabel.text = "What's new?"
        titleLabel.font = UIFont.themeFontWithSize(15, weight: .bold)

        if UIDevice.current.userInterfaceIdiom == .pad {
            titleLabel.font = UIFont.themeFontWithSize(20, weight: .bold)
        }

        titleLabel.textColor = UIColor.themeColor(.offBlack)
        titleLabel.textAlignment = .center

        let text = "Thanks for updating Tenfold!\n" +
                   "Ever make an annoying mistake while playing? " +
                   "You can now undo your latest move by swiping right."
        textLabel.numberOfLines = 0
        textLabel.attributedText = NSMutableAttributedString.themeString(.paragraph, text)

        ruleGrid.animationType = RuleGridAnimationType(rawValue: UpdatesModal.gridData["animationType"].string!)!
        ruleGrid.values = UpdatesModal.gridData["values"].arrayValue.map({ $0.int })
        ruleGrid.crossedOutIndeces = UpdatesModal.gridData["crossedOut"].arrayValue.map({ $0.int! })

        ruleGrid.pairs = UpdatesModal.gridData["pairs"].arrayValue.map({ JSONPair in
                JSONPair.arrayValue.map({ index in index.int! })
            })

        ModalOverlay.configureModalButton(okButton, color: UIColor.themeColor(.secondaryAccent))
        okButton.setTitle("Back to the game", for: UIControlState())
        okButton.addTarget(self, action: #selector(UpdatesModal.didTapOK), for: .touchUpInside)

        modalBox.addSubview(titleLabel)
        modalBox.addSubview(textLabel)
        modalBox.addSubview(ruleGrid)
        modalBox.addSubview(okButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ruleGrid.playLoop()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ruleGrid.invalidateLoop()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ruleGrid.initialisePositionWithinFrame(ruleGrid.frame, withInsets: UIEdgeInsets.zero)
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            titleLabel.autoMatch(.width, to: .width, of: modalBox)
            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: ModalOverlay.contentPadding)

            textLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 25)
            textLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 25)
            textLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: ModalOverlay.titleTextSpacing)

            ruleGrid.autoSetDimensions(to: gridSize())
            ruleGrid.autoAlignAxis(toSuperviewAxis: .vertical)
            ruleGrid.autoPinEdge(.top, to: .bottom, of: textLabel, withOffset: ModalOverlay.contentPadding * 1.5)
            ruleGrid.autoPinEdge(.bottom, to: .top, of: okButton, withOffset: -ModalOverlay.contentPadding * 1.5)

            okButton.autoAlignAxis(toSuperviewAxis: .vertical)
            okButton.autoPinEdge(toSuperviewEdge: .bottom)
            okButton.autoMatch(.width, to: .width, of: modalBox)
            okButton.autoSetDimension(.height, toSize: ModalOverlay.modalButtonHeight)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    @objc func didTapOK() {
        dismiss(animated: true, completion: nil)
    }

    private func gridSize() -> CGSize {
        let gridWidth = UIDevice.current.userInterfaceIdiom == .pad ?
                        370 :
                        view.bounds.size.width * 0.8
        return Grid.size(forAvailableWidth: gridWidth, cellCount: ruleGrid.values.count)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
