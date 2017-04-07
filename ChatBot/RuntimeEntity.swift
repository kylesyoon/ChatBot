//
//  RuntimeEntity.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

enum Entity: String {
    case airport
    case code
    case name
    case city
    case state
}

struct RuntimeEntity: Decodable, Glossy {
    
    let entity: String?
    let location: [Int]?
    let value: String?
    let confidence: Double?
    
    init?(json: JSON) {
        self.entity = "entity" <~~ json
        self.location = "location" <~~ json
        self.value = "value" <~~ json
        self.confidence = "confidence" <~~ json
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "entity" ~~> self.entity,
            "location" ~~> self.location,
            "value" ~~> self.value,
            "confidence" ~~> self.confidence
            ])
    }
    
}
