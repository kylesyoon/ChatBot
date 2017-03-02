//
//  RuntimeLogMessage.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct RuntimeLogMessage {
    
    let level: String?
    let message: String?
    
    init?(json: JSON) {
        self.level = "level" <~~ json
        self.message = "msg" <~~ json
    }
    
}
