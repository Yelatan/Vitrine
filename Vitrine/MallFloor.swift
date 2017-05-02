//
//  Network.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/2/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation


class MallFloor: Mappable {
    var id: String = ""
    var name: String = ""
    var images = [String]()
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        id <- map["_id"]
        name <- map["name"]
        images <- map["images"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [MallFloor] {
        var floors = [MallFloor]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let n = Mapper<MallFloor>().map(item as AnyObject)!
                floors.append(n)
            }
        }
        
        return floors
    }
}
