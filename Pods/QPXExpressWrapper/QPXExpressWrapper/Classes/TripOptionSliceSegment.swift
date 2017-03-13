//
//  TripOptionSliceSegment.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOptionSliceSegment: Decodable {
    
    public let kind: String
    public let duration: Int?
    public let flight: TripOptionSliceSegmentFlight?
    public let identifier: String?
    public let cabin: String?
    public let bookingCode: String?
    public let bookingCodeCount: Int?
    public let marriedSegmentGroup: String?
    public let leg: [TripOptionSliceSegmentLeg]?
    public let connectionDuration: Int?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        
        self.kind = kind
        self.duration = "duration" <~~ json
        self.flight = "flight" <~~ json
        self.identifier = "id" <~~ json
        self.cabin = "cabin" <~~ json
        self.bookingCode = "bookingCode" <~~ json
        self.bookingCodeCount = "bookingCodeCount" <~~ json
        self.marriedSegmentGroup = "marriedSegmentGroup" <~~ json
        if let jsonLeg = json["leg"] as? [JSON],
            let leg = [TripOptionSliceSegmentLeg].from(jsonArray: jsonLeg) {
            self.leg = leg
        }
        else {
            self.leg = nil
        }
        self.connectionDuration = "connectionDuration" <~~ json
    }
    
}

extension TripOptionSliceSegment: Equatable {}

public func ==(lhs: TripOptionSliceSegment, rhs: TripOptionSliceSegment) -> Bool {
    return lhs.kind == rhs.kind &&
        lhs.duration! == rhs.duration! &&
        lhs.flight! == rhs.flight! &&
        lhs.identifier! == rhs.identifier! &&
        lhs.cabin! == rhs.cabin! &&
        lhs.bookingCode! == rhs.bookingCode! &&
        lhs.bookingCodeCount! == rhs.bookingCodeCount! &&
        lhs.marriedSegmentGroup! == rhs.marriedSegmentGroup! &&
        lhs.leg! == rhs.leg! &&
        lhs.connectionDuration! == rhs.connectionDuration!
}
