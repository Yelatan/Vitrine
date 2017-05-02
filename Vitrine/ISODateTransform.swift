//
//  ISODateTransform.swift
//  Vitrine
//
//  Created by viktorten on 3/14/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation

open class ISODateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = Double
    
    public init() {}
    
    open func transformFromJSON(_ value: AnyObject?) -> Date? {
        if let timeStr = value as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
            formatter.locale = Locale.current
            formatter.formatterBehavior = DateFormatter.Behavior.default
            return formatter.date(from: timeStr)
        }
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSince1970)
        }
        return nil
    }
}
