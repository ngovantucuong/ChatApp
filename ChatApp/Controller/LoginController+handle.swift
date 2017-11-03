//
//  LoginController+handle.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/28/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImage(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectImageFromPicker: UIImage?
        
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectImageFromPicker = editImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectImageFromPicker = originalImage
        }
        
        if let selectImage = selectImageFromPicker {
            profileImage.image = selectImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegment.titleForSegment(at: loginRegisterSegment.selectedSegmentIndex)
        logRegisterButton.setTitle(title, for: .normal)
        
        inputContainerHeightAnchor?.constant = loginRegisterSegment.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextView.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegment.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextView.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegment.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passTextFieldHeightAnchor?.isActive = false
        passTextFieldHeightAnchor = passTextView.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegment.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passTextFieldHeightAnchor?.isActive = true
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegment.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let password = passTextView.text, let email = emailTextView.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
            }
            
            self.messageController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        guard let password = passTextView.text, let email = emailTextView.text, let name = nameTextView.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let image = self.profileImage.image, let uploadData = UIImageJPEGRepresentation(image, 0.1) {
//            if let uploadData = UIImagePNGRepresentation(self.profileImage.image!) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                    
                    if error != nil {
                        print(error!)
                    }
                    
                    if let profileImageUrl = metaData?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserToDatabase(uid: uid, values: values)
                    }
                })
            }
            
        }
    }
    
    private func registerUserToDatabase(uid: String, values: [String: Any]) {
        // successfully authenticated user
        let ref = Database.database().reference(fromURL: "https://chatapp-18333.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.messageController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
            print("Save user successfully into firebase db")
        })
    }
}
