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
        super.init(position: .Center)

        titleLabel.text = "What's new?"
        titleLabel.font = UIFont.themeFontWithSize(15, weight: .Bold)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            titleLabel.font = UIFont.themeFontWithSize(20, weight: .Bold)
        }

        titleLabel.textColor = UIColor.themeColor(.OffBlack)
        titleLabel.textAlignment = .Center

        let text = "Thanks for updating Tenfold!\n" +
                   "Ever make an annoying mistake while playing? " +
                   "You can now undo your latest move by swiping right."
        textLabel.numberOfLines = 0
        textLabel.attributedText = NSMutableAttributedString.themeString(.Paragraph, text)

        ruleGrid.animationType = RuleGridAnimationType(rawValue: UpdatesModal.gridData["animationType"].string!)!
        ruleGrid.values = UpdatesModal.gridData["values"].arrayValue.map({ $0.int })
        ruleGrid.crossedOutIndeces = UpdatesModal.gridData["crossedOut"].arrayValue.map({ $0.int! })

        ruleGrid.pairs = UpdatesModal.gridData["pairs"].arrayValue.map({ JSONPair in
                JSONPair.arrayValue.map({ index in index.int! })
            })

        ModalOverlay.configureModalButton(okButton, color: UIColor.themeColor(.SecondaryAccent))
        okButton.setTitle("Back to the game", forState: .Normal)
        okButton.addTarget(self, action: #selector(UpdatesModal.didTapOK), forControlEvents: .TouchUpInside)

        modal.addSubview(titleLabel)
        modal.addSubview(textLabel)
        modal.addSubview(ruleGrid)
        modal.addSubview(okButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ruleGrid.playLoop()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ruleGrid.invalidateLoop()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ruleGrid.initialisePositionWithinFrame(ruleGrid.frame, withInsets: UIEdgeInsetsZero)
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            titleLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: ModalOverlay.contentPadding)

            textLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 25)
            textLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 25)
            textLabel.autoPinEdge(.Top,
                                  toEdge: .Bottom,
                                  ofView: titleLabel,
                                  withOffset: ModalOverlay.titleTextSpacing)

            ruleGrid.autoSetDimensionsToSize(gridSize())
            ruleGrid.autoAlignAxisToSuperviewAxis(.Vertical)
            ruleGrid.autoPinEdge(.Top,
                                 toEdge: .Bottom,
                                 ofView: textLabel,
                                 withOffset: ModalOverlay.contentPadding * 1.5)
            ruleGrid.autoPinEdge(.Bottom,
                                 toEdge: .Top,
                                 ofView: okButton,
                                 withOffset: -ModalOverlay.contentPadding * 1.5)

            okButton.autoAlignAxisToSuperviewAxis(.Vertical)
            okButton.autoPinEdgeToSuperviewEdge(.Bottom)
            okButton.autoMatchDimension(.Width, toDimension: .Width, ofView: modal)
            okButton.autoSetDimension(.Height, toSize: ModalOverlay.modalButtonHeight)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    func didTapOK() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func gridSize() -> CGSize {
        let gridWidth = UIDevice.currentDevice().userInterfaceIdiom == .Pad ?
                        370 :
                        view.bounds.size.width * 0.8
        return Grid.size(forAvailableWidth: gridWidth, cellCount: ruleGrid.values.count)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
