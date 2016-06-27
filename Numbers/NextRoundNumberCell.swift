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

    private static let dotRadius: CGFloat = 1
    private static let animationDuration: Double = 0.6
    private static let animationDamping: CGFloat = 0.3
    private static let animationVelocity: CGFloat = 0.6
    private static let fontSizeFactor: CGFloat = 0.3

    private let dot = UIView()
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

    override init (frame: CGRect) {
        super.init(frame: frame)

        dot.backgroundColor = UIColor.themeColor(.OffWhiteDark)

        let radius = NextRoundNumberCell.dotRadius
        dot.layer.cornerRadius = radius
        dot.frame = CGRect(x: (frame.size.width / 2.0) - radius,
                           y: (frame.size.height / 2.0) - radius,
                           width: 2 * radius,
                           height: 2 * radius)

        numberLabel.textAlignment = .Center
        numberLabel.textColor = UIColor.themeColor(.OffWhiteDark)
        numberLabel.frame = contentView.frame
        numberLabel.hidden = true

        // Set the font size to what I want it to be when it's at its largest,
        // and scale it down later, so the scale up transformation won't look blurry
        let fontSize = NextRoundNumberCell.fontSizeFactor * contentView.bounds.size.height
        numberLabel.font = UIFont.themeFontWithSize(fontSize, weight: .Bold)

        contentView.addSubview(numberLabel)
        contentView.addSubview(dot)
    }

    override func layoutSubviews () {
        super.layoutSubviews()
        numberLabel.frame = contentView.bounds
    }

    private func blimp () {
        guard value != nil else { return }

        if shouldBlimp {
            numberLabel.transform = NextRoundNumberCell.shrink(numberLabel)
            numberLabel.hidden = false

            animateSpring({
                self.dot.alpha = 0
                self.numberLabel.transform = CGAffineTransformIdentity
            })
        } else {
            animate({
                self.dot.alpha = 1
                self.numberLabel.transform = NextRoundNumberCell.shrink(self.numberLabel)
            }, completion: { _ in
                self.numberLabel.hidden = true
            })
        }
    }

    private func animateSpring (animations: () -> Void) {
        UIView.animateWithDuration(NextRoundNumberCell.animationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: NextRoundNumberCell.animationDamping,
                                   initialSpringVelocity: NextRoundNumberCell.animationVelocity,
                                   options: .CurveEaseInOut,
                                   animations: {
            animations()
        }, completion: nil)
    }

    private func animate (animations: () -> Void, completion: ((finished: Bool) -> Void)? = nil) {
        UIView.animateWithDuration(NextRoundNumberCell.animationDuration,
                                   delay: 0,
                                   options: .CurveEaseInOut,
                                   animations: {
            animations()
        }, completion: completion)
    }

    class func shrink (view: UIView) -> CGAffineTransform {
        return CGAffineTransformScale(view.transform, 0.1, 0.1)
    }

    required init? (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
