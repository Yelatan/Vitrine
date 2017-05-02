//
//  MallMapController.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/7/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class MallMapController: UIViewController, UIScrollViewDelegate {
    var mall: Mall!
    @IBOutlet weak var emptyMessage: UILabel!
    
    var floors = [MallFloor]()
    var floorIndex = 0 {
        didSet {
            if floors.count > 0 {
                activityIndicator.startAnimating()
                let floor = floors[floorIndex]
                
                mapImageView.sd_setImage(with: API.imageURL("floors/images", string: floor.images[0])) { (image, error, imageCacheType, url) in
                    self.updateZoom()
                    self.activityIndicator.stopAnimating()
                    
                    print(API.imageURL("floors/images", string: floor.images[0]))
                }
                
                emptyMessage.isHidden = true
                title = "\(mall.name) - \(floor.name)"
            }
            else {
                self.activityIndicator.stopAnimating()
                emptyMessage.isHidden = false
            }
        }
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapImageView: UIImageView!
    
    @IBAction func upFloor(_ sender: AnyObject) {
        if floorIndex < floors.count-1 {
            floorIndex += 1
        }
    }
    
    @IBAction func downFloor(_ sender: AnyObject) {
        if floorIndex > 0 {
            floorIndex -= 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadFloors()
    }
    
    func loadFloors() {
//        API.get("malls/\(mall.id)/floors") {
            Alamofire.request("http://apivitrine.witharts.kz/api/malls/\(mall.id)/floors").responseJSON(completionHandler: { (response) in
                switch(response.result) {
                case .success(let JSON):
                    self.floors = MallFloor.fromJSONArray(JSON as AnyObject)
                    self.floorIndex = 0
                case .failure(let error):
                    print(error)
                }
            })
            
//        }
    }

    func updateZoom() {
        let zoomScale = min(scrollView.bounds.size.width / mapImageView.image!.size.width, scrollView.bounds.size.height / mapImageView.image!.size.height)
    
        if (zoomScale > 1) {
            scrollView.minimumZoomScale = 1
        }
        else {
            scrollView.minimumZoomScale = zoomScale
            scrollView.zoomScale = zoomScale
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapImageView
    }
}
