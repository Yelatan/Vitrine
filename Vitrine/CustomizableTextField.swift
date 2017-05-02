//
//  CustomizableTextField.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/6/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class CustomizableTextField: UITextField {
    
    @IBInspectable var placeholderColor: UIColor!
    @IBInspectable var leftImage: UIImage!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        if placeholder != nil {
            let str = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName:placeholderColor])
            attributedPlaceholder = str
        }
        
        if leftImage != nil {
            let iv = UIImageView(image: leftImage)
            iv.contentMode = .right
            iv.frame = CGRect(x: 0, y: 0, width: 20, height: 10)
            iv.alpha = 0.3
            leftView = iv
            leftViewMode = .always
        }
    }
}
