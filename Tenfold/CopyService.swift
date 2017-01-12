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
    case motivational
    case lastNumberInstance
    case appInfo
}

class CopyService {
    static var singleton: CopyService? = nil

    let phrasebooks: [Phrasebook: MaybeRemoteJSON] = [
        .motivational: CopyService.makePhrasebook(fromRemoteFileName: "motivational-phrases",
                                                  withBackupFileName: "motivationalPhrases"),
        .lastNumberInstance: CopyService.makePhrasebook(fromRemoteFileName: "last-number-instance",
                                                        withBackupFileName: "lastNumberInstance"),
        .appInfo: CopyService.makePhrasebook(fromRemoteFileName: "app-info",
                                             withBackupFileName: "appInfo")
    ]

    class func url(_ jsonFileName: String) -> String {
        return "http://tenfoldapp.com/api/\(jsonFileName).json"
    }

    class func makePhrasebook(fromRemoteFileName remoteFileName: String,
                              withBackupFileName backupFileName: String) -> MaybeRemoteJSON {
        return MaybeRemoteJSON(fromUrl: "http://tenfoldapp.com/api/\(remoteFileName).json",
                               withBackupFile: backupFileName)
    }

    class func phrasebook(_ phrasebook: Phrasebook) -> JSON {
        return (singleton?.phrasebooks[phrasebook]!.data!)!
    }
}
