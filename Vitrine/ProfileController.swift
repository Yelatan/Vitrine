//
//  ProfileController.swift
//  Vitrine
//
//  Created by Vitrine on 10.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire

class ProfileController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var city: PickerTextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var birthday: DateTextField!
    @IBOutlet weak var gender: PickerTextField!
    @IBOutlet weak var phone: IconTextField!
    @IBOutlet weak var email: IconTextField!
    @IBOutlet weak var address: IconTextField!
    @IBOutlet weak var social_facebook: UILabel!
    @IBOutlet weak var social_facebook_icon: UIImageView!
    @IBOutlet weak var social_vk: UILabel!
    @IBOutlet weak var social_vk_icon: UIImageView!
    @IBOutlet weak var social_gmail: UILabel!
    @IBOutlet weak var social_gmail_icon: UIImageView!
    
    @IBOutlet weak var oldPassword: IconTextField!
    @IBOutlet weak var password: IconTextField!
    @IBOutlet weak var rePassword: IconTextField!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var picChange: Bool = false
    var cityID: String!
    var dateChange: Bool = false
    var oauth_modal: OAuthIOModal? = nil
    var request_object: OAuthIORequest? = nil
    var stateToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.oauth_modal = OAuthIOModal(key: "djqVkWg5yikUS6_ZxMKGoick1Kk", delegate: self)
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if(GlobalConstants.Person.hasName()) {
            self.navigationItem.title = GlobalConstants.Person.Name + " " +  GlobalConstants.Person.Surname
        }
        
        let imageView:UIImageView = UIImageView(image: UIImage(named: "background"))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        tableView.backgroundView = imageView
        
        gender.items = [
            PickerTextField.Item(value: "male", label: "Мужчина", pic: UIImage(named: "sex_male_on")),
            PickerTextField.Item(value: "female", label: "Женщина", pic: UIImage(named: "sex_female_on"))
        ]
        
        update()
        
//        API.get("cities", encoding: <#URLEncoding.Destination#>) { response in
        Alamofire.request("http://apivitrine.witharts.kz/api/cities").responseJSON { response in
            switch(response.result) {
            case .success(let JSON):
                let cities = City.fromJSONArray(JSON as AnyObject)
                self.city.items = cities.map({ (city) -> PickerTextField.Item in
                    return PickerTextField.Item(value: city.id, label: city.name, pic: nil)
                })
                
                if (GlobalConstants.Person.hasCity()) {
                    self.city.selectedValue = GlobalConstants.Person.CityID
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func update() {
    
        if(GlobalConstants.Person.hasName()) {
            name.text = GlobalConstants.Person.Name
            surname.text = GlobalConstants.Person.Surname
        }
        
        if(GlobalConstants.Person.hasAvatar()) {
            photoView.sd_setImage(with: GlobalConstants.Person.getAvatarUrl())
        }
        
        if (GlobalConstants.Person.hasBirthday()) {
            birthday.text = GlobalConstants.Person.getBirthdayString()
        }
        
        if (GlobalConstants.Person.hasGender()) {
            gender.selectedValue = GlobalConstants.Person.Gender
//            if GlobalConstants.Person.Gender == "male" {
//                gender.selectedStateImage = UIImage(named: "sex_male_on")
//            } else {
//                gender.selectedStateImage = UIImage(named: "sex_female_on")
//            }
        }
        
        if (GlobalConstants.Person.hasPhone()) {
            phone.text = GlobalConstants.Person.Phone
        }
        
        if (GlobalConstants.Person.Email != nil) {
            email.text = GlobalConstants.Person.Email
        }
        
        if (GlobalConstants.Person.hasAddress()) {
            address.text = GlobalConstants.Person.Address
        }
        
        if GlobalConstants.Person.inSocial(User.ACC_FB) {
            social_facebook.text = "Подключен"
        }
        if GlobalConstants.Person.inSocial(User.ACC_VK) {
            social_vk.text = "Подключен"
        }
        if GlobalConstants.Person.inSocial(User.ACC_GP) {
            social_gmail.text = "Подключен"
        }
    }
    
    var imagePickMenu: UIAlertController!
    var imageActionMenu: UIAlertController!
    
    @IBAction func photoChange(_ sender: AnyObject) {
        
        self.present(self.getImageMenu(), animated: true, completion: nil)
        
    }
    
    func getImageMenu() -> UIAlertController {
        if self.imagePickMenu == nil {
            self.imagePickMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let var1 = UIAlertAction(title: "Выбрать фото", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.imagePicker("gallery")
            })
            
            let var2 = UIAlertAction(title: "Сделать фото", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.imagePicker("camera")
            })
            
            let var3 = UIAlertAction(title: "Удалить фото", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                GlobalConstants.Person.deleteUserAvatar()
                self.photoView.image = UIImage(named: "guest")
            })
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            self.imagePickMenu .addAction(var2)
            self.imagePickMenu .addAction(var1)
            //self.imagePickMenu .addAction(var3)
            self.imagePickMenu .addAction(cancelAction)
            
        }
        
        return self.imagePickMenu
    }

    var selectedTag: Int!
    func imagePicker(_ type: String){
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if(type == "camera"){
            picker.sourceType = .camera
        }
        else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true) { () -> Void in }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { //Когда выбрана картинка
        
        
        let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage //Берем фото
        dismiss(animated: true, completion: nil)
        
        photoView.image = newImage
        let imageData = UIImageJPEGRepresentation(photoView.image!, 0.5)
        let imageString = "data:image/jpeg;base64," + imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        SVProgressHUD.show()
        
        //        API.put("users/avatar", params: ["encoded": imageString as AnyObject]) { response in
        Alamofire.request("http://apivitrine.witharts.kz/api/users/avatar", method: .put, parameters: ["encoded": imageString as AnyObject]).responseJSON { response in
            print(response)
            switch response.result {
            case .success(let JSON as NSDictionary):
                if(response.response?.statusCode != 200) {
                    SVProgressHUD.showError(withStatus: JSON["message"] as! String)
                } else {
                    
                    SVProgressHUD.showSuccess(withStatus: "")
                    GlobalConstants.Person.setUserAvatar(JSON["fileName"] as! String)
                }
            case .failure(_):
                SVProgressHUD.showError(withStatus: "Ошибка")
            default :
                print("WTF?")
            }
        }
    }
    
    @IBAction func logout(_ sender: AnyObject) {
//        API.post("users/logout", encoding: <#URLEncoding.Destination#>) { response in
        Alamofire.request("http://apivitrine.witharts.kz/api/users/logout", method: .post).responseJSON { response in
            GlobalConstants.Person.logout()
            super.performSegue(withIdentifier: "logout", sender: nil)
        }
    }
    
    @IBAction func datePicker(_ sender: AnyObject) {
        
        let datePicker = ActionSheetDatePicker(title: "", datePickerMode: UIDatePickerMode.date, selectedDate: Date(), doneBlock: {
            picker, value, index in
            
            
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
            
            let selectedTime = dateFormatter.date(from: "\(value)")
            
            let dateFormatterShow: DateFormatter = DateFormatter()
            dateFormatterShow.locale = Locale(identifier: "ru_RU")
            dateFormatterShow.dateStyle =  DateFormatter.Style.long
            
            self.birthday.text = dateFormatterShow.string(from: selectedTime!)

            
            return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!!.superview)
        
        datePicker?.show()
        
    }
    
    func timeWasSelected(_ selectedTime: Date, element: AnyObject) {
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        
        let dateFormatterShow: DateFormatter = DateFormatter()
        dateFormatterShow.locale = Locale(identifier: "ru_RU")
        dateFormatterShow.dateStyle =  DateFormatter.Style.long
        
        birthday.text = dateFormatterShow.string(from: selectedTime)
    }

    
    @IBAction func saveProfile(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        var parameters = [String: String]()
        
//        if !city.text!.isEmpty && city.text != GlobalConstants.Person.CityName {
//            parameters["_cityId"] = city.selectedItem.value
//        }

        if !name.text!.isEmpty && name.text != GlobalConstants.Person.Name {
            parameters["firstName"] = name.text
        }
        
        if !surname.text!.isEmpty && surname.text != GlobalConstants.Person.Surname {
            parameters["lastName"] = surname.text
        }
        
        if !address.text!.isEmpty && address.text != GlobalConstants.Person.Address {
            parameters["address"] = address.text
        }
        
        if !phone.text!.isEmpty && phone.text != GlobalConstants.Person.Phone {
            parameters["phone"] = phone.text
        }
        
        if !gender.text!.isEmpty && gender.text != GlobalConstants.Person.Gender {
            parameters["gender"] = gender.selectedItem.value
        }
        
        if !birthday.text!.isEmpty && birthday.text != GlobalConstants.Person.getBirthdayString() {
            let df1: DateFormatter = DateFormatter()
//            df1.dateFormat = "E MMM dd HH:mm:ss OOOO yyyy"
            df1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            
            let df2: DateFormatter = DateFormatter()
            df2.dateFormat = "dd/MM/yyyy"
    
            parameters["birthDate"] = df1.string(from: df2.date(from: birthday.text!)!)
        }
        
//        API.put("users/profile", params: parameters as [String : AnyObject], encoding: <#URLEncoding.Destination#>) { response in
        Alamofire.request("http://apivitrine.witharts.kz/api/profile", method: .put, parameters: parameters as [String : AnyObject]).responseJSON { response in
            switch (response.result) {
            case .success(let JSON):
                GlobalConstants.Person.updatePersonalData(JSON as AnyObject)
                SVProgressHUD.showSuccess(withStatus: "")
            case .failure(_):
                SVProgressHUD.showError(withStatus: "Ошибка")
            }
        }
    }
    
    @IBAction func changePassword(_ sender: AnyObject) {
        SVProgressHUD.show()
        
        if ((oldPassword.text!.isEmpty || password.text!.isEmpty || rePassword.text!.isEmpty) ) {
            SVProgressHUD.showError(withStatus: "Необходимо заполнить все поля")
            return
        }
        
        var parameters = [String: String]()
        parameters["oldPassword"] = oldPassword.text
        parameters["newPassword"] = password.text
        parameters["newPasswordConfirm"] = rePassword.text
        
//        API.put("users/password", params: parameters as [String : AnyObject], encoding: <#URLEncoding.Destination#>) { response in
        Alamofire.request("http://apivitrine.witharts.kz/api/users/password", parameters: parameters as [String : AnyObject]).responseJSON { response in
        switch (response.result) {
            case .success(let JSON as NSDictionary):
                GlobalConstants.Person.updatePersonalData(JSON as AnyObject)
                if(response.response?.statusCode != 200) {
                    SVProgressHUD.showInfo(withStatus: JSON["message"] as! String)
                } else {
                    SVProgressHUD.showSuccess(withStatus: "")
                }
            case .failure(_):
                SVProgressHUD.showError(withStatus: "Ошибка")
            default:
                print("WTF")
            }
        }
    }
    
    @IBAction func fbLogin(_ sender: AnyObject) {
        showModal("facebook")
    }
    
    @IBAction func vkLogin(_ sender: AnyObject) {
        showModal("vk")
    }

    @IBAction func gLogin(_ sender: AnyObject) {
        showModal("gmail")
    }
    
    func showModal(_ provider: String) {
        self.oauth_modal?.show(withProvider: provider)
    }
    
    func didReceiveOAuthIOResponse(_ request: OAuthIORequest!) {
        var params = [String:String]()
        var identity = ""
        
        request.me([]) { (data, a, b) in
            switch request.data.provider {
            case "vk":
                print("didn't fix")
//                identity = data?["raw"]!["id"] as! String
            default:
                print("didn't fix")
//                identity = data?["raw"]!["email"] as! String
            }
            
            params["identity"] = identity
            params["provider"] = request.data.provider
            
//            API.post("users/account", params: params as [String : AnyObject], encoding: <#URLEncoding.Destination#>) { response in
            Alamofire.request("http://apivitrine.witharts.kz/api/users/account", parameters: params as [String : AnyObject]).responseJSON { response in
            switch(response.result) {
                case .success(let JSON):
                    switch request.data.provider {
                    case "vk":
                        self.social_vk.text = "Подключен"
                    case "facebook":
                        self.social_facebook.text = "Подключен"
                    case "gmail":
                        self.social_gmail.text = "Подключен"
                    default:
                        print("ERROR")
                    }
                
                case .failure(_):
                    SVProgressHUD.showError(withStatus: "Ошибка")
                }
            }
        }
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
}
