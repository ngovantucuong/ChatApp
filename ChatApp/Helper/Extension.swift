//
//  Extension.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/24/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()
extension UIImageView {
    func loadImageFromCacheWithUrlString(urlString: String) {
        
        if let url = NSURL(string: urlString) {
            URLSession.shared.dataTask(with: url as URL, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                }
                
                if let imageData = imageCache.object(forKey: urlString as NSString) {
                    DispatchQueue.main.async {
                        self.image = imageData as? UIImage
                    }
                }
                
                DispatchQueue.main.async {
                    if let dataImage = UIImage(data: data!) {
                        imageCache.setObject(dataImage, forKey: urlString as NSString)
                        self.image = dataImage
                    }
                }
                
            }).resume()
        }
       
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
       self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
}

extension UIView {
    func addConstrainWithFormat(format: String, views: UIView...) {
        var dictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            dictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: dictionary))
    }
}
