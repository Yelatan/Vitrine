//
//  AboutController.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/6/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class AboutController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func reportError(_ sender: Any) {
        let googleUrlString = "mailto:service@vitrine.kz?&subject=reportError&body=..."
        if let googleUrl = NSURL(string: googleUrlString) {            
            if UIApplication.shared.canOpenURL(googleUrl as URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(googleUrl as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(googleUrl as URL)
                }
            }
        }
    }
    
    @IBAction func commentAction(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://www.vitrine.kz")!)
    }
    @IBAction func supportAction(_ sender: Any) {
        let numb = "87019999020"
        if let url = URL(string: "tel://\(numb)") {
            UIApplication.shared.openURL(url)
        }
    }
}
