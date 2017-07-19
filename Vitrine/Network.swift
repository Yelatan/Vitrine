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
        var networks2 = [Network]()
        var count = 0
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let n = Mapper<Network>().map(item as? AnyObject)!
                networks.append(n)
                if !n.vitrines.isEmpty{
                    if networks[count].vitrines[0].cityId != nil {
                        let vitrineCityId = networks[count].vitrines[0].cityId!
                        let cityIdd = GlobalConstants.Person.CityID!
                        if vitrineCityId == "\(cityIdd)"{
                            networks2.append(n)
                        }
                    }
                }
                count += 1
            }
        }
        return networks2
    }
    
    static func fromJSONArrayDis(_ JSON: AnyObject) -> [Network] {
        var count = 0
        var networks = [Network]()
        var networks1 = [Network]()
        var networks2 = [Network]()
        var distanceCal = [Double]()
        var distanceCal3 = [Double]()
        if JSON.count > 0 {
            for item in JSON as! NSArray {
                let n = Mapper<Network>().map(item as? AnyObject)!
                networks1.append(n)
                if !n.vitrines.isEmpty{
                    let coordin = networks1[count].vitrines[0].calcDistance(networks1[count].vitrines[0].coordinates)
                    let vitrineCityId = networks1[count].vitrines[0].cityId!
                    let cityIdd = GlobalConstants.Person.CityID!
                    if vitrineCityId == "\(cityIdd)"{
                        networks2.append(n)
                        distanceCal.append(coordin)
                    }
                }
                count += 1
            }
            let sortedDistanceArray = NSMutableArray(array: distanceCal)
            let sortedMallsArray = NSMutableArray(array: networks2)
            
            var sortedAboveIndex = distanceCal.count
            var swaps = 0
            repeat {
                var lastSwapIndex = 0
                
                if sortedAboveIndex > 1 {
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
            networks = sortedMallsArray as! Array
        }
        return networks
    }
}
