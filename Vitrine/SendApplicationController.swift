//
//  SendApplication.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/6/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class SendApplicationController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet var scrollViewContentHeight: NSLayoutConstraint!
    @IBOutlet weak var companyField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    
    @IBAction func didSendApp(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        let params = VitrineParams()
        
        if let c = companyField.text {
            params.main("company", value: c)
        }
        
        if let n = nameField.text {
            params.main("name", value: n)
        }
        
        if let n = numberField.text {
            params.main("phone", value: n)
        }
        
//        API.post("users/send-request", params: params.get() as [String : AnyObject], encoding: <#URLEncoding.Destination#>) { response in
        Alamofire.request("http://manager.vitrine.kz:3000/api/users/profile", method: .post, parameters: params.get() as! [String : AnyObject]).responseJSON { response in
            switch(response.result) {
                case .success(let JSON):
//                    SVProgressHUD.showSuccess(withStatus: JSON["message"] as! String)
                SVProgressHUD.showSuccess(withStatus: "Отправлено")
                case .failure(_):
                    SVProgressHUD.showError(withStatus: "Ошибка")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewContentHeight.isActive = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(SendApplicationController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SendApplicationController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(_ notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
            self.scrollViewBottom.constant = keyboardSize.height
            if self.view.frame.size.height - keyboardSize.height < self.scrollViewContentHeight.constant {
                self.scrollViewContentHeight.isActive = true
            }
            UIView.animate(withDuration: animationDuration!, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    func keyboardWillHide(_ notification: Notification){
        if let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            self.scrollViewBottom.constant = 0
            self.scrollViewContentHeight.isActive = false
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }
}
