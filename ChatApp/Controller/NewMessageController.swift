//
//  NewMessageController.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/28/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.tableView.register(UserCell.self, forCellReuseIdentifier: "cellid")
        
        fetchUser()
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.toId = snapshot.key
                self.users.append(user)
                
                // this is can crash of bakground thread, so let use dispacth_ays to fix
                self.tableView.reloadData()
            }
            
        }, withCancel: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let urlImage = user.profileImageUrl {
            cell.profileImageView.loadImageFromCacheWithUrlString(urlString: urlImage)
        }
        
        return cell
    }
    
    var messageController: MessageController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageController?.handleChatLog(users: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

