//
//  TripsDataAirport.swift
//  Flights
//
//  Created by Kyle Yoon on 3/5/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripsDataAirport: Decodable {
    
    public let kind: String?
    public let code: String?
    public let city: String?
    public let name: String?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        self.kind = kind
        self.code = "code" <~~ json
        self.city = "city" <~~ json
        self.name = "name" <~~ json
    }
    
}

//TODO: Equatable protocol

extension TripsDataAirport: Equatable {}

public func ==(lhs: TripsDataAirport, rhs: TripsDataAirport) -> Bool {
    return lhs.kind == rhs.kind &&
        lhs.code == rhs.code &&
        lhs.city == rhs.city &&
        lhs.name == rhs.name
}
