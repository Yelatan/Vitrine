//
//  ProductCategory.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/1/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation


class ProductCategory: Mappable {
    var id: String = ""
    var parentId: String = ""
    var name: String = ""
    var logo: String?
    var parentBack: Bool
    var parentAll: Bool
    
    required init?(_ map: Map) {
        parentBack = false
        parentAll = false
    }
    
    init(withName name: String) {
        self.name = name
        parentBack = false
        parentAll = false
    }
    
    func mapping(_ map: Map) {
        id <- map["_id"]
        parentId <- map["_parentId"]
        name <- map["name"]
        logo <- map["logo"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [ProductCategory] {
        var categories = [ProductCategory]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                categories.append(Mapper<ProductCategory>().map(item as AnyObject)!)
            }
        }        
        return categories
    }
}
