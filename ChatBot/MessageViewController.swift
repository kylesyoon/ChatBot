//
//  MessageViewController.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import SlackTextViewController
import Alamofire
import QPXExpressWrapper
import CoreLocation

class MessageViewController: SLKTextViewController {
    let tripsSegue = "tripsSegue"
    var messages = [Any]()
    var allAirports: [[String: String]]?
    var previousContext: RuntimeContext?
    var searchResults: SearchResults?
    var locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    var originAirport: [String: String]? {
        didSet {
            guard
                let airport = originAirport,
                let name = airport["name"] else {
                    return
            }
            let airportMessage = Message(username: "Travel Agent",
                                         text: "Setting your departure airport to \(name).",
                                         profileImage: #imageLiteral(resourceName: "vokal"),
                                         type: .normal)
            insertMessage(message: airportMessage)
            if let navController = self.navigationController {
                let view = UIView(frame: CGRect(x: 0,
                                                y: navController.navigationBar.frame.origin.y + navController.navigationBar.frame.height,
                                                width: self.view.frame.width,
                                                height: 44.0))
                view.backgroundColor = UIColor.vok_primary
                let label = UILabel(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: self.view.frame.width,
                                                  height: 44.0))
                label.text = "Departing from \(name)"
                label.textColor = UIColor.white
                label.textAlignment = .center
                view.addSubview(label)
                self.view.addSubview(view)
            }
        }
    }
    var destinationAirport: [String: String]?
    var filteredFlight: FlightViewModel?
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override init(tableViewStyle style: UITableViewStyle) {
        super.init(tableViewStyle: style)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubview(toFront: activityIndicator)
        self.title = "Flights"
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 134.0
        tableView?.separatorStyle = .none
        tableView?.register(UINib(nibName: String(describing: MessageCell.self), bundle: nil),
                            forCellReuseIdentifier: String(describing: MessageCell.self))
        tableView?.register(UINib(nibName: String(describing: ButtonCell.self), bundle: nil),
                            forCellReuseIdentifier: String(describing: ButtonCell.self))
        tableView?.register(UINib(nibName: String(describing: TripCell.self), bundle: nil),
                            forCellReuseIdentifier: String(describing: TripCell.self))
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse:
            break
        default:
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tripsSegue,
            let tripsViewController = segue.destination as? TripsViewController,
            let searchResults = self.searchResults {
            tripsViewController.searchResults = searchResults
        }
    }
    
    func nearbyAirportSuccessBlock() -> (MessageResponseSuccessCompletion) {
        func findMatchedAirportName(from response: MessageResponse) {
            guard
                let context = response.context,
                let output = response.output, 
                let text = output.text,
                let firstText = text.first else {
                return
            }
            // pass context along
            self.previousContext = context
            // output what bot said
            let startMessage = Message(username: "Travel Agent",
                                       text: firstText,
                                       profileImage: #imageLiteral(resourceName: "vokal"),
                                       type: .normal)
            insertMessage(message: startMessage)
            // find the airport that bot figured out
            guard
                let entities = response.entities,
                let urlPath = Bundle.main.url(forResource: "airport_objects", withExtension: "json"),
                let data = try? Data(contentsOf: urlPath),
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                let jsonArray = jsonObject as? [[String: String]] else {
                    return
            }
            self.allAirports = jsonArray
            // map it to our airport object database
            for entity in entities {
                if entity.entity == "name" {
                    for airportJson in jsonArray {
                        if airportJson["name"] == entity.value {
                            self.originAirport = airportJson
                            break
                        }
                    }
                    break
                }
            }
        }
        return findMatchedAirportName
    }
    
    func messageResponseSuccessBlock() -> (MessageResponseSuccessCompletion) {
        func processMessageResponse(response: MessageResponse) {
            guard
                let context = response.context,
                let output = response.output,
                let text = output.text,
                let firstText = text.first else {
                    return
            }
            self.previousContext = context
            guard
                let entities = response.entities,
                let messageText = self.responseOutputWithByReplacingCodes(output: firstText, with: entities) else {
                    return
            }
            // Show dialog output
            let message = Message(username: "Travel Agent",
                                  text: messageText,
                                  profileImage: #imageLiteral(resourceName: "vokal"),
                                  type: .normal)
            self.insertMessage(message: message)

            if let intent = response.intents?.first, intent.intent == "filter" {
                self.activityIndicator.stopAnimating()
                self.filterIntentRecognized(for: response)
            }
            else if let intent = response.intents?.first, intent.intent == "modify" {
                self.modifyIntentRecognized(for: response)
            }
            else {
                // booking intent
                var airportEntity: RuntimeEntity?
                var dateEntity: RuntimeEntity?
                for entity in entities {
                    if let airport = entity.entity, airport == "airport" {
                        airportEntity = entity
                    }
                    else if let date = entity.entity, date == "sys-date" {
                        dateEntity = entity
                    }
                }
                if
                    let airport = airportEntity?.value,
                    let dateString = dateEntity?.value {
                    // Got destination and date
                    guard let allAirports = self.allAirports else { return }
                    
                    for airportDict in allAirports {
                        if airportDict["code"] == airport {
                            self.destinationAirport = airportDict
                            break
                        }
                    }
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    guard
                        let date = dateFormatter.date(from: dateString),
                        let origin = self.originAirport?["code"] else {
                            return
                    }
                    
                    let request = self.tripRequest(from: origin,
                                                   to: airport,
                                                   on: date)
                    APIUtility.shared.searchTripsWithRequest(tripRequest: request,
                                                             success: {
                                                                [weak self]
                                                                results in
                                                                self?.activityIndicator.stopAnimating()
                                                                self?.searchResults = results
                                                                let message = Message(username: "",
                                                                                      text: "",
                                                                                      profileImage: #imageLiteral(resourceName: "vokal"),
                                                                                      type: .button)
                                                                self?.insertMessage(message: message)
                        },
                                                             failure: nil)
                }
                else if let airport = airportEntity?.value {
                    self.activityIndicator.stopAnimating()
                    // just got airport
                    guard let allAirports = self.allAirports else { return }
                    for airportDict in allAirports {
                        if airportDict["code"] == airport {
                            self.destinationAirport = airportDict
                            break
                        }
                    }
                }
                else if let dateString = dateEntity?.value {
                    if let dest = self.destinationAirport?["code"] {
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        guard
                            let date = dateFormatter.date(from: dateString),
                            let origin = self.originAirport?["code"] else {
                                return
                        }
                        
                        let request = self.tripRequest(from: origin,
                                                       to: dest,
                                                       on: date)
                        APIUtility.shared.searchTripsWithRequest(tripRequest: request,
                                                                 success: {
                                                                    [weak self]
                                                                    results in
                                                                    self?.activityIndicator.stopAnimating()
                                                                    self?.searchResults = results
                                                                    let message = Message(username: "",
                                                                                          text: "",
                                                                                          profileImage: #imageLiteral(resourceName: "vokal"),
                                                                                          type: .button)
                                                                    self?.insertMessage(message: message)
                            },
                                                                 failure: nil)
                    }
                }
                else {
                    // unknown?
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        return processMessageResponse
    }
    
    func tripRequest(from origin: String, to destination: String, on date: Date) -> TripRequest {
        let departureTripSlice = TripRequestSlice(origin: origin,
                                                  destination: destination,
                                                  date: date)
        let requestPassengers = TripRequestPassengers(adultCount: 1,
                                                      childCount: nil,
                                                      infantInLapCount: nil,
                                                      infantInSeatCount: nil,
                                                      seniorCount: nil)
        return TripRequest(passengers: requestPassengers,
                           slice: [departureTripSlice],
                           maxPrice: nil,
                           saleCountry: nil,
                           refundable: nil,
                           solutions: nil)
    }
    
    func responseOutputWithByReplacingCodes(output: String, with entities: [RuntimeEntity]) -> String? {
        var output = output
        guard let allAirports = self.allAirports else { return output }
        for entity in entities {
            guard
                let type = entity.entity,
                let value = entity.value else { break }
            switch type {
            case Entity.airport.rawValue:
                if let matchedAirport = (allAirports.filter { $0["code"] == value }).first {
                    if let name = matchedAirport["name"] {
                        output = output.replacingOccurrences(of: value, with: "\n\(name)")
                    }
                }
            case Entity.code.rawValue:
                if let matchedAirport = (allAirports.filter { $0["code"] == value }).first {
                    if let name = matchedAirport["name"] {
                        output = output.replacingOccurrences(of: value, with: "\n\(name)")
                    }
                }
            case Entity.name.rawValue:
                fallthrough
            case Entity.city.rawValue:
                fallthrough
            case Entity.state.rawValue:
                fallthrough
            default:
                // something else
                break
            }
        }
        return output
    }
    
    func filterIntentRecognized(for response: MessageResponse) {
        guard
            let intent = response.intents?.first, 
            intent.intent == "filter",
            let entities = response.entities else {
            // should already be checked but safeguarding
            return
        }
        
        var filterEntityOptional: RuntimeEntity?
        for entity in entities {
            if entity.entity == "filter" {
                filterEntityOptional = entity
            }
        }
        
        guard
            let filterEntity = filterEntityOptional,
            let value = filterEntity.value,
            let flights = self.searchResults else {
            // should have one filter entity
            return
        }
        
        if value == "cheapest" {
            self.showCheapestFlightOptions(for: flights)
        }
        else if value == "shortest" {
            self.showShortestFlightOptions(for: flights)
        }
    }
    
    func modifyIntentRecognized(for response: MessageResponse) {
        guard
            let intent = response.intents?.first,
            intent.intent == "modify",
            let entities = response.entities else {
            return
        }
        
        var dateEntityOptional: RuntimeEntity?
        
        for entity in entities {
            if entity.entity == "sys-date" {
                dateEntityOptional = entity
            }
        }
        
        if
            let dateEntity = dateEntityOptional,
            let dateString = dateEntity.value,
            let dest = self.destinationAirport?["code"] {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard
                let date = dateFormatter.date(from: dateString),
                let origin = self.originAirport?["code"] else {
                    return
            }
            
            let request = self.tripRequest(from: origin,
                                           to: dest,
                                           on: date)
            APIUtility.shared.searchTripsWithRequest(tripRequest: request,
                                                     success: {
                                                        [weak self]
                                                        results in
                                                        self?.activityIndicator.stopAnimating()
                                                        self?.searchResults = results
                                                        let message = Message(username: "",
                                                                              text: "",
                                                                              profileImage: #imageLiteral(resourceName: "vokal"),
                                                                              type: .button)
                                                        self?.insertMessage(message: message)
                },
                                                     failure: nil)
        }
    }
    
    func showCheapestFlightOptions(for searchResults: SearchResults) {
        guard let tripOptions = self.searchResults?.trips?.tripOptions else {
            return
        }
        let sortedAscSaleTotal = tripOptions.sorted(by: { tripOptionA, tripOptionB -> Bool in
            guard
                let saleTotalA = tripOptionA.saleTotal,
                let saleTotalB = tripOptionB.saleTotal else {
                    return false
            }
            let removedUnitA = saleTotalA.replacingOccurrences(of: "USD", with: "")
            let removedUnitB = saleTotalB.replacingOccurrences(of: "USD", with: "")
            
            guard let doubleTotalA = Double(removedUnitA), let doubleTotalB = Double(removedUnitB) else {
                return false
            }
            
            return doubleTotalA < doubleTotalB
        })
        
        guard let cheapestOption = sortedAscSaleTotal.first else {
            return
        }
        
        var cheapestOptions = [TripOption]()
        for tripOption in sortedAscSaleTotal {
            if tripOption.saleTotal == cheapestOption.saleTotal {
                cheapestOptions.append(tripOption)
            }
            else {
                // it's sorted so the first one that isn't the same break the loop
                break
            }
        }
        if
            let allCarriers = searchResults.trips?.data?.carrier {
            var cheapFlights = [FlightViewModel]()
            var indexPaths = [IndexPath]()
            for (index, cheapOption) in cheapestOptions.enumerated() {
                if let airlines = TripsDataSource.fullCarrierNamesTripOption(tripOption: cheapOption,
                                                                             allCarriers: allCarriers,
                                                                             currentSliceIndex: 0){
                    let cheapFlight = FlightViewModel(cheapOption, airlines, 0)
                    cheapFlights.append(cheapFlight)
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
            }
            self.tableView?.beginUpdates()
            self.messages = cheapFlights + self.messages
            self.tableView?.insertRows(at: indexPaths,
                                       with: .bottom)
            self.tableView?.endUpdates()
            self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0),
                                        at: .bottom,
                                        animated: true)
        }
    }
    
    func showShortestFlightOptions(for searchResults: SearchResults) {
        // Get difference
        guard let tripOptions = self.searchResults?.trips?.tripOptions else {
            return
        }
        
        let sortedTotalDurationAsc = tripOptions.sorted { optionA, optionB -> Bool in
            // Get first slice, first segment, first leg departure time
            // Get last slice, last segment, last leg arrival time
            guard
                let departureA = optionA.slice?.first?.segment?.first?.leg?.first?.departureTime,
                let departureB = optionB.slice?.first?.segment?.first?.leg?.first?.departureTime,
                let arrivalA = optionA.slice?.last?.segment?.last?.leg?.last?.arrivalTime,
                let arrivalB = optionB.slice?.last?.segment?.last?.leg?.last?.arrivalTime else {
                return false
            }
            // difference
            let differenceA = arrivalA.timeIntervalSince(departureA)
            let differenceB = arrivalB.timeIntervalSince(departureB)
            // compare
            return differenceA < differenceB
        }
        
        guard
            let allCarriers = searchResults.trips?.data?.carrier,
            let shortestOption = sortedTotalDurationAsc.first,
            let shortestOptionAirlineNames = TripsDataSource.fullCarrierNamesTripOption(tripOption: shortestOption,
                                                                                        allCarriers: allCarriers,
                                                                                        currentSliceIndex: 0) else {
                                                                                            return
        }
        
        let shortestFlightViewModel = FlightViewModel(shortestOption, shortestOptionAirlineNames, 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView?.beginUpdates()
        self.messages.insert(shortestFlightViewModel, at: 0)
        self.tableView?.insertRows(at: [indexPath],
                                   with: .bottom)
        self.tableView?.endUpdates()
        self.tableView?.scrollToRow(at: indexPath,
                                    at: .bottom,
                                    animated: true)
    }
}

// MARK: - Messaging

extension MessageViewController {
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        if let chatMessage = message as? Message {
            switch chatMessage.type {
            case .normal:
                // do nothing
                tableView.deselectRow(at: indexPath, animated: true)
            case .button:
                tableView.deselectRow(at: indexPath, animated: true)
                self.performSegue(withIdentifier: tripsSegue, sender: nil)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if let chatMessage = message as? Message {
            switch chatMessage.type {
            case .normal:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self),
                                                               for: indexPath) as? MessageCell else {
                                                                return UITableViewCell()
                }
                cell.avatarImageView.image = chatMessage.profileImage
                cell.titleLabel.text = chatMessage.username
                cell.detailLabel.text = chatMessage.text
                // this makes sure the cell inverts if tableview is inverted
                cell.transform = tableView.transform
                return cell
            case .button:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ButtonCell.self),
                                                               for: indexPath) as? ButtonCell else  {
                                                                return UITableViewCell()
                }
                cell.transform = tableView.transform
                return cell
            }
        }
        else if let flightViewModel = message as? FlightViewModel {
            guard let tripCell = tableView.dequeueReusableCell(withIdentifier: String(describing: TripCell.self),
                                                               for: indexPath) as? TripCell else {
                return UITableViewCell()
            }
            tripCell.transform = tableView.transform
            tripCell.configure(with: flightViewModel)
            
            return tripCell
        }
        else {
            assert(false, "Unidentified cell type in cellForRow")
            return UITableViewCell()
        }
    }
    
    // MARK: - Other SLKTextViewController
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }
    
    /// Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(_ sender: Any?) {
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        let message = Message(username: "Kyle",
                              text: self.textView.text,
                              profileImage: #imageLiteral(resourceName: "me"),
                              type: .normal)
        self.insertMessage(message: message)
        super.didPressRightButton(sender)
        if
            let destination = self.destinationAirport,
            let name = destination["name"] {
            self.activityIndicator.startAnimating()
            APIUtility.shared.sendMessage(message: message.text,
                                          withPreviousContext: self.previousContext,
                                          customContext: ["airport_name": name],
                                          success: self.messageResponseSuccessBlock(),
                                          failure: nil)
        }
        else {
            self.activityIndicator.startAnimating()
            APIUtility.shared.sendMessage(message: message.text,
                                          withPreviousContext: self.previousContext,
                                          success: self.messageResponseSuccessBlock(),
                                          failure: nil)
        }
    }
    
    func insertMessage(message: Message) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView?.beginUpdates()
        self.messages.insert(message, at: 0)
        self.tableView?.insertRows(at: [indexPath],
                                   with: .bottom)
        self.tableView?.endUpdates()
        self.tableView?.scrollToRow(at: indexPath,
                                    at: .bottom,
                                    animated: true)
    }
}

extension MessageViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        manager.stopUpdatingLocation()
        guard let firstLocation = locations.first else { return }
        if self.currentCoordinate == nil {
            self.currentCoordinate = firstLocation.coordinate
            APIUtility.shared.queryWorkspaceIdentifier(success: {
                APIUtility.shared.getNearbyAirports(latitude: firstLocation.coordinate.latitude,
                                                    longitude: firstLocation.coordinate.longitude,
                                                    success: { names in
                                                        if let firstAirportName = names.first {
                                                            APIUtility.shared.sendMessage(message: firstAirportName,
                                                                                          withPreviousContext: nil,
                                                                                          success: self.nearbyAirportSuccessBlock(),
                                                                                          failure: {
                                                                                            error in
                                                                                            if let error = error {
                                                                                                print(error)
                                                                                            }
                                                            })
                                                        }
                                                        
                },
                                                    failure: { error in
                                                        if let error = error {
                                                            print(error)
                                                        }
                                                        
                })
            },
                                                       failure: nil)
        }

    }
}
