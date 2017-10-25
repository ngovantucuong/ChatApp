//
//  Extension.swift
//  ChatApp
//
//  Created by ngovantucuong on 10/24/17.
//  Copyright © 2017 apple. All rights reserved.
//

import UIKit

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
