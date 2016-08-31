//
//  GameStats.swift
//  Tenfold
//
//  Created by Elise Hein on 30/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class GameStats: NSObject, NSCoding {
    let historicNumberCount: Int
    let numbersRemaining: Int
    let totalRounds: Int
    let startTime: NSDate?
    let endTime: NSDate

    private static let historicNumberCountCoderKey = "gameStatsHistoricNumberCountCoderKey"
    private static let numbersRemainingCoderKey = "gameStatsNumbersRemainingCoderKey"
    private static let totalRoundsCoderKey = "gameStatsTotalRoundsCoderKey"
    private static let startTimeCoderKey = "gameStatsStartTimeCoderKey"
    private static let endTimeCoderKey = "gameStatsEndTimeCoderKey"

    init(historicNumberCount: Int,
         numbersRemaining: Int,
         totalRounds: Int,
         startTime: NSDate?,
         endTime: NSDate) {
        self.historicNumberCount = historicNumberCount
        self.numbersRemaining = numbersRemaining
        self.totalRounds = totalRounds
        self.startTime = startTime
        self.endTime = endTime
        super.init()
    }

    convenience init(game: Game) {
        self.init(historicNumberCount: game.historicNumberCount,
                  numbersRemaining: game.numbersRemaining(),
                  totalRounds: game.currentRound,
                  startTime: game.startTime,
                  endTime: NSDate())
    }

    required init?(coder aDecoder: NSCoder) {
        // swiftlint:disable:next line_length
        self.historicNumberCount = Int(aDecoder.decodeIntForKey(GameStats.historicNumberCountCoderKey))
        self.numbersRemaining = Int(aDecoder.decodeIntForKey(GameStats.numbersRemainingCoderKey))
        self.totalRounds = Int(aDecoder.decodeIntForKey(GameStats.totalRoundsCoderKey))
        self.startTime = aDecoder.decodeObjectForKey(GameStats.startTimeCoderKey) as? NSDate
        self.endTime = (aDecoder.decodeObjectForKey(GameStats.endTimeCoderKey) as? NSDate)!

        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(Int32(historicNumberCount), forKey: GameStats.historicNumberCountCoderKey)
        aCoder.encodeInt(Int32(numbersRemaining), forKey: GameStats.numbersRemainingCoderKey)
        aCoder.encodeInt(Int32(totalRounds), forKey: GameStats.totalRoundsCoderKey)
        aCoder.encodeObject(startTime!, forKey: GameStats.startTimeCoderKey)
        aCoder.encodeObject(endTime, forKey: GameStats.endTimeCoderKey)
    }
}
