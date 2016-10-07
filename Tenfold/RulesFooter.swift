//
//  RulesFooter.swift
//  Tenfold
//
//  Created by Elise Hein on 27/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit


class RulesFooter: UICollectionReusableView {

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let tip = "Swipe left any time to see these instructions."
        label.numberOfLines = 0
        label.attributedText = NSMutableAttributedString.themeString(.Tip, tip)

        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var labelFrame = bounds
        labelFrame.size.height = 80
        labelFrame.origin.y += bounds.size.height - labelFrame.size.height
        label.frame = labelFrame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
