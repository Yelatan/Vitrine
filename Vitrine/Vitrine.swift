//
//  Vitrine.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/1/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import CoreLocation

class Vitrine: Mappable, MapObject {
    var locManager = CLLocationManager()
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
    var vitriness = [Vitrine]()
    var courdDouble = [Double]()
    
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
        vitriness <- map["_vitrines"]
        
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [Vitrine] {
        var vitrines = [Vitrine]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let v = Mapper<Vitrine>().map(item as AnyObject)!
                
                vitrines.append(v)
                v.distance = (v.calcDistance((v.coordinates)))
            }
        }
        return vitrines
    }
    
    static func fromJSONArray(_ JSON: AnyObject, withLocation loc: [Double]) -> [Vitrine] {
        
        
        var vitrines = [Vitrine]()
        if JSON.count > 0 {
            for item in JSON as! NSDictionary {
                let v = Mapper<Vitrine>().map(item as AnyObject)
                
                v?.distance = (v!.calcDistance((v?.coordinates)!))
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
    
    
    func calcDistance(_ location: [Double]) -> Double {
        if !location.isEmpty {
            

            let locValue:CLLocationCoordinate2D = locManager.location!.coordinate
            let locDouble = [locValue.latitude, locValue.longitude]

            
            let coordinate1 = CLLocation(latitude: location[1], longitude: location[0])
            let coordinate2 = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            let distanceInMeters = coordinate1.distance(from: coordinate2) as Double
            self.courdDouble.append(distanceInMeters/1000)
            return distanceInMeters/1000            
            
        } else {
            self.courdDouble.append(-1.0)
            return -1.0
        }
    }
}
