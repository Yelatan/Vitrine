//
//  DateTextField.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/24/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class DateTextField: IconTextField {
    let pickerView = UIDatePicker()
    
    var date = Date() {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            text = formatter.string(from: date)                        
//            text = (date as NSDate).formattedDate(withFormat: "dd/MM/yyyy")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputView = pickerView
        pickerView.datePickerMode = UIDatePickerMode.date
        pickerView.addTarget(self, action: #selector(DateTextField.datePick(_:)), for: UIControlEvents.valueChanged)
        pickerView.date = date
    }
    
    override func caretRect(for position: UITextPosition!) -> CGRect {
        return CGRect.zero
    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Disable copy, select all, paste
        if action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)) || action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        // Default
        return super.canPerformAction(action, withSender: sender)
    }
    
    func datePick(_ sender: UIDatePicker) {
        date = pickerView.date
    }
}
