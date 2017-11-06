//
//  ViewController.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/24/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

    var messagesChat = [Message]()
    var messageDictionary = [String: Message]()
    let cellId = "cellid"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named: "new_message_icon")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserLogIn()
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MessageController.handleChatLog(_:))))
//        observeMessage()
    }
    
    func observeUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-message").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            let messageRef = Database.database().reference().child("user-message").child(uid).child(userID)
            messageRef.observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessageWithMessageID(messageID: messageID)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageID(messageID: String) {
        let messageRef = Database.database().reference().child("messages").child(messageID)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let message = snapshot.value as? [String: Any] {
                let messages = Message()
                messages.fromId = message["fromId"] as? String
                messages.text = message["text"] as? String
                messages.timestamp = message["timestamp"] as? Int
                messages.toId = message["toId"] as? String
                
                if let chatParner = messages.chatParnerID(){
                    self.messageDictionary[chatParner] = messages
                    
                    self.messagesChat = Array(self.messageDictionary.values)
                    //                        self.messagesChat.sorted(by: { (message1, message2) -> Bool in
                    //                            return message1.timestamp! > message2.timestamp!
                    //                        })
                }
                self.attemptReloadTable()
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadTable() {
        self.time?.invalidate()
        print("we just canceled our time")
        self.time = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        print("we load 0.1 s")
    }
    
    var time: Timer?
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            print("we reload table")
            self.tableView.reloadData()
        }
    }
    
    func observeMessage() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let message = snapshot.value as? [String: Any] {
                let messages = Message()
                messages.fromId = message["fromId"] as? String
                messages.text = message["text"] as? String
                messages.timestamp = message["timestamp"] as? Int
                messages.toId = message["toId"] as? String
                
                if let toId = messages.toId {
                    self.messageDictionary[toId] = messages
                    
                    self.messagesChat = Array(self.messageDictionary.values)
//                    self.messagesChat.sorted(by: { (message1, message2) -> Bool in
//                        return message1.timestamp! > message2.timestamp!
//                    })
                }
                
                self.tableView.reloadData()
            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesChat.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell
        cell?.message = messagesChat[indexPath.row]
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messagesChat[indexPath.row]
        guard let chatParnert = message.chatParnerID() else { return }
        
        let ref = Database.database().reference().child("users").child(chatParnert)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User()
            user.toId = chatParnert
            user.email = dictionary["email"] as? String
            user.name = dictionary["name"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
            
            self.handleChatLog(users: user)
        }, withCancel: nil)
    }
    
    @objc func handleNewMessage() {
        let controller = NewMessageController()
        controller.messageController = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
    func checkIfUserLogIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            // for some reason uid equal nil
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
//                self.navigationItem.title = dictionary["name"] as? String
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.setupNavBarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    
//    let titleView: UIView = {
//        let view = UIView()
//        view.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        view.backgroundColor = UIColor.red
//        view.isUserInteractionEnabled = true
//        return view
//    }()
//
//    let containerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isUserInteractionEnabled = true
//        return view
//    }()
    
    private func setupNavBarWithUser(user: User) {
        messagesChat.removeAll()
        messageDictionary.removeAll()
        self.tableView.reloadData()
    
        observeUserMessage()
        
        let buttonTitle = UIButton(type: .system)
        buttonTitle.isUserInteractionEnabled = true
        buttonTitle.setTitle("Chat Start", for: .normal)
        buttonTitle.addTarget(self, action: #selector(handleChatLog), for: .touchUpInside)
        
//        titleView.addSubview(containerView)
//
//        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
//        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
//
//        let profileImageView = UIImageView()
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.clipsToBounds = true
//        if let stringImage = user.profileImageUrl {
//            profileImageView.loadImageFromCacheWithUrlString(urlString: stringImage)
//        }
//        profileImageView.layer.cornerRadius = 20
//
//        let textLabel = UILabel()
//        textLabel.translatesAutoresizingMaskIntoConstraints = false
//        if let name = user.name {
//            textLabel.text = name
//        }
        
//        containerView.addSubview(profileImageView)
//        containerView.addSubview(textLabel)
//
//        // profileImageView constraint
//        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
//        // textLabel constraint
//        textLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
//        textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        textLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        textLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
//        self.navigationItem.titleView = titleView
        self.navigationItem.titleView = buttonTitle
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MessageController.handleChatLog(_:))))
    }
    
    @objc func handleChatLog(users: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = users
        navigationController?.pushViewController(chatLogController, animated: true)
    }

    @objc func handleLogout() {
        do {
         try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }


}

