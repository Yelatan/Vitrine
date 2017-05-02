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
        let parameters = ["email": emailText.text!]
        
        
        //Alamofire.request(patientIdUrl, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        
        Alamofire.request("\(GlobalConstants.baseURL)reset_password", method: .post, parameters: parameters)
            .responseJSON { response in
                /*
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                */
                
                if let JSON = response.result.value {
                    
                    let UserJson = JSON as! Dictionary<String, AnyObject>
                    let status = UserJson["status"] as? String
                    
                    if (status == "error") {
                        
                        let message = UserJson["message"] as? String
                        SVProgressHUD.showError(withStatus: message)
                        
                        let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: Time) {
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        
                        let message = UserJson["message"] as? String
                        SVProgressHUD.showSuccess(withStatus: message)
                        
                        let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: Time) {
                            SVProgressHUD.dismiss()
                        }
                        
                    }
                }else{
                    SVProgressHUD.dismiss()
                }
                
                
        }
    }
}
