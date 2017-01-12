//
//  GameplayMessagePill.swift
//  Tenfold
//
//  Created by Elise Hein on 03/10/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameplayMessagePill: Pill {
    var newlyUnrepresentedNumber: Int? {
        didSet {
            if let number = newlyUnrepresentedNumber {
                let phrases = CopyService.phrasebook(.lastNumberInstance).arrayValue
                let phrase = phrases.randomElement().string
                text = String(format: phrase!, number)
            }
        }
    }

    init() {
        super.init(type: .text)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
