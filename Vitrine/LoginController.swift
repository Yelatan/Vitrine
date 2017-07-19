//
//  LoginController.swift
//  Vitrine
//
//  Created by Vitrine on 28.11.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire
import GoogleSignIn


class LoginController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate{
    
    //google sign in
    
    func sign(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        SVProgressHUD.show()
        if (error == nil) {
            var parameter = [String : AnyObject]()
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            var picture = ""
            if user.profile.hasImage
            {
                let pic = user.profile.imageURL(withDimension: 400)
                picture = "\(pic!)"
            }
            
            parameter["firstname"] = "\(givenName!)" as AnyObject
            parameter["lastname"] = "\(familyName!)" as AnyObject
            parameter["email"] = "\(email!)" as AnyObject
            parameter["provider"] = "google_plus" as AnyObject
            parameter["identity"] = "\(userId)" as AnyObject
            parameter["avatar"] = picture as AnyObject
            self.authorLogin(withParams: parameter, provider: "google_plus")
            
        } else {
            print("\(error.localizedDescription)")
            SVProgressHUD.showError(withStatus: "Ошибка")
        }
    }
    
    
    func sign(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url as URL!,sourceApplication: sourceApplication,annotation: annotation)
    }
    
    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true) { () -> Void in
        }
    }
    
    func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true) { () -> Void in
        }
    }
    
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        //Perform if user gets disconnected
    }


    @IBOutlet weak var menuButton: UIButton!
//    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet var scrollViewContentHeight: NSLayoutConstraint!
    
    
    
    var oauth_modal: OAuthIOModal? = nil
    var userdef = UserDefaults.standard
    var request_object: OAuthIORequest? = nil
    var stateToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        
        self.oauth_modal = OAuthIOModal(key: "djqVkWg5yikUS6_ZxMKGoick1Kk", delegate: self)
        self.scrollViewContentHeight.isActive = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        if GlobalConstants.fromReveal{
            menuButton.addTarget(self, action: #selector(self.menuActionFunc), for: UIControlEvents.touchUpInside)
        }else{
            if self.revealViewController() != nil {
                menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func menuActionFunc(){
//        self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
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
//        showModal("google_plus")
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if configureError != nil {
        }else {
            GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func showModal(_ provider: String) {
        SVProgressHUD.show()
//        //API.get
        Alamofire.request("http://manager.vitrine.kz:3000/api/users/state-token").responseJSON { response in
            print("reponse")
            print(response)
            print("reponse end")
            if(response.response?.statusCode == 200) {
                if let stateToke = response.result.value as? NSDictionary{
                    self.stateToken =  stateToke["token"] as! String
                }
                let options = NSMutableDictionary()
                options.setValue("true", forKey: "cache")
                options.setValue(self.stateToken, forKey: "state")
//                self.oauth_modal?.show(withProvider: provider, options: options as! [AnyHashable: Any])
                    self.oauth_modal?.show(withProvider: provider)
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
    
    
    func didReceiveOAuthIOResponse(_ request: OAuthIORequest!) {
        request.me([]) { (data, a, b) in
            print("show modal")
            switch request.data.provider {
            case "vk":
                let dict = data?["raw"] as! [String:AnyObject]
                SVProgressHUD.dismiss()
                self.authorLogin(withParams: dict, provider: "vk")
                
            case "facebook":
                print("facebook")
                let dict = data?["raw"] as! [String:AnyObject]
                print(dict)
                self.authorLogin(withParams: dict, provider: "facebook")
                
            case "google_plus":
                print("google_plus")
                let dict = data?["raw"] as! [String:AnyObject]
                print(dict)
                self.authorLogin(withParams: dict, provider: "google_plus")
            default:
                print("didn't fix")
                //                identity = data?["raw"]!["email"] as! String
            }
        }
        SVProgressHUD.showSuccess(withStatus: "Успешно!")
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
    
    func authorLogin(withParams params: [String: AnyObject], provider: String){
        self.view.endEditing(true)
        var parameter = [String: AnyObject]()
        
        self.userdef.set(provider, forKey: "soc_accounts")
        switch provider {
        case "vk":
            print("vk")
            for (_, value) in params {
                let itedict = value as! NSArray
                for ii in itedict{
                    let jsson = ii as! [String:AnyObject]
                    parameter["firstname"] = (jsson["first_name"] as? String)! as AnyObject
                    parameter["lastname"] = (jsson["last_name"] as? String)! as AnyObject
                    parameter["avatar"] = (jsson["photo_max_orig"] as? String)! as AnyObject
                    parameter["identity"] = (jsson["uid"] as? AnyObject)!
                }
            }
            parameter["provider"] = "vk" as AnyObject
            parameter["email"] = " " as AnyObject
        case "facebook":
            print("FB")
            print(params)
            parameter["firstname"] = params["first_name"]
            parameter["lastname"] = params["last_name"]
            parameter["email"] = params["email"]
            parameter["provider"] = "facebook" as AnyObject
            parameter["identity"] = (params["id"] as! String) as AnyObject
            parameter["avatar"] = "http://graph.facebook.com/\((params["id"] as! String))/picture?type=large" as AnyObject
        case "google_plus":
                parameter = params
        default:
            print("error")
        }
        
        print(parameter)
        
        Alamofire.request("http://manager.vitrine.kz:3000/api/users/loginiOS", method: .post, parameters: parameter as [String : AnyObject]).responseJSON { response in
            print(response)
            print(parameter)
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
                    print(userJson)
                    GlobalConstants.Person.setUserToken(JSON["token"] as! String)
                    GlobalConstants.Person.updatePersonalData(userJson as AnyObject)
                    SVProgressHUD.dismiss()
                    super.performSegue(withIdentifier: "loginPush", sender: nil)
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
                }
            } else {
                let message = JSON["message"] as? String                
                if message! == "Wrong credentials"{
                    SVProgressHUD.showError(withStatus: "Не правильный логин или пароль")
                }else{
                    SVProgressHUD.showError(withStatus: message!)
                }
                let Time = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: Time) {
                    SVProgressHUD.dismiss()
                }
                
            }
        }
    }
}
