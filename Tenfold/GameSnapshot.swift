//
//  GameSnapshot.swift
//  Tenfold
//
//  Created by Elise Hein on 30/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class GameSnapshot: NSObject, NSCoding {
    let historicNumberCount: Int
    let numbersRemaining: Int
    let totalRounds: Int
    let startTime: Date?
    let endTime: Date

    fileprivate static let historicNumberCountCoderKey = "gameSnapshotHistoricNumberCountCoderKey"
    fileprivate static let numbersRemainingCoderKey = "gameSnapshotNumbersRemainingCoderKey"
    fileprivate static let totalRoundsCoderKey = "gameSnapshotTotalRoundsCoderKey"
    fileprivate static let startTimeCoderKey = "gameSnapshotStartTimeCoderKey"
    fileprivate static let endTimeCoderKey = "gameSnapshotEndTimeCoderKey"

    init(historicNumberCount: Int,
         numbersRemaining: Int,
         totalRounds: Int,
         startTime: Date?,
         endTime: Date) {
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
                  startTime: game.startTime as Date?,
                  endTime: Date())
    }

    required init?(coder aDecoder: NSCoder) {
        self.historicNumberCount = Int(aDecoder.decodeCInt(forKey: GameSnapshot.historicNumberCountCoderKey))
        self.numbersRemaining = Int(aDecoder.decodeCInt(forKey: GameSnapshot.numbersRemainingCoderKey))
        self.totalRounds = Int(aDecoder.decodeCInt(forKey: GameSnapshot.totalRoundsCoderKey))
        self.startTime = aDecoder.decodeObject(forKey: GameSnapshot.startTimeCoderKey) as? Date
        self.endTime = (aDecoder.decodeObject(forKey: GameSnapshot.endTimeCoderKey) as? Date)!

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encodeCInt(Int32(historicNumberCount), forKey: GameSnapshot.historicNumberCountCoderKey)
        aCoder.encodeCInt(Int32(numbersRemaining), forKey: GameSnapshot.numbersRemainingCoderKey)
        aCoder.encodeCInt(Int32(totalRounds), forKey: GameSnapshot.totalRoundsCoderKey)
        aCoder.encode(startTime! as Any?, forKey: GameSnapshot.startTimeCoderKey)
        aCoder.encode(endTime as Any?, forKey: GameSnapshot.endTimeCoderKey)
    }
}
