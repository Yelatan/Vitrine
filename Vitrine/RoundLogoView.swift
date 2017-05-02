//
//  RoundImageView.swift
//  Vitrine
//
//  Created by Viktor Ten on 2/25/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage


@IBDesignable class RoundLogoView: UIView {
    let nibName = "RoundLogoView"
    var view: UIView!

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set(image) {
            imageView.image = image
        }
    }
    
    var imageURLString: String? {
        didSet {
            imageView.sd_setImage(with: URL(string: self.imageURLString!))
        }
    }
    
    var imageURL: URL? {
        didSet {
            imageView.sd_setImage(with: imageURL!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    
        return view
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
    }
}
