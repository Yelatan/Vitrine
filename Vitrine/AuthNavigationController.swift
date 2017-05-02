//
//  AuthNavigationController.swift
//  Vitrinne
//
//  Created by Bakbergen on 4/13/17.
//  Copyright © 2017 Bakbergen. All rights reserved.
//

import UIKit
import Foundation

protocol AuthDelegate {
    func onAuthSuccess()
}

class AuthNavigationController: UINavigationController {
    var authDelegate: AuthDelegate? = nil
    
    func success() {
        authDelegate?.onAuthSuccess()
    }
}
