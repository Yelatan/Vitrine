//
//  ProductSuggestionsController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/3/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class ProductSuggestionsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var products = [Product]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let product = products[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        
        if product.photos.count > 0 {
            imageView.sd_setImage(with: URL(string: product.photos[0]))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/3, height: collectionView.frame.size.width/3)
    }
}
