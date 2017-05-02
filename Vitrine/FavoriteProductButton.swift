//
//  FavoriteButton.swift
//  Vitrine
//
//  Created by Admin on 08.04.16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import Alamofire

class FavoriteProductButton: UIButton {
    
    var productId = ""
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(FavoriteProductButton.didPress), for: UIControlEvents.touchUpInside)
    }
    
    func didPress() {
        GlobalConstants.Person.authenticated(fromController: (self.window?.rootViewController)!) {
            let url = "users/favorite-product"
            let params = ["_id": self.productId]
            
            if (GlobalConstants.Person.getFavProds().contains(self.productId)) {
                //                API.delete("\(url)/\(self.productId)") { response in
                Alamofire.request("http://apivitrine.witharts.kz/api/\(url)/\(self.productId)").responseJSON { response in
                    switch(response.result) {
                        case .success(_):
                            GlobalConstants.Person.delFavProd(self.productId)
                            self.isSelected = false
                        case .failure(let error):
                            print(error)
                            }
                }
            } else {
                //                API.post(url, params: params) { response in switch(response.result) {
                Alamofire.request("http://apivitrine.witharts.kz/api/users/login", method: .post, parameters: params as [String : AnyObject]).responseJSON { response in
                    switch(response.result) {
                        case .success(_):
                            GlobalConstants.Person.addFavProd(self.productId)
                            self.isSelected = true
                        case .failure(let error):
                            print(error)
                    }
                }
            }
        }
    }
}
