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

    class func restorePreviousGameStats() -> [String: AnyObject]? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let statsData = defaults.objectForKey(StorageService.previousGameStatsStorageKey)

        if let statsData = statsData as? NSData {
            let gameStats = NSKeyedUnarchiver.unarchiveObjectWithData(statsData)
            if let stats = gameStats as? [String: AnyObject] {
                return stats
            } else {
                return [:]
            }
        } else {
            return [:]
        }
    }

    class func saveFinishedGameStats(game: Game) {
        guard game.playingSince != nil else { return }

        var stats = restorePreviousGameStats()
        stats!["playingSince"] = game.playingSince
        stats!["historicNumberCount"] = game.historicNumberCount
        stats!["numbersRemaining"] = game.numbersRemaining()

        let statsData = NSKeyedArchiver.archivedDataWithRootObject(stats!)
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
