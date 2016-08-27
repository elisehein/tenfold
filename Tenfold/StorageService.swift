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
    private static let soundPrefStorageKey = "tenfoldSoundPrefStorageKey"

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

    class func saveSoundPreference(soundOn: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(soundOn, forKey:StorageService.soundPrefStorageKey)
    }

    class func restoreSoundPreference() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let soundPref = defaults.boolForKey(StorageService.soundPrefStorageKey)
        return soundPref
    }
}
