//
//  ProductInfoController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/13/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class ProductInfoController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var wrapperHeight: NSLayoutConstraint!
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = product.name
        descriptionLabel.text = product.description
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // wrapperHeight.constant = infoLabel.frame.origin.y + infoLabel.frame.size.height
    }
}
