//
//  RoundImageView.swift
//  Vitrine
//
//  Created by Viktor Ten on 2/25/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


protocol MultiPickerViewDelegate {
    func multiPickerView(_ multiPickerView: MultiPickerView, didSelectValues values: NSArray)
    func multiPickerViewDone(_ multiPickerView: MultiPickerView)
}


@IBDesignable class MultiPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    let nibName = "MultiPickerView"
    var view: UIView!
    var options: [NSArray] = [[]] {
        didSet {
            selected = options.map({ (o) -> String in return o[0] as! String})
        }
    }
    var initialSelected = [0] {
        didSet {
            for (i, el) in initialSelected.enumerated() {
                selected[i] = options[i][el] as! String
                pickerView.selectRow(el, inComponent: i, animated: false)
            }
        }
    }
    var selected: [String] = []
    var delegate: MultiPickerViewDelegate?

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func didClickDone(_ sender: UIButton) {
        delegate!.multiPickerViewDone(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func triggerSelection() {
        delegate!.multiPickerView(self, didSelectValues: selected as NSArray)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[component][row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = options[component][row] as? String
        let aString = NSAttributedString(string: title!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        return aString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected[component] = options[component][row] as! String
        delegate!.multiPickerView(self, didSelectValues: selected as NSArray)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return options.count
    }
}
