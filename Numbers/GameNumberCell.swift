//
//  GameNumberCell.swift
//  Numbers
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameNumberCell: UICollectionViewCell {
    var shouldDeselectWithFailure: Bool = false

    private let numberLabel = UILabel()
    private let endOfRoundMarker = CAShapeLayer()

    private let defaultBackgroundColor = UIColor.themeColor(.OffWhite)
    private let crossedOutBackgroundColor = UIColor.themeColor(.OffBlack)

    private let markerMargin: CGFloat = 2
    private let markerDepth: CGFloat = 3.2
    private let markerLength: CGFloat = 8.5

    var animationDuration: NSTimeInterval = 0

    override var selected: Bool {
        didSet {
            if selected {
                UIView.animateWithDuration(animationDuration, animations: {
                    self.contentView.backgroundColor = UIColor.themeColorHighlighted(.OffWhite)
                })
            } else if shouldDeselectWithFailure {
                indicateFailure()
                shouldDeselectWithFailure = false
            } else {
                resetColors()
            }
        }
    }

    var value: Int? {
        didSet {
            if let value = value {
                numberLabel.text = String(value)
            }
        }
    }

    var marksEndOfRound: Bool = false {
        didSet {
            endOfRoundMarker.hidden = !marksEndOfRound
        }
    }

    var isCrossedOut: Bool = false {
        didSet {
            resetColors()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        numberLabel.textAlignment = .Center
        numberLabel.backgroundColor = UIColor.clearColor()

        contentView.addSubview(numberLabel)
        contentView.layer.addSublayer(endOfRoundMarker)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = defaultBackgroundColor
        animationDuration = 0
        marksEndOfRound = false
        isCrossedOut = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.frame = contentView.bounds
        numberLabel.font = UIFont.themeFontWithSize(contentView.bounds.size.height * 0.45)
        drawEndOfRoundMarker()
    }

    private func resetColors() {
        UIView.animateWithDuration(animationDuration, animations: {
            if self.isCrossedOut {
                self.endOfRoundMarker.fillColor = self.defaultBackgroundColor.CGColor
                self.contentView.backgroundColor = self.crossedOutBackgroundColor
                self.numberLabel.textColor = UIColor.clearColor()
            } else {
                self.endOfRoundMarker.fillColor = self.crossedOutBackgroundColor.CGColor
                self.contentView.backgroundColor = self.defaultBackgroundColor
                self.numberLabel.textColor = self.crossedOutBackgroundColor
            }
        })
    }

    private func indicateFailure () {
        UIView.animateWithDuration(0.16, delay: 0, options: .Repeat, animations: {
            UIView.setAnimationRepeatCount(2)
            self.contentView.backgroundColor = UIColor.themeColor(.OffBlack)
            }, completion: { (value: Bool) in
                self.contentView.backgroundColor = self.defaultBackgroundColor
        })
    }

    private func drawEndOfRoundMarker () {
        let markerPath = CGPathCreateMutable()
        let totalWidth: CGFloat = contentView.bounds.size.width
        let totalHeight: CGFloat = contentView.bounds.size.height

        CGPathMoveToPoint(markerPath, nil,
                          totalWidth - markerMargin,
                          totalHeight - markerMargin)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin,
                             totalHeight - markerMargin - markerLength)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin - markerDepth,
                             totalHeight - markerMargin - markerLength)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin - markerDepth,
                             totalHeight - markerMargin - markerDepth)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin - markerLength,
                             totalHeight - markerMargin - markerDepth)
        CGPathAddLineToPoint(markerPath,
                             nil,
                             totalWidth - markerMargin - markerLength,
                             totalHeight - markerMargin)
        CGPathCloseSubpath(markerPath)
        endOfRoundMarker.path = markerPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
