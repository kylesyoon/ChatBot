//
//  TripOptionPricingSegment.swift
//  Flights
//
//  Created by Kyle Yoon on 3/5/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOptionPricingSegment: Decodable {
    
    public let kind: String
    public let fareID: String?
    public let segmentID: String?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        
        self.kind = kind
        self.fareID = "fareId" <~~ json
        self.segmentID = "segmentId" <~~ json
    }
    
}

extension TripOptionPricingSegment: Equatable {}

public func ==(lhs: TripOptionPricingSegment, rhs: TripOptionPricingSegment) -> Bool {
    return lhs.kind == rhs.kind &&
        lhs.fareID == rhs.fareID &&
        lhs.segmentID == rhs.segmentID
}
