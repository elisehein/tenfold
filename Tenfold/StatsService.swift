//
//  StatsService.swift
//  Tenfold
//
//  Created by Elise Hein on 30/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

struct GameRanking {
    let gameStats: GameStats
    let rank: Int
    let isLatestGame: Bool
}

class StatsService {

    class func numberOfFinishedGames() -> Int {
        let stats = allGameStats()
        return stats.filter({ $0.numbersRemaining == 0 }).count
    }

    class func latestGameIsLongest() -> Bool {
        let sortedLengths = sortedGameLengths()

        guard sortedLengths.count > 0 else {
            return false
        }

        let allStats = allGameStats()
        return allStats[latestGameStatsIndex(amongGameStats: allStats)].historicNumberCount == sortedLengths.last
    }

    class func latestGameIsShortestFinishedGame() -> Bool {
        let sortedLengths = sortedFinishedGameLengths()

        guard sortedLengths.count > 0 else {
            return false
        }

        let stats = finishedGameStats()
        return stats[latestGameStatsIndex(amongGameStats: stats)].historicNumberCount == sortedLengths.first
    }

    class func ranked(gameStats: Array<GameStats>) -> Array<GameStats> {
        return gameStats.sort({ pairOfStats in
            pairOfStats.0.historicNumberCount < pairOfStats.1.historicNumberCount
        })
    }

    class func finishedGameStats() -> Array<GameStats> {
        let stats = allGameStats()
        return stats.filter({ $0.numbersRemaining == 0 })
    }

    // Need of better naming.
    // This function returns the top three game stats based on our ranking criteria
    // (currently historicNumberCount); if the latest (i.e. current game)
    // isn't a part of the top three, it's appended as the fourth, with the
    // Int key signifying the rank of the specific game (e.g, 1, 2, 3, 8)
    class func latestGameRankingContext() -> Array<GameRanking> {
        var rankingContext: Array<GameRanking> = Array()

        let rankedStats = finishedGameStats()
        let latestGameRank = latestGameStatsIndex(amongGameStats: rankedStats) + 1

        for rank in Array(0...min(3, rankedStats.count)) {
            print("Adding", rank, "to ranking context")
            let gameStats = rankedStats[rank]
            rankingContext.append(GameRanking(gameStats: gameStats,
                                              rank: rank,
                                              isLatestGame: rank == latestGameRank))
        }

        if latestGameRank > 3 {
            let latestGameStats = GameRanking(gameStats: rankedStats[latestGameRank - 1],
                                              rank: latestGameRank,
                                              isLatestGame: true)
            rankingContext.append(latestGameStats)
        }

        return rankingContext
    }

    class func latestGameStatsIndex(amongGameStats gameStats: Array<GameStats>) -> Int {
        let endTimes: Array<NSDate> = gameStats.map({ $0.endTime })
        let sortedEndTimes = endTimes.sort({ pairOfDates in
            pairOfDates.0.compare(pairOfDates.1) == .OrderedAscending
        })

        return endTimes.indexOf(sortedEndTimes.last!)!
    }

    private class func sortedGameLengths() -> Array<Int> {
        let gameLengths = allGameStats().map({ $0.historicNumberCount })
        return gameLengths.sort()
    }

    private class func sortedFinishedGameLengths() -> Array<Int> {
        let gameLengths = finishedGameStats().map({ $0.historicNumberCount })
        return gameLengths.sort()
    }

    private class func allGameStats() -> Array<GameStats> {
        return StorageService.restorePreviousGameStats()
    }
}
