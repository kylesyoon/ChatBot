//
//  NSDateFormatter+Extension.swift
//  Flights
//
//  Created by Kyle Yoon on 2/14/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation

let dateFormatter = DateFormatter()

extension DateFormatter {
    
    func decode(dateString: String) -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZZZ" //"2016-02-19T17:35-08:00"
        return dateFormatter.date(from: dateString)
    }
    
    func presentableDate(fromDate date: Date) -> String {
        dateFormatter.dateFormat = "MMM'.' dd',' yy"
        return dateFormatter.string(from: date)
    }
    
    func presentableTime(fromDate date: Date) -> String {
        let usTwelveHourLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = usTwelveHourLocale // Investigate what this locale does
        dateFormatter.dateFormat = "hh':'mm a"
        return dateFormatter.string(from: date)
    }
    
}
