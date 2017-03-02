//
//  RuntimeIntent.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct RuntimeIntent: Decodable {
    
    let intent: String?
    let confidence: Double?
    
    init?(json: JSON) {
        self.intent = "intent" <~~ json
        self.confidence = "confidence" <~~ json
    }
    
}
