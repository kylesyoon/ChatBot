//
//  MessageInput.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct MessageInput: Decodable {
    
    let text: String?
    
    init?(json: JSON) {
        self.text = "text" <~~ json
    }
    
}
