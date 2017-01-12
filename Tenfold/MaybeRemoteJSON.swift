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

    // This has to be retained, otherwise it's gone by the time
    // the callback executes, resulting in a cancelled request.
    var sessionManager: SessionManager?

    init(fromUrl urlString: String, withBackupFile fileName: String) {
        data = JSON.initFromFile(fileName)

        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        sessionManager = Alamofire.SessionManager(configuration: configuration)

        sessionManager!.request(urlString).responseJSON { response in
            guard response.result.value != nil else { return }
            guard response.response?.statusCode == 200 else { return }

            if let responseData = response.result.value {
                self.data = JSON(responseData)
            }
        }
    }
}
