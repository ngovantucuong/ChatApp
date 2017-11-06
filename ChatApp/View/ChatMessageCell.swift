//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by ngovantucuong on 11/4/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
   
    let textView: UITextView = {
        let textview = UITextView()
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.backgroundColor = UIColor.clear
        textview.textColor = UIColor.white
        textview.font = UIFont.systemFont(ofSize: 16)
        return textview
    }()
    
    static let blueColor = UIColor.init(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "hillary_profile")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.brown
        return imageView
    }()
    
    var bubbleConstraintWidth: NSLayoutConstraint?
    var bubbleConstraintLeft: NSLayoutConstraint?
    var bubbleConstraintRight: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
//        bubbleView.addSubview(messageImageView)
//        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
//        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
//        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
//        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
//
//        bubbleView.addSubview(playButton)
//        //x,y,w,h
//        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
//        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
//        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//
//        bubbleView.addSubview(activityIndicatorView)
//        //x,y,w,h
//        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
//        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
//        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //x,y,w,h
        
        bubbleConstraintLeft = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleConstraintLeft?.isActive = true
        bubbleConstraintLeft = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        //        bubbleViewLeftAnchor?.active = false
        
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleConstraintWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleConstraintWidth?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //ios 9 constraints
        //x,y,w,h
        //        textView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        //        textView.widthAnchor.constraintEqualToConstant(200).active = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
