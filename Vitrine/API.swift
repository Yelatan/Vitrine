//
//  API.swift
//  Vitrinne
//
//  Created by Bakbergen on 4/13/17.
//  Copyright © 2017 Bakbergen. All rights reserved.
//

import Foundation
import Alamofire

class API {
    
    static func imageURL(_ prefix: String, string: String) -> URL {
        print("\(GlobalConstants.baseURL)/uploads/\(prefix)/2x/\(string)")
        return URL(string: "\(GlobalConstants.baseURL)/uploads/\(prefix)/2x/\(string)")!
    }
    
    static func jsonFromDict(_ d: [String: AnyObject]) -> String! {
        do {
            if(!d.isEmpty) {
                let find = try String(data: JSONSerialization.data(withJSONObject: d, options: JSONSerialization.WritingOptions(rawValue: 0)),
                                      encoding: String.Encoding.utf8)                
                return find!
            } else {
                return nil
            }
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}

class VitrineParams : CustomStringConvertible {
    var params = [String:String]()
    var find = [String:AnyObject]()
    
    func searchParams(_ p: ProductSearchParams) {
        
        if !p.method.value.isEmpty {
            self.main("sort", value: p.method.value)
        }
        
        if let v = p.text {
            if !v.isEmpty {
                //                self.find("search", value: v)
                self.find["search"] = v as AnyObject
            }
        }
        
        if let v = p.category {
            if !v.id.isEmpty {
                //                self.find("_categories", value: v.id)
                self.find["_categories"] = v.id as AnyObject
                
            }
        }
        
        if let v = p.brand {
            if !v.id.isEmpty {
                //                self.find("_brandId", value: v.id)
                self.find["_brandId"] = v.id as AnyObject
            }
        }
        
        if let v = p.priceRange {
            var values = [String: String]()
            
            if v.from != "Ниже" {
                values["$gte"] = v.from
            }
            if v.to != "И выше" {
                values["$lte"] = v.to
            }
            if !values.isEmpty {
                //                self.find("price", value: values)
                self.find["price"] = values as AnyObject
            }
        }
        
        if p.sale {
            //            self.find("discount", value: ["$gt": 0])
            self.find["discount"] = ["$gt": 0] as AnyObject
        }
    }
    
    func main(_ key: String, value: String) {
        params[key] = value
    }
    
    func find(_ key: String, value: AnyObject) {
        find[key] = value
    }
    
    func get() -> [String:String]{
        if(!find.isEmpty) {
            params["find"] = API.jsonFromDict(find)
        }
        return params as! [String:String]
    }
    
    var description: String {
        return String(describing: self.get())
    }
}
