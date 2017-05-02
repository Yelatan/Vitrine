//
//  DrawerScrollView.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/4/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class DrawerScrollView: UIScrollView, UIScrollViewDelegate {
    var isOpened = false
    var handleHeight: CGFloat = 44
    var bottomConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        alwaysBounceVertical = true
        isPagingEnabled = true
        delegate = self
    }
    
    func toggle(_ animated: Bool = true) {
        if isOpened {
            close(animated)
        }
        else if !isOpened {
            open(animated)
        }
    }
    
    func open(_ animated: Bool = true) {
        setParentTopOffset(superview!.frame.size.height - frame.size.height, animated: animated)
        isOpened = true
    }
    
    func close(_ animated: Bool = true) {
        setParentTopOffset(superview!.frame.size.height - handleHeight, animated: animated)
        isOpened = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y > 20 && !isOpened {
            open()
        }
        else {
            if scrollView.contentOffset.y < -20 && isOpened {
                close()
            }
        }
    }
    
    fileprivate func setParentTopOffset(_ top: CGFloat, animated: Bool = true) {
        if bottomConstraint == nil {
            var newFrame = frame
            newFrame.origin.y = top
            if animated {
                UIView.animate(withDuration: 0.2, animations: {
                    self.frame = newFrame
                })
            }
            else {
                self.frame = newFrame
            }
        }
        else {
            setParentBottomConstraint(superview!.frame.size.height - top, animated: animated)
        }
    }
    
    fileprivate func setParentBottomConstraint(_ bottom: CGFloat, animated: Bool = true) {
        bottomConstraint?.constant = bottom
        if animated {
            UIView.animate(withDuration: 0.2, animations: { 
                self.layoutIfNeeded()
            })
        }
    }
}
