//
//  LoginController.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/24/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LoginController: UIViewController {

    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let logRegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    @objc func handleRegister() {
        guard let password = passTextView.text, let email = emailTextView.text, let name = nameTextView.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error)
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // successfully authenticated user
            let ref = Database.database().reference(fromURL: "https://chatapp-18333.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                
                print("Save user successfully into firebase db")
            })
        }
        
    }
    
    let nameTextView: UITextField = {
        let tv = UITextField()
        tv.placeholder = "Name"
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let nameSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextView: UITextField = {
        let tv = UITextField()
        tv.placeholder = "Email Address"
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let emailSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passTextView: UITextField = {
        let tv = UITextField()
        tv.placeholder = "Password"
        tv.isSecureTextEntry = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let profileImage: UIImageView = {
        let ig = UIImageView()
        ig.image = UIImage(named: "gameofthrones_splash")
        ig.contentMode = .scaleAspectFill
        ig.translatesAutoresizingMaskIntoConstraints = false
        return ig
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(inputContainerView)
        view.addSubview(logRegisterButton)
        view.addSubview(profileImage)
        
        inputContainerView.addSubview(nameTextView)
        inputContainerView.addSubview(nameSeparator)
        inputContainerView.addSubview(emailTextView)
        inputContainerView.addSubview(emailSeparator)
        inputContainerView.addSubview(passTextView)
        
        setupContainerView()
    }
    
    func setupContainerView() {
        view.addConstrainWithFormat(format: "H:|-12-[v0]-12-|", views: inputContainerView)
        view.addConstrainWithFormat(format: "V:[v0(150)]-12-[v1(50)]", views: inputContainerView, logRegisterButton)
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        view.addConstrainWithFormat(format: "H:|-12-[v0]-12-|", views: logRegisterButton)
        
        inputContainerView.addConstrainWithFormat(format: "H:|-12-[v0]|", views: nameTextView)
        inputContainerView.addConstrainWithFormat(format: "V:|[v0][v1(1)][v2][v3(1)][v4]", views: nameTextView, nameSeparator, emailTextView, emailSeparator, passTextView)
        
        inputContainerView.addConstrainWithFormat(format: "H:|[v0]|", views: nameSeparator)
        nameTextView.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        inputContainerView.addConstrainWithFormat(format: "H:|-12-[v0]|", views: emailTextView)
        inputContainerView.addConstrainWithFormat(format: "H:|[v0]|", views: emailSeparator)
        emailTextView.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        inputContainerView.addConstrainWithFormat(format: "H:|-12-[v0]|", views: passTextView)
        passTextView.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3).isActive = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
 
}
