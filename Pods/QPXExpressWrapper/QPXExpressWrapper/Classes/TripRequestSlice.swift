//
//  TripRequestSlice.swift
//  Flights
//
//  Created by Kyle Yoon on 3/1/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripRequestSlice: Decodable, Encodable {
    
    public let kind: String = "qpxexpress#sliceInput"
    public let origin: String
    public let destination: String
    public let date: Date
    
    // Not using yet
//    public let maxStops: Int?
//    public let maxConnectionDuration: Int?
//    public let preferredCabin: String?
//    public let permittedDepartureTime: [String: String]?
//    public let permittedCarrier: [String]?
//    public let alliance: String?
//    public let prohibitedCarrier: [String]?
    
    public init(origin: String,
                destination: String,
                date: Date) {
        self.origin = origin
        self.destination = destination
        self.date = date
    }
    
    public init?(json: JSON) {
        guard let origin: String = "origin" <~~ json,
            let destination: String = "destination" <~~ json,
            let date: Date = "date" <~~ json else {
            return nil
        }
        self.origin = origin
        self.destination = destination
        self.date = date
    }

    public func toJSON() -> JSON? {
        let tripDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self.date)
        guard
            let year = tripDateComponents.year,
            let month = tripDateComponents.month,
            let day = tripDateComponents.day else {
                 return nil
        }
        let dateString = "\(year)-\(month)-\(day)"
        return jsonify([
            "kind" ~~> self.kind,
            "origin" ~~> self.origin,
            "destination" ~~> self.destination,
            "date" ~~> dateString
            ])
    }
    
}
