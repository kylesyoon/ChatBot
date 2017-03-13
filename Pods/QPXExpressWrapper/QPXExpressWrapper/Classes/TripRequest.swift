//
//  TripRequest.swift
//  Flights
//
//  Created by Kyle Yoon on 2/22/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripRequest: Decodable, Encodable {

    public let passengers: TripRequestPassengers
    public let slice: [TripRequestSlice]
    public let maxPrice: String?
    public let saleCountry: String?
    public let refundable: Bool?
    public let solutions: Int?
    
    public init(passengers: TripRequestPassengers,
                slice: [TripRequestSlice],
                maxPrice: String?,
                saleCountry: String?,
                refundable: Bool?,
                solutions: Int?) {
        self.passengers = passengers
        self.slice = slice
        self.maxPrice = maxPrice
        self.saleCountry = saleCountry
        self.refundable = refundable
        self.solutions = solutions
    }
    
    public init?(json: JSON) {
        guard let passengers: TripRequestPassengers = "passengers" <~~ json,
            let sliceJSON = json["slice"] as? [JSON],
            let slice = [TripRequestSlice].from(jsonArray: sliceJSON) else {
            return nil
        }
        self.passengers = passengers
        self.slice = slice
        self.maxPrice = "maxPrice" <~~ json
        self.saleCountry = "saleCountry" <~~ json
        self.refundable = "refundable" <~~ json
        self.solutions = "solutions" <~~ json
    }
    
    public func toJSON() -> JSON? {
        guard
            let sliceJSON = self.slice.toJSONArray(),
            let json = jsonify([
                "passengers" ~~> self.passengers,
                "slice" ~~> sliceJSON,
                "maxPrice" ~~> self.maxPrice,
                "saleCountry" ~~> self.saleCountry,
                "refundable" ~~> self.refundable,
                "solutions" ~~> self.solutions
                ]) else {
                    return nil
        }
        return ["request": json]
    }

}
