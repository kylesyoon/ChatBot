//
//  TripsDataCarrier.swift
//  Flights
//
//  Created by Kyle Yoon on 3/5/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripsDataCarrier: Decodable {
    
    public let kind: String?
    public let code: String?
    public let name: String?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        self.kind = kind
        self.code = "code" <~~ json
        self.name = "name" <~~ json
    }
    
}

extension TripsDataCarrier: Equatable {}

public func ==(lhs: TripsDataCarrier, rhs: TripsDataCarrier) -> Bool {
    return lhs.kind == rhs.kind &&
        lhs.code == rhs.code &&
        lhs.name == rhs.name
}
