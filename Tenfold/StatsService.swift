//
//  StatsService.swift
//  Tenfold
//
//  Created by Elise Hein on 30/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class StatsService {

    class func constructGameStats(game: Game) -> GameStats {
        return GameStats(historicNumberCount: game.historicNumberCount,
                         numbersRemaining: game.numbersRemaining(),
                         totalRounds: game.currentRound,
                         startTime: game.startTime,
                         endTime: NSDate())
    }

    class func firstEverFinishedGame(game: Game) -> Bool {
        let stats = fetchStats()
        return stats.filter({ $0.numbersRemaining == 0 }).count == 0
    }

    class func longestGameToDate(game: Game) -> Bool {
        return game.historicNumberCount > sortedGameLengths().last
    }

    class func shortestGameToDate(game: Game) -> Bool {
        return game.historicNumberCount < sortedFinishedGameLengths().first
    }

    class func ranked(gameStats: Array<GameStats>) -> Array<GameStats> {
        return gameStats.sort({ pairOfStats in
            pairOfStats.0.historicNumberCount < pairOfStats.1.historicNumberCount
        })
    }

    class func finishedGameStats() -> Array<GameStats> {
        let stats = fetchStats()
        return stats.filter({ $0.numbersRemaining == 0 })
    }

    class func latestGameStatsIndex() -> Int {
        let stats = fetchStats()
        let endTimes: Array<NSDate> = stats.map({ $0.endTime })
        let latestEndTime = endTimes.sort({ pairOfDates in
            pairOfDates.0.compare(pairOfDates.1) == .OrderedAscending
        }).first

        return endTimes.indexOf(latestEndTime!)!
    }

    private class func sortedGameLengths() -> Array<Int> {
        let gameLengths = fetchStats().map({ $0.historicNumberCount })
        return gameLengths.sort()
    }

    private class func sortedFinishedGameLengths() -> Array<Int> {
        let gameLengths = finishedGameStats().map({ $0.historicNumberCount })
        return gameLengths.sort()
    }

    private class func fetchStats() -> Array<GameStats> {
        return StorageService.restorePreviousGameStats()
    }
}
