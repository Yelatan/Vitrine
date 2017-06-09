//
//  Vitrine.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/1/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation

class Vitrine: Mappable, MapObject {
    var id: String = ""
    var name: String = ""
    var address: String = ""
    var disabled: Bool = false
    var photos = [String]()
    var phones = [String]()
    var cityId: String?
    var mallId: String?
    var coordinates = [Double]()
    
    var networkId: String?
    var networkLogo: String?
    var networkName: String?
    var networkDescription: String?
    var distance = -1.0
    var whatVitrine = ""
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        id <- map["_id"]
        name <- map["name"]
        address <- map["address"]
        coordinates <- map["coordinates"]
        disabled <- map["disabled"]
        photos <- map["photos"]
        phones <- map["phones"]

        cityId <- map["_cityId"]
        mallId <- map["_mallId"]
        coordinates <- map["coordinates"]
        
        networkId <- map["_networkId._id"]
        networkLogo <- map["_networkId.logo"]
        networkLogo <- map["logo"]
        networkName <- map["_networkId.name"]
        networkDescription <- map["_networkId.description"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [Vitrine] {
        var vitrines = [Vitrine]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let v = Mapper<Vitrine>().map(item as AnyObject)!
                vitrines.append(v)
            }
        }
        return vitrines
    }
    
    static func fromJSONArray(_ JSON: AnyObject, withLocation loc: [Double]) -> [Vitrine] {
        var vitrines = [Vitrine]()
        if JSON.count > 0 {
            for item in JSON as! NSDictionary {
                let v = Mapper<Vitrine>().map(item as AnyObject)
                v?.distance = (v!.calcDistance(loc))
                if v != nil {
                    vitrines.append(v!)
                }else{
                }
            }
        }
        return vitrines
    }
    
    static func fromJSONArrayDict(_ JSON: AnyObject, withLocation loc: [Double]) -> [Vitrine] {
        var vitrines = [Vitrine]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let v = Mapper<Vitrine>().map(item as AnyObject)
                v?.distance = (v!.calcDistance(loc))
                if v != nil {
                    vitrines.append(v!)
                }else{
                }
            }
        }
        return vitrines
    }
    
    
    func calcDistance(_ location: [Double]) -> Double {
        if !location.isEmpty {
            let loc1 = CLLocation.init(latitude: location[1], longitude: location[0])
            let loc2 = CLLocation.init(latitude: self.coordinates[1], longitude: self.coordinates[0])
            return loc1.distance(from: loc2)/1000
        } else {
            return -1.0
        }
    }
}
