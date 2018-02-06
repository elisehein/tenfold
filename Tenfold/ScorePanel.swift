//
//  ScorePanel.swift
//  Tenfold
//
//  Created by Elise Hein on 29/01/2018.
//  Copyright © 2018 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum ScorePanelAppearance {
    case overlay
    case inline
}

class ScorePanel: UIView {

    static let height: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 60 : 48
    }()

    private let label = UILabel()
    private let logo = UIImageView(image: UIImage(named: "tenfold-logo-small"))
    private let currentRoundLabel = UILabel()
    private let numbersRemainingLabel = UILabel()
    private let shadowLayer = UIView()

    private static let labelTransformFactor: CGFloat = 1.35

    private var appearance: ScorePanelAppearance = .inline

    private var isShowing = false

    var onTap: (() -> Void)?

    var numbersRemaining: Int = 0 {
        didSet {
            // Only pulse on game moves (remove pair & add round), not on undo moves
            if numbersRemaining < oldValue || numbersRemaining == oldValue * 2 {
                pulse(numbersRemainingLabel)
            }

            numbersRemainingLabel.attributedText = constructAttrString(for: numbersRemaining)
        }
    }

    var currentRound: Int = 0 {
        didSet {
            if currentRound > oldValue {
                pulse(currentRoundLabel)
            }

            currentRoundLabel.attributedText = constructAttrString(for: currentRound)
        }
    }

    var topInset: CGFloat = 0

    init(appearance: ScorePanelAppearance) {
        self.appearance = appearance
        super.init(frame: CGRect.zero)

        shadowLayer.backgroundColor = UIColor.clear
        shadowLayer.layer.shadowColor = UIColor.black.cgColor
        shadowLayer.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowLayer.layer.shadowOpacity = 0.15
        shadowLayer.layer.shadowRadius = 2
        shadowLayer.layer.masksToBounds = true
        shadowLayer.clipsToBounds = false
        addSubview(shadowLayer)

        label.layer.masksToBounds = true
        addSubview(label)

        label.attributedText = labelAttrString()
        configureBackground()

        logo.contentMode = .scaleAspectFit
        logo.frame = CGRect.zero
        logo.clipsToBounds = true
        addSubview(logo)

        currentRoundLabel.transform = ScorePanel.labelTransform()
        numbersRemainingLabel.transform = ScorePanel.labelTransform()
        addSubview(currentRoundLabel)
        addSubview(numbersRemainingLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(ScorePanel.didReceiveTap))

        addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard isShowing else { return }

        var labelFrame = bounds
        labelFrame.origin.y += topInset
        labelFrame.size.height -= topInset
        label.frame = labelFrame

        let logoSize: CGFloat = 18
        logo.frame = CGRect(x: (bounds.size.width - logoSize) / 2,
                            y: (bounds.size.height - topInset - logoSize) / 2 + topInset,
                            width: logoSize,
                            height: logoSize)

        // First make a narrower box in the middle of the pill
        var countFrame = bounds
        countFrame.size.width = 170
        countFrame.size.height -= topInset
        countFrame.origin.x = (bounds.size.width - countFrame.size.width) / 2
        countFrame.origin.y += topInset

        // Then cut it in half & use one half for each count
        countFrame.size.width /= 2
        countFrame.size.width -= logoSize / 2
        currentRoundLabel.frame = countFrame
        countFrame.origin.x += countFrame.size.width + logoSize
        numbersRemainingLabel.frame = countFrame

        shadowLayer.frame = bounds
        shadowLayer.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }

    @objc private func didReceiveTap() {
        onTap?()
    }

    private func configureBackground() {
        switch appearance {
        case .inline:
            shadowLayer.backgroundColor = UIColor.clear
        case .overlay:
            // This colour is midway between OffWhite and OffWhiteShaded (for less contrast)
            shadowLayer.backgroundColor = UIColor(hex: "#F4EBD8").withAlphaComponent(0.95)
        }

        shadowLayer.isHidden = appearance == .inline
    }

    func constructAttrString(for count: Int) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString.themeString(.pill, "\(count)")

        // Start from a scaled down font size so the pulse doesn't look blurry
        let originalPillFontSize = TextStyleProperties.fontSize[.pill]!

        let attrs = [
            NSAttributedStringKey.foregroundColor: UIColor.themeColorDarker(.tan),
            NSAttributedStringKey.font: UIFont.themeFontWithSize(originalPillFontSize *
                ScorePanel.labelTransformFactor)
        ]

        attrString.addAttributes(attrs, range: NSRange(location: 0, length: attrString.length))
        return attrString
    }

    func toggle(showing: Bool, animated: Bool = false) {
        guard isShowing != showing else { return }

        // We need to toggle this flag straight away (not during completion) so that it automatically
        // takes care of cases where the toggling is still in progress
        self.isShowing = showing

        // Ensure we begin the transition from the correct position
        frame = frame(when: !showing)

        UIView.animate(withDuration: animated ? 0.6 : 0,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
                        self.alpha = showing ? 1 : 0
                        self.frame = self.frame(when: showing)
        }, completion: nil)
    }

    private func frame(when showing: Bool) -> CGRect {
        let width = UIScreen.main.bounds.size.width
        let height = ScorePanel.height + topInset

        var y: CGFloat = 0
        var x: CGFloat = 0

        if showing {
            y = 0
            x = 0
        } else {
            y = -(height + 10)
            x = 0
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func pulse(_ aLabel: UILabel) {
        UIView.animate(withDuration: GameGridCell.animationDuration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        aLabel.transform = CGAffineTransform.identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                aLabel.transform = ScorePanel.labelTransform()
            }, completion: { _ in
                aLabel.transform = ScorePanel.labelTransform()
            })
        })
    }

    func labelAttrString() -> NSMutableAttributedString {
        let text = "ROUND TO GO"
        let attrString = NSMutableAttributedString.themeString(.pill, text)

        let gap = NSTextAttachment()
        gap.bounds = CGRect(x: 0, y: 0, width: 170, height: 0)
        let gapString = NSAttributedString(attachment: gap)

        attrString.replaceCharacters(in: NSRange(location: 5, length: 1), with: gapString)

        let attrs = [NSAttributedStringKey.font: UIFont.themeFontWithSize(Pill.detailFontSize),
                     NSAttributedStringKey.foregroundColor: UIColor.themeColor(.tan)]
        attrString.addAttributes(attrs, range: NSRange(location: 0, length: text.count))
        return attrString
    }

    private static func labelTransform() -> CGAffineTransform {
        let defaultScale = 1 / labelTransformFactor
        return CGAffineTransform.identity.scaledBy(x: defaultScale, y: defaultScale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
