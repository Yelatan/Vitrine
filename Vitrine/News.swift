//
//  News.swift
//  Vitrine
//
//  Created by Viktor Ten on 2/26/16.
//  Copyright © 2016 Viktor Ten. All rights reserved.
//

import Foundation


class News: Mappable {
    var global: Bool = false
    var name: String = ""
    var text: String = ""
    var type: String = "news"
    var stockTill: Date?
    var disabled: Bool = false
    var photos = [String]()
    var createdAt: Date?
    
    var networkId: String?
    var networkName: String?
    var networkLogo: String?
    var vitrineAddress: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        global <- map["global"]
        name <- map["name"]
        text <- map["text"]
        type <- map["type"]
        stockTill <- (map["stockTill"], ISODateTransform())
        disabled <- map["disabled"]
        photos <- map["photos"]
        createdAt <- (map["createdAt"], ISODateTransform())
        
        networkId <- map["_networkId._id"]
        networkName <- map["_networkId.name"]
        networkLogo <- map["_networkId.logo"]
        vitrineAddress <- map["_vitrines.0.address"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [News] {
        var products = [News]()
        if (JSON.count != 0) {
            for item in JSON as! NSArray {
                products.append(Mapper<News>().map(item as AnyObject)!)
            }
        }
        
        return products
    }
}
