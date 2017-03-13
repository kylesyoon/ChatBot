//
//  TripOptionSlice.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOptionSlice: Decodable {
    
    public let kind: String
    public let duration: Int?
    public let segment: [TripOptionSliceSegment]?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        
        self.kind = kind
        self.duration = "duration" <~~ json
        if let jsonSegment = json["segment"] as? [JSON],
            let segment = [TripOptionSliceSegment].from(jsonArray: jsonSegment) {
            self.segment = segment
        }
        else {
            self.segment = nil
        }
    }

}
