//
//  ChatLogController.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/29/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User? {
        didSet {
            self.navigationItem.title = user?.name
            observeMessage()
        }
    }
    
    var messages = [Message]()
    let cellid = "cellid"
    
    func observeMessage() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.toId else { return }
        
        let ref = Database.database().reference().child("user-message").child(uid).child(toId)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let refMessage = Database.database().reference().child("messages").child(messageID)
            refMessage.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? Int
                message.toId = dictionary["toId"] as? String
                message.imageUrl = dictionary["imageUrl"] as? String
                
                if message.chatParnerID() == self.user?.toId {
                    self.messages.append(message)
                    self.collectionView?.reloadData()
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellid)
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.keyboardDismissMode = .interactive
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard)))
        
//        setupComponents()
//        setupKeyBoardObservers()
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImage)))
        
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
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        buttonSend.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        buttonSend.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        buttonSend.widthAnchor.constraint(equalToConstant: 80).isActive = true
        buttonSend.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        textFiled.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        textFiled.rightAnchor.constraint(equalTo: buttonSend.leftAnchor).isActive = true
        textFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        textFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return containerView
    }()
    
    @objc func handleUploadImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectImagePicker: UIImage?
        if let imageOriginal = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectImagePicker = imageOriginal
        } else if let imageEdit = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectImagePicker = imageEdit
        }
        
        if let selectImage = selectImagePicker {
            uploadToFirebaseStorageWithImage(image: selectImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirebaseStorageWithImage(image: UIImage) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("user_messages").child(imageName)
        if let imageUpload = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(imageUpload, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Fail upload image to firebase", error!)
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithUrlImage(imageUrl: imageUrl)
                }
            })
        }
        
    }
    
    private func sendMessageWithUrlImage(imageUrl: String) {
        let ref = Database.database().reference().child("messages")
        let refChild = ref.childByAutoId()
        
        let toUid = user?.toId
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = ["imageUrl": imageUrl, "toId": toUid!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
        
        refChild.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
            }
            
            self.textFiled.text = nil
            
            let userMessageRef = Database.database().reference().child("user-message").child(fromId!).child(toUid!)
            
            let messageId = refChild.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipentUserMessage = Database.database().reference().child("user-message").child(toUid!).child(fromId!)
            recipentUserMessage.updateChildValues([messageId: 1])
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func handleDismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleHideKeyboard(notification: Notification) {
       containerBottomConstraint?.constant = 0
    }
    
    @objc func handleShowKeyboard(notification: Notification) {
        let keyBoardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        self.containerBottomConstraint?.constant = -(keyBoardFrame?.height)!
        
        UIView.animate(withDuration: duration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as? ChatMessageCell
        let message = messages[indexPath.item]
        cell?.textView.text = message.text
        
        setupCell(cell: cell!, message: message)
        
        if let message = message.text {
           cell?.bubbleConstraintWidth?.constant = estimateFrameForText(text: message).width + 32
        }
        return cell!
    }
    
    func setupCell(cell: ChatMessageCell, message: Message) {
        if let urlImage = self.user?.profileImageUrl {
            cell.profileImageView.loadImageFromCacheWithUrlString(urlString: urlImage)
        }
        
        if let urlMessageImage = message.imageUrl {
            cell.messageImageView.loadImageFromCacheWithUrlString(urlString: urlMessageImage)
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageView.isHidden = false
        } else {
            cell.messageImageView.isHidden = true
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleConstraintLeft?.isActive = false
            cell.bubbleConstraintRight?.isActive = true
        } else {
            cell.bubbleView.backgroundColor = UIColor.init(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleConstraintRight?.isActive = false
            cell.bubbleConstraintLeft?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 28
        }
        
        let bound = UIScreen.main.bounds
        
        return CGSize(width: bound.width, height: height)
    }
    
    func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attribute = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attribute, context: nil)
    }
    
    let textFiled: UITextField = {
        let textFiled = UITextField()
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        textFiled.placeholder = "Enter Message..."
        return textFiled
    }()
    
    var containerBottomConstraint: NSLayoutConstraint?
    
    func setupComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        // containerConstraint
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerBottomConstraint?.isActive = true
        
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
        
        refChild.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
            }
            
            self.textFiled.text = nil
            
            let userMessageRef = Database.database().reference().child("user-message").child(fromId!).child(toUid!)
            
            let messageId = refChild.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipentUserMessage = Database.database().reference().child("user-message").child(toUid!).child(fromId!)
            recipentUserMessage.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
