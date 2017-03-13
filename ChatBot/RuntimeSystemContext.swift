//
//  RuntimeSystemContext.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct RuntimeSystemContext: Decodable, Encodable {
    
    let dialogStack: [RuntimeDialogStack]?
    let dialogTurnCounter: Int?
    let dialogRequestCounter: Int?
    
    init?(json: JSON) {
//        if let dialogStackJSON = json["dialog_stack"] as? [JSON],
//            let dialogStack = [RuntimeDialogStack].from(jsonArray: dialogStackJSON) {
//            self.dialogStack = dialogStack
//        }
//        else {
//            self.dialogStack = nil
//        }
        self.dialogStack = "dialog_stack" <~~ json
        self.dialogTurnCounter = "dialog_turn_counter" <~~ json
        self.dialogRequestCounter = "dialog_request_counter" <~~ json
    }
    
    func toJSON() -> JSON? {
        guard let dialogStackJSON = self.dialogStack?.toJSONArray() else { return nil }
        return jsonify([
            "dialog_stack" ~~> dialogStackJSON,
            "dialog_turn_counter" ~~> self.dialogTurnCounter,
            "dialog_request_counter" ~~> self.dialogRequestCounter
            ])
    }
    
}
