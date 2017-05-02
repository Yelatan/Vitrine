//
//  UIView+fade.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/5/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    func fadeIn(_ initialAlpha: CGFloat = 0, duration: TimeInterval = 0.3) {
        self.isHidden = false
        self.alpha = initialAlpha
        UIView.animate(withDuration: duration, animations: { 
            self.alpha = 1
        }) 
    }
    
    func fadeOut(_ initialAlpha: CGFloat = 1, duration: TimeInterval = 0.3) {
        self.alpha = initialAlpha
        UIView.animate(withDuration: duration, animations: { 
            self.alpha = 0
            }, completion: { (result) in
                self.isHidden = true
        }) 
    }
    
    func centerInSuperView() {
        center = CGPoint(x: superview!.frame.size.width/2, y: superview!.frame.size.height/2)
    }
}
