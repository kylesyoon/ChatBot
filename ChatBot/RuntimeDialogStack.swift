//
//  RuntimeDialogStack.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

struct RuntimeDialogStack: Decodable {
    
    let dialogNode: String?
    let invokedSubdialog: String?
    
    init?(json: JSON) {
        self.dialogNode = "dialog_node" <~~ json
        self.invokedSubdialog = "invoked_subdialog" <~~ json
    }
    
}
