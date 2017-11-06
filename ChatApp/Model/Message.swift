//
//  Message.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/31/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: Int?
    var toId: String?
    var imageUrl: String?
    
    func chatParnerID() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId! : fromId!
    }
}
