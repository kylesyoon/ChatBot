//
//  TripOption.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOption: Decodable {
    
    public let kind: String
    public let saleTotal: String?
    public let identifier: String?
    public let slice: [TripOptionSlice]?
    public let pricing: [TripOptionPricing]?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        
        self.kind = kind
        self.saleTotal = "saleTotal" <~~ json
        self.identifier = "id" <~~ json
        if let jsonSlice = json["slice"] as? [JSON],
            let slice = [TripOptionSlice].from(jsonArray: jsonSlice) {
            self.slice = slice
        }
        else {
            self.slice = nil
        }
        
        if let jsonPricing = json["pricing"] as? [JSON],
            let pricing = [TripOptionPricing].from(jsonArray: jsonPricing) {
            self.pricing = pricing
        }
        else {
            self.pricing = nil
        }
    }
    
}
