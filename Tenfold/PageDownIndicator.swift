//
//  PageDownIndicator.swift
//  Tenfold
//
//  Created by Elise Hein on 01/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class PageDownIndicator: UICollectionReusableView {

    let iconView = UIImageView(image: UIImage(named: "chevron-down"))

    override init(frame: CGRect) {
        super.init(frame: frame)

        iconView.contentMode = .center
        addSubview(iconView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var iconViewFrame = bounds
        iconViewFrame.size.height = 70
        iconViewFrame.origin.y += bounds.size.height - iconViewFrame.size.height
        iconView.frame = iconViewFrame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
