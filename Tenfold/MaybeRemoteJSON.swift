//
//  MaybeRemoteJSON.swift
//  Tenfold
//
//  Created by Elise Hein on 04/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class MaybeRemoteJSON {

    var data: JSON?

    init(fromUrl urlString: String, withBackupFile fileName: String) {
        data = JSON.initFromFile(fileName)

        let URL = NSURL(string: urlString)!
        let URLRequest = NSMutableURLRequest(URL: URL)
        URLRequest.cachePolicy = .ReloadIgnoringCacheData

        Alamofire.request(URLRequest).response { request, response, remoteData, error in
                guard error == nil else { return }
                guard remoteData != nil else { return }
                guard response?.statusCode == 200 else { return }

                self.data = JSON(data: remoteData!)
        }
    }
}
