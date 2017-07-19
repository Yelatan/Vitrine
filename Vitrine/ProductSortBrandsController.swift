//
//  ProductSortBrandsController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/2/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ProductSortBrandsController: UITableViewController {
    var vitrine: Vitrine?
    var network: Network?
    var brands = [Brand]()
    var selectedBrand: Brand?
    
    func loadData() {
        var url = "brands"
        
        if let v = vitrine {
            url = "vitrines/\(v.id)/\(url)"
        }
        
        if let n = network {
            url = "brands?shop_id=\(n.id)"
        }
        Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)").responseJSON { response in            
            switch(response.result) {
            case .success(let JSON):
                let br = Brand(withName: "Все бренды")
                self.brands.append(br)
                self.brands.append(contentsOf: Brand.fromJSONArray(JSON as AnyObject))
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        loadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brands.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell")!
        let brand = brands[indexPath.row]
        let textLabel = cell.viewWithTag(1) as! UILabel
        let imageView = cell.viewWithTag(2) as! UIImageView
        
        textLabel.text = brand.name
        if let logo = brand.logo {
            imageView.sd_setImage(with: API.imageURL("brands/logo", string: logo))
        }
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        cell.selectedBackgroundView = bgView
        
        if selectedBrand != nil && brand.name == selectedBrand!.name {
            cell.isSelected = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBrand = brands[indexPath.row]
        performSegue(withIdentifier: "SelectBrand", sender: self)
    }
}
