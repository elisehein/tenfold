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
    case available
    case pendingPairing
    case crossedOut
}

class GameGridCell: UICollectionViewCell {
    static let fontSizeFactor: CGFloat = 0.45
    static let animationDuration = 0.2

    fileprivate let numberLabel = UILabel()
    fileprivate let endOfRoundMarker = EndOfRoundMarker()

    // We want two separate color fillers to animate in case the selection happens
    // quite quickly; for example, when the selection animation hasn't finished, but
    // the crossing out animation must already begin
    fileprivate let bottomColorFiller = UIView()
    fileprivate let topColorFiller = UIView()

    var useClearBackground = false
    var lightColor = UIColor.themeColor(.offWhiteShaded)
    let darkColor = UIColor.themeColor(.offBlack)
    let accentColor = UIColor.themeColor(.accent)

    fileprivate var unfillingInProgress = false

    var state: GameGridCellState = .available

    var value: Int? {
        didSet {
            numberLabel.text = value != nil ? "\(value!)" : nil
        }
    }

    var marksEndOfRound: Bool = false {
        didSet {
            endOfRoundMarker.isHidden = !marksEndOfRound
        }
    }

    var aboutToBeRevealed: Bool = false {
        didSet {
            if aboutToBeRevealed {
                contentView.alpha = 0
            } else if oldValue && !aboutToBeRevealed {
                UIView.animate(withDuration: 0.2, animations: {
                    self.contentView.alpha = 1
                })
            } else {
                contentView.alpha = 1
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = UIColor.clear

        contentView.clipsToBounds = true

        contentView.addSubview(bottomColorFiller)
        contentView.addSubview(topColorFiller)
        contentView.addSubview(numberLabel)
        contentView.layer.addSublayer(endOfRoundMarker)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bottomColorFiller.transform = CGAffineTransform(scaleX: 0, y: 0)
        topColorFiller.transform = CGAffineTransform(scaleX: 0, y: 0)
        marksEndOfRound = false
        state = .available
        value = nil
        aboutToBeRevealed = false
        resetColors()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for colorFiller in [bottomColorFiller, topColorFiller] {
            colorFiller.frame = edgeToEdgeCircleFrame()
            colorFiller.layer.cornerRadius = colorFiller.frame.size.width / 2.0
            colorFiller.transform = CGAffineTransform(scaleX: 0, y: 0)
        }

        numberLabel.frame = contentView.bounds

        let fontSize = contentView.bounds.size.height * GameGridCell.fontSizeFactor
        numberLabel.font = UIFont.themeFontWithSize(fontSize)

        endOfRoundMarker.frame = contentView.bounds
    }

    func reveal() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction, animations: {
            self.contentView.alpha = 1
        }, completion: nil)
    }

    func fadeOutContentMomentarily(forSeconds seconds: Double,
                                   whileInvisible whileInvisibleBlock: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.15, animations: {
            self.contentView.backgroundColor = self.cellBackgroundColor()

            for subview in self.contentView.subviews {
                subview.alpha = 0
            }
        }, completion: { _ in
            whileInvisibleBlock()

            UIView.animate(withDuration: 0.15,
                                       delay: seconds,
                                       options: [],
                                       animations: {
                for subview in self.contentView.subviews {
                    subview.alpha = 1
                }

                self.resetColors()
            }, completion: nil)
        })
    }

    func flash(withColor color: UIColor) {
        guard state == .available else { return }

        UIView.animate(withDuration: 0.3,
                                   delay: 0.3,
                                   options: [.curveEaseOut, .allowUserInteraction],
                                   animations: {
            self.contentView.backgroundColor = color
        }, completion: { _ in
            UIView.animate(withDuration: 0.3,
                                       delay: 0,
                                       options: [.curveEaseIn, .allowUserInteraction],
                                       animations: {
                guard self.state == .available else { return }
                self.contentView.backgroundColor = self.cellBackgroundColor()
            }, completion: nil)
        })
    }

    func crossOut() {
        state = .crossedOut

        fill(usingColor: darkColor, filler: topColorFiller, completion: {
            self.resetColors()
        })
    }

    func unCrossOut(withDelay delay: Double = 0, animated: Bool = false) {
        state = .available

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
        state = .pendingPairing
        fill(usingColor: accentColor, filler: bottomColorFiller)
    }

    func indicateSelectionFailure() {
        indicateDeselection(withDelay: 0.2)
    }

    func indicateDeselection(withDelay delay: Double = 0) {
        state = .available
        unfill(usingColor: UIColor.themeColor(.accent), filler: bottomColorFiller, withDelay: delay)
    }

    fileprivate func fill(usingColor color: UIColor,
                      filler: UIView,
                      delay: Double = 0,
                      completion: (() -> Void)? = nil) {
        filler.backgroundColor = color
        filler.transform = CGAffineTransform(scaleX: 0, y: 0)

        UIView.animate(withDuration: GameGridCell.animationDuration,
                                   delay: delay,
                                   options: [.curveEaseOut, .beginFromCurrentState],
                                   animations: {
            filler.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { (finished: Bool) in
            if finished && !self.unfillingInProgress {
                self.contentView.backgroundColor = color
                filler.transform = CGAffineTransform(scaleX: 0, y: 0)
            }
            completion?()
        })
    }


    fileprivate func unfill(usingColor color: UIColor,
                        filler: UIView,
                        withDelay delay: Double,
                        completion: (() -> Void)? = nil) {
        filler.backgroundColor = color
        filler.transform = CGAffineTransform(scaleX: 1, y: 1)
        contentView.backgroundColor = cellBackgroundColor()
        unfillingInProgress = true

        // Zero transforms cannot be animated; see
        // http://stackoverflow.com/a/25966733/2026098
        UIView.animate(withDuration: GameGridCell.animationDuration,
                                   delay: delay,
                                   options: [.curveEaseIn, .beginFromCurrentState],
                                   animations: {
            filler.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }, completion: { _ in
            self.unfillingInProgress = false
            filler.transform = CGAffineTransform(scaleX: 0, y: 0)
            completion?()
        })
    }

    // We need to wait for whichever cell's selection triggered the removal to finish animating
    func prepareForRemoval(completion: @escaping (() -> Void)) {
        let delayTime = Int64((GameGridCell.animationDuration + 0.1) * Double(NSEC_PER_SEC))
        let dispatchTime = DispatchTime.now() + Double(delayTime) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            UIView.animate(withDuration: 0.15,
                                       delay: 0,
                                       options: .curveEaseOut,
                                       animations: {
                self.contentView.backgroundColor = self.cellBackgroundColor()
            }, completion: { _ in
                completion()
            })
        }
    }

    func resetColors() {
        bottomColorFiller.backgroundColor = UIColor.clear
        topColorFiller.backgroundColor = UIColor.clear

        switch state {
        case .crossedOut:
            endOfRoundMarker.fillColor = lightColor.cgColor
            numberLabel.textColor = UIColor.clear
            contentView.backgroundColor = darkColor
        case .pendingPairing:
            endOfRoundMarker.fillColor = darkColor.cgColor
            numberLabel.textColor = darkColor
            contentView.backgroundColor = accentColor
        default:
            endOfRoundMarker.fillColor = darkColor.cgColor
            numberLabel.textColor = darkColor
            contentView.backgroundColor = cellBackgroundColor()
        }
    }

    fileprivate func cellBackgroundColor() -> UIColor {
        return useClearBackground ? UIColor.clear : lightColor
    }

    fileprivate func edgeToEdgeCircleFrame() -> CGRect {
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
