//
//  GenderPickerTextField.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/24/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class PickerTextField: IconTextField, UIPickerViewDataSource, UIPickerViewDelegate {
    struct Item {
        var value: String!
        var label: String!
        var pic: UIImage?
    }
    
    let pickerView = UIPickerView()
    
    var items = [Item]()
    var selectedRow = 0 {
        didSet {
            text = selectedItem.label
            selectedStateImage = selectedItem.pic
        }
    }
    var selectedItem: Item {
        get {
            return items[selectedRow]
        }
    }
    var selectedValue: String {
        get {
            return items[selectedRow].value
        }
        set(value) {
            let index: Int? = items.index { (item) -> Bool in
                return item.value == value
            }
            selectedRow = index == nil ? 0 : index!
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        if items.count > 0 {
            text = selectedItem.label
            selectedStateImage = selectedItem.pic
        }
        return super.becomeFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        inputView = pickerView
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}
