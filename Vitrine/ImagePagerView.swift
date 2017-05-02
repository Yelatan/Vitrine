//
//  ImagePager.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/15/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class ImagePagerView: UIView, UIScrollViewDelegate {
    let nibName = "ImagePagerView"
    var view: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imageCount = 0
    var imageURLs = [URL]()
    var imageViews = [UIImageView]()

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
    
    func imageAtIndex(_ index: Int) -> UIImage? {
        if imageViews.count > index {
            return imageViews[index].image
        }
        return nil
    }

    func addImageURL(_ url: URL) {
        imageCount += 1
        imageURLs.append(url)
        
        scrollView.frame = bounds
        let iv = UIImageView(frame: scrollView.frame)
        iv.sd_setImage(with: url)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.center.x = iv.center.x + scrollView.frame.size.width * CGFloat(imageCount - 1)
        scrollView.addSubview(iv)
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(imageCount), height: frame.size.height)
        scrollView.isScrollEnabled = imageCount > 1
        pageControl.isHidden = imageCount <= 1
        
        iv.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin]
        pageControl.numberOfPages = imageCount
        
        imageViews.append(iv)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x/frame.size.width)
    }
    
    @IBAction func didClickPageControl(_ sender: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
}
