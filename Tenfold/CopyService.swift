//
//  CopyService.swift
//  Tenfold
//
//  Created by Elise Hein on 04/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import SwiftyJSON

enum Phrasebook {
    case Motivational
    case LastNumberInstance
    case AppInfo
}

class CopyService {
    static var singleton: CopyService? = nil

    let phrasebooks: [Phrasebook: MaybeRemoteJSON] = [
        .Motivational: CopyService.makePhrasebook(fromRemoteFileName: "motivational-phrases",
                                                  withBackupFileName: "motivationalPhrases"),
        .LastNumberInstance: CopyService.makePhrasebook(fromRemoteFileName: "last-number-instance",
                                                        withBackupFileName: "lastNumberInstance"),
        .AppInfo: CopyService.makePhrasebook(fromRemoteFileName: "app-info",
                                             withBackupFileName: "appInfo")
    ]

    class func url(jsonFileName: String) -> String {
        return "http://tenfoldapp.com/api/\(jsonFileName).json"
    }

    class func makePhrasebook(fromRemoteFileName remoteFileName: String,
                              withBackupFileName backupFileName: String) -> MaybeRemoteJSON {
        return MaybeRemoteJSON(fromUrl: "http://tenfoldapp.com/api/\(remoteFileName).json",
                               withBackupFile: backupFileName)
    }

    class func phrasebook(phrasebook: Phrasebook) -> JSON {
        return (singleton?.phrasebooks[phrasebook]!.data!)!
    }
}
