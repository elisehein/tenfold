//
//  RankingService.swift
//  Tenfold
//
//  Created by Elise Hein on 30/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

struct RankedGame {
    let gameSnapshot: GameSnapshot
    let rank: Int
    let isLatestGame: Bool
}

class RankingService {

    static let singleton = RankingService.init()

    var orderedGameSnapshots: [GameSnapshot]

    init() {
        orderedGameSnapshots = StorageService.restoreOrderedGameSnapshots()
    }

    class func order(_ gameSnapshots: [GameSnapshot]) -> [GameSnapshot] {
        return gameSnapshots.sorted(by: { snapshot, otherSnapshot  in
            snapshot.historicNumberCount < otherSnapshot.historicNumberCount
        })
    }

    func numberOfWinningGames() -> Int {
        return orderedGameSnapshots.filter({ $0.numbersRemaining == 0 }).count
    }

    func gameIsLongerThanCurrentLongest(_ game: Game) -> Bool {
        guard orderedGameSnapshots.count > 0 else {
            return false
        }

        return (orderedGameSnapshots.last?.historicNumberCount)! < game.historicNumberCount
    }

    func latestGameIsLongest() -> Bool {
        let latestIndex = latestGameSnapshotIndex(inOrderedSnapshots: orderedGameSnapshots)

        if let latestIndex = latestIndex {
            return latestIndex == orderedGameSnapshots.endIndex
        } else {
            return false
        }
    }

    func latestGameIsShortestWinningGame() -> Bool {
        let snapshots = orderedWinningGameSnapshots()
        let latestIndex = latestGameSnapshotIndex(inOrderedSnapshots: snapshots)

        return latestIndex == 0
    }

    // This function returns the top three game stats based on our ranking criteria
    // (currently historicNumberCount); if the latest (i.e. current game)
    // isn't a part of the top three, it's appended as the fourth, with the
    // Int key signifying the rank of the specific game (e.g, 1, 2, 3, 8)
    func topRankedGames(cappedTo cap: Int) -> [RankedGame] {
        var rankedGames: [RankedGame] = []
        let snapshots = orderedWinningGameSnapshots()

        if snapshots.count == 0 {
            return []
        }

        let latestGameIndex = latestGameSnapshotIndex(inOrderedSnapshots: snapshots)!

        // If the cap is 3, we want to limit the initial list to 2, as the current game
        // may not fit inside the top 3, in which case it would be added as a fourth
        let capIndex = min(cap - 1, snapshots.count)
        for index in Array(0..<capIndex) {
            let snapshot = snapshots[index]
            rankedGames.append(RankedGame(gameSnapshot: snapshot,
                                          rank: index + 1,
                                          isLatestGame: index == latestGameIndex))
        }

        let latestGameRank = latestGameIndex + 1
        if latestGameRank >= cap {
            let rankedGame = RankedGame(gameSnapshot: snapshots[latestGameIndex],
                                        rank: latestGameRank,
                                        isLatestGame: true)
            rankedGames.append(rankedGame)
        }

        return rankedGames
    }

    func latestGameSnapshotIndex(inOrderedSnapshots orderedSnapshots: [GameSnapshot]) -> Int? {
        guard orderedSnapshots.count > 0 else {
            return nil
        }

        let endTimes: [Date] = orderedSnapshots.map({ ($0.endTime as Date) })
        let sortedEndTimes = endTimes.sorted { $0.compare($1) == .orderedAscending }

        return endTimes.index(of: sortedEndTimes.last!)!
    }

    fileprivate func orderedWinningGameSnapshots() -> [GameSnapshot] {
        return orderedGameSnapshots.filter({ $0.numbersRemaining == 0 })
    }
}
