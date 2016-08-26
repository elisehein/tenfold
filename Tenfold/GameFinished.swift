//
//  GameFinished.swift
//  Tenfold
//
//  Created by Elise Hein on 24/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import PureLayout
import UIKit

class GameFinished: UIViewController {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let statsLabel = UILabel()
    private let closeButton = Button()

    private let game: Game

    private var hasLoadedConstraints = false

    init(game: Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .CrossDissolve

        imageView.image = UIImage(named: "balloon")
        imageView.contentMode = .ScaleAspectFit

        var titleFont = UIFont.themeFontWithSize(16, weight: .Bold)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            titleFont = titleFont.fontWithSize(22)
        }

        titleLabel.font = titleFont
        titleLabel.text = "OMG!"
        titleLabel.textColor = UIColor.themeColor(.OffBlack)

        statsLabel.numberOfLines = 0
        let statsText = "You finished the game!\n" +
                        "You crossed out a total of \(game.historicNumberCount) numbers " +
                        "in \(game.currentRound) rounds."
        statsLabel.attributedText = constructAttributedString(withText: statsText)


        closeButton.addTarget(self,
                              action: #selector(GameFinished.dismiss),
                              forControlEvents: .TouchUpInside)
        closeButton.setTitle("TAKE ME BACK", forState: .Normal)

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(statsLabel)
        view.addSubview(closeButton)

        view.backgroundColor = UIColor.themeColor(.OffWhite)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {

            var imageSize = CGSize(width: 96, height: 187)
            var imageCenterOffset: CGFloat = -100
            var imageBottomSpacing: CGFloat = 70
            var titleBottomSpacing: CGFloat = 30

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                imageSize = CGSize(width: 120, height: 220)
                imageCenterOffset = -150
                imageBottomSpacing = 120
                titleBottomSpacing = 60
            }

            imageView.autoSetDimensionsToSize(imageSize)
            imageView.autoAlignAxisToSuperviewAxis(.Vertical)
            imageView.autoAlignAxis(.Horizontal,
                                    toSameAxisOfView: view,
                                    withOffset: imageCenterOffset)

            titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            titleLabel.autoPinEdge(.Top,
                                   toEdge: .Bottom,
                                   ofView: imageView,
                                   withOffset: imageBottomSpacing)

            statsLabel.autoPinEdge(.Top,
                                   toEdge: .Bottom,
                                   ofView: titleLabel,
                                   withOffset: titleBottomSpacing)
            statsLabel.autoMatchDimension(.Width,
                                          toDimension: .Width,
                                          ofView: view,
                                          withMultiplier: 0.8)
            statsLabel.autoAlignAxisToSuperviewAxis(.Vertical)

            closeButton.autoAlignAxisToSuperviewAxis(.Vertical)
            closeButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 30)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animateWithDuration(2,
                                   delay: 0,
                                   options: [.CurveEaseInOut,
                                             .Autoreverse,
                                             .Repeat,
                                             .AllowUserInteraction],
                                   animations: {
            var imageFrame = self.imageView.frame
            imageFrame.origin.y -= 40
            self.imageView.frame = imageFrame
        }, completion: nil)
    }

    private func constructAttributedString(withText text: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .Center

        var font = UIFont.themeFontWithSize(14)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = font.fontWithSize(18)
        }

        let attrString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: attrString.length)

        attrString.addAttribute(NSParagraphStyleAttributeName,
                                value: paragraphStyle,
                                range: fullRange)

        attrString.addAttribute(NSFontAttributeName,
                                value: font,
                                range: fullRange)

        attrString.addAttribute(NSForegroundColorAttributeName,
                                value: UIColor.themeColor(.OffBlack),
                                range: fullRange)
        return attrString
    }

    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
