//
//  Brand.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/2/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation

class Brand: Mappable {
    var id: String = ""
    var name: String = ""
    var logo: String?
    
    required init?(_ map: Map) {
        
    }
    
    init(withName name: String) {
        self.name = name
    }
    
    func mapping(_ map: Map) {
        id <- map["_id"]
        name <- map["name"]
        logo <- map["logo"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [Brand] {
        var brands = [Brand]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                brands.append(Mapper<Brand>().map(item as AnyObject)!)
            }
        }
        
        return brands
    }
}
