//
//  IconTextField.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/24/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class IconTextField: UITextField {
    fileprivate var _icon: UIButton?
    
    @IBInspectable var normalStateImage: UIImage? {
        didSet {
            if let i = normalStateImage {
                icon.setImage(i, for: UIControlState())
            }
        }
    }
    @IBInspectable var selectedStateImage: UIImage? {
        didSet {
            if let i = selectedStateImage {
                icon.setImage(i, for: UIControlState.selected)
            }
        }
    }
    var icon: UIButton {
        get {
            if _icon == nil {
                leftViewMode = .always
                _icon = UIButton(frame: CGRect(x: 0, y: (bounds.size.height-22)/2, width: 40, height: 22))
                _icon!.imageView?.contentMode = .scaleAspectFit
                leftView = _icon
            }
            return _icon!
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let i = normalStateImage {
            icon.setImage(i, for: UIControlState())
        }
        
        let accessoryHeight = CGFloat(40)
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: accessoryHeight))
        accessoryView.backgroundColor = UIColor.white
        let doneButton = UIButton(type: UIButtonType.system)
        doneButton.frame = CGRect(x: frame.size.width - 75, y: 0, width: 70, height: accessoryHeight)
        doneButton.setTitle("ГОТОВО", for: UIControlState())
        doneButton.autoresizingMask = UIViewAutoresizing.flexibleLeftMargin
        doneButton.addTarget(self, action: #selector(IconTextField.done(_:)), for: UIControlEvents.touchUpInside)
        accessoryView.addSubview(doneButton)
        inputAccessoryView = accessoryView
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
        if _icon != nil {
            icon.isSelected = !text!.isEmpty
        }
    }

    func done(_ sender: UIButton) {
        resignFirstResponder()
    }
}
