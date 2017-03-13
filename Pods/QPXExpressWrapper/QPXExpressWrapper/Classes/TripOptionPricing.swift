//
//  TripOptionPricing.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOptionPricing: Decodable {
    
    public let kind: String
    public let fare: [TripOptionPricingFare]?
    public let segmentPricing: [TripOptionPricingSegment]?
    public let baseFareTotal: String?
    public let saleFareTotal: String?
    public let saleTotal: String?
    public let passengers: TripRequestPassengers?
    public let tax: [TripOptionPricingTax]?
    public let fareCalculation: String?
    public let latestTicketingTime: Date?
    public let ptc: String?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        self.kind = kind
        
        if let jsonFare = json["fare"] as? [JSON],
            let fare = [TripOptionPricingFare].from(jsonArray: jsonFare) {
            self.fare = fare
        }
        else {
            self.fare = nil
        }
        
        if let jsonSegmentPricing = json["segmentPricing"] as? [JSON],
            let segmentPricing = [TripOptionPricingSegment].from(jsonArray: jsonSegmentPricing) {
            self.segmentPricing = segmentPricing
        }
        else {
            self.segmentPricing = nil
        }
        
        self.baseFareTotal = "baseFareTotal" <~~ json
        self.saleFareTotal = "saleFareTotal" <~~ json
        self.saleTotal = "saleTotal" <~~ json
        self.passengers = "passengers" <~~ json
        
        if let jsonTax = json["tax"] as? [JSON],
            let tax = [TripOptionPricingTax].from(jsonArray: jsonTax) {
            self.tax = tax
        }
        else {
            self.tax = nil
        }
        
        self.fareCalculation = "fareCalculation" <~~ json
        if let latestTicketingTime: String = "latestTicketingTime" <~~ json {
            self.latestTicketingTime = SearchResults.dateFormatter.decodedDate(for: latestTicketingTime)
        }
        else {
            self.latestTicketingTime = nil
        }
        self.ptc = "ptc" <~~ json
    }

}
