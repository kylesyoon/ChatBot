//
//  TripCell.swift
//  Flights
//
//  Created by Kyle Yoon on 2/29/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import UIKit
import QPXExpressWrapper

class TripCell: UITableViewCell {
    
    static let cellIdentifier = "TripCell"
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var airlineLogoImageView: UIImageView!
    @IBOutlet var flightTimeLabel: UILabel!
    @IBOutlet var airlineLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var layoverLabel: UILabel!
    
    internal func configure(with sourceFlight: FlightViewModel) {
        let tripOption = sourceFlight.tripOption
        let sliceIndex = sourceFlight.sliceIndex
        self.configurePrice(tripOption: tripOption)
        if let slices = tripOption.slice {
            self.configureFlightTimes(slice: slices[sliceIndex])
            self.configureCarrierNames(names: sourceFlight.airlineNames)
            self.configureLayovers(slice: slices[sliceIndex])
        }
    }
    
    private func configurePrice(tripOption: TripOption) {
        //TODO: Get the right price
        // When do we have more than 1 pricing?
        if let saleTotal = tripOption.pricing?[0].saleTotal {
            if saleTotal.hasPrefix("USD") {
                self.priceLabel.text = "$" + (saleTotal as NSString).substring(from: 3)
            }
        }
    }
    
    private func configureFlightTimes(slice: TripOptionSlice) {
        if
            let firstLeg = slice.segment?.first?.leg?.first,
            let lastLeg = slice.segment?.last?.leg?.last,
            let departureTime = firstLeg.departureTime,
            let arrivalTime = lastLeg.arrivalTime {
            let departureString = dateFormatter.presentableTime(fromDate: departureTime)
            let arrivalString = dateFormatter.presentableTime(fromDate: arrivalTime)
            self.flightTimeLabel.text = departureString + "-" + arrivalString
            let durationComponents = Calendar.current.dateComponents([.day, .hour, .minute],
                                                                     from: departureTime,
                                                                     to: arrivalTime)
            if
                let hour = durationComponents.hour,
                let min = durationComponents.minute,
                let firstLegOrigin = firstLeg.origin,
                let lastLegDestination = lastLeg.destination {
                let duration = "\(hour)h:\(min)m"
                self.detailsLabel.text = duration + " " + "\(firstLegOrigin)" + "-" + "\(lastLegDestination)"
            }
        }
    }
    
    private func configureCarrierNames(names: [String]) {
        self.airlineLabel.text = ""
        for airlineName in names {
            self.airlineLabel.text! += airlineName
            if names.last != airlineName {
                self.airlineLabel.text! += ", "
            }
        }
    }
    
    private func configureLayovers(slice: TripOptionSlice) {
        var connectionDurationsAndAirports = [(Int, String)]()
        if let segments = slice.segment {
            for segment in segments {
                if let legs = segment.leg {
                    for leg in legs {
                        if
                            let connectionDuration = leg.connectionDuration,
                            let destination = leg.destination {
                            connectionDurationsAndAirports.append((connectionDuration, destination))
                        }
                    }
                    
                    if
                        let connectionDuration = segment.connectionDuration,
                        let lastLegOfSegment = legs.last,
                        let destination = lastLegOfSegment.destination {
                        connectionDurationsAndAirports.append((connectionDuration, destination))
                    }
                }
            }
        }
        
        let stopCount = connectionDurationsAndAirports.count
        if stopCount > 0 {
            self.layoverLabel.isHidden = false
            // If there are more than one stop, then list them out underneath
            self.layoverLabel.text = "\(stopCount) \(stopCount > 1 ? "stops\n" : "stop" + " ")"
            for connectionDurationAndAirport in connectionDurationsAndAirports {
                var layoverDetails = ""
                if connectionDurationAndAirport.0 / 60 > 1 {
                    layoverDetails = layoverDetails + "\(Int(connectionDurationAndAirport.0 / 60))h" + " "
                }
                layoverDetails = layoverDetails + "\(connectionDurationAndAirport.0 % 60)m" + " in " + connectionDurationAndAirport.1
                // If it's not the last one, then add a new line
                if connectionDurationsAndAirports.last! != connectionDurationAndAirport {
                    layoverDetails = layoverDetails + "\n"
                }
                self.layoverLabel.text = self.layoverLabel.text! + layoverDetails
            }
        } else {
            self.layoverLabel.isHidden = true
        }
    }
    
}
