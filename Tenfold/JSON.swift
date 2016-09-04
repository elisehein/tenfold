//
//  JSON.swift
//  Tenfold
//
//  Created by Elise Hein on 28/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

extension JSON {
    static func initFromFile(fileName: String) -> JSON? {
        var data: JSON?

        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                data = JSON(data: jsonData)
            } catch {
                print("Error retrieving JSON data")
            }
        }

        return data!
    }
}
