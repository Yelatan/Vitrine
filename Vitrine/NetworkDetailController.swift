//
//  BrandDetailController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/13/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class NetworkDetailController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var imagePagerView: ImagePagerView!

    var id: String?
    var network: Network?
    var initializedParallax = false

    override func viewDidLoad() {        
        super.viewDidLoad()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !initializedParallax {
            initializedParallax = true
            scrollView.addParallax(with: imagePagerView, andHeight: 200)            
        }
    }
    
    private func loadData() {
        if id == nil { return }
        //        API.get("networks/\(id!)", params: nil) { response in
       Alamofire.request("http://manager.vitrine.kz:3000/api/networks/\(id!)").responseJSON { response in
            switch(response.result) {
            case .success(let JSON):
                self.network = Mapper<Network>().map(JSON as? AnyObject)

                self.titleLabel.text = self.network?.name
                self.descriptionLabel.text = self.network?.description
                for photo in self.network!.photos {
                    self.imagePagerView.addImageURL(API.imageURL("networks/photos", string: photo))
                }

                self.phoneLabel.text = self.network?.phones.joined(separator: "\n")

                //self.updateContentHeight()
            case .failure(let error):
                print(error)
            }
        }
     
//        API.get("networks/\(id!)/vitrines", params: nil) { response in switch(response.result) {
        Alamofire.request("http://manager.vitrine.kz:3000/api/networks/\(id!)/vitrines").responseJSON { response in
            switch(response.result) {
            case .success(let JSON):
            let vitrines = Vitrine.fromJSONArray(JSON as AnyObject)
            self.addressLabel.text = vitrines.map({ (vitrine: Vitrine) -> String in
                return vitrine.address
            }).joined(separator: "\n")
        case .failure(let error):
            print(error)
            }
        }
    }
}

