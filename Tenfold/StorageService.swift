//
//  StorageService.swift
//  Tenfold
//
//  Created by Elise Hein on 26/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class StorageService {

    private static let gameStorageKey = "tenfoldGameStorageKey"
    private static let previousGameStatsStorageKey = "previousGameStatsStorageKey"
    private static let soundPrefStorageKey = "tenfoldSoundPrefStorageKey"

    class func registerDefaults() {
        NSUserDefaults.standardUserDefaults().registerDefaults([
            soundPrefStorageKey: true
        ])
    }

    class func saveGame(game: Game) {
        let gameData = NSKeyedArchiver.archivedDataWithRootObject(game)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(gameData, forKey: StorageService.gameStorageKey)
    }

    class func restoreGame() -> Game? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let gameData = defaults.objectForKey(StorageService.gameStorageKey)

        if let gameData = gameData as? NSData {
            let game = NSKeyedUnarchiver.unarchiveObjectWithData(gameData)
            return game as? Game
        } else {
            return nil
        }
    }

    class func restorePreviousGameStats() -> Array<GameStats> {
        let defaults = NSUserDefaults.standardUserDefaults()
        let statsData = defaults.objectForKey(StorageService.previousGameStatsStorageKey)

        if let statsData = statsData as? NSData {
            let gameStats = NSKeyedUnarchiver.unarchiveObjectWithData(statsData)
            if let stats = gameStats as? Array<GameStats> {
                return stats
            } else {
                return []
            }
        } else {
            return []
        }
    }

    // If a game was finished, we want to save the stats in all cases,
    // even if the criteria goes against our triviality heuristics
    class func saveFinishedGameStats(game: Game, forced: Bool = false) {
        if !forced {
            // Simple heuristics to avoid storing every trivial game on device
            guard game.startTime != nil else { return }
            guard game.currentRound > 3 else { return }
            guard game.historicNumberCount - game.numbersRemaining() > 20 else { return }
        }

        var stats = restorePreviousGameStats()
        let currentStats = GameStats(game: game)

        // This ensures preference to the latest game in the case of equal scoring
        stats.insert(currentStats, atIndex: 0)
        let rankedStats = StatsService.ranked(stats)
        print("Storing ranked stats", rankedStats)

        let statsData = NSKeyedArchiver.archivedDataWithRootObject(rankedStats)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(statsData, forKey: StorageService.previousGameStatsStorageKey)
    }

    class func currentSoundPreference() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let soundPref = defaults.boolForKey(StorageService.soundPrefStorageKey)
        return soundPref
    }

    class func toggleSoundPreference() {
        let currentPreference = currentSoundPreference()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(!currentPreference, forKey:StorageService.soundPrefStorageKey)
    }
}
