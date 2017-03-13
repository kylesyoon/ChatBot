//
//  TripOptionPricingFare.swift
//  Flights
//
//  Created by Kyle Yoon on 3/5/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOptionPricingFare: Decodable {
    
    public let kind: String
    public let identifier: String?
    public let carrier: String?
    public let origin: String?
    public let destination: String?
    public let basisCode: String?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        
        self.kind = kind
        self.identifier = "id" <~~ json
        self.carrier = "carrier" <~~ json
        self.origin = "origin" <~~ json
        self.destination = "destination" <~~ json
        self.basisCode = "basisCode" <~~ json
    }

}

extension TripOptionPricingFare: Equatable {}

public func ==(lhs: TripOptionPricingFare, rhs: TripOptionPricingFare) -> Bool {
    return lhs.kind == rhs.kind &&
        lhs.identifier == rhs.identifier &&
        lhs.carrier == rhs.carrier &&
        lhs.origin == rhs.origin &&
        lhs.destination == rhs.destination &&
        lhs.basisCode == rhs.basisCode
}
