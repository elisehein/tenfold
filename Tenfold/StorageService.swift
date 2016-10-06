//
//  StorageService.swift
//  Tenfold
//
//  Created by Elise Hein on 26/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

enum StorageKey: String {
    case Game = "tenfoldGameStorageKey"
    case OrderedGameSnapshots = "orderedGameSnapshotsStorageKey"
    case FirstLaunchFlag = "tenfoldFirstLaunchFlagStorageKey"

    enum SettingsFlag: String {
        case SoundOn = "tenfoldSoundPrefStorageKey"
        case RandomInitialNumbers = "tenfoldRandomInitialNumbersFlagStorageKey"
    }

    enum FeatureAnnouncements: String {
       case Undo = "tenfoldUndoFeatureAnnouncementStorageKey"
    }
}

class StorageService {

    class func registerDefaults() {
        NSUserDefaults.standardUserDefaults().registerDefaults([
            StorageKey.FirstLaunchFlag.rawValue: true,
            StorageKey.SettingsFlag.SoundOn.rawValue: true,
            StorageKey.SettingsFlag.RandomInitialNumbers.rawValue: false,
            StorageKey.FeatureAnnouncements.Undo.rawValue: false
        ])
    }

    class func toggleFirstLaunchFlag() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let flag = defaults.boolForKey(StorageKey.FirstLaunchFlag.rawValue)
        defaults.setBool(false, forKey: StorageKey.FirstLaunchFlag.rawValue)
        return flag
    }

    class func saveGame(game: Game) {
        let gameData = NSKeyedArchiver.archivedDataWithRootObject(game)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(gameData, forKey: StorageKey.Game.rawValue)
    }

    class func restoreGame() -> Game? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let gameData = defaults.objectForKey(StorageKey.Game.rawValue)

        if let gameData = gameData as? NSData {
            let game = NSKeyedUnarchiver.unarchiveObjectWithData(gameData)
            return game as? Game
        } else {
            return nil
        }
    }

    class func restoreOrderedGameSnapshots() -> [GameSnapshot] {
        let defaults = NSUserDefaults.standardUserDefaults()
        let statsData = defaults.objectForKey(StorageKey.OrderedGameSnapshots.rawValue)

        if let statsData = statsData as? NSData {
            let gameStats = NSKeyedUnarchiver.unarchiveObjectWithData(statsData)
            if let stats = gameStats as? [GameSnapshot] {
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
                           forKey: StorageKey.OrderedGameSnapshots.rawValue)
        RankingService.singleton.orderedGameSnapshots = orderedSnapshots
    }

    class func toggleFeatureAnnouncementsFlag() -> Bool {
        let shouldShow = !hasSeenFeatureAnnouncement(.Undo)
        markFeatureAnnouncementSeen(.Undo)
        return shouldShow
    }

    class func toggleFlag(forSetting setting: StorageKey.SettingsFlag) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(!currentFlag(forSetting: setting), forKey: setting.rawValue)
    }

    class func currentFlag(forSetting setting: StorageKey.SettingsFlag) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(setting.rawValue)
    }

    class func hasSeenFeatureAnnouncement(featureAnnouncement: StorageKey.FeatureAnnouncements) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(featureAnnouncement.rawValue)
    }

    class func markFeatureAnnouncementSeen(featureAnnouncement: StorageKey.FeatureAnnouncements) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey:featureAnnouncement.rawValue)
    }
}
