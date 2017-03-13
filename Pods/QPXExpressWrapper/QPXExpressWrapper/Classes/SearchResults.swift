//
//  SearchData.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct SearchResults: Decodable {
    
    public static let dateFormatter = DateFormatter()
    public let kind: String
    public let trips: Trips?
    
    // Only setable within this class
    fileprivate(set) public var isRoundTrip: Bool = true
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        self.kind = kind
        self.trips = "trips" <~~ json
    }
    
}

extension DateFormatter {
    
    func decodedDate(for dateString: String) -> Date? {
        self.dateFormat = "yyyy-MM-dd'T'HH:mmZZZZZ" //"2016-02-19T17:35-08:00"
        return self.date(from: dateString)
    }
    
}
