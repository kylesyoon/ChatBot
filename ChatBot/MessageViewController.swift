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
    
    var messages = [Message]()
    var workspaceIdentifier: String?
    var isSignedIn: Bool = false
    var previousContext: RuntimeContext?
    var searchResults: SearchResults?
    var locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    var currentAirportObject: [String: String]? {
        didSet {
            guard
                let airport = currentAirportObject,
                let name = airport["name"] else { return }
            let airportMessage = Message(username: "ChatBot",
                                         text: "Setting your departure airport to \(name).",
                                         profileImage: #imageLiteral(resourceName: "bot"),
                                         type: .normal)
            insertMessage(message: airportMessage)
        }
    }
    
    override init(tableViewStyle style: UITableViewStyle) {
        super.init(tableViewStyle: style)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 50.0
        tableView?.separatorStyle = .none
        tableView?.register(UINib(nibName: String(describing: MessageCell.self), bundle: nil),
                            forCellReuseIdentifier: String(describing: MessageCell.self))
        tableView?.register(UINib(nibName: String(describing: ButtonCell.self), bundle: nil),
                            forCellReuseIdentifier: String(describing: ButtonCell.self))
        
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
                let output = response.output, 
                let text = output.text, let firstText = text.first else {
                return
            }
            let startMessage = Message(username: "ChatBot", text: firstText, profileImage: #imageLiteral(resourceName: "bot"), type: .normal)
            insertMessage(message: startMessage)
            
            guard
                let entities = response.entities,
                let urlPath = Bundle.main.url(forResource: "airport_objects", withExtension: "json"),
                let data = try? Data(contentsOf: urlPath),
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                let jsonArray = jsonObject as? [[String: String]] else {
                    return
            }
            
            for entity in entities {
                if entity.entity == "name" {
                    for airportJson in jsonArray {
                        if airportJson["name"] == entity.value {
                            self.currentAirportObject = airportJson
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
            print(response)
            guard
                let output = response.output,
                let text = output.text,
                let firstText = text.first else {
                    return
            }
            if let context = response.context {
                self.previousContext = context
            }
            let message = Message(username: "ChatBot",
                                  text: firstText,
                                  profileImage: #imageLiteral(resourceName: "bot"),
                                  type: .normal)
            self.insertMessage(message: message)
            guard
                let entities = response.entities, entities.count == 2,
                let originEntity = entities.first,
                let origin = originEntity.value,
                let destination = entities[1].value else {
                    return
            }
            
            let request = self.tripRequest(from: origin, to: destination)
            APIUtility.shared.searchTripsWithRequest(tripRequest: request,
                                                     success: {
                                                        [weak self]
                                                        results in
                                                        self?.searchResults = results
                                                        let message = Message(username: "",
                                                                              text: "",
                                                                              profileImage: #imageLiteral(resourceName: "bot"),
                                                                              type: .button)
                                                        self?.insertMessage(message: message)
                },
                                                     failure: nil)
        }
        return processMessageResponse
    }
    
    func tripRequest(from origin: String, to destination: String) -> TripRequest {
        let departureTripSlice = TripRequestSlice(origin: origin,
                                                  destination: destination,
                                                  date: Date())
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
}

// MARK: - Messaging

extension MessageViewController {
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        switch message.type {
        case .normal:
            // do nothing
            tableView.deselectRow(at: indexPath, animated: true)
        case .button:
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: tripsSegue, sender: nil)
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
        switch message.type {
        case .normal:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self),
                                                           for: indexPath) as? MessageCell else {
                                                            return UITableViewCell()
            }
            let message = messages[indexPath.row]
            cell.avatarImageView.image = message.profileImage
            cell.titleLabel.text = message.username
            cell.detailLabel.text = message.text
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
    
    // MARK: - Other SLKTextViewController
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }
    
    /// Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(_ sender: Any?) {
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        let message = Message(username: "Me",
                              text: self.textView.text,
                              profileImage: #imageLiteral(resourceName: "me"),
                              type: .normal)
        self.insertMessage(message: message)
        super.didPressRightButton(sender)
        APIUtility.shared.sendMessage(message: message.text,
                                      withPreviousContext: self.previousContext,
                                      success: self.messageResponseSuccessBlock(),
                                      failure: nil)
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
