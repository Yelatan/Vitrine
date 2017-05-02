//
//  ProductSortMethodController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/1/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class ProductSortMethodController: UITableViewController {
    var selectedMethod = ProductSortMethod.PriceAscending
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProductSortMethod.all.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell")!
        let method = ProductSortMethod.all[indexPath.row]
        cell.textLabel!.text = method.rawValue
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        cell.selectedBackgroundView = bgView
        
        if method == selectedMethod {
            cell.isSelected = true
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMethod = ProductSortMethod.all[indexPath.row]
        performSegue(withIdentifier: "SelectSortMethod", sender: self)
    }
}
