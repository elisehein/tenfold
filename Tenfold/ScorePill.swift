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
    case Floating
    case Static
}

class ScorePill: Pill {

    private let logo = UIImageView(image: UIImage(named: "tenfold-logo-small"))
    private let roundLabel = UILabel()
    private let numbersLabel = UILabel()
    private static let countLabelTransformFactor: CGFloat = 1.45

    var onTap: (() -> Void)? = nil
    var type: ScorePillType = .Static

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
        super.init(type: .Text)

        text = "ROUND TO GO"
        configureBackground()

        logo.contentMode = .ScaleAspectFit
        logo.frame = CGRect.zero
        logo.clipsToBounds = true

        roundLabel.transform = countLabelTransform()
        numbersLabel.transform = countLabelTransform()

        shadowLayer.layer.shadowOpacity = 0.3

        let tap = UITapGestureRecognizer(target: self, action: #selector(ScorePill.didReceiveTap))

        addGestureRecognizer(tap)
        addSubview(logo)
        addSubview(roundLabel)
        addSubview(numbersLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard isShowing else { return }

        let logoSize: CGFloat = 18
        logo.frame = CGRect(x: (bounds.size.width - logoSize) / 2,
                            y: (bounds.size.height - logoSize) / 2,
                            width: logoSize,
                            height: logoSize)

        // First make a narrower box in the middle of the pill
        var countFrame = bounds
        countFrame.size.width = 150
        countFrame.origin.x = (bounds.size.width - countFrame.size.width) / 2

        // Then cut it in half & use one half for each count
        countFrame.size.width /= 2
        countFrame.size.width -= logoSize / 2
        roundLabel.frame = countFrame
        countFrame.origin.x += countFrame.size.width + logoSize
        numbersLabel.frame = countFrame
    }

    func didReceiveTap() {
        onTap?()
    }

    override func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let attrString = super.constructAttributedString(withText: text)

        let gap = NSTextAttachment()
        gap.bounds = CGRect(x: 0, y: 0, width: 140, height: 0)
        let gapString = NSAttributedString(attachment: gap)

        attrString.replaceCharactersInRange(NSRange(location: 5, length: 1), withAttributedString: gapString)

        let attrs = [NSFontAttributeName: UIFont.themeFontWithSize(Pill.detailFontSize),
                     NSForegroundColorAttributeName: UIColor(hex: "#94855D")]
        attrString.addAttributes(attrs, range: NSRange(location: 0, length: text.characters.count))
        return attrString
    }

    override func textLabelWidth() -> CGFloat {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 300 : 260
    }

    private func configureBackground() {
        if type == .Static {
            label.backgroundColor = UIColor.clearColor()
        } else {
            label.backgroundColor = UIColor.themeColor(.OffWhite).colorWithAlphaComponent(0.92)
        }
        shadowLayer.hidden = type == .Static
    }

    private func constructAttributedStringForCount(count: Int) -> NSMutableAttributedString {
        let attrString = super.constructAttributedString(withText: "\(count)")

        // Start from a scaled down font size so the pulse doesn't look blurry
        let originalPillFontSize = NSAttributedString.fontSize(forTextStyle: .Pill)

        let attrs = [
            NSForegroundColorAttributeName: UIColor(hex: "#5A491B"),
            NSFontAttributeName: UIFont.themeFontWithSize(originalPillFontSize *
                                                          ScorePill.countLabelTransformFactor)
        ]

        attrString.addAttributes(attrs, range: NSRange(location: 0, length: attrString.length))
        return attrString
    }

    private func pulse(aLabel: UILabel) {
        UIView.animateWithDuration(GameGridCell.animationDuration,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
            aLabel.transform = CGAffineTransformIdentity
        }, completion: { _ in
            UIView.animateWithDuration(0.15, animations: {
                aLabel.transform = self.countLabelTransform()
            }, completion: { _ in
                aLabel.transform = self.countLabelTransform()
            })
        })
    }

    private func countLabelTransform() -> CGAffineTransform {
        let defaultScale = 1 / ScorePill.countLabelTransformFactor
        return CGAffineTransformScale(CGAffineTransformIdentity, defaultScale, defaultScale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
