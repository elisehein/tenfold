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

    var type: ScorePillType = .Static {
        didSet {
            guard type != oldValue else { return }
            guard superview != nil else { return }

            if type == .Floating {
                isShowing = false
                configureBackground()
                toggle(inFrame: superview!.frame, showing: true, animated: true)
            } else {
                toggle(inFrame: superview!.frame, showing: false, animated: true, completion: {
                    self.configureBackground()
                    self.toggle(inFrame: self.superview!.frame, showing: true, animated: true)
                })
            }
        }
    }

    var numbers: Int = 0 {
        didSet {
            numbersLabel.attributedText = constructAttributedStringForCount(numbers)
        }
    }

    var round: Int = 0 {
        didSet {
            roundLabel.attributedText = constructAttributedStringForCount(round)
        }
    }

    init() {
        super.init(type: .Text)

        text = "ROUND NUMS"
        configureBackground()

        logo.contentMode = .ScaleAspectFit
        logo.frame = CGRect.zero
        logo.clipsToBounds = true

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

    override func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let attrString = super.constructAttributedString(withText: text)

        let gap = NSTextAttachment()
        gap.bounds = CGRect(x: 0, y: 0, width: 140, height: 0)
        let gapString = NSAttributedString(attachment: gap)

        attrString.replaceCharactersInRange(NSRange(location: 5, length: 1), withAttributedString: gapString)

        let attrs = [NSFontAttributeName: UIFont.themeFontWithSize(10),
                     NSForegroundColorAttributeName: UIColor(hex: "#94855D")]
        attrString.addAttributes(attrs, range: NSRange(location: 0, length: text.characters.count))
        return attrString
    }

    override func textLabelWidth() -> CGFloat {
        return 260
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

        let attrs = [NSForegroundColorAttributeName: UIColor(hex: "#5A491B")]
        attrString.addAttributes(attrs, range: NSRange(location: 0, length: attrString.length))
        return attrString

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
