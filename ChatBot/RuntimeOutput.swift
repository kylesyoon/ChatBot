//
//  RuntimeOutput.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct RuntimeOutput: Decodable {
    
    let text: [String]?
    let logMessages: [RuntimeLogMessage]?
    let nodesVisited: [String]?
    
    init?(json: JSON) {
        self.text = "text" <~~ json
        self.nodesVisited = "nodes_visited" <~~ json
        
        if let logMessagesJSON = json["log_messages"] as? [JSON],
            let logMessages = [RuntimeLogMessage].from(jsonArray: logMessagesJSON) {
            self.logMessages = logMessages
        }
        else {
            self.logMessages = nil
        }
    }
    
}
