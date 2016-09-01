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
        super.init(frame: CGRect.zero)

        label.text = "Swipe right any time for instructions."
        label.textColor = UIColor.themeColor(.OffBlack)
        label.font = UIFont.themeFontWithSize(13, weight: .Italic)
        label.textAlignment = .Center
        label.numberOfLines = 0

        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
