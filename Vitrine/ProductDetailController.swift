//
//  ProductDetailController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/2/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ProductDetailController: UIViewController, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    var product: Product!

    @IBOutlet weak var vitrineNavbarButton: UIBarButtonItem!
    @IBOutlet weak var drawerButton: UIButton!
    @IBOutlet var drawerBottom: NSLayoutConstraint!
    @IBOutlet weak var drawerScrollView: UIScrollView!
    var drawerShown = false
    var drawerInitialPosition = CGFloat(0)
    var drawerHeight = CGFloat(0)
    var suggestionsController: ProductSuggestionsController?
    var toolbarsShown = true
    var showVitrineButton = false
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceBgView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pagerBgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var productInfoView: UIView!
    @IBOutlet weak var closeButtonRight: NSLayoutConstraint!
    @IBOutlet weak var priceLabelRight: NSLayoutConstraint!
    @IBOutlet weak var pageControlLeft: NSLayoutConstraint!
    @IBOutlet weak var infoPanelTop: NSLayoutConstraint!
 
    @IBOutlet weak var favButton: FavoriteProductButton!
    
    @IBAction func changePage(_ sender: UIPageControl) {
        imageCollectionView.setContentOffset(
            CGPoint(x: view.frame.size.width * CGFloat(sender.currentPage), y: 0),
            animated: true
        )
    }
    
    @IBAction func didClickInfoButton(_ sender: AnyObject) {
        showProductInfo()
    }
    
    @IBAction func didClickInfoCloseButton(_ sender: AnyObject) {
        hideProductInfo()
    }
    
    @IBAction func didClickShareButton(_ sender: AnyObject) {
        let text = product.name
        var objectsToShare: [AnyObject] = [text as AnyObject]

        if product.photos.count > 0 {
            let cell = imageCollectionView.cellForItem(at: IndexPath(row: 0, section: 0))!
            let imageView = cell.viewWithTag(1) as! UIImageView
            let image: UIImage? = imageView.image            
            if image != nil {
                objectsToShare.append(image!)
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceLabel.text = String(format: "%.0f тг.", product!.priceDiscount!)
        priceBgView.layer.cornerRadius = priceBgView.frame.size.height/2
        pagerBgView.layer.cornerRadius = pagerBgView.frame.size.height/2
        titleLabel.text = product.name
        detailLabel.text = product.brandName
        
        favButton.productId = product.id
        
        if (GlobalConstants.Person.inFavProds(product!.id)) {
            favButton.isSelected = true
        }
        
        pageControl.numberOfPages = product.photos.count
        
        drawerInitialPosition = drawerBottom.constant
        drawerHeight = drawerScrollView.frame.size.height
        
        loadSuggestions()
        
        if showVitrineButton {
            navigationItem.rightBarButtonItem = vitrineNavbarButton
        }
        else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageControl.numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PagerCell", for: indexPath) as! ImagePagerCell
        cell.imageURL = API.imageURL("products/photos", string: product.photos[indexPath.row])

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("HAI")
        if toolbarsShown {
            hideToolbars()
        }
        else {
            showToolbars()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(imageCollectionView.contentOffset.x / view.frame.size.width)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!) {
        case "ProductSuggestions":
            suggestionsController = segue.destination as! ProductSuggestionsController
        case "ProductInfo":
            let productInfoController = segue.destination as! ProductInfoController
            productInfoController.product = product
        case "Vitrine":
            let controller = segue.destination as! ProductsController
            controller.networkId = product.networkId
        default:
            return
        }
    }
    
    // Drawer logic
    @IBAction func didClickFilterToggle(_ sender: AnyObject) {
        drawerShown = !drawerShown
        toggleFilterDrawer(drawerShown, animated: true)
    }
    
    func toggleFilterDrawer(_ show: Bool, animated: Bool) {
        drawerBottom.constant = show ? drawerHeight : drawerInitialPosition
        
        if animated {
            UIView.animate(withDuration: CATransaction.animationDuration(), animations: { () -> Void in
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let diff = drawerHeight - drawerInitialPosition
        
        if scrollView == drawerScrollView {
            if scrollView.contentOffset.y > 20 && !drawerShown {
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - diff), animated: false)
                drawerShown = true
                toggleFilterDrawer(drawerShown, animated: false)
            }
            else {
                if scrollView.contentOffset.y < -20 && drawerShown {
                    drawerShown = false
                    toggleFilterDrawer(drawerShown, animated: false)
                    scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y + diff), animated: false)
                }
            }
        }
    }
    
    fileprivate func loadSuggestions() {
//        API.get("products/\(product!.id)/similar", params: nil, encoding: <#URLEncoding.Destination#>) {
            Alamofire.request("http://apivitrine.witharts.kz/api/products/\((self.product!.id)!)/similar").responseJSON { response in
            print(("http://apivitrine.witharts.kz/api/products/\((self.product!.id)!)/similar"))
            switch(response.result) {
            case .success(let JSON):
                let suggestions = Product.fromJSONArray(JSON as AnyObject)
                if suggestions.count > 0 {
                    self.suggestionsController!.products = suggestions
                    self.enableSuggestionsDrawer()
                }
                else {
                    print("LOLZ")
                    self.enableSuggestionsDrawer()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func enableSuggestionsDrawer() {
        drawerScrollView.isScrollEnabled = true
        drawerInitialPosition = drawerInitialPosition + 44
        drawerBottom.constant = drawerInitialPosition
        
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    fileprivate func showProductInfo() {
        hideToolbars()

        closeButtonRight.constant = 20
        productInfoView.isHidden = false
        productInfoView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.productInfoView.alpha = 1
            self.view.layoutIfNeeded()
        }) 
    }
    
    fileprivate func hideProductInfo() {
        showToolbars()
        
        closeButtonRight.constant = -60
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.productInfoView.alpha = 0
            }, completion: { (result) -> Void in
                self.productInfoView.isHidden = true
        }) 
    }
    
    fileprivate func hideToolbars() {
        toolbarsShown = false
        priceLabelRight.constant = CGFloat(-200)
        pageControlLeft.constant = CGFloat(-200)
        infoPanelTop.constant = drawerShown ? 560 : 260
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    fileprivate func showToolbars() {
        toolbarsShown = true
        priceLabelRight.constant = 20
        pageControlLeft.constant = 20
        infoPanelTop.constant = 60
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
}



class ImagePagerCell: UICollectionViewCell, UIScrollViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    var imageURL: URL? {
        didSet {
            
            imageView.sd_setImage(with: imageURL) { (image, error, imageCacheType, url) in
                //didn't fix, because of the image is does not exist                 
//                let zoomScale = max(self.bounds.size.width / (image?.size.width)!, self.bounds.size.height / (image?.size.height)!)
                let zoomScale: CGFloat = 100
                if (zoomScale > 1) {
                    self.scrollView.minimumZoomScale = 1
                }
                else {
                    self.scrollView.minimumZoomScale = zoomScale
                    self.scrollView.zoomScale = zoomScale
                    
                }
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
        
        scrollView.isUserInteractionEnabled = false
        contentView.addGestureRecognizer(scrollView.panGestureRecognizer);
        contentView.addGestureRecognizer(scrollView.pinchGestureRecognizer!);
    }
}
