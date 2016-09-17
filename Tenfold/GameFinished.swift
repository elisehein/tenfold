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
    private let rankingTable: RankingTable
    private let closeButton = Button()

    private let game: Game

    private var hasLoadedConstraints = false

    private static let imageSize: CGSize = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ?
               CGSize(width: 120, height: 220) :
               CGSize(width: 80, height: 150)
    }()

    private static let imageBottomSpacing: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 70 : 30
    }()

    private static let titleBottomSpacing: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 20 : 10
    }()

    private static let tableTopSpacing: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 80 : 40
    }()

    private static let statsLabelWidthFactor: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 0.65 : 0.85
    }()

    private static let closeButtonBottomInset: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 60 : 30
    }()

    init(game: Game) {
        self.game = game

        let topRankedGames = RankingService.singleton.topRankedGames(cappedTo: 4)
        self.rankingTable = RankingTable(rankedGames: topRankedGames)
        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .CrossDissolve

        imageView.image = UIImage(named: "balloon")
        imageView.contentMode = .ScaleAspectFit

        var titleFont = UIFont.themeFontWithSize(16, weight: .Bold)

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            titleFont = titleFont.fontWithSize(22)
        }

        titleLabel.font = titleFont
        titleLabel.text = "You've done it!"
        titleLabel.textColor = UIColor.themeColor(.OffBlack)

        statsLabel.numberOfLines = 0
        statsLabel.attributedText = NSAttributedString.styled(as: .Paragraph, usingText: statsText())

        closeButton.addTarget(self,
                              action: #selector(GameFinished.dismiss),
                              forControlEvents: .TouchUpInside)
        closeButton.setTitle("Take me back", forState: .Normal)

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(statsLabel)
        view.addSubview(rankingTable)
        view.addSubview(closeButton)

        view.backgroundColor = UIColor.themeColor(.OffWhite)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            titleLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -30)

            imageView.autoSetDimensionsToSize(GameFinished.imageSize)
            imageView.autoPinEdge(.Bottom,
                                  toEdge: .Top,
                                  ofView: titleLabel,
                                  withOffset: -GameFinished.imageBottomSpacing)

            statsLabel.autoPinEdge(.Top,
                                   toEdge: .Bottom,
                                   ofView: titleLabel,
                                   withOffset: GameFinished.titleBottomSpacing)
            statsLabel.autoMatchDimension(.Width,
                                          toDimension: .Width,
                                          ofView: view,
                                          withMultiplier: GameFinished.statsLabelWidthFactor)

            rankingTable.autoMatchDimension(.Width,
                                            toDimension: .Width,
                                            ofView: view,
                                            withMultiplier: 0.5)
            rankingTable.autoPinEdge(.Top,
                                     toEdge: .Bottom,
                                     ofView: statsLabel,
                                     withOffset: GameFinished.tableTopSpacing)
            rankingTable.autoSetDimension(.Height, toSize: rankingTable.heightOccupied())

            closeButton.autoPinEdgeToSuperviewEdge(.Bottom,
                                                   withInset: GameFinished.closeButtonBottomInset)

            // swiftlint:disable:next line_length
            [titleLabel, imageView, statsLabel, rankingTable, closeButton].autoAlignViewsToAxis(.Vertical)

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
            imageFrame.origin.y -= 35
            self.imageView.frame = imageFrame
        }, completion: nil)
    }

    private func statsText() -> String {
        var text = ""

        if RankingService.singleton.numberOfWinningGames() == 1 {
            text += "And it's a first! It took you \(game.historicNumberCount) numbers " +
                    "and \(game.currentRound) rounds to empty the grid. "
        } else {
            if RankingService.singleton.latestGameIsShortestWinningGame() {
                text += "And it's your shortest game to date! "
            } else if RankingService.singleton.latestGameIsLongest() {
                text += "This is your longest game to date – you got there in the end! "
            }

            text += "Here's how you fared against your previous games."
        }

        return text
    }

    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
