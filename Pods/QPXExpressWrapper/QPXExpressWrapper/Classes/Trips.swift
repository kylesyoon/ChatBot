//
//  Trips.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct Trips: Decodable {
    
    public let kind: String
    public let requestID: String?
    public let data: TripsData?
    public let tripOptions: [TripOption]?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        
        self.kind = kind
        self.requestID = "requestId" <~~ json
        self.data = "data" <~~ json
        if let tripOptionJSON = json["tripOption"] as? [JSON],
            let tripOptions = [TripOption].from(jsonArray: tripOptionJSON) {
            self.tripOptions = tripOptions
        }
        else {
            self.tripOptions = nil
        }
        
    }

}
