//
//  Airport.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 4/10/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct Airport: Decodable, Encodable {
    let name: String
    let code: String
    let city: String
    let state: String
    
    init?(json: JSON) {
        guard
            let name: String = "name" <~~ json,
            let code: String = "code" <~~ json,
            let city: String = "city" <~~ json,
            let state: String = "state" <~~ json else {
            return nil
        }
        
        self.name = name
        self.code = code
        self.city = city
        self.state = state
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> self.name,
            "code" ~~> self.code,
            "city" ~~> self.city,
            "state" ~~> self.state
            ])
    }
}
