//
//  User.swift
//  Vitrine
//
//  Created by Vitrine on 08.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit

class User: NSObject, AuthDelegate {
    
    var ID: String!
    var Name: String!
    var Surname: String!
    var Address: String!
    var Email: String!
    var Avatar: String!
    var AvatarThumb: String!
    var Birthday: Date!
    var CityID: String!
    var CityName: String!
    var Gender: String!
    var Phone: String!
    var social_facebook: String!
    var social_gmail: String!
    var social_vk: String!
    var accounts = [String:String]()
    var type: String!
    var token: String!
    fileprivate var favProducts: [String]!
    fileprivate var favVitrines: [String]!
    fileprivate var favNetworks: [String]!
    
    fileprivate let ID_STR = "id"
    fileprivate let EMAIL_STR = "email"
    fileprivate let TOKEN_STR = "token"
    fileprivate let AVATAR_STR = "avatar"
    fileprivate let NAME_STR = "name"
    fileprivate let SURNAME_STR = "surname"
    fileprivate let CITY_NAME_STR = "city_name"
    fileprivate let CITY_ID_STR = "city_id"
    fileprivate let BIRTHDAY_STR = "birthday"
    fileprivate let GENDER_STR = "gender"
    fileprivate let ADDRESS_STR = "address"
    fileprivate let PHONE_STR = "phone"
    static let FAV_PRODUCTS = "fav_prods"
    static let FAV_VITRINES = "fav_vits"
    static let FAV_NETWORKS = "fav_nets"
    
    static let ACCOUNTS = "accounts"
    static let ACC_FB = "facebook"
    static let ACC_VK = "vk"
    static let ACC_GP = "gmail"

    override init() {
        super.init()
        refreshData()
    }
    
    func updatePersonalData(_ JSON: AnyObject) {        
        if let accounts = JSON["_accounts"] as? NSArray {
            for accs in accounts{
                if let dataAccount = accs as? NSDictionary{
                    if dataAccount["_id"] != nil {
                        self.addSocialAcc(dataAccount["provider"] as! String, id: dataAccount["_id"] as! String)
                    }
                }
            }
        }

        if let id = JSON["_id"] as? String {
            self.setId(id)
        }
        
        if let avatar = JSON["avatar"] as? String {
            self.setUserAvatar(avatar)
        }
        
        if let email = JSON["email"] as? String {
            self.setUserEmail(email)
        }
        
        if let firstName = JSON["firstName"] as? String {
            self.setFirstName(firstName)
        }
        
        if let lastName = JSON["lastName"] as? String {
            self.setLastName(lastName)
        }
        
        if let address = JSON["address"] as? String {
            self.setUserAddress(address)
        }
        
        if let gender = JSON["gender"] as? String {
            self.setUserGender(gender)
        }
        
        if let phone = JSON["phone"] as? String {
            self.setUserPhone(phone)
        }
        
        if let birthday = JSON["birthDate"] as? String {
            self.setUserBirthday(birthday)
        }
        
        if let cityName = JSON["cityName"] as? String {
            self.setUserCityName(cityName)
        }
        
        if let cityId = JSON["_cityId"] as? String {
            self.setUserCityId(cityId)
        }
        
        if let fav_nets = JSON["_favorite_networks"] as? [String] {
            self.setFavList(fav_nets, forKey: User.FAV_NETWORKS)
        }
        
        if let fav_prods = JSON["_favorite_products"] as? [String] {
            self.setFavList(fav_prods, forKey: User.FAV_PRODUCTS)
        }
    }
    
    func setUserAvatar(_ s: String) {
        Avatar = s
        getDefaults().set(s, forKey: AVATAR_STR)
    }
    
    func deleteUserAvatar() {
        getDefaults().removeObject(forKey: AVATAR_STR)
    }
    
    func setId(_ s: String) {
        ID = s
        getDefaults().set(s, forKey: ID_STR)
    }
    
    func setUserEmail(_ s: String) {
        Email = s
        getDefaults().set(s, forKey: EMAIL_STR)
    }
    
    func setUserToken(_ s: String) {
        token = s
        getDefaults().set(s, forKey: TOKEN_STR)
    }
    
    func setLastName(_ s: String) {
        Surname = s
        getDefaults().set(s, forKey: SURNAME_STR)
    }
    
    func setFirstName(_ s: String) {
        Name = s
        getDefaults().set(s, forKey: NAME_STR)
    }
    
    func setUserAddress(_ s: String) {
        Address = s
        getDefaults().set(s, forKey: ADDRESS_STR)
    }
    
    func setUserGender(_ s: String) {
        Gender = s
        getDefaults().set(s, forKey: GENDER_STR)
    }
    
    func setUserPhone(_ s: String) {
        Phone = s
        getDefaults().set(s, forKey: PHONE_STR)
    }
    
    func setUserBirthday(_ s: String) {
        let df1: DateFormatter = DateFormatter()
        df1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        Birthday = df1.date(from: s)
        getDefaults().set(Birthday, forKey: BIRTHDAY_STR)
    }
    
    func setUserCityName(_ s: String) {
        CityName = s
        getDefaults().set(s, forKey: CITY_NAME_STR)
    }
    
    func setUserCityId(_ s: String) {
        CityID = s
        getDefaults().set(s, forKey: CITY_ID_STR)
    }
    
    func getAvatarUrl() -> URL {
        if(Avatar == nil) {
            Avatar = getDefaults().string(forKey: NAME_STR)
        }
        return API.imageURL("users/avatar", string: Avatar)
    }
    
    func getLastName() -> String {
        if(Name == nil) {
            Name = getDefaults().string(forKey: NAME_STR)
        }
        return Name
    }
    
    func getFirstName() -> String {
        if(Surname == nil) {
            Surname = getDefaults().string(forKey: SURNAME_STR)
        }
        return Surname
    }
    
    func getAddress() -> String {
        if(Address == nil) {
            Address = getDefaults().string(forKey: ADDRESS_STR)
        }
        return Address
    }
    
    func getGender() -> String {
        if(Gender == nil) {
            Gender = getDefaults().string(forKey: GENDER_STR)
        }
        return Gender
    }
    
    func getBirthdayString() -> String {
        let df1: DateFormatter = DateFormatter()
        df1.dateFormat = "dd/MM/yyyy"
        
        if(Birthday == nil) {
            Birthday = getDefaults().object(forKey: BIRTHDAY_STR) as? Date
        }
        if let b = Birthday {
            return df1.string(from: b)
        } else {
            return ""
        }
    }
    
    func setFavList(_ favs: [String], forKey key: String) {
      switch(key) {
        case User.FAV_PRODUCTS:
            favProducts = favs
        case User.FAV_VITRINES:
            favVitrines = favs
        case User.FAV_NETWORKS:
            favNetworks = favs
        default:
            return
        }
        
        getDefaults().set(favs, forKey: key)
    }
    
    func getFavs(_ key: String!) -> [String] {
        switch(key) {
        case User.FAV_PRODUCTS:
            if(favProducts == nil) {
                let favs = getDefaults().object(forKey: key)
                favProducts = favs == nil ? [String]() : favs as! [String]
            }
            return favProducts
        case User.FAV_NETWORKS:
            if(favNetworks == nil) {
                let favs = getDefaults().object(forKey: key)
                favNetworks = favs == nil ? [String]() : favs as! [String]
            }
            return favNetworks
        default:
            return [String]()
        }
    }
    
    func setFav(_ id: String, forKey key: String, info: String = "") {
        var favs: AnyObject
        
        switch(key) {
        case User.FAV_PRODUCTS:
            favProducts.append(id)
            favs = favProducts as AnyObject
        case User.FAV_VITRINES:
            favVitrines.append(id)
            favs = favVitrines as AnyObject
        case User.FAV_NETWORKS:
            favNetworks.append(id)
            favs = favNetworks as AnyObject
        case User.ACCOUNTS:
            accounts[id] = info
            favs = accounts as AnyObject
        default:
            return
        }
        
        getDefaults().set(favs, forKey: key)
    }
    
//    func setFav(id: String, forKey key: String) {
//        var favs = [String]()
//        
//        switch(key) {
//        case User.FAV_PRODUCTS:
//            favProducts.append(id)
//            favs = favProducts
//        case User.FAV_VITRINES:
//            favVitrines.append(id)
//            favs = favVitrines
//        case User.FAV_NETWORKS:
//            favNetworks.append(id)
//            favs = favNetworks
//        default:
//            return
//        }
//        
//        getDefaults().setObject(favs, forKey: key)
//    }
    
    func delFav(_ id: String, forKey key: String!) {
        var favs = [String]()
        
        switch(key) {
        case User.FAV_PRODUCTS:
            if(favProducts != nil) {
                favProducts.remove(at: favProducts.index(of: id)!)
                favs = favProducts
            }
        case User.FAV_VITRINES:
            if(favVitrines != nil) {
                favVitrines.remove(at: favVitrines.index(of: id)!)
                favs = favVitrines
            }
        case User.FAV_NETWORKS:
            if(favNetworks != nil) {
                favNetworks.remove(at: favNetworks.index(of: id)!)
                favs = favNetworks
            }
        default:
            return
        }
        
        getDefaults().set(favs, forKey: key)
    }
    
    func inFavs(_ id: String, forKey key: String) -> Bool {
        switch(key) {
        case User.FAV_PRODUCTS:
            return favProducts != nil && favProducts.contains(id)
        case User.FAV_VITRINES:
            return favVitrines != nil && favVitrines.contains(id)
        case User.FAV_NETWORKS:
            return favNetworks != nil && favNetworks.contains(id)
        default:
            return false
        }
    }
    
    func getFavProds() -> [String] {
        return getFavs(User.FAV_PRODUCTS)
    }
    
    func addFavProd(_ id: String) {
        setFav(id, forKey: User.FAV_PRODUCTS)
    }
    
    func delFavProd(_ id: String) {
        delFav(id, forKey: User.FAV_PRODUCTS)
    }
    
    func getFavVits() -> [String] {
        return getFavs(User.FAV_VITRINES)
    }
    
    func addFavVit(_ id: String) {
        setFav(id, forKey: User.FAV_VITRINES)
    }
    
    func delFavVit(_ id: String) {
        delFav(id, forKey: User.FAV_VITRINES)
    }
    
    func getFavNets() -> [String] {
        return getFavs(User.FAV_NETWORKS)
    }
    
    func addFavNet(_ id: String) {
        setFav(id, forKey: User.FAV_NETWORKS)
    }
    
    func delFavNet(_ id: String) {
        delFav(id, forKey: User.FAV_NETWORKS)
    }
    
    func inFavProds(_ id: String) -> Bool {
        return favProducts != nil && favProducts.contains(id)
    }

    func addSocialAcc(_ provider: String, id: String) {
        setFav(provider, forKey: User.ACCOUNTS, info: id)
    }
    
    func inSocial(_ provider: String) -> Bool {
        return accounts[provider] != nil
    }
    
    fileprivate func getDefaults() -> UserDefaults {
        let defaults = UserDefaults.standard
//        defaults.registerDefaults([
//            NAME_STR : "Гость",
//            SURNAME_STR: "",
//            CITY_NAME_STR: "Vitrine"
//            ])
        
        return defaults
    }
    
    func hasAvatar() -> Bool {
        return UserDefaults.standard.string(forKey: AVATAR_STR) != nil
    }
    
    func hasName() -> Bool {
        return UserDefaults.standard.string(forKey: NAME_STR) != nil
    }
    
    func hasCity() -> Bool {
        return UserDefaults.standard.string(forKey: CITY_ID_STR) != nil
    }
    
    func hasBirthday() -> Bool {
        return UserDefaults.standard.object(forKey: BIRTHDAY_STR) != nil
    }
    
    func hasGender() -> Bool {
        return UserDefaults.standard.string(forKey: GENDER_STR) != nil
    }
    
    func hasPhone() -> Bool {
        return UserDefaults.standard.string(forKey: PHONE_STR) != nil
    }
    
    func hasAddress() -> Bool {
        return UserDefaults.standard.string(forKey: ADDRESS_STR) != nil
    }
    
    func hasToken() -> Bool {
        return UserDefaults.standard.string(forKey: TOKEN_STR) != nil
    }
    
    func logout() {
        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
            UserDefaults.standard.removeObject(forKey: key)
        }
        setUserCityId(CityID)
        setUserCityName(CityName)
        refreshData()
    }
    
    var loginHandler: ((Void) -> Void)? = nil
    func authenticated(fromController c: UIViewController, completionHandler: ((Void) -> Void)? = nil) {
        if let handler = completionHandler {
            loginHandler = handler
        }
        
        if (hasToken()) {
            if (loginHandler != nil) {
                loginHandler!()
            }
        } else {
            self.logout()
            let storyboard : UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
            let vc : LoginController = storyboard.instantiateViewController(withIdentifier: "login") as! LoginController
            let nc = AuthNavigationController(rootViewController: vc)
            nc.authDelegate = self
            c.present(nc, animated: true, completion: nil)
            
        }
    }
    
    func onAuthSuccess() {
        if let handler = loginHandler {
            handler()
        }
    }
    
    internal func refreshData() {
        let defaults = getDefaults()
        
        if defaults.string(forKey: TOKEN_STR) != nil {
            ID = defaults.string(forKey: ID_STR)
            Email = defaults.string(forKey: EMAIL_STR)
            token = defaults.string(forKey: TOKEN_STR)
            Avatar = defaults.string(forKey: AVATAR_STR)
            Name = defaults.string(forKey: NAME_STR)
            Surname = defaults.string(forKey: SURNAME_STR)
            Gender = defaults.string(forKey: GENDER_STR)
            Address = defaults.string(forKey: ADDRESS_STR)
            Phone = defaults.string(forKey: PHONE_STR)
            Birthday = defaults.object(forKey: BIRTHDAY_STR) as? Date
            
            favProducts = defaults.object(forKey: User.FAV_PRODUCTS) as? [String]
            favNetworks = defaults.object(forKey: User.FAV_NETWORKS) as? [String]

            if let accs = defaults.object(forKey: User.ACCOUNTS) as? [String:String] {
                accounts = accs
            }
//            accounts = defaults.objectForKey(User.ACCOUNTS) as? [String:String]
        }
        
        CityName = defaults.string(forKey: CITY_NAME_STR)
        CityID = defaults.string(forKey: CITY_ID_STR)
    }
}
