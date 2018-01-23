//
//  ScorePill.swift
//  Tenfold
//
//  Created by Elise Hein on 03/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum ScorePillType {
    case floating
    case `static`
}

class ScorePill: Pill {

    private let logo = UIImageView(image: UIImage(named: "tenfold-logo-small"))
    private let roundLabel = UILabel()
    private let numbersLabel = UILabel()
    private static let countLabelTransformFactor: CGFloat = 1.35

    var onTap: (() -> Void)?
    var type: ScorePillType = .static

    var numbers: Int = 0 {
        didSet {
            // Only pulse on game moves (remove pair & add round), not on undo moves
            if numbers < oldValue || numbers == oldValue * 2 {
                pulse(numbersLabel)
            }

            numbersLabel.attributedText = constructAttributedStringForCount(numbers)
        }
    }

    var round: Int = 0 {
        didSet {
            if round > oldValue {
                pulse(roundLabel)
            }

            roundLabel.attributedText = constructAttributedStringForCount(round)
        }
    }

    init(type: ScorePillType) {
        self.type = type
        super.init(type: .text)

        anchorEdge = .top

        text = "ROUND TO GO"
        configureBackground()

        logo.contentMode = .scaleAspectFit
        logo.frame = CGRect.zero
        logo.clipsToBounds = true

        roundLabel.transform = countLabelTransform()
        numbersLabel.transform = countLabelTransform()

        shadowLayer.layer.shadowOpacity = 0.15

        let tap = UITapGestureRecognizer(target: self, action: #selector(ScorePill.didReceiveTap))

        addGestureRecognizer(tap)
        label.addSubview(logo)
        label.addSubview(roundLabel)
        label.addSubview(numbersLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard isShowing else { return }

        if type == .floating {
            var labelFrame = label.frame
            labelFrame.origin.y -= Pill.margin
            labelFrame.size.height += 10
            label.frame = labelFrame

            label.layer.cornerRadius = 0
            shadowLayer.layer.shadowPath = UIBezierPath(rect: label.frame).cgPath
        }

        let logoSize: CGFloat = 18
        logo.frame = CGRect(x: (label.frame.size.width - logoSize) / 2,
                            y: (label.frame.size.height - logoSize) / 2,
                            width: logoSize,
                            height: logoSize)

        // First make a narrower box in the middle of the pill
        var countFrame = label.bounds
        countFrame.size.width = 170
        countFrame.origin.x = (label.bounds.size.width - countFrame.size.width) / 2

        // Then cut it in half & use one half for each count
        countFrame.size.width /= 2
        countFrame.size.width -= logoSize / 2
        roundLabel.frame = countFrame
        countFrame.origin.x += countFrame.size.width + logoSize
        numbersLabel.frame = countFrame
    }

    @objc func didReceiveTap() {
        onTap?()
    }

    override func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let attrString = super.constructAttributedString(withText: text)

        let gap = NSTextAttachment()
        gap.bounds = CGRect(x: 0, y: 0, width: 170, height: 0)
        let gapString = NSAttributedString(attachment: gap)

        attrString.replaceCharacters(in: NSRange(location: 5, length: 1), with: gapString)

        let attrs = [NSAttributedStringKey.font: UIFont.themeFontWithSize(Pill.detailFontSize),
                     NSAttributedStringKey.foregroundColor: UIColor.themeColor(.tan)]
        attrString.addAttributes(attrs, range: NSRange(location: 0, length: text.count))
        return attrString
    }

    override func textLabelWidth() -> CGFloat {
        guard superview != nil else { return 0 }
        return superview!.bounds.size.width
    }

    private func configureBackground() {
        if type == .static {
            label.backgroundColor = UIColor.clear
        } else {
            // This colour is midway between OffWhite and OffWhiteShaded (for less contrast)
            label.backgroundColor = UIColor(hex: "#F4EBD8").withAlphaComponent(0.95)
        }
        shadowLayer.isHidden = type == .static
    }

    private func constructAttributedStringForCount(_ count: Int) -> NSMutableAttributedString {
        let attrString = super.constructAttributedString(withText: "\(count)")

        // Start from a scaled down font size so the pulse doesn't look blurry
        let originalPillFontSize = TextStyleProperties.fontSize[.pill]!

        let attrs = [
            NSAttributedStringKey.foregroundColor: UIColor.themeColorDarker(.tan),
            NSAttributedStringKey.font: UIFont.themeFontWithSize(originalPillFontSize *
                                                          ScorePill.countLabelTransformFactor)
        ]

        attrString.addAttributes(attrs, range: NSRange(location: 0, length: attrString.length))
        return attrString
    }

    private func pulse(_ aLabel: UILabel) {
        UIView.animate(withDuration: GameGridCell.animationDuration,
                                   delay: 0,
                                   options: .curveEaseOut,
                                   animations: {
            aLabel.transform = CGAffineTransform.identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                aLabel.transform = self.countLabelTransform()
            }, completion: { _ in
                aLabel.transform = self.countLabelTransform()
            })
        })
    }

    private func countLabelTransform() -> CGAffineTransform {
        let defaultScale = 1 / ScorePill.countLabelTransformFactor
        return CGAffineTransform.identity.scaledBy(x: defaultScale, y: defaultScale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
