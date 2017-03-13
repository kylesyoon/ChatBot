//
//  TripRequestPassengers.swift
//  Flights
//
//  Created by Kyle Yoon on 3/1/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripRequestPassengers: Decodable, Encodable {
    
    public let kind: String = "qpxexpress#passengerCounts"
    public var adultCount: Int
    public var childCount: Int?
    public var infantInLapCount: Int?
    public var infantInSeatCount: Int?
    public var seniorCount: Int?
    
    public init(adultCount: Int,
                childCount: Int?,
                infantInLapCount: Int?,
                infantInSeatCount: Int?,
                seniorCount: Int?) {
        self.adultCount = adultCount
        self.childCount = childCount
        self.infantInLapCount = infantInLapCount
        self.infantInSeatCount = infantInSeatCount
        self.seniorCount = seniorCount
    }
    
    public init?(json: JSON) {
        guard let adultCount: Int = "adultCount" <~~ json else {
            return nil
        }
        self.adultCount = adultCount
        self.childCount = "childCount" <~~ json
        self.infantInLapCount = "infantInLapCount" <~~ json
        self.infantInSeatCount = "infantInSeatCount" <~~ json
        self.seniorCount = "seniorCount" <~~ json
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "kind" ~~> self.kind,
            "adultCount" ~~> self.adultCount,
            "childCount" ~~> self.childCount,
            "infantInLapCount" ~~> self.infantInLapCount,
            "infantInSeatCount" ~~> self.infantInSeatCount,
            "seniorCount" ~~> self.seniorCount
            ])
    }
    
}

extension TripRequestPassengers: Equatable {}

public func ==(lhs: TripRequestPassengers, rhs: TripRequestPassengers) -> Bool {
    if lhs.adultCount != rhs.adultCount {
        return false
    }

    if lhs.childCount != rhs.adultCount {
        return false
    }
    
    if lhs.infantInLapCount != rhs.infantInLapCount {
        return false
    }
    
    if lhs.infantInSeatCount != rhs.infantInSeatCount {
        return false
    }
    
    if lhs.seniorCount != rhs.seniorCount {
        return false
    }
    
    return true
}
