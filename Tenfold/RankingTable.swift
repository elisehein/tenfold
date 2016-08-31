//
//  RankingTable.swift
//  Tenfold
//
//  Created by Elise Hein on 30/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class RankingTable: UIView {

    private static let rowHeight: CGFloat = 25
    private let data: Array<GameRanking>

    init(data: Array<GameRanking>) {
        self.data = data

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
            rowFrame.origin.y += currentRow * RankingTable.rowHeight
            rowFrame.size.height = RankingTable.rowHeight
            row.frame = rowFrame

            let rankingLabel = row.subviews[0]
            let numbersLabel = row.subviews[1]
            let roundsLabel = row.subviews[2]

            var labelFrame = row.bounds
            labelFrame.size.width *= 0.3
            labelFrame.origin.x += 20 // For padding
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
        return CGFloat(subviews.count) * RankingTable.rowHeight
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
        var rows = Array<UIView>()

        for gameRanking in data {
            rows.append(tableRow(gameRanking))
        }

       return rows
    }

    private func tableRow(gameRanking: GameRanking) -> UIView {
        let rowView = UIView()

        let rankLabel = UILabel()
        rankLabel.text = "# \(gameRanking.rank)"

        let numbersLabel = UILabel()
        numbersLabel.text = String(gameRanking.gameStats.historicNumberCount)

        let roundsLabel = UILabel()
        roundsLabel.text = String(gameRanking.gameStats.totalRounds)

        for label in [rankLabel, numbersLabel, roundsLabel] {
            label.textColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.8)
            label.font = UIFont.themeFontWithSize(14, weight: gameRanking.isLatestGame ? .Bold : .Regular)
            label.textAlignment = .Left
        }

        if gameRanking.isLatestGame {
            rowView.backgroundColor = UIColor.themeColor(.OffWhiteShaded)
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
