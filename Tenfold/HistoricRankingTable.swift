//
//  HistoricRankingTable.swift
//  Tenfold
//
//  Created by Elise Hein on 30/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class HistoricRankingTable: UIView {

    private static let rowHeight: CGFloat = 25
    private let game: Game

    init(game: Game) {
        self.game = game
        super.init(frame: CGRect.zero)

        addSubview(tableHeaderView())

        for row in tableRows() {
            addSubview(row)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var currentRow: CGFloat = 0

        for row in subviews {
            var rowFrame = bounds
            rowFrame.origin.y += currentRow * HistoricRankingTable.rowHeight
            rowFrame.size.height = HistoricRankingTable.rowHeight
            row.frame = rowFrame

            let rankingLabel = row.subviews[0]
            let numbersLabel = row.subviews[1]
            let roundsLabel = row.subviews[2]

            var labelFrame = row.bounds
            labelFrame.size.width *= 0.3
            rankingLabel.frame = labelFrame

            labelFrame.origin.x += labelFrame.size.width
            labelFrame.size.width = 0.4 * rowFrame.size.width
            numbersLabel.frame = labelFrame

            labelFrame.origin.x += labelFrame.size.width
            labelFrame.size.width = 0.3 * rowFrame.size.width
            roundsLabel.frame = labelFrame

            currentRow += 1
        }
    }

    func heightOccupied() -> CGFloat {
        return CGFloat(subviews.count) * HistoricRankingTable.rowHeight
    }

    private func tableHeaderView() -> UIView {
        let headerView = UIView()

        let numbersLabel = UILabel()
        numbersLabel.text = "Numbers"

        let roundsLabel = UILabel()
        roundsLabel.text = "Rounds"

        for label in [numbersLabel, roundsLabel] {
            label.font = UIFont.themeFontWithSize(12)
            label.textAlignment = .Left
            label.textColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.8)
        }

        headerView.addSubview(UIView()) // Spacer
        headerView.addSubview(numbersLabel)
        headerView.addSubview(roundsLabel)

        return headerView
    }

    private func tableRows() -> Array<UIView> {
        let rankedStats = StatsService.finishedGameStats()
        let lastIndex = min(3, rankedStats.count)
        let topThree = rankedStats[0..<lastIndex]
        let currentGameRank = StatsService.latestGameStatsIndex() + 1

        var rows: Array<UIView> = []
        var currentRow = 1

        for gameStats in topThree {
            rows.append(tableRow(currentRow,
                                 gameStats: gameStats,
                                 isCurrentGame: currentGameRank == currentRow))
            currentRow += 1
        }

        if currentGameRank > 3 {
            print("The current game was longer than the top three, append it to the end")
            rows.append(tableRow(currentGameRank,
                                 gameStats: rankedStats[currentGameRank - 1],
                                 isCurrentGame: true))
            // TODO if > 4 add top border
        }

       return rows
    }

    private func tableRow(rank: Int, gameStats: GameStats, isCurrentGame: Bool) -> UIView {
        let rowView = UIView()

        let rankLabel = UILabel()
        rankLabel.text = "# \(rank)"

        let numbersLabel = UILabel()
        numbersLabel.text = String(gameStats.historicNumberCount)

        let roundsLabel = UILabel()
        roundsLabel.text = String(gameStats.totalRounds)

        for label in [rankLabel, numbersLabel, roundsLabel] {
            label.textColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.8)
            label.font = UIFont.themeFontWithSize(14, weight: isCurrentGame ? .Bold : .Regular)
            label.textAlignment = .Left
        }

        rowView.addSubview(rankLabel)
        rowView.addSubview(numbersLabel)
        rowView.addSubview(roundsLabel)

        return rowView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
