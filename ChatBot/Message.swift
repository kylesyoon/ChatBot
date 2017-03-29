//
//  Message.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import UIKit

enum MessageType {
    case normal
    case button
}

struct Message {
    
    let username: String
    let text: String
    let profileImage: UIImage
    let type: MessageType
    
}
