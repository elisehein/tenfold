//
//  NoMorePairsPill.swift
//  Tenfold
//
//  Created by Elise Hein on 06/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class NoMorePairsPill: Pill {

    init() {
        super.init(type: .Icon)
        iconName = "flag"
        iconView.backgroundColor = UIColor.themeColor(.SecondaryAccent).colorWithAlphaComponent(0.95)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
