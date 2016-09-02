//
//  GameGridCell.swift
//  Tenfold
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GameGridCell: UICollectionViewCell {
    static let fontSizeFactor: CGFloat = 0.45
    private static let animationDuration = 0.2

    private let numberLabel = UILabel()
    private let endOfRoundMarker = CAShapeLayer()

    // We want two separate color fillers to animate in case the selection happens quite quickly;
    // for example, when the selection animation hasn't finished, but the crossing out animation
    // must already begin
    private let selectionColorFiller = UIView()
    private let crossedOutColorFiller = UIView()

    var useClearBackground = false
    var defaultBackgroundColor = UIColor.themeColor(.OffWhite)
    private let crossedOutBackgroundColor = UIColor.themeColor(.OffBlack)

    private let markerMargin: CGFloat = 3.5
    private let markerDepth: CGFloat = 3
    private let markerLength: CGFloat = 8.5

    private var deselectionInProgress = false

    var crossedOut: Bool = false
    var selectedForPairing: Bool = false

    var value: Int? {
        didSet {
            numberLabel.text = value != nil ? "\(value!)" : nil
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

        contentView.addSubview(selectionColorFiller)
        contentView.addSubview(crossedOutColorFiller)
        contentView.addSubview(numberLabel)
        contentView.layer.addSublayer(endOfRoundMarker)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectionColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        crossedOutColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        marksEndOfRound = false
        crossedOut = false
        selectedForPairing = false
        value = nil
        resetColors()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for colorFiller in [selectionColorFiller, crossedOutColorFiller] {
            colorFiller.frame = edgeToEdgeCircleFrame()
            colorFiller.layer.cornerRadius = colorFiller.frame.size.width / 2.0
            colorFiller.transform = CGAffineTransformMakeScale(0, 0)
        }

        numberLabel.frame = contentView.bounds

        let fontSize = contentView.bounds.size.height * GameGridCell.fontSizeFactor
        numberLabel.font = UIFont.themeFontWithSize(fontSize)

        drawEndOfRoundMarker()
    }

    func flash() {
        guard !selectedForPairing && !crossedOut else { return }

        UIView.animateWithDuration(0.3,
                                   delay: 0.3,
                                   options: .CurveEaseOut,
                                   animations: {
            self.contentView.backgroundColor = UIColor.themeColorDarker(.OffWhiteShaded)
        }, completion: { _ in
            UIView.animateWithDuration(0.3,
                                       delay: 0,
                                       options: .CurveEaseIn,
                                       animations: {
                guard !self.selectedForPairing && !self.crossedOut else { return }
                self.contentView.backgroundColor = self.defaultBackgroundColor
            }, completion: nil)
        })
    }

    func crossOut() {
        crossedOut = true
        crossedOutColorFiller.backgroundColor = crossedOutBackgroundColor
        crossedOutColorFiller.transform = CGAffineTransformMakeScale(0, 0)

        UIView.animateWithDuration(GameGridCell.animationDuration,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
            self.crossedOutColorFiller.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: { _ in
            self.resetColors()
            self.crossedOutColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        })
    }

    func unCrossOut() {
        crossedOut = false
        self.resetColors()
    }

    func indicateSelectionFailure() {
        indicateDeselection(withDelay: 0.2)
    }

    func indicateSelection() {
        selectedForPairing = true
        selectionColorFiller.backgroundColor = UIColor.themeColor(.Accent)
        selectionColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(GameGridCell.animationDuration,
                                   delay: 0,
                                   options: [.CurveEaseOut, .BeginFromCurrentState],
                                   animations: {
            self.selectionColorFiller.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: { (finished: Bool) in
            if finished && !self.deselectionInProgress {
                self.contentView.backgroundColor = UIColor.themeColor(.Accent)
                self.selectionColorFiller.transform = CGAffineTransformMakeScale(0, 0)
            }
        })
    }

    func indicateDeselection(withDelay delay: Double = 0) {
        selectedForPairing = false
        selectionColorFiller.backgroundColor = UIColor.themeColor(.Accent)
        selectionColorFiller.transform = CGAffineTransformMakeScale(1, 1)
        contentView.backgroundColor = cellBackgroundColor()
        deselectionInProgress = true

        // Zero transforms cannot be animated; see
        // http://stackoverflow.com/a/25966733/2026098
        UIView.animateWithDuration(GameGridCell.animationDuration,
                                   delay: delay,
                                   options: [.CurveEaseIn, .BeginFromCurrentState],
                                   animations: {
            self.selectionColorFiller.transform = CGAffineTransformMakeScale(0.001, 0.001)
        }, completion: { _ in
            self.deselectionInProgress = false
            self.selectionColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        })
    }

    // We need to wait for whichever cell's selection triggered the removel to finish animating
    func prepareForRemoval(completion completion: (() -> Void)) {
        let delayTime = Int64((GameGridCell.animationDuration + 0.1) * Double(NSEC_PER_SEC))
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delayTime)
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.15,
                                       delay: 0,
                                       options: .CurveEaseOut,
                                       animations: {
                self.contentView.backgroundColor = self.cellBackgroundColor()
            }, completion: { _ in
                completion()
            })
        }
    }

    func resetColors() {
        selectionColorFiller.backgroundColor = UIColor.clearColor()
        crossedOutColorFiller.backgroundColor = UIColor.clearColor()

        if crossedOut {
            endOfRoundMarker.fillColor = defaultBackgroundColor.CGColor
            numberLabel.textColor = UIColor.clearColor()
            contentView.backgroundColor = crossedOutBackgroundColor
        } else {
            endOfRoundMarker.fillColor = crossedOutBackgroundColor.CGColor
            numberLabel.textColor = crossedOutBackgroundColor
            contentView.backgroundColor = selectedForPairing ?
                                          UIColor.themeColor(.Accent) :
                                          cellBackgroundColor()
        }
    }

    private func cellBackgroundColor() -> UIColor {
        return useClearBackground ? UIColor.clearColor() : defaultBackgroundColor
    }

    private func edgeToEdgeCircleFrame() -> CGRect {
        let diagonal = ceil(contentView.bounds.size.width * sqrt(2))
        return CGRect(x: -(diagonal - contentView.bounds.size.width) / 2.0,
                      y: -(diagonal - contentView.bounds.size.height) / 2.0,
                      width: diagonal,
                      height: diagonal)
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
