//
//  GameInfo.swift
//  Numbers
//
//  Created by Elise Hein on 23/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class PopUp: UIView {

    var generalInfo: String? {
        didSet {
            generalLabel.text = generalInfo
        }
    }

    var nextRoundInfo: String? {
        didSet {
            nextRoundLabel.text = nextRoundInfo
        }
    }

    private let labelsContainer = UIView()
    private let generalLabel = UILabel()
    private let nextRoundLabel = UILabel()
    private let shadow = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)


        for label in [generalLabel, nextRoundLabel] {
            label.textAlignment = .Center
            label.font = UIFont.themeFontWithSize(14)
            label.textColor = UIColor.themeColor(.OffWhite)
        }

        labelsContainer.clipsToBounds = true

        nextRoundLabel.alpha = 0

        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: -1)

        backgroundColor = UIColor.themeColor(.OffBlack)

        addSubview(labelsContainer)
        labelsContainer.addSubview(generalLabel)
        labelsContainer.addSubview(nextRoundLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        labelsContainer.frame = bounds
        generalLabel.frame = bounds

        // Next round label initial position is below general label
        var nextRoundLabelFrame = bounds
        nextRoundLabelFrame.origin.y += bounds.size.height
        nextRoundLabel.frame =  nextRoundLabelFrame
    }

    func toggleInfo(showNextRound showNextRound: Bool) {
        UIView.animateWithDuration(0.2,
                                   delay: 0,
                                   options: .CurveEaseIn,
                                   animations: {
            if showNextRound {
                var generalLabelFrame = self.bounds
                generalLabelFrame.origin.y -= self.bounds.size.height
                self.generalLabel.frame = generalLabelFrame
                self.nextRoundLabel.frame = self.bounds
                self.generalLabel.alpha = 0
                self.nextRoundLabel.alpha = 1
            } else {
                self.generalLabel.frame = self.bounds
                var nextRoundLabelFrame = self.bounds
                nextRoundLabelFrame.origin.y += self.bounds.size.height
                self.nextRoundLabel.frame = nextRoundLabelFrame
                self.generalLabel.alpha = 1
                self.nextRoundLabel.alpha = 0
            }
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
