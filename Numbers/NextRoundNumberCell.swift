//
//  NextRoundNumberCell.swift
//  Numbers
//
//  Created by Elise Hein on 26/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class NextRoundNumberCell: UICollectionViewCell {
    private static let fontSizeFactor: CGFloat = 0.4

    private let numberLabel = UILabel()

    // Ensure valueIsHidden is set before value
    var valueIsHidden: Bool = true

    var value: Int? = nil {
        didSet {
            numberLabel.text = value != nil ? "\(value!)" : nil
            numberLabel.alpha = valueIsHidden ? 0 : 1
        }
    }

    // Cells which are below the final numbers of the actual game act only as spacers
    // for ease of positioning; they should not have a background colour, because
    // it would be visible from underneath the actual game.
    var isSpacer: Bool = true {
        didSet {
            contentView.backgroundColor = isSpacer ?
                                          UIColor.clearColor() :
                                          UIColor.themeColor(.NeutralAccent)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        numberLabel.textAlignment = .Center
        numberLabel.textColor = UIColor.themeColorDarker(.NeutralAccent)
        numberLabel.frame = contentView.frame

        // Set the font size to what I want it to be when it's at its largest,
        // and scale it down later, so the scale up transformation won't look blurry
        let fontSize = NextRoundNumberCell.fontSizeFactor * contentView.bounds.size.height
        numberLabel.font = UIFont.themeFontWithSize(fontSize)

        contentView.addSubview(numberLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = UIColor.clearColor()
        valueIsHidden = true
        value = nil
        isSpacer = true
    }

    func revealValue() {
        guard value != nil else { return }
        guard valueIsHidden == true else { return }

        valueIsHidden = false
        numberLabel.alpha = 1
    }

    func hideValue() {
        guard value != nil else { return }
        guard valueIsHidden == false else { return }

        valueIsHidden = true

        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   options: .CurveEaseInOut,
                                   animations: {
            self.numberLabel.alpha = CGFloat(0)
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
