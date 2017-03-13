//
//  Flight.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOptionSliceSegmentFlight: Decodable {
    
    public let carrier: String?
    public let number: String?
    
    public init?(json: JSON) {
        self.number = "number" <~~ json
        self.carrier = "carrier" <~~ json
    }
    
}

extension TripOptionSliceSegmentFlight: Equatable {}

public func ==(lhs: TripOptionSliceSegmentFlight, rhs: TripOptionSliceSegmentFlight) -> Bool {
    return lhs.carrier == rhs.carrier &&
        lhs.number == rhs.number
}
