//
//  BaseAdapter.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/17/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation


protocol BaseAdapter: UITableViewDataSource {
    func getItem(_ indexPath: IndexPath) -> AnyObject!
}
