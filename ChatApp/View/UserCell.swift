//
//  UserCell.swift
//  ChatApp
//
//  Created by ngovantucuong on 11/1/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp {
                let date = NSDate(timeIntervalSince1970: TimeInterval(seconds))
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                self.timeLabel.text = dateFormatter.string(from: date as Date)
            }
        }
    }
    
    private func setupNameAndProfile() {
        let chatParnerID: String?
        if message?.fromId == Auth.auth().currentUser?.uid {
            chatParnerID = message?.toId
        } else {
            chatParnerID = message?.fromId
        }
        
        if let Id = chatParnerID {
        let ref = Database.database().reference().child("users").child(Id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: Any] {
        self.textLabel?.text = dictionary["name"] as? String
    
        if let profileImageUrl = dictionary["profileImageUrl"] {
        self.profileImageView.loadImageFromCacheWithUrlString(urlString: profileImageUrl as! String)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.frame = CGRect(x: 64, y: (self.textLabel?.frame.origin.y)! - 2, width: (self.textLabel?.frame.width)!, height: (self.textLabel?.frame.height)!)
        
        self.detailTextLabel?.frame = CGRect(x: 64, y: (self.detailTextLabel?.frame.origin.y)! + 2, width: (self.detailTextLabel?.frame.width)!, height: (self.detailTextLabel?.frame.height)!)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
