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
    var disnn = [Double]()
    
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
        coordinates <- map["coordinates"]
        
    }
    
    static func countDistance(distanes: [Double]) -> [Double]{
        return distanes
    }
    
    static func fromJSONArray(_ JSON: AnyObject) -> [Mall] {
        var malls = [Mall]()
        if JSON.count >= 0 {            
            for item in JSON as! NSArray {
                let asrs = item as! NSDictionary
                let cityIdd = GlobalConstants.Person.CityID!
                if ("\(cityIdd)" == "\(asrs["_cityId"]!)"){
                    malls.append(Mapper<Mall>().map(item as? AnyObject)!)
                }
            }
        }
        return malls
    }
    
    static func fromJSONArray(_ JSON: AnyObject, withLocation loc: [Double]) -> [Mall] {
        var malls = [Mall]()
        var malls3 = [Mall]()
        
        var distanceCal = [Double]()
        var distanceCal3 = [Double]()
        var count = 0
        
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let m = Mapper<Mall>().map(item as? AnyObject)!
                if !m.coordinates.isEmpty{
                    let asrs = item as! NSDictionary
                    let cityIdd = GlobalConstants.Person.CityID!
                    if ("\(cityIdd)" == "\(asrs["_cityId"]!)"){
                        malls3.append(m)
                        let coordinat = malls3[count].calcDistance(loc)
                        distanceCal.append(coordinat)
                        count += 1
                    }
                    
                }
            }
            self.countDistance(distanes: distanceCal)
            
            let sortedDistanceArray = NSMutableArray(array: distanceCal)
            let sortedMallsArray = NSMutableArray(array: malls3)
            
            var sortedAboveIndex = distanceCal.count
            var swaps = 0
            
            repeat {
                var lastSwapIndex = 0
                
                if sortedAboveIndex > 0 {
                    for i in 1..<sortedAboveIndex {
                        if (sortedDistanceArray[i - 1] as! Double) > (sortedDistanceArray[i] as! Double) {
                            
                            sortedDistanceArray.exchangeObject(at: i, withObjectAt: i-1)
                            sortedMallsArray.exchangeObject(at: i, withObjectAt: i-1)
                            
                            lastSwapIndex = i
                            swaps += 1
                        }
                    }
                }
                sortedAboveIndex = lastSwapIndex                
            } while (sortedAboveIndex != 0)
            malls = sortedMallsArray as! Array
        }
        return malls
    }
    
    public func calcDistance(_ location: [Double]) -> Double {
        if location.count > 0 && self.coordinates.count > 0{
            let loc1 = CLLocation.init(latitude: location[1], longitude: location[0])
            let loc2 = CLLocation.init(latitude: self.coordinates[1], longitude: self.coordinates[0])            
            return loc1.distance(from: loc2)/1000
        }else {
            return -1.0
        }
    }
}
