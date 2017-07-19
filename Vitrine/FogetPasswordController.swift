//
//  FogetPasswordController.swift
//  Vitrine
//
//  Created by Vitrine on 01.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire

class FogetPasswordController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet var scrollViewContentHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewContentHeight.isActive = false

        NotificationCenter.default.addObserver(self, selector: #selector(FogetPasswordController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FogetPasswordController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }
    
    @IBAction func didClickRecoverButton(_ sender: AnyObject) {
        recover()
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

    fileprivate func recover() {
        SVProgressHUD.show()
        let parameters = ["email": emailText.text!]
        Alamofire.request("http://manager.vitrine.kz:3000/api/users/restore-password", method: .post, parameters: parameters)
            .responseJSON { response in
                print(response)
                if let JSON = response.result.value {
                    let UserJson = JSON as! Dictionary<String, AnyObject>
//                    let status = UserJson["status"] as? String
                    let message = UserJson["message"] as? String
                    if message! != "No accounts were found"{
                        SVProgressHUD.showSuccess(withStatus: "Новый пароль был выслан на указанный адрес электронной почты")
                    }else{
                        SVProgressHUD.showError(withStatus: "Пользователь с указанным адресом электронной почты не найден")
                    }
                    let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: Time) {
                        SVProgressHUD.dismiss()
                    }
                }else{
                    SVProgressHUD.dismiss()
                }
        }
    }
}
