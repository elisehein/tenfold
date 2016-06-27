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

    private static let dotRadius: CGFloat = 2

    private let dot = UIView()
    private let numberLabel = UILabel()

    private var didBlimp = false

    var shouldBlimp: Bool = false {
        didSet {
            if shouldBlimp {
                blimp()
            }
        }
    }

    var value: Int? = nil {
        didSet {
            numberLabel.text = value != nil ? "\(value!)" : ""
        }
    }

    override init (frame: CGRect) {
        super.init(frame: frame)

//        dot.backgroundColor = UIColor.themeColor(.OffBlack)
//
//        let radius = NextRoundNumberCell.dotRadius
//        dot.layer.cornerRadius = radius
//        dot.frame = CGRect(x: (frame.size.width / 2.0) - radius,
//                           y: (frame.size.height / 2.0) - radius,
//                           width: 2 * radius,
//                           height: 2 * radius)

        numberLabel.textAlignment = .Center
        numberLabel.font = UIFont.themeFontWithSize(frame.size.height * 0.25) // TODO
        numberLabel.textColor = UIColor.themeColor(.OffBlack)
        numberLabel.center = center
        numberLabel.clipsToBounds = true

        contentView.addSubview(dot)
        contentView.addSubview(numberLabel)
    }

    override func layoutSubviews () {
        super.layoutSubviews()
        numberLabel.frame = contentView.bounds
    }

    func blimp () {
        if !didBlimp {
            animate({
//                self.numberLabel.frame = self.contentView.bounds
            })

            didBlimp = true
        }
    }

    func animate (fn: () -> Void) {
        UIView.animateWithDuration(1,
                                   delay: 0,
                                   usingSpringWithDamping: 0.35,
                                   initialSpringVelocity: 0.6,
                                   options: .CurveEaseInOut,
                                   animations: {
            fn()
        }, completion: nil)
    }

    required init? (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
