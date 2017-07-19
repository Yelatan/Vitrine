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
    var cityId: String?
    
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
        cityId <- map["_cityId"]
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
    
    
//    static func fromJSONArray(_ JSON: AnyObject) -> [News] {
//        var news = [News]()
//        var news2 = [News]()
//        var count = 0        
//        if JSON.count != 0 {
//            for item in JSON as! NSArray {
//                let n = Mapper<News>().map(item as? AnyObject)!
//                news.append(n)
//                if news[count].cityId != nil {
//                    let vitrineCityId = news[count].cityId!
//                    if GlobalConstants.Person.CityID != nil {
//                        let cityIdd = GlobalConstants.Person.CityID!
//                        if vitrineCityId == "\(cityIdd)"{
//                            news2.append(n)
//                        }
//                    }
//                }
//                count += 1
//            }
//        }
//        return news2
//    }
}
