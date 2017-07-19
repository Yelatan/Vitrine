//
//  NewsDetailController.swift
//  Vitrine
//
//  Created by Vitrine on 09.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire

class NewsDetailController: UIViewController {

    var news: News!
    
    @IBOutlet weak var logoView: RoundLogoView!
    @IBOutlet weak var networkTitleLabel: UILabel!
    @IBOutlet weak var networkDetailLabel: UILabel!
    @IBOutlet weak var newsBodyView: UIView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsDetailLabel: UILabel!
    @IBOutlet weak var newsTextLabel: UILabel!
    @IBOutlet var imagePagerView: ImagePagerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentHeight: NSLayoutConstraint!
    
    var Database:Dictionary<String, AnyObject>!

    @IBAction func shareButton(_ sender: AnyObject) {
        let text = news.name
        let image: UIImage? = imagePagerView.imageCount > 0 ? imagePagerView.imageAtIndex(0) : nil
        
        var objectsToShare: [AnyObject] = [text as AnyObject]
        if image != nil {
            objectsToShare.append(image!)
        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func didClickNetworkLogo(_ sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTitleLabel.text = news.name
        newsTextLabel.text = news.text
        networkTitleLabel.text = news.networkName
        networkDetailLabel.text = news.vitrineAddress
        if news.networkLogo != nil {
            logoView.imageURL = API.imageURL("networks/logo", string: news.networkLogo!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        scrollView.addParallax(with: imagePagerView, andHeight: 170, andShadow: false)
//        scrollView.addSubview(imagePagerView)
        if (news.photos.count > 0 && imagePagerView.imageCount == 0) {
            for photo in news.photos {
                imagePagerView.addImageURL(API.imageURL("news/photos", string: photo))
                
            }
        }
        
        newsTextLabel.sizeToFit()
        scrollContentHeight.constant = newsTextLabel.frame.size.height + 150
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "Products"){
            let controller = segue.destination as! ProductsController
            controller.networkId = news.networkId
        }
    }
}
