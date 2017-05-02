//
//  Mall.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/2/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import CoreLocation


class Mall: Mappable, MapObject {
    var id: String = ""
    var name: String = ""
    var address: String!
    var description: String?
    var photos = [String]()
    var logo: String?
    var coordinates = [Double]()
    var disabled = false
    var distance = -1.0
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(_ map: Map) {
        id <- map["_id"]
        name <- map["name"]
        address <- map["address"]
        description <- map["description"]
        photos <- map["photos"]
        logo <- map["logo"]
        disabled <- map["disabled"]
//        coordinates <- map["coordinates"]
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [Mall] {
        var malls = [Mall]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                malls.append(Mapper<Mall>().map(item as AnyObject)!)
            }
        }
        
        return malls
    }
    
    static func fromJSONArray(_ JSON: AnyObject, withLocation loc: [Double]) -> [Mall] {
        var malls = [Mall]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let m: Mall = Mapper<Mall>().map(item as AnyObject)!
                print(loc)
                m.distance = m.calcDistance(loc)
                malls.append(m)
            }
        }
        return malls
    }
    
    func calcDistance(_ location: [Double]) -> Double {
        //didn't fix
//        if !location.isEmpty {
//                let loc1 = CLLocation.init(latitude: location[1], longitude: location[0])
//                let loc2 = CLLocation.init(latitude: self.coordinates[1], longitude: self.coordinates[0])
//                return loc1.distance(from: loc2)/1000
//            return 10
//        }else {
//            return -1.0
//        }
        return 10
    }
}
