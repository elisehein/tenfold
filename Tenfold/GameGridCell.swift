//
//  GameGridCell.swift
//  Tenfold
//
//  Created by Elise Hein on 13/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum GameGridCellState {
    case Available
    case PendingPairing
    case CrossedOut
}

class GameGridCell: UICollectionViewCell {
    static let fontSizeFactor: CGFloat = 0.45
    private static let animationDuration = 0.2

    private let numberLabel = UILabel()
    private let endOfRoundMarker = EndOfRoundMarker()

    // We want two separate color fillers to animate in case the selection happens
    // quite quickly; for example, when the selection animation hasn't finished, but
    // the crossing out animation must already begin
    private let bottomColorFiller = UIView()
    private let topColorFiller = UIView()

    var useClearBackground = false
    var lightColor = UIColor.themeColor(.OffWhiteShaded)
    let darkColor = UIColor.themeColor(.OffBlack)
    let accentColor = UIColor.themeColor(.Accent)

    private var unfillingInProgress = false

    var state: GameGridCellState = .Available

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

    var aboutToBeRevealed: Bool = false {
        didSet {
            if aboutToBeRevealed {
                contentView.alpha = 0
            } else if oldValue && !aboutToBeRevealed {
                UIView.animateWithDuration(0.15, animations: {
                    self.contentView.alpha = 1
                })
            } else {
                contentView.alpha = 1
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        numberLabel.textAlignment = .Center
        numberLabel.backgroundColor = UIColor.clearColor()

        contentView.clipsToBounds = true

        contentView.addSubview(bottomColorFiller)
        contentView.addSubview(topColorFiller)
        contentView.addSubview(numberLabel)
        contentView.layer.addSublayer(endOfRoundMarker)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bottomColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        topColorFiller.transform = CGAffineTransformMakeScale(0, 0)
        marksEndOfRound = false
        state == .Available
        value = nil
        aboutToBeRevealed = false
        resetColors()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for colorFiller in [bottomColorFiller, topColorFiller] {
            colorFiller.frame = edgeToEdgeCircleFrame()
            colorFiller.layer.cornerRadius = colorFiller.frame.size.width / 2.0
            colorFiller.transform = CGAffineTransformMakeScale(0, 0)
        }

        numberLabel.frame = contentView.bounds

        let fontSize = contentView.bounds.size.height * GameGridCell.fontSizeFactor
        numberLabel.font = UIFont.themeFontWithSize(fontSize)

        endOfRoundMarker.frame = contentView.bounds
    }

    func reveal() {
        UIView.animateWithDuration(0.15, animations: {
            self.contentView.alpha = 1
        })
    }

    func flash(withColor color: UIColor) {
        guard state == .Available else { return }

        UIView.animateWithDuration(0.3,
                                   delay: 0.3,
                                   options: [.CurveEaseOut, .AllowUserInteraction],
                                   animations: {
            self.contentView.backgroundColor = color
        }, completion: { _ in
            UIView.animateWithDuration(0.3,
                                       delay: 0,
                                       options: [.CurveEaseIn, .AllowUserInteraction],
                                       animations: {
                guard self.state == .Available else { return }
                self.contentView.backgroundColor = self.cellBackgroundColor()
            }, completion: nil)
        })
    }

    func crossOut() {
        state = .CrossedOut

        fill(usingColor: darkColor, filler: topColorFiller, completion: {
            self.resetColors()
        })
    }

    func unCrossOut(withDelay delay: Double = 0, animated: Bool = false) {
        state = .Available

        if animated {
            numberLabel.textColor = darkColor
            fill(usingColor: lightColor, filler: bottomColorFiller, delay: delay, completion: {
                self.resetColors()
            })
        } else {
            self.resetColors()
        }
    }

    func indicateSelection() {
        state = .PendingPairing
        fill(usingColor: accentColor, filler: bottomColorFiller)
    }

    func indicateSelectionFailure() {
        indicateDeselection(withDelay: 0.2)
    }

    func indicateDeselection(withDelay delay: Double = 0) {
        state = .Available
        unfill(usingColor: UIColor.themeColor(.Accent), filler: bottomColorFiller, withDelay: delay)
    }

    private func fill(usingColor color: UIColor,
                      filler: UIView,
                      delay: Double = 0,
                      completion: (() -> Void)? = nil) {
        filler.backgroundColor = color
        filler.transform = CGAffineTransformMakeScale(0, 0)

        UIView.animateWithDuration(GameGridCell.animationDuration,
                                   delay: delay,
                                   options: [.CurveEaseOut, .BeginFromCurrentState],
                                   animations: {
            filler.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: { (finished: Bool) in
            completion?()

            if finished && !self.unfillingInProgress {
                self.contentView.backgroundColor = color
                filler.transform = CGAffineTransformMakeScale(0, 0)
            }
        })
    }


    private func unfill(usingColor color: UIColor,
                        filler: UIView,
                        withDelay delay: Double,
                        completion: (() -> Void)? = nil) {
        filler.backgroundColor = color
        filler.transform = CGAffineTransformMakeScale(1, 1)
        contentView.backgroundColor = cellBackgroundColor()
        unfillingInProgress = true

        // Zero transforms cannot be animated; see
        // http://stackoverflow.com/a/25966733/2026098
        UIView.animateWithDuration(GameGridCell.animationDuration,
                                   delay: delay,
                                   options: [.CurveEaseIn, .BeginFromCurrentState],
                                   animations: {
            filler.transform = CGAffineTransformMakeScale(0.001, 0.001)
        }, completion: { _ in
            self.unfillingInProgress = false
            filler.transform = CGAffineTransformMakeScale(0, 0)
            completion?()
        })
    }

    // We need to wait for whichever cell's selection triggered the removal to finish animating
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
        bottomColorFiller.backgroundColor = UIColor.clearColor()
        topColorFiller.backgroundColor = UIColor.clearColor()

        switch state {
        case .CrossedOut:
            endOfRoundMarker.fillColor = lightColor.CGColor
            numberLabel.textColor = UIColor.clearColor()
            contentView.backgroundColor = darkColor
        case .PendingPairing:
            endOfRoundMarker.fillColor = darkColor.CGColor
            numberLabel.textColor = darkColor
            contentView.backgroundColor = accentColor
        default:
            endOfRoundMarker.fillColor = darkColor.CGColor
            numberLabel.textColor = darkColor
            contentView.backgroundColor = cellBackgroundColor()
        }
    }

    private func cellBackgroundColor() -> UIColor {
        return useClearBackground ? UIColor.clearColor() : lightColor
    }

    private func edgeToEdgeCircleFrame() -> CGRect {
        let diagonal = ceil(contentView.bounds.size.width * sqrt(2))
        return CGRect(x: -(diagonal - contentView.bounds.size.width) / 2.0,
                      y: -(diagonal - contentView.bounds.size.height) / 2.0,
                      width: diagonal,
                      height: diagonal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
