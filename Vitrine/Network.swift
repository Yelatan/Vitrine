//
//  Network.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/2/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation


class Network: Mappable {
    var id: String = ""
    var name: String = ""
    var description: String?
    var photos = [String]()
    var logo: String?
    var phones = [String]()
    var disabled = false
    
    var ownerId: String?
    var brands = [String]()
    var categories = [String]()
    var vitrines = [Vitrine]()
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        id <- map["_id"]
        name <- map["name"]
        description <- map["description"]
        photos <- map["photos"]
        logo <- map["logo"]
        disabled <- map["disabled"]
        phones <- map["phones"]
        
        brands <- map["_brands"]
        categories <- map["_categories"]
        ownerId <- map["_ownerId"]
        vitrines <- map["_vitrines"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [Network] {
        var networks = [Network]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let n = Mapper<Network>().map(item as? AnyObject)!
                networks.append(n)                
            }
        }
        return networks
    }
}
