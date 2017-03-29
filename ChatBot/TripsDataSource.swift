//
//  TripsDataSource.swift
//  Flights
//
//  Created by Kyle Yoon on 2/29/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

//TODO: Implement datasource that gets results holding both departure and return.
import Foundation
import QPXExpressWrapper

typealias FlightViewModel = (tripOption: TripOption, airlineNames: [String], sliceIndex: Int)

class TripsDataSource {
    
    private let departureSliceIndex = 0;
    private let returnSliceaIndex = 1;
    
    var searchResults: SearchResults
    var tripCellDataToDisplay: [[FlightViewModel]] = []
    var isSelectingDepature = true {
        didSet {
            currentSliceIndex = isSelectingDepature ? 0 : 1
        }
    }
    private(set) var currentSliceIndex = 0
    // Lets the datasource know that the second slice (return) for trip options need to be displayed
    // TODO: Fix this shit so it's not garbage
    var tripSelectionStatus = TripSelectionStatus.selectedNone {
        didSet {
            // 0 index slice for departure, 1 index slice for return
            switch tripSelectionStatus {
            case .selectedReturn:
                fallthrough
            case .selectedDeparture:
                currentSliceIndex = 1
            case .selectedNone:
                fallthrough
            default:
                currentSliceIndex = 0
            }
        }
    }
    
    init(searchResults: SearchResults) {
        self.searchResults = searchResults
        if let uniqueDepartures = self.findUniqueDepartures() {
            self.tripCellDataToDisplay = uniqueDepartures
        }
    }
    
    internal func tripCellDataForIndexPath(indexPath: IndexPath) -> FlightViewModel {
        return self.tripCellDataToDisplay[indexPath.section][indexPath.row]
    }

    internal func numberOfRowsForSection(section: Int) -> Int {
        return tripCellDataToDisplay[section].count
    }
    
    internal func numberOfSections() -> Int {
        return tripCellDataToDisplay.count
    }
    
    /**
     Configures the data source to display the selected departure slice in section 0 and associated return slices in section 1. ONLY use with round trips.
     
     - parameter departureIndexPath: The departure slice index path
     */
    internal func configureReturnFlights(for departureIndexPath: NSIndexPath) {
        let selectedTripCellData = self.tripCellDataToDisplay[departureIndexPath.section][departureIndexPath.row]
        if
            let trips = self.searchResults.trips,
            let tripOptions = trips.tripOptions {
            let sameDepartureTripOptions = tripOptions.filter { tripOption in
                guard let slice = tripOption.slice, let selectedSlice = selectedTripCellData.tripOption.slice else {
                    return false
                }
                
                return slice[0].segment! == selectedSlice[0].segment!
            }
            let departureTripCellData = sameDepartureTripOptions.map { tripOption -> (FlightViewModel) in
                if let airlineNames = self.fullCarrierNamesTripOption(tripOption: tripOption) {
                    return FlightViewModel(tripOption: tripOption,
                                           airlineNames: airlineNames,
                                           sliceIndex: self.currentSliceIndex)
                }
                return FlightViewModel(tripOption: tripOption,
                                       airlineNames: [""],
                                       sliceIndex: self.currentSliceIndex)
            }
            self.tripCellDataToDisplay = [[selectedTripCellData], departureTripCellData]
        }
    }
    
    /**
     Configured the data source to display the selected complete trip option. ONLY use with round trips.
     
     - parameter returnIndexPath: The selected return slice index path.
     */
    internal func configureCompletedRoundTrip(for returnIndexPath: NSIndexPath) {
        let selectedTripCellData = self.tripCellDataToDisplay[returnIndexPath.section][returnIndexPath.row]
        self.tripCellDataToDisplay = [self.tripCellDataToDisplay[0], [selectedTripCellData]]
    }
    
    internal func configureCompletedOneWayTrip(for departureIndexPath: NSIndexPath) {
        let selectedTripCellData = self.tripCellDataToDisplay[departureIndexPath.section][departureIndexPath.row]
        self.tripCellDataToDisplay = [[selectedTripCellData]]
    }
    
    /**
     Filters trip options with redundant slice[0]s (departure slice) and makes a sectioned array of TripCellData tuples.

     - returns: A sectioned array of TripCellData
     */
    private func findUniqueDepartures() -> [[FlightViewModel]]? {
        var tripCellDataToDisplay = [FlightViewModel]()
        guard let tripOptions = self.searchResults.trips?.tripOptions else {
            return nil
        }
        for tripOption in tripOptions {
            // If the display array has a an option with the same departure slice,
            // Don't add it again
            let duplicateTripOptions = tripCellDataToDisplay.filter { viewModel in
                guard
                    let slice = viewModel.tripOption.slice?[0],
                    let tripOptionSlice = tripOption.slice?[0] else {
                    return false
                }
                return slice.segment! == tripOptionSlice.segment!
            }
            if duplicateTripOptions.isEmpty, let carrierNames = self.fullCarrierNamesTripOption(tripOption: tripOption) {
                tripCellDataToDisplay.append(FlightViewModel(tripOption: tripOption, airlineNames: carrierNames, sliceIndex: 0))
            }
        }
        
        return [tripCellDataToDisplay]
    }
    
    /**
     Get's the carrier code from the trip option and finds the airline name in the search results trip data.
     
     - parameter tripOption: The trip option with carrier codes of interest
     
     - returns: The carrier names
     */
    private func fullCarrierNamesTripOption(tripOption: TripOption) -> [String]? {
        guard let slice = tripOption.slice, let segment = slice[self.currentSliceIndex].segment else { return nil }
        let airlineCarrierCodes = segment.map { $0.flight?.carrier }
        var carriers = [TripsDataCarrier]()
        for code in airlineCarrierCodes {
            if let carrier = self.searchResults.trips?.data?.carrier {
                carriers.append(contentsOf: carrier.filter { $0.code! == code! })
            }
        }
        var uniqueCarrierNames = [String]()
        for carrier in carriers {
            if !uniqueCarrierNames.contains(carrier.name!) {
                uniqueCarrierNames.append(carrier.name!)
            }
        }
        
        return uniqueCarrierNames
    }
    
}
