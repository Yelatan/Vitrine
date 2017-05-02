//
//  LoginController.swift
//  Vitrine
//
//  Created by Vitrine on 28.11.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire


class LoginController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet var scrollViewContentHeight: NSLayoutConstraint!
    
    
    
    var oauth_modal: OAuthIOModal? = nil
//
    var request_object: OAuthIORequest? = nil
    var stateToken: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewContentHeight.isActive = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        self.oauth_modal = OAuthIOModal(key: "djqVkWg5yikUS6_ZxMKGoick1Kk", delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func cancelLogin(_ sender: UIButton) {
        super.dismiss(animated: true, completion: {})
    }
    
    @IBAction func EnterAction(_ sender: AnyObject) {
        login(withParams: ["email":emailText.text!, "password":passwordText.text!, "provider": "site"])
    }
    
    @IBAction func facebookAction(_ sender: AnyObject) {
        showModal("facebook")
    }
    
    @IBAction func vkAction(_ sender: AnyObject) {
        showModal("vk")
    }
    
    @IBAction func gmailAction(_ sender: AnyObject) {
        showModal("gmail")
    }
    
    func showModal(_ provider: String) {
        SVProgressHUD.show()
        //API.get
        Alamofire.request("http://apivitrine.witharts.kz/api/users/state-token").responseJSON { response in
            if(response.response!.statusCode == 200) {
                SVProgressHUD.dismiss()
                
//                self.stateToken = response.result.value!["token"] as! String
                if let stateToke = response.result.value as? NSDictionary{
                    self.stateToken =  stateToke["token"] as! String
                }
                
                let options = NSMutableDictionary()
                options.setValue("true", forKey: "cache")
                options.setValue(self.stateToken, forKey: "state")
                self.oauth_modal?.show(withProvider: provider, options: options as! [AnyHashable: Any])
            }else{
                if let resultMes = response.result.value as? NSDictionary{
                    if let message = resultMes["message"] {
                        SVProgressHUD.showError(withStatus: message as! String)
                    } else {
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    func didReceiveOAuthIOResponse(_ request: OAuthIORequest!) {
        let cred: NSDictionary = request.getCredentials()! as NSDictionary
//        print(cred)
        login(withParams: ["code":cred["access_token"] as! String, "state":self.stateToken, "provider":cred["provider"] as! String])
        self.request_object = request
    }
    
    func didFailWithOAuthIOError(_ error: NSError!) {
        print("OAuth failed")
    }
    
    
    func didFailAuthenticationServerSide(_ body: String!, andResponse response: URLResponse!, andError error: NSError!) {
        
    }
    
    func didAuthenticateServerSide(_ body: String!, andResponse response: URLResponse!) {
        
    }
    
    func didReceiveOAuthIOCode(_ code: String!) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch(textField) {
        case emailText:
            self.passwordText.becomeFirstResponder()
        default:
            login(withParams: ["email":emailText.text!, "password":passwordText.text!, "provider": "site"])
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
            self.scrollViewBottom.constant = 0
            self.scrollViewContentHeight.isActive = false
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }

    fileprivate func login(withParams params: [String: String]) {
        self.view.endEditing(true)
        SVProgressHUD.show()
        Alamofire.request("http://apivitrine.witharts.kz/api/users/login", method: .post, parameters: params as [String : AnyObject]).responseJSON { response in
            let JSON = response.result.value as! Dictionary<String, AnyObject>
            if (response.response!.statusCode == 200) {

                let status = JSON["status"] as? String

                if (status == "error") {
                    let message = JSON["message"] as? String
                    SVProgressHUD.showError(withStatus: message)

                    let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: Time) {
                        SVProgressHUD.dismiss()
                    }
                } else if (status == "locked"){
                    SVProgressHUD.dismiss()
                    super.performSegue(withIdentifier: "block", sender: nil)

                } else {
                    let userJson = JSON["user"] as! Dictionary<String, AnyObject>
                    GlobalConstants.Person.setUserToken(JSON["token"] as! String)
                    GlobalConstants.Person.updatePersonalData(userJson as AnyObject)
                    SVProgressHUD.dismiss()
                    super.dismiss(animated: true, completion: {})
                    (super.parent as! AuthNavigationController).success()
                }
            } else {
                let message = JSON["message"] as? String
                SVProgressHUD.showError(withStatus: message)
                
                let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: Time) {
                    SVProgressHUD.dismiss()
                }
            }
        }
        //did change
//        API.post("users/login", params: params as [String : AnyObject], encoding: <#URLEncoding.Destination#>) { response in
//            let JSON = response.result.value as! Dictionary<String, AnyObject>
//            if (response.response!.statusCode == 200) {
//                
//                let status = JSON["status"] as? String
//                
//                if (status == "error") {
//                    let message = JSON["message"] as? String
//                    SVProgressHUD.showError(withStatus: message)
//                    
//                    let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                    DispatchQueue.main.asyncAfter(deadline: Time) {
//                        SVProgressHUD.dismiss()
//                    }
//                } else if (status == "locked"){
//                    SVProgressHUD.dismiss()
//                    super.performSegue(withIdentifier: "block", sender: nil)
//                    
//                } else {
//                    let userJson = JSON["user"] as! Dictionary<String, AnyObject>
//                    GlobalConstants.Person.setUserToken(JSON["token"] as! String)
//                    GlobalConstants.Person.updatePersonalData(userJson as AnyObject)
//                    SVProgressHUD.dismiss()
//                    super.dismiss(animated: true, completion: {})
//                    (super.parent as! AuthNavigationController).success()
//                }
//            } else {
//                let message = JSON["message"] as? String
//                SVProgressHUD.showError(withStatus: message)
//                
//                let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: Time) {
//                    SVProgressHUD.dismiss()
//                }
//            }
//        }
    }
}
