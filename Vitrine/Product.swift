//
//  Product.swift
//  Vitrine
//
//  Created by Viktor Ten on 2/26/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation


class Product: Mappable {
    var id: String!
    var name: String!
    var price: Float?
    var priceDiscount: Float?
    var discount: Float?
    var discountTill: Date?
    var discountType: String?
    var photos = [String]()
    var description = ""
    
    var networkId: String?
    var networkName: String?
    var brandName: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        id <- map["_id"]
        name <- map["name"]
        price <- map["price"]
        priceDiscount <- map["priceWithDiscount"]
        discount <- map["discount"]
        discountTill <- (map["discountTill"], ISODateTransform())
        discountType <- map["discountType"]
        photos <- map["photos"]
        description <- map["description"]
        
        networkId <- map["_networkId._id"]
        networkName <- map["_networkId.name"]
        brandName <- map["_brandId.name"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [Product] {
        var products = [Product]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                products.append(Mapper<Product>().map(item as AnyObject)!)
            }
        }
        
        return products
    }
}
