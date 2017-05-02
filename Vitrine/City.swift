//
//  City.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/24/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation

class City: Mappable {
    var id: String = ""
    var name: String = ""
    var coordinates: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        id <- map["_id"]
        name <- map["name"]
        coordinates <- map["coordinates"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [City] {
        var cities = [City]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
//                cities.append(Mapper<City>().map())
                cities.append(Mapper<City>().map(item as? AnyObject)!)
                
            }
        }
        
        return cities
    }
}
