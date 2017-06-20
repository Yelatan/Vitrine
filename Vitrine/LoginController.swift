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
//    @IBOutlet weak var menuButton: UIButton!
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
        self.oauth_modal = OAuthIOModal(key: "djqVkWg5yikUS6_ZxMKGoick1Kk", delegate: self)
        
        self.scrollViewContentHeight.isActive = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

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
        print("cancel dismiss")
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
        Alamofire.request("http://manager.vitrine.kz:3000/api/users/state-token").responseJSON { response in
            if(response.response!.statusCode == 200) {
                if let stateToke = response.result.value as? NSDictionary{
                    self.stateToken =  stateToke["token"] as! String
                }
                let options = NSMutableDictionary()
                options.setValue("true", forKey: "cache")
                options.setValue(self.stateToken, forKey: "state")
                self.oauth_modal?.show(withProvider: provider, options: options as! [AnyHashable: Any])
                SVProgressHUD.dismiss()
            }else{
                if let resultMes = response.result.value as? NSDictionary{
                    if let message = resultMes["message"] {
                        SVProgressHUD.showError(withStatus: message as! String)
                    }else {
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
//    func didReceiveOAuthIOResponse(_ request: OAuthIORequest!) {
//        var cred: Dictionary = request.getCredentials()
//        print("cred")
//        print(cred)
//        print(cred["oauth_token"])
//        print(cred["oauth_token_secret"])
//        print("cred end")
//        
//        var params = [String:String]()
//        var identity = ""
//        var headers = [String: String]()
//        if (GlobalConstants.Person.token != nil){
//            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
//        }
//        
//        request.me([]) { (data, a, b) in
//            switch request.data.provider {
//            case "vk":
//                print("vk")
//                let dict = data?["raw"] as! [String:AnyObject]
//                print(dict)
//                print("dict")
//                let dict2 = dict["uid"]
//                
//                for (key, value) in dict {
//                    print("\(value)")
//                    
//                    let itedict = value as! NSArray
//                    for ii in itedict{
//                        let jsson = ii as! [String:AnyObject]
//                        print(jsson["first_name"] as? String)
//                    }
//                }
//                
////                let userJson = dict as! Dictionary<String, AnyObject>
////                GlobalConstants.Person.setUserToken(dict["token"] as! String)
////                GlobalConstants.Person.updatePersonalData(userJson as AnyObject)
////                
////                super.performSegue(withIdentifier: "loginPush", sender: nil)
//                
//                identity = "id"
//            case "facebook":
//                print("facebook")
//                let dict = data?["raw"] as! [String:AnyObject]
//                print(dict)
//                let dict2 = dict["uid"]
//                identity = "id"
//            case "gmail":
//                print("gmail")
//                let dict = data?["raw"] as! [String:AnyObject]
////                print(dict)
//                let dict2 = dict["uid"]
//                identity = "id"
//            default:
//                print("didn't fix")
//            }
////            params["identity"] = identity
//            params["provider"] = request.data.provider
//            params["code"] = cred["access_token"] as! String
//            params["state"] = self.stateToken
//            
//            Alamofire.request("http://manager.vitrine.kz:3000/api/users/login", method: .post, parameters: params as [String : AnyObject], headers: headers).responseJSON { response in
//                print("response")
//                print(response)
//                print("response end")
//                print("params")
//                print(params)
//                print("params end")
//                switch(response.result) {
//                case .success(var JSON):
//                    JSON = response.result.value as! Dictionary<String, AnyObject>
//                    switch request.data.provider {
//                    case "vk":
//                        GlobalConstants.Person.accounts["ACC_VK"] = "ok"
//                        
//                        super.performSegue(withIdentifier: "loginPush", sender: nil)
//                        
//                    case "facebook":
//                        GlobalConstants.Person.accounts["ACC_FB"] = "ok"
//                    case "gmail":
//                        print("gmail auth")
//                    default:
//                        print("ERROR")
//                    }
//                    
//                case .failure(_):
//                    SVProgressHUD.showError(withStatus: "Ошибка")
//                }
//            }
//        }
//        self.request_object = request
//    }
    
    func didFailWithOAuthIOError(_ error: NSError!) {
        print("OAuth failed")
    }
    
    
    func didFailAuthenticationServerSide(_ body: String!, andResponse response: URLResponse!, andError error: NSError!) {
        
    }
    
    func didAuthenticateServerSide(_ body: String!, andResponse response: URLResponse!) {
        
    }
    
    func didReceiveOAuthIOCode(_ code: String!) {
        
    }
    
//    func showModal(_ provider: String) {        
//        SVProgressHUD.show()
//        print("show modal")
//        //API.get
//        Alamofire.request("http://manager.vitrine.kz:3000/api/users/state-token").responseJSON { response in
//            print(response)
//            print(response.response!.statusCode)
//            if(response.response!.statusCode == 200) {
//                
//                
////                self.stateToken = response.result.value!["token"] as! String
//                if let stateToke = response.result.value as? NSDictionary{
//                    self.stateToken =  stateToke["token"] as! String
//                }
//                
//                let options = NSMutableDictionary()
//                options.setValue("true", forKey: "cache")
//                options.setValue(self.stateToken, forKey: "state")
//                self.oauth_modal?.show(withProvider: provider, options: options as! [AnyHashable: Any])
//                SVProgressHUD.dismiss()
//            }else{
//                if let resultMes = response.result.value as? NSDictionary{
//                    if let message = resultMes["message"] {
//                        SVProgressHUD.showError(withStatus: message as! String)
//                    }else {
//                        SVProgressHUD.dismiss()
//                    }
//                }
//            }
//        }
//    }
//    
    func didReceiveOAuthIOResponse(_ request: OAuthIORequest!) {
        let cred: NSDictionary = request.getCredentials()! as NSDictionary
        login(withParams: ["code":cred["access_token"] as! String, "state":self.stateToken, "provider":cred["provider"] as! String])
        self.request_object = request
    }
//
//    func didFailWithOAuthIOError(_ error: NSError!) {
//        print("OAuth failed")
//    }
//    
//    
//    func didFailAuthenticationServerSide(_ body: String!, andResponse response: URLResponse!, andError error: NSError!) {
//        
//    }
//    
//    func didAuthenticateServerSide(_ body: String!, andResponse response: URLResponse!) {
//        
//    }
//    
//    func didReceiveOAuthIOCode(_ code: String!) {
//        
//    }
    
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
        Alamofire.request("http://manager.vitrine.kz:3000/api/users/login", method: .post, parameters: params as [String : AnyObject]).responseJSON { response in
            print(response)
            print(params)
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
                    
                    super.performSegue(withIdentifier: "loginPush", sender: nil)
                    
//                    super.dismiss(animated: true, completion: {})
//                    (super.parent as! AuthNavigationController).success()
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
