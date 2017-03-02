//
//  MessageResponse.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct MessageResponse: Decodable {
    
    let input: MessageInput?
    let intents: [RuntimeIntent]?
    let entities: [RuntimeEntity]?
    let alternateIntents: Bool?
    let context: RuntimeContext?
    let output: RuntimeOutput?
    
    init?(json: JSON) {
        self.input = "input" <~~ json
        self.intents = "intents" <~~ json
        self.entities  = "entities" <~~ json
        self.alternateIntents = "alternate_intents" <~~ json
        self.context = "context" <~~ json
        self.output = "output" <~~ json
    }
    
}
