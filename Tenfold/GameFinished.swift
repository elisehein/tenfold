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
    fileprivate let imageView = UIImageView()
    fileprivate let titleLabel = UILabel()
    fileprivate let statsLabel = UILabel()
    fileprivate let rankingTable: RankingTable
    fileprivate let closeButton = Button()

    fileprivate let game: Game

    fileprivate var hasLoadedConstraints = false

    fileprivate static let imageSize: CGSize = {
        return UIDevice.current.userInterfaceIdiom == .pad ?
               CGSize(width: 120, height: 220) :
               CGSize(width: 80, height: 150)
    }()

    fileprivate static let imageBottomSpacing: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 70 : 30
    }()

    fileprivate static let titleBottomSpacing: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10
    }()

    fileprivate static let tableTopSpacing: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40
    }()

    fileprivate static let statsLabelWidthFactor: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 0.65 : 0.85
    }()

    fileprivate static let closeButtonBottomInset: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
    }()

    init(game: Game) {
        self.game = game

        let topRankedGames = RankingService.singleton.topRankedGames(cappedTo: 4)
        self.rankingTable = RankingTable(rankedGames: topRankedGames)
        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .crossDissolve

        imageView.image = UIImage(named: "balloon")
        imageView.contentMode = .scaleAspectFit

        var titleFont = UIFont.themeFontWithSize(16, weight: .bold)

        if UIDevice.current.userInterfaceIdiom == .pad {
            titleFont = titleFont.withSize(22)
        }

        titleLabel.font = titleFont
        titleLabel.text = "You've done it!"
        titleLabel.textColor = UIColor.themeColor(.offBlack)

        statsLabel.numberOfLines = 0
        statsLabel.attributedText = NSMutableAttributedString.themeString(.paragraph, statsText())

        closeButton.addTarget(self,
                              action: #selector(self.dismissScreen),
                              for: .touchUpInside)
        closeButton.setTitle("Take me back", for: UIControlState())

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(statsLabel)
        view.addSubview(rankingTable)
        view.addSubview(closeButton)

        view.backgroundColor = UIColor.themeColor(.offWhite)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !hasLoadedConstraints {
            titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: view, withOffset: -30)

            imageView.autoSetDimensions(to: GameFinished.imageSize)
            imageView.autoPinEdge(.bottom,
                                  to: .top,
                                  of: titleLabel,
                                  withOffset: -GameFinished.imageBottomSpacing)

            statsLabel.autoPinEdge(.top,
                                   to: .bottom,
                                   of: titleLabel,
                                   withOffset: GameFinished.titleBottomSpacing)
            statsLabel.autoMatch(.width,
                                          to: .width,
                                          of: view,
                                          withMultiplier: GameFinished.statsLabelWidthFactor)

            rankingTable.autoMatch(.width,
                                            to: .width,
                                            of: view,
                                            withMultiplier: 0.5)
            rankingTable.autoPinEdge(.top,
                                     to: .bottom,
                                     of: statsLabel,
                                     withOffset: GameFinished.tableTopSpacing)
            rankingTable.autoSetDimension(.height, toSize: rankingTable.heightOccupied())

            closeButton.autoPinEdge(toSuperviewEdge: .bottom,
                                                   withInset: GameFinished.closeButtonBottomInset)

            // swiftlint:disable:next line_length
            ([titleLabel, imageView, statsLabel, rankingTable, closeButton] as NSArray).autoAlignViews(to: .vertical)

            hasLoadedConstraints = true
        }

        super.updateViewConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 2,
                                   delay: 0,
                                   options: [.autoreverse, .repeat, .allowUserInteraction],
                                   animations: {
            var imageFrame = self.imageView.frame
            imageFrame.origin.y -= 35
            self.imageView.frame = imageFrame
        }, completion: nil)
    }

    fileprivate func statsText() -> String {
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

    @objc func dismissScreen() {
        self.dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
