//
//  StorageService.swift
//  Numbers
//
//  Created by Elise Hein on 26/06/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation

class StorageService {

    private static let gameStorageKey = "singularFieldsGameStorageKey"

    class func saveGame (game: Game) {
        let gameData = NSKeyedArchiver.archivedDataWithRootObject(game)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(gameData, forKey: StorageService.gameStorageKey)
    }

    class func restoreGame () -> Game? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let gameData = defaults.objectForKey(StorageService.gameStorageKey)

        if let gameData = gameData as? NSData {
            let game = NSKeyedUnarchiver.unarchiveObjectWithData(gameData)
            return game as? Game
        } else {
            return nil
        }
    }
}
