//
//  MallInfoController.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/7/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class MallInfoController: UIViewController {
    var mall: Mall!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var imagePagerView: ImagePagerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "  " + mall.name
        descLabel.text = "Адрес:\n" + "\(mall.address!)\n\n" + mall.description!
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if mall.photos.count > 0 && imagePagerView.imageCount == 0 {
//            scrollView.addParallax(with: imagePagerView, andHeight: 200, andShadow: false)
            scrollView.contentOffset = CGPoint(x: 0, y: -200)
            for photo in mall.photos {
                print("malls/photos \(photo)")
                imagePagerView.addImageURL(API.imageURL("malls/photos", string: photo))
            }
        }        
    }
}
