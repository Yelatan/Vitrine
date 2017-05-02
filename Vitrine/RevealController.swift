//
//  RevealController.swift
//  Vitrinne
//
//  Created by Bakbergen on 4/13/17.
//  Copyright © 2017 Bakbergen. All rights reserved.
//

import Foundation
import UIKit


class RevealController: SWRevealViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !GlobalConstants.Person.hasCity() {
            performSegue(withIdentifier: "PickCity", sender: nil)
        }
    }
    
    
}
