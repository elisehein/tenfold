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

    private static let rowHeight: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 45 : 25
    }()

    private let rankedGames: [RankedGame]

    init(rankedGames: [RankedGame]) {
        self.rankedGames = rankedGames

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
            let labelFrameInset: CGFloat = 20
            labelFrame.size.width = 0.35 * labelFrame.size.width - labelFrameInset
            labelFrame.origin.x += labelFrameInset
            rankingLabel.frame = labelFrame

            labelFrame.origin.x += labelFrame.size.width
            labelFrame.size.width = 0.35 * rowFrame.size.width
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
            let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12
            label.font = UIFont.themeFontWithSize(fontSize)
            label.textAlignment = .left
            label.textColor = UIColor.themeColor(.offBlack).withAlphaComponent(0.8)
        }

        headerView.addSubview(UIView()) // Spacer
        headerView.addSubview(numbersLabel)
        headerView.addSubview(roundsLabel)

        return headerView
    }

    private func tableRows() -> [UIView] {
        var rows = [UIView]()

        for rankedGame in rankedGames {
            rows.append(tableRow(rankedGame))
        }

       return rows
    }

    private func tableRow(_ rankedGame: RankedGame) -> UIView {
        let rowView = UIView()

        let rankLabel = UILabel()
        rankLabel.text = "# \(rankedGame.rank)"

        let numbersLabel = UILabel()
        numbersLabel.text = String(rankedGame.gameSnapshot.historicNumberCount)

        let roundsLabel = UILabel()
        roundsLabel.text = String(rankedGame.gameSnapshot.totalRounds)

        for label in [rankLabel, numbersLabel, roundsLabel] {
            label.textColor = UIColor.themeColor(.offBlack).withAlphaComponent(0.8)
            let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14
            label.font = UIFont.themeFontWithSize(fontSize,
                                                  weight: rankedGame.isLatestGame ?
                                                          .bold :
                                                          .regular)
            label.textAlignment = .left
        }

        if rankedGame.isLatestGame {
            rowView.backgroundColor = UIColor.themeColor(.offWhiteShaded)
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
