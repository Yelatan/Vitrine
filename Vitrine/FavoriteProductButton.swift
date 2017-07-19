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
        var headers = [String: String]()
        if (GlobalConstants.Person.hasToken()) {
            headers = [String: String]()
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
        }
        GlobalConstants.Person.authenticated(fromController: (self.window?.rootViewController)!) {
            let url = "users/favorite-product"
            var params = ["provider":"site"]
            
            if (GlobalConstants.Person.getFavProds().contains(self.productId)) {
                Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)/\(self.productId)", method: .delete, headers: headers).responseJSON { response in                    
                    switch(response.result) {
                        case .success(_):
                            GlobalConstants.Person.delFavProd(self.productId)
                            self.isSelected = false
                        case .failure(let error):
                            print(error)
                            }
                }
            } else {
                params = ["_id": self.productId]
                Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)", method: .post, parameters: params, headers: headers).responseJSON { response in
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
