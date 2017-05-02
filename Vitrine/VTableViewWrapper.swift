//
//  VTableViewWrapper.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/4/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


protocol VTableViewDelegate {
    func vTableView<ItemType>(didSelectItem item: ItemType)
    func vTableViewDidRequestMoreData()
}


class VTableViewWrapper: VUtilView, UITableViewDelegate, UITableViewDataSource {
    var cellReuseIdentifiers: [String] {
        return []
    }
    let tableView = UITableView()
    var moreDataAvailable = true {
        didSet {
            if (!moreDataAvailable) {
                tableView.removeInfiniteScroll()
            } else {
                tableView.addInfiniteScroll { (scrollView) in
                    self.delegate?.vTableViewDidRequestMoreData()
                }
                tableView.infiniteScrollIndicatorStyle = .white
            }
        }
    }
    var items = [AnyObject]() {
        didSet {
            tableView.reloadData()
            tableView.finishInfiniteScroll()
            
            if items.count > 0 {
                hideLoader()
            }
            else {
                showLoader()
            }
        }
    }
    var delegate: VTableViewDelegate? {
        didSet {
            delegate?.vTableViewDidRequestMoreData()
        }
    }
    var hiddenKeyboardPadding: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.frame = bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.clipsToBounds = false
        addSubview(tableView)
        
        for id in cellReuseIdentifiers {
            let nib = UINib(nibName: id, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: id)
        }

//        tableView.addInfiniteScrollWithHandler { (scrollView) in
//            self.delegate?.vTableViewDidRequestMoreData()
//        }
//        tableView.infiniteScrollIndicatorStyle = .White
        
        NotificationCenter.default.addObserver(self, selector: #selector(VTableViewWrapper.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VTableViewWrapper.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.vTableView(didSelectItem: item)
    }
    
    override func showEmptyMessage(_ text: String) {
        hideLoader()
        super.showEmptyMessage(text)
    }
    
    func keyboardWillShow(_ notification:Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
            UIView.animate(withDuration: animationDuration!, animations: { 
                self.tableView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - keyboardSize.height + self.hiddenKeyboardPadding)
            })
        }
    }
    
    func keyboardWillHide(_ notification:Notification){
        if let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            UIView.animate(withDuration: animationDuration, animations: {
                self.tableView.frame = self.bounds
            })
        }
    }
}
