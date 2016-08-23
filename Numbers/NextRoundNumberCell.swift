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

    private static let animationDuration: Double = 0.6
    private static let animationDamping: CGFloat = 0.3
    private static let animationVelocity: CGFloat = 0.6
    private static let fontSizeFactor = GameNumberCell.fontSizeFactor

    private let numberLabel = UILabel()

    var shouldBlimp: Bool = false {
        didSet {
            blimp()
        }
    }

    var value: Int? = nil {
        didSet {
            numberLabel.text = value != nil ? "\(value!)" : nil
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
        numberLabel.hidden = true

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
        isSpacer = true
    }

    private func blimp() {
        guard value != nil else { return }

        if shouldBlimp {
            numberLabel.transform = NextRoundNumberCell.shrink(numberLabel)
            numberLabel.hidden = false

            animateSpring({
                self.numberLabel.transform = CGAffineTransformIdentity
            })
        } else {
            animate({
                self.numberLabel.transform = NextRoundNumberCell.shrink(self.numberLabel)
            }, completion: { _ in
                self.numberLabel.hidden = true
            })
        }
    }

    private func animateSpring(animations: () -> Void) {
        UIView.animateWithDuration(NextRoundNumberCell.animationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: NextRoundNumberCell.animationDamping,
                                   initialSpringVelocity: NextRoundNumberCell.animationVelocity,
                                   options: .CurveEaseInOut,
                                   animations: {
            animations()
        }, completion: nil)
    }

    private func animate(animations: () -> Void, completion: ((finished: Bool) -> Void)? = nil) {
        UIView.animateWithDuration(NextRoundNumberCell.animationDuration,
                                   delay: 0,
                                   options: .CurveEaseInOut,
                                   animations: {
            animations()
        }, completion: completion)
    }

    class func shrink(view: UIView) -> CGAffineTransform {
        return CGAffineTransformScale(view.transform, 0.1, 0.1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
