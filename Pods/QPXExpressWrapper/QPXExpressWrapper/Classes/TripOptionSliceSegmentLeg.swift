//
//  TripOptionSliceLeg.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOptionSliceSegmentLeg: Decodable {
    
    public let kind: String
    public let identifier: String?
    public let aircraft: String?
    public let arrivalTime: Date? // TODO: We have to show the local time of that location.
    public let departureTime: Date? // TODO: We have to show the local time of that location.
    public let origin: String?
    public let destination: String?
    public let originTerminal: String?
    public let destinationTerminal: String?
    public let duration: Int?
    public let onTimePerformance: Int?
    public let operatingDisclosure: String?
    public let mileage: Int?
    public let meal: String?
    public let secure: Bool?
    public let connectionDuration: Int?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        self.kind = kind
        self.identifier = "id" <~~ json
        self.aircraft = "aircraft" <~~ json
        if let arrivalTimeString: String = "arrivalTime" <~~ json {
            self.arrivalTime = SearchResults.dateFormatter.decodedDate(for: arrivalTimeString)
        }
        else {
            self.arrivalTime = nil
        }
        
        if let departureTimeString: String = "departureTime" <~~ json {
            self.departureTime = SearchResults.dateFormatter.decodedDate(for: departureTimeString)
        }
        else {
            self.departureTime = nil
        }
        self.origin = "origin" <~~ json
        self.destination = "destination" <~~ json
        self.originTerminal = "originTerminal" <~~ json
        self.destinationTerminal = "destinationTerminal" <~~ json
        self.duration = "duration" <~~ json
        self.onTimePerformance = "onTimePerformance" <~~ json
        self.operatingDisclosure = "operatingDisclosure" <~~ json
        self.mileage = "mileage" <~~ json
        self.meal = "meal" <~~ json
        self.secure = "secure" <~~ json
        self.connectionDuration = "connectionDuration" <~~ json
    }

}

extension TripOptionSliceSegmentLeg: Equatable {}

public func ==(lhs: TripOptionSliceSegmentLeg, rhs: TripOptionSliceSegmentLeg) -> Bool {
    return lhs.kind == rhs.kind &&
        lhs.identifier == rhs.identifier &&
        lhs.aircraft == rhs.aircraft && 
        (lhs.arrivalTime == rhs.arrivalTime) && 
        (lhs.departureTime == rhs.departureTime) && 
        lhs.origin == rhs.origin && 
        lhs.destination == rhs.destination && 
        lhs.originTerminal == rhs.originTerminal &&
        lhs.destinationTerminal == rhs.destinationTerminal && 
        lhs.duration == rhs.duration && 
        lhs.mileage == rhs.mileage &&
        lhs.meal == rhs.meal &&
        lhs.secure == rhs.secure &&
        lhs.onTimePerformance == rhs.onTimePerformance &&
        lhs.operatingDisclosure == rhs.operatingDisclosure &&
        lhs.connectionDuration == rhs.connectionDuration
}
