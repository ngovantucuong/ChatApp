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
    var imageWidth: Int?
    var imageHeight: Int?
    
    var videoUrl: String?
    
    func chatParnerID() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId! : fromId!
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        timestamp = dictionary["timestamp"] as? Int
        toId = dictionary["text"] as? String
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["fromId"] as? Int
        imageHeight = dictionary["fromId"] as? Int
        
        videoUrl = dictionary["videoUrl"] as? String
    }
}
