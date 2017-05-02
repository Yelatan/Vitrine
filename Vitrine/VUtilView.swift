//
//  VUtilView.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/5/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class VUtilView: UIView {
    var progressView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    var emptyView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(progressView)
        progressView.hidesWhenStopped = true
        progressView.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        progressView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        progressView.startAnimating()
    }
    
    func showLoader() {
        progressView.startAnimating()
        bringSubview(toFront: progressView)
        hideEmptyView()
    }
    
    func hideLoader() {
        progressView.stopAnimating()
        hideEmptyView()
    }
    
    func showEmptyMessage(_ text: String) {
        let label = UILabel(frame: bounds)
        label.textAlignment = NSTextAlignment.center
        label.text = text
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        emptyView = label
        addSubview(emptyView!)
        emptyView!.autoresizingMask = .flexibleWidth
        emptyView!.centerInSuperView()
    }
    
    func hideEmptyView() {
        emptyView?.removeFromSuperview()
    }
    
    func showEmptyView(_ view: UIView) {
        emptyView = view
        addSubview(emptyView!)
    }
}
