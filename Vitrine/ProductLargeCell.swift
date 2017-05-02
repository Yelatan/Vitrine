//
//  ProductSmallCell.swift
//  Vitrine
//
//  Created by Viktor Ten on 2/26/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class ProductLargeCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var discountStroke: UIView!
    @IBOutlet weak var favButton: UIButton!
    
    var title: String? {
        didSet {
            titleLabel.text = title!
        }
    }
    
    var price: Float? {
        didSet {
            priceLabel.text = String(format: "%.0f тг.", price!)
        }
    }
    
    var discountPrice: Float? {
        didSet {
            if discountPrice != nil {
                discountLabel.isHidden = false
                discountStroke.isHidden = false
                discountLabel.text = String(format: "%.0f тг.", price!)
            }
            else {
                discountLabel.isHidden = true
                discountStroke.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImageView.layer.borderWidth = 1
        productImageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
    }
}
