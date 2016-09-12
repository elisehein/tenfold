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
    private static let orderedGameSnapshotsStorageKey = "orderedGameSnapshotsStorageKey"
    private static let soundPrefStorageKey = "tenfoldSoundPrefStorageKey"
    private static let firstLaunchFlagStorageKey = "tenfoldFirstLaunchFlagStorageKey"

    class func registerDefaults() {
        NSUserDefaults.standardUserDefaults().registerDefaults([
            soundPrefStorageKey: true,
            firstLaunchFlagStorageKey: true
        ])
    }

    class func restoreFirstLaunchFlag() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(StorageService.firstLaunchFlagStorageKey)
    }

    class func saveFirstLaunchFlag(firstLaunch: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(firstLaunch, forKey:StorageService.firstLaunchFlagStorageKey)
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

    class func restoreOrderedGameSnapshots() -> Array<GameSnapshot> {
        let defaults = NSUserDefaults.standardUserDefaults()
        let statsData = defaults.objectForKey(StorageService.orderedGameSnapshotsStorageKey)

        if let statsData = statsData as? NSData {
            let gameStats = NSKeyedUnarchiver.unarchiveObjectWithData(statsData)
            if let stats = gameStats as? Array<GameSnapshot> {
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
    class func saveGameSnapshot(game: Game, forced: Bool = false) {
        if !forced {
            // Simple heuristics to avoid storing every trivial game on device
            guard game.startTime != nil else { return }
            guard game.currentRound > 3 else { return }
            guard game.historicNumberCount - game.numbersRemaining() > 20 else { return }
        }

        var snapshots = restoreOrderedGameSnapshots()
        let currentSnapshot = GameSnapshot(game: game)

        // This ensures preference to the latest game in the case of equal scoring
        snapshots.insert(currentSnapshot, atIndex: 0)
        let orderedSnapshots = RankingService.order(snapshots)

        let orderedSnapshotsData = NSKeyedArchiver.archivedDataWithRootObject(orderedSnapshots)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(orderedSnapshotsData,
                           forKey: StorageService.orderedGameSnapshotsStorageKey)
        RankingService.singleton.orderedGameSnapshots = orderedSnapshots
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
