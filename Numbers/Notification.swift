//
//  GameInfo.swift
//  Numbers
//
//  Created by Elise Hein on 23/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Notification: UIView {

    private let label = UILabel()
    private let shadowLayer = UIView()

    var text: String = "" {
        didSet {
            label.text = text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.textAlignment = .Center
        label.font = UIFont.themeFontWithSize(15)
        label.textColor = UIColor.themeColor(.OffWhite)
        label.backgroundColor = UIColor.themeColor(.OffBlack)
        label.layer.masksToBounds = true

        shadowLayer.backgroundColor = UIColor.clearColor()
        shadowLayer.layer.shadowColor = UIColor.blackColor().CGColor
        shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer.layer.shadowOpacity = 0.2
        shadowLayer.layer.shadowRadius = 2
        shadowLayer.layer.masksToBounds = true
        shadowLayer.clipsToBounds = false

        addSubview(shadowLayer)
        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var labelFrame = bounds
        labelFrame.size.width = label.intrinsicContentSize().width + 30
        labelFrame.origin.x += (bounds.size.width - labelFrame.size.width) / 2
        label.frame = labelFrame
        label.layer.cornerRadius = label.frame.size.height / 2

        shadowLayer.frame = bounds
        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: labelFrame,
                                                    cornerRadius: label.layer.cornerRadius).CGPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
