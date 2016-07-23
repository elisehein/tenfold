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
    private static let animationDuration = 0.2

    private let numberLabel = UILabel()
    private let endOfRoundMarker = CAShapeLayer()
    private let backgroundColorFiller = UIView()

    private let defaultBackgroundColor = UIColor.themeColor(.OffWhite)
    private let crossedOutBackgroundColor = UIColor.themeColor(.OffBlack)

    private let markerMargin: CGFloat = 3.5
    private let markerDepth: CGFloat = 3
    private let markerLength: CGFloat = 8.5

    private var deselectionInProgress = false

    var crossedOut: Bool = false

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

    override init(frame: CGRect) {
        super.init(frame: frame)

        numberLabel.textAlignment = .Center
        numberLabel.backgroundColor = UIColor.clearColor()

        contentView.clipsToBounds = true

        contentView.addSubview(backgroundColorFiller)
        contentView.addSubview(numberLabel)
        contentView.layer.addSublayer(endOfRoundMarker)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        marksEndOfRound = false
        crossedOut = false
        resetColors()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColorFiller.frame = edgeToEdgeCircleFrame()
        backgroundColorFiller.layer.cornerRadius = backgroundColorFiller.frame.size.width / 2.0
        backgroundColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        numberLabel.frame = contentView.bounds
        numberLabel.font = UIFont.themeFontWithSize(contentView.bounds.size.height * 0.45)
        drawEndOfRoundMarker()
    }

    func crossOut() {
        crossedOut = true
        resetColors(animated: true)
    }

    func indicateSelectionFailure() {
        indicateDeselection(withDelay: GameNumberCell.animationDuration + 0.15)
    }

    func indicateSelection() {
        resetColors(animated: true)
    }

    func indicateDeselection(withDelay delay: Double = 0) {
        backgroundColorFiller.backgroundColor = UIColor.themeColor(.Accent)
        contentView.backgroundColor = defaultBackgroundColor
        deselectionInProgress = true

        // Zero transforms cannot be animated; see
        // http://stackoverflow.com/a/25966733/2026098
        UIView.animateWithDuration(GameNumberCell.animationDuration,
                                   delay: delay,
                                   options: .CurveEaseIn,
                                   animations: {
            self.backgroundColorFiller.transform = CGAffineTransformMakeScale(0.001, 0.001)
        }, completion: { _ in
            self.deselectionInProgress = false
            self.backgroundColorFiller.transform = CGAffineTransformMakeScale(0, 0)
            self.contentView.backgroundColor = self.defaultBackgroundColor
        })
    }

    func resetColors(animated animated: Bool = false, delay: Double = 0) {
        backgroundColorFiller.backgroundColor = UIColor.clearColor()
        fillWith(backgroundColorForState(), animated: animated, completion: {
            if self.crossedOut {
                self.endOfRoundMarker.fillColor = self.defaultBackgroundColor.CGColor
                self.numberLabel.textColor = UIColor.clearColor()
            } else {
                self.endOfRoundMarker.fillColor = self.crossedOutBackgroundColor.CGColor
                self.numberLabel.textColor = self.crossedOutBackgroundColor
            }
        })

    }

    private func fillWith(color: UIColor,
                          animated: Bool,
                          completion: (() -> Void)? = nil) {
        if animated {
            backgroundColorFiller.backgroundColor = color
            backgroundColorFiller.transform = CGAffineTransformMakeScale(0, 0)
            UIView.animateWithDuration(GameNumberCell.animationDuration,
                                       delay: 0,
                                       options: [.CurveEaseOut, .BeginFromCurrentState],
                                       animations: {
                self.backgroundColorFiller.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: { (finished: Bool) in
                if finished && !self.deselectionInProgress {
                    self.contentView.backgroundColor = color
                    completion?()
                }
            })
        } else {
            contentView.backgroundColor = color
            completion?()
        }
    }

    private func edgeToEdgeCircleFrame() -> CGRect {
        let diagonal = ceil(contentView.bounds.size.width * sqrt(2))
        return CGRect(x: -(diagonal - contentView.bounds.size.width) / 2.0,
                      y: -(diagonal - contentView.bounds.size.height) / 2.0,
                      width: diagonal,
                      height: diagonal)
    }

    private func backgroundColorForState() -> UIColor {
        if crossedOut {
            return crossedOutBackgroundColor
        } else if selected {
            return UIColor.themeColor(.Accent)
        } else {
            return defaultBackgroundColor
        }
    }

    private func drawEndOfRoundMarker() {
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
