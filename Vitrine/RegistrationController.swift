//
//  RegistrationController.swift
//  Vitrine
//
//  Created by Vitrine on 01.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire

class RegistrationController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rePasswordField: UITextField!
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet var scrollViewContentHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewContentHeight.isActive = false

        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }

    @IBAction func regAction(_ sender: AnyObject) {
        register()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch(textField) {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            rePasswordField.becomeFirstResponder()
        default:
            register()
       }
        return true
    }
    
    func keyboardWillShow(_ notification:Notification){
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
    
    func keyboardWillHide(_ notification:Notification){
        if let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            self.scrollViewBottom.constant = 60
            self.scrollViewContentHeight.isActive = false
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    fileprivate func validate() -> (Bool, String?) {
        if emailField.text!.isEmpty {
            return (false, "E-mail отсутствует")
        }
        
        if passwordField.text != rePasswordField.text {
            return (false, "Пароли не совпадают")
        }
        
        return (true, nil)
    }


    fileprivate func register() {
        let (valid, message) = validate()
        if !valid {
            SVProgressHUD.showError(withStatus: message)
            let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: Time) {
                SVProgressHUD.dismiss()
            }
            return
        }
        
        self.view.endEditing(true)
        
        if (emailField.text == "") {
            
            SVProgressHUD.showError(withStatus: "EMail отсутствует")
            
            let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: Time) {
                SVProgressHUD.dismiss()
            }
        } else if (passwordField.text != rePasswordField.text) {
            
            SVProgressHUD.showError(withStatus: "Пароли не совпадают")
            
            let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: Time) {
                SVProgressHUD.dismiss()
            }
        } else {
            SVProgressHUD.show()
            let parameters = ["email":emailField.text!, "password":passwordField.text!]
            
//            API.post("users/register", params: parameters as [String : AnyObject]) { response in
                Alamofire.request("http://manager.vitrine.kz:3000/api/users/register", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    print(response)
                if let JSON = response.result.value {
                    let responseJson = JSON as! Dictionary<String, AnyObject>
                    
                    let token = responseJson["token"] as? String
                    
                    if (token == nil) {
                        let message = responseJson["message"] as? String
                        SVProgressHUD.showError(withStatus: message)
                        
                        let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: Time) {
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        let userJson = responseJson["user"] as! Dictionary<String, AnyObject>
                        GlobalConstants.Person.setUserToken(token!)
                        GlobalConstants.Person.updatePersonalData(userJson as AnyObject)
                        
                        SVProgressHUD.dismiss()
                        super.dismiss(animated: true, completion: {})
//                        (super.parent as! AuthNavigationController).success()
                        super.performSegue(withIdentifier: "loginPush", sender: nil)
                    }
                }else{
                    print("not response JSON")
                    SVProgressHUD.dismiss()
                }
            }            
        }
    }
}
