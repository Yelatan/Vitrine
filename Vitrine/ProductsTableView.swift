//
//  ProductsTableView.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/25/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



protocol ProductsTableViewDelegate {
    func productsTableView(didClickNetwork networkId: String)
}


@IBDesignable class ProductsTableView: VTableViewWrapper {
    var networkSelectDelegate: ProductsTableViewDelegate?
    var products = [Product]() {
        didSet {
            items = products
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "ProductsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ProductsTableViewCell")
    }
    
    func reset() {
        products = [Product]()
        moreDataAvailable = true
        print("moredataavailable")
        print(moreDataAvailable)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductsTableViewCell") as! ProductsTableViewCell
        cell.product = products[indexPath.row]
        cell.likeButton.isSelected = true
        cell.likeButton.productId = products[indexPath.row].id
        cell.productsTableView = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

@IBDesignable class ProductsTableViewCell: UITableViewCell {
    var productsTableView: ProductsTableView!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var vitrineButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var discountStroke: UIView!
    @IBOutlet weak var likeButton: FavoriteProductButton!
    
    @IBAction func didClickNetworkButton(_ sender: AnyObject) {
        productsTableView.networkSelectDelegate?.productsTableView(didClickNetwork: product.networkId!)
    }

    var product: Product! {
        didSet {
            nameLabel.text = product.name
            priceLabel.text = String(format: "%.0f тг.", product.price!)
            if(!product.photos.isEmpty) {
                photoImageView.sd_setImage(with: API.imageURL("products/photos", string: product.photos[0]))
            }
            brandNameLabel.text = product.brandName
            vitrineButton.setTitle(product.networkName, for: UIControlState())
            
            if product.discount > 0 {
                discountPriceLabel.isHidden = false
                discountStroke.isHidden = false
                discountPriceLabel.text = String(format: "%.0f тг.", product.priceDiscount!)
            }
            else {
                discountPriceLabel.isHidden = true
                discountStroke.isHidden = true
            }
        }
    }
}
