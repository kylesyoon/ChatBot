//
//  RuntimeSystemContext.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct RuntimeSystemContext: Decodable {
    
    let dialogStack: [RuntimeDialogStack]?
    let dialogTurnCounter: Int?
    let dialogRequestCounter: Int?
    
    init?(json: JSON) {
        self.dialogStack = "dialogStack" <~~ json
        self.dialogTurnCounter = "dialog_turn_counter" <~~ json
        self.dialogRequestCounter = "dialog_request_counter" <~~ json
    }
    
}
