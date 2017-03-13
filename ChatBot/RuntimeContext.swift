//
//  RuntimeContext.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct RuntimeContext: Decodable, Encodable {
    
    let conversationIdentifier: String?
    let system: RuntimeSystemContext?
    
    init?(json: JSON) {
        self.conversationIdentifier = "conversation_id" <~~ json
        self.system = "system" <~~ json
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "conversation_id" ~~> self.conversationIdentifier,
            "system" ~~> self.system
            ])
    }
    
}
