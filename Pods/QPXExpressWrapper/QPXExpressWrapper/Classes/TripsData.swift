//
//  TripsData.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripsData: Decodable {
    
    public let kind: String?
    public let airport: [TripsDataAirport]?
    public let city: [TripsDataCity]?
    public let aircraft: [TripsDataAircraft]?
    public let tax: [TripsDataTax]?
    public let carrier: [TripsDataCarrier]?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        self.kind = kind
        
        if let airportJSON = json["airport"] as? [JSON],
            let airport = [TripsDataAirport].from(jsonArray: airportJSON) {
            self.airport = airport
        }
        else {
            self.airport = nil
        }
        
        if let cityJSON = json["city"] as? [JSON],
            let city = [TripsDataCity].from(jsonArray: cityJSON) {
            self.city = city
        }
        else {
            self.city = nil
        }
        
        if let aircraftJSON = json["aircraft"] as? [JSON],
            let aircraft = [TripsDataAircraft].from(jsonArray: aircraftJSON) {
            self.aircraft = aircraft
        }
        else {
            self.aircraft = nil
        }
        
        if let taxJSON = json["tax"] as? [JSON],
            let tax = [TripsDataTax].from(jsonArray: taxJSON) {
            self.tax = tax
        }
        else {
            self.tax = nil
        }
        
        if let carrierJSON = json["carrier"] as? [JSON],
            let carrier = [TripsDataCarrier].from(jsonArray: carrierJSON) {
            self.carrier = carrier
        }
        else {
            self.carrier = nil
        }
    }

}
