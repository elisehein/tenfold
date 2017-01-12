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

        let URL = Foundation.URL(string: urlString)!
        let URLRequest = NSMutableURLRequest(url: URL)
        URLRequest.cachePolicy = .reloadIgnoringCacheData

        Alamofire.request(urlString).responseJSON { response in
            guard response.result.value != nil else { return }
            guard response.response?.statusCode == 200 else { return }

            if let responseData = response.result.value as? Data {
                self.data = JSON(data: responseData)
            }
        }
    }
}
