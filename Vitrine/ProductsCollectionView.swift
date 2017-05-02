//
//  ProductsCollectionView.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/4/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
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



protocol vCollectionViewDelegate {
    func vCollectionView<ItemType>(didSelectItem product: ItemType)
    func vCollectionViewDidRequestMoreData()
}


@IBDesignable class ProductsCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    enum DisplayMode {
        case list, grid
    }
    
    var collectionView: UICollectionView! = nil
    @IBInspectable var delegate: vCollectionViewDelegate? {
        didSet {
            delegate?.vCollectionViewDidRequestMoreData()
        }
    }
    var moreDataAvailable = true {
        didSet {
            if !moreDataAvailable {
                collectionView.removeInfiniteScroll()
            }
        }
    }
    var products = [Product]() {
        didSet {
            collectionView.reloadData()
            collectionView.finishInfiniteScroll()
            
            if products.count > 0 {
                hideLoader()
            }
            else {
                showLoader()
            }
        }
    }
    var displayMode = DisplayMode.grid {
        didSet {
            collectionView.reloadData()
        }
    }
    var stickyHeader: UIView?
    var stickyHeaderTop: NSLayoutConstraint?

    let progressView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.frame = bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        let nib = UINib(nibName: "ProductsCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ProductsCollectionViewCell")
        
        addSubview(collectionView)
        
        addSubview(progressView)
        progressView.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        progressView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        progressView.hidesWhenStopped = true
        progressView.startAnimating()
        
        collectionView.addInfiniteScroll { (scrollView) in
            self.delegate?.vCollectionViewDidRequestMoreData()
        }
    }
    
    func addStickyHeaderView(_ view: UIView, withInitialTopOffset top: CGFloat = 0) {
        view.removeFromSuperview()
        stickyHeader = view
        addSubview(view)
        
        let views = ["sticky": stickyHeader!, "super": self]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[sticky(==super)]", options: [], metrics: nil, views: views))
        stickyHeaderTop = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(top)-[sticky]", options: [], metrics: nil, views: views)[0]
        addConstraint(stickyHeaderTop!)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductsCollectionViewCell", for: indexPath) as! ProductsCollectionViewCell
        cell.product = products[indexPath.row]

        return cell
    }
    
    func getItem(_ indexPath: IndexPath) -> Product {
        return products[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if displayMode == .grid {
            return CGSize(
                width: collectionView.frame.size.width/2 - 3,
                height: (collectionView.frame.size.width/2) * 1.4 - 3
            )
        }
        else {
            return CGSize(
                width: collectionView.frame.size.width - 6,
                height: collectionView.frame.size.width * 1.3 - 6
            )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 3, bottom: 3, right: 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if stickyHeader == nil {
            return CGSize(width: frame.size.width, height: 0)
        }
        else {
            return stickyHeader!.frame.size
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if stickyHeader != nil {
            stickyHeaderTop!.constant = -scrollView.contentOffset.y
            if stickyHeaderTop!.constant < 0 {
                stickyHeaderTop!.constant = 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        delegate?.vCollectionView(didSelectItem: product)
    }
    
    func showLoader() {
        progressView.startAnimating()
    }
    
    func hideLoader() {
        progressView.stopAnimating()
    }
    
    func refresh() {
        self.collectionView.reloadData()
    }
}


@IBDesignable class ProductsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var discountStroke: UIView!
    @IBOutlet weak var favButton: FavoriteProductButton!
    
    var product: Product! {
        didSet {
            titleLabel.text = product.name!
            priceLabel.text = String(format: "%.0f тг.", product.price!)
            detailLabel.text = product.brandName
            
            if product.discount > 0 {
                discountLabel.isHidden = false
                discountStroke.isHidden = false
                discountLabel.text = String(format: "%.0f тг.", product.priceDiscount!)
            }
            else {
                discountLabel.isHidden = true
                discountStroke.isHidden = true
            }

            if product.photos.count > 0 {
                imageView.sd_setImage(with: API.imageURL("products/photos", string: product.photos[0]))
            }
            
            favButton.isSelected = GlobalConstants.Person.inFavProds(product.id)
            favButton.productId = product.id
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
    }
}
