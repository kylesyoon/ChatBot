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

class MessageViewController: SLKTextViewController {
    let tripsSegue = "tripsSegue"
    
    var messages = [Message]()
    var workspaceIdentifier: String?
    var isSignedIn: Bool = false
    var previousContext: RuntimeContext?
    var searchResults: SearchResults?
    
    override init(tableViewStyle style: UITableViewStyle) {
        super.init(tableViewStyle: style)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
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
        
        APIUtility.shared.queryWorkspaceIdentifier(success: nil, failure: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tripsSegue,
            let tripsViewController = segue.destination as? TripsViewController,
            let searchResults = self.searchResults {
            tripsViewController.searchResults = searchResults
        }
    }
    
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
        query(with: message.text)
    }
    
    func query(with message: String) {
        APIUtility.shared.sendMessage(message: message,
                                      withPreviousContext: self.previousContext,
                                      success: {
                                        [weak self]
                                        messageReponse in
                                        guard
                                            let output = messageReponse.output,
                                            let text = output.text,
                                            let firstText = text.first else {
                                                return
                                        }
                                        if let context = messageReponse.context {
                                            self?.previousContext = context
                                        }
                                        let message = Message(username: "ChatBot",
                                                              text: firstText,
                                                              profileImage: #imageLiteral(resourceName: "bot"),
                                                              type: .normal)
                                        self?.insertMessage(message: message)
                                        guard
                                            let entities = messageReponse.entities, entities.count == 2,
                                            let originEntity = entities.first,
                                            let origin = originEntity.value,
                                            let destination = entities[1].value,
                                            let request = self?.tripRequest(from: origin, to: destination) else {
                                                return
                                        }
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
            },
                                      failure: nil)
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
