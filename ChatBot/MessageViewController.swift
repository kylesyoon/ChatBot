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

class MessageViewController: SLKTextViewController {
    
    let conversationURL = "https://gateway.watsonplatform.net/conversation/api/v1/workspaces/"
    let versionParameter = "version=2017-02-03"
    
    var messages = [Message]()
    var workspaceIdentifier: String?
    var isSignedIn: Bool = false
    var previousContext: RuntimeContext?
    
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
        
        Alamofire.request(conversationURL + "?" + versionParameter)
            .authenticate(user: username, password: password)
            .responseJSON {
                [weak self]
                response in
                if let json = response.result.value as? [String: Any],
                    let workspaces = json["workspaces"] as? [[String: Any]],
                    let workspaceIdentifier = workspaces.first?["workspace_id"] as? String {
                    self?.workspaceIdentifier = workspaceIdentifier
                }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }
    
    /// Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(_ sender: Any?) {
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        
        let message = Message(username: "Me",
                              text: self.textView.text,
                              profileImage: #imageLiteral(resourceName: "me"))
        let indexPath = IndexPath(row: 0, section: 0)
        
        self.tableView?.beginUpdates()
        self.messages.insert(message, at: 0)
        self.tableView?.insertRows(at: [indexPath],
                                   with: .bottom)
        self.tableView?.endUpdates()
        self.tableView?.scrollToRow(at: indexPath,
                                    at: .bottom,
                                    animated: true)
        
        super.didPressRightButton(sender)
        
        query(with: message.text)
    }
    
    func query(with message: String) {
        guard let workspaceIdentifier = workspaceIdentifier else {
            return
        }
        
        let input = ["text": message]
        var json: [String: Any] = ["input": input]

        if let context = self.previousContext {
            json["context"] = context.toJSON()
        }
        
        Alamofire
            .request(conversationURL + "\(workspaceIdentifier)/message?" + versionParameter,
                method: .post,
                parameters: json,
                encoding: JSONEncoding.default,
                headers: ["Content-Type": "application/json"])
            .authenticate(user: username, password: password)
            .responseJSON {
                [weak self]
                response in
                if let json = response.result.value as? [String: Any],
                    let model = MessageResponse(json: json),
                    let output = model.output,
                    let text = output.text,
                    let firstText = text.first {
                    if let context = model.context {
                        self?.previousContext = context
                    }
                    let message = Message(username: "ChatBot",
                                          text: firstText,
                                          profileImage: #imageLiteral(resourceName: "bot"))
                    let indexPath = IndexPath(row: 0, section: 0)
                    self?.tableView?.beginUpdates()
                    self?.messages.insert(message, at: 0)
                    self?.tableView?.insertRows(at: [indexPath],
                                               with: .bottom)
                    self?.tableView?.endUpdates()
                    self?.tableView?.scrollToRow(at: indexPath,
                                                at: .bottom,
                                                animated: true)
                }
        }
    }
    
}
