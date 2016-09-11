//
//  GameSnapshot.swift
//  Tenfold
//
//  Created by Elise Hein on 30/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class GameSnapshot: NSObject, NSCoding {
    let fullNumberCount: Int
    let numbersRemaining: Int
    let totalRounds: Int
    let startTime: NSDate?
    let endTime: NSDate

    private static let fullNumberCountCoderKey = "gameSnapshotHistoricNumberCountCoderKey"
    private static let numbersRemainingCoderKey = "gameSnapshotNumbersRemainingCoderKey"
    private static let totalRoundsCoderKey = "gameSnapshotTotalRoundsCoderKey"
    private static let startTimeCoderKey = "gameSnapshotStartTimeCoderKey"
    private static let endTimeCoderKey = "gameSnapshotEndTimeCoderKey"

    init(fullNumberCount: Int,
         numbersRemaining: Int,
         totalRounds: Int,
         startTime: NSDate?,
         endTime: NSDate) {
        self.fullNumberCount = fullNumberCount
        self.numbersRemaining = numbersRemaining
        self.totalRounds = totalRounds
        self.startTime = startTime
        self.endTime = endTime
        super.init()
    }

    convenience init(game: Game) {
        self.init(fullNumberCount: game.fullNumberCount,
                  numbersRemaining: game.numbersRemaining(),
                  totalRounds: game.currentRound,
                  startTime: game.startTime,
                  endTime: NSDate())
    }

    required init?(coder aDecoder: NSCoder) {
        self.fullNumberCount = Int(aDecoder.decodeIntForKey(GameSnapshot.fullNumberCountCoderKey))
        self.numbersRemaining = Int(aDecoder.decodeIntForKey(GameSnapshot.numbersRemainingCoderKey))
        self.totalRounds = Int(aDecoder.decodeIntForKey(GameSnapshot.totalRoundsCoderKey))
        self.startTime = aDecoder.decodeObjectForKey(GameSnapshot.startTimeCoderKey) as? NSDate
        self.endTime = (aDecoder.decodeObjectForKey(GameSnapshot.endTimeCoderKey) as? NSDate)!

        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(Int32(fullNumberCount),
                         forKey: GameSnapshot.fullNumberCountCoderKey)
        aCoder.encodeInt(Int32(numbersRemaining), forKey: GameSnapshot.numbersRemainingCoderKey)
        aCoder.encodeInt(Int32(totalRounds), forKey: GameSnapshot.totalRoundsCoderKey)
        aCoder.encodeObject(startTime!, forKey: GameSnapshot.startTimeCoderKey)
        aCoder.encodeObject(endTime, forKey: GameSnapshot.endTimeCoderKey)
    }
}
