//
//  ChatLogController.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/29/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    var user: User? {
        didSet {
            self.navigationItem.title = user?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        
        setupComponents()
    }
    
    let textFiled: UITextField = {
        let textFiled = UITextField()
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        textFiled.placeholder = "Enter Message..."
        return textFiled
    }()
    
    func setupComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        // containerConstraint
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let buttonSend = UIButton(type: .system)
        buttonSend.setTitle("Send", for: .normal)
        buttonSend.translatesAutoresizingMaskIntoConstraints = false
        buttonSend.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        
        containerView.addSubview(buttonSend)
        containerView.addSubview(textFiled)
        containerView.addSubview(separatorView)
        
        buttonSend.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        buttonSend.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        buttonSend.widthAnchor.constraint(equalToConstant: 80).isActive = true
        buttonSend.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        textFiled.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        textFiled.rightAnchor.constraint(equalTo: buttonSend.leftAnchor).isActive = true
        textFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        textFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func handleSend() {
        let ref = Database.database().reference().child("messages")
        let refChild = ref.childByAutoId()
        
        let toUid = user?.toId
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = ["text": textFiled.text!, "toId": toUid!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
        refChild.updateChildValues(values)
        
        refChild.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
            }
            
            let userMessageRef = Database.database().reference().child("user-message").child(fromId!)
            
            let messageId = refChild.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipentUserMessage = Database.database().reference().child("user-message").child(toUid!)
            recipentUserMessage.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
