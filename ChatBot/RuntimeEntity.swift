//
//  RuntimeEntity.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct RuntimeEntity: Decodable {
    
    let entity: String?
    let location: [Int]?
    let value: String?
    
    init?(json: JSON) {
        self.entity = "entity" <~~ json
        self.location = "location" <~~ json
        self.value = "value" <~~ json
    }
    
}
