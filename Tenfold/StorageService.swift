//
//  StorageService.swift
//  Tenfold
//
//  Created by Elise Hein on 26/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

enum StorageKey: String {
    case game = "tenfoldGameStorageKey"
    case orderedGameSnapshots = "orderedGameSnapshotsStorageKey"
    case firstLaunchFlag = "tenfoldFirstLaunchFlagStorageKey"

    enum SettingsFlag: String {
        case soundOn = "tenfoldSoundPrefStorageKey"
        case vibrationOn = "tenfoldVibrationFlagStorageKey"
        case randomInitialNumbers = "tenfoldRandomInitialNumbersFlagStorageKey"
    }

    enum FeatureAnnouncement: String {
       case undo = "tenfoldUndoFeatureAnnouncementStorageKey"
       case options = "tenfoldOptionsFeatureAnnouncementStorageKey"
       case nextRoundDisallowed = "tenfoldNextRoundDisallowedFeatureAnnouncementStorageKey"
    }
}

class StorageService {

    class func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            StorageKey.firstLaunchFlag.rawValue: true,
            StorageKey.SettingsFlag.soundOn.rawValue: true,
            StorageKey.SettingsFlag.vibrationOn.rawValue: true,
            StorageKey.SettingsFlag.randomInitialNumbers.rawValue: false,
            StorageKey.FeatureAnnouncement.undo.rawValue: false,
            StorageKey.FeatureAnnouncement.options.rawValue: false,
            StorageKey.FeatureAnnouncement.nextRoundDisallowed.rawValue: false
        ])
    }

    class func toggleFirstLaunchFlag() -> Bool {
        let defaults = UserDefaults.standard
        let flag = defaults.bool(forKey: StorageKey.firstLaunchFlag.rawValue)
        defaults.set(false, forKey: StorageKey.firstLaunchFlag.rawValue)
        return flag
    }

    class func saveGame(_ game: Game) {
        let gameData = NSKeyedArchiver.archivedData(withRootObject: game)
        let defaults = UserDefaults.standard
        defaults.set(gameData, forKey: StorageKey.game.rawValue)
    }

    class func restoreGame() -> Game? {
        let defaults = UserDefaults.standard
        let gameData = defaults.object(forKey: StorageKey.game.rawValue)

        if let gameData = gameData as? Data {
            let game = NSKeyedUnarchiver.unarchiveObject(with: gameData)
            return game as? Game
        } else {
            return nil
        }
    }

    class func restoreOrderedGameSnapshots() -> [GameSnapshot] {
        let defaults = UserDefaults.standard
        let statsData = defaults.object(forKey: StorageKey.orderedGameSnapshots.rawValue)

        if let statsData = statsData as? Data {
            let gameStats = NSKeyedUnarchiver.unarchiveObject(with: statsData)
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
    class func saveGameSnapshot(_ game: Game, forced: Bool = false) {
        if !forced {
            // Simple heuristics to avoid storing every trivial game on device
            guard game.startTime != nil else { return }
            guard game.currentRound > 3 else { return }
            guard game.historicNumberCount - game.numbersRemaining() > 20 else { return }
        }

        var snapshots = restoreOrderedGameSnapshots()
        let currentSnapshot = GameSnapshot(game: game)

        // This ensures preference to the latest game in the case of equal scoring
        snapshots.insert(currentSnapshot, at: 0)
        let orderedSnapshots = RankingService.order(snapshots)

        let orderedSnapshotsData = NSKeyedArchiver.archivedData(withRootObject: orderedSnapshots)
        let defaults = UserDefaults.standard
        defaults.set(orderedSnapshotsData,
                           forKey: StorageKey.orderedGameSnapshots.rawValue)
        RankingService.singleton.orderedGameSnapshots = orderedSnapshots
    }

    class func toggleFeatureAnnouncementFlag(_ feature: StorageKey.FeatureAnnouncement) -> Bool {
        let shouldShow = !hasSeenFeatureAnnouncement(feature)
        markFeatureAnnouncementSeen(feature)
        return shouldShow
    }

    class func toggleFlag(forSetting setting: StorageKey.SettingsFlag) {
        let defaults = UserDefaults.standard
        defaults.set(!currentFlag(forSetting: setting), forKey: setting.rawValue)
    }

    class func currentFlag(forSetting setting: StorageKey.SettingsFlag) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: setting.rawValue)
    }

    class func hasSeenFeatureAnnouncement(_ featureAnnouncement: StorageKey.FeatureAnnouncement) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: featureAnnouncement.rawValue)
    }

    class func markFeatureAnnouncementSeen(_ featureAnnouncement: StorageKey.FeatureAnnouncement) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: featureAnnouncement.rawValue)
    }
}
