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

    class func restorePreviousGameStats() -> Array<[String: AnyObject]> {
        let defaults = NSUserDefaults.standardUserDefaults()
        let statsData = defaults.objectForKey(StorageService.previousGameStatsStorageKey)

        if let statsData = statsData as? NSData {
            let gameStats = NSKeyedUnarchiver.unarchiveObjectWithData(statsData)
            if let stats = gameStats as? Array<[String: AnyObject]> {
                return stats
            } else {
                return []
            }
        } else {
            return []
        }
    }

    class func saveFinishedGameStats(game: Game) {
        // Simple heuristics to avoid storing every trivial game on device
        guard game.startTime != nil else { return }
        guard game.currentRound > 3 else { return }
        guard game.historicNumberCount - game.numbersRemaining() > 20 else { return }

        var stats = restorePreviousGameStats()
        var currentStats: [String: AnyObject] = [:]
        currentStats["startTime"] = game.startTime
        currentStats["endTime"] = NSDate()
        currentStats["historicNumberCount"] = game.historicNumberCount
        currentStats["numbersRemaining"] = game.numbersRemaining()
        stats.append(currentStats)

        let statsData = NSKeyedArchiver.archivedDataWithRootObject(stats)
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
