//
//  ProductSortCategoriesController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/1/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class ProductSortCategoriesController: UITableViewController {
    var vitrine: Vitrine?
    var network: Network?
    var categories = [ProductCategory]()
    var selectedCategory: ProductCategory?
    
    internal func loadData(_ id: String = "") {
        let params = VitrineParams()
        var url = "categories"
        
        if (!id.isEmpty) {
            url += "/\(id)"
            params.main("children", value: "1")
            if let v = vitrine {
//                params.find("_vitrineId", value: v.id)
                params.find["_vitrineId"] = v.id as AnyObject
            }
            
            if let n = network {
//                params.find("_networkId", value: n.id)
                params.find["_networkId"] = n.id as AnyObject
            }
        } else {
            params.main("top", value: "1")
            if let v = vitrine {
                url = "vitrines/\(v.id)/\(url)"
            }
            
            if let n = network {
                url = "networks/\(n.id)/\(url)"
            }
        }
        
//        API.get(url, params: params, encoding: <#URLEncoding.Destination#>) { response in
        //Alamofire.request("http://apivitrine.witharts.kz/api/users/login", parameters: params as [String : AnyObject]).responseJSON { response in
        //Bako
        Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)", parameters: params.get()).responseJSON { response in
            print("category sort")
            print(response)
            switch response.result {
            case .success(let JSON):
                self.categories = [ProductCategory]()
                if (id.isEmpty) {
                    let all = ProductCategory(withName: "Все категории")
                    all.parentAll = true
                    self.categories.append(all)                    

                    let productCategoryArray = ProductCategory.fromJSONArray(JSON as AnyObject)
                    for productCateg in productCategoryArray{
                        self.categories.append(productCateg)
                    }
                } else {
                    let parentCategory = Mapper<ProductCategory>().map((JSON as! Dictionary<String, AnyObject>)["category"])!
                    let all = Mapper<ProductCategory>().map((JSON as! Dictionary<String, AnyObject>)["category"])!
                    parentCategory.parentBack = true
                    all.parentAll = true
                    

                    self.categories.append(parentCategory)
                    self.categories.append(all)
                    self.categories.append(contentsOf: ProductCategory.fromJSONArray((JSON as! Dictionary<String, AnyObject>)["children"]!))
                }
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
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell")!
        let category = categories[indexPath.row]
        let textLabel = cell.viewWithTag(1) as! UILabel
        let imageView = cell.viewWithTag(2) as! UIImageView
        
        if category.parentAll {
            textLabel.text = "Все товары"
        } else {
            textLabel.text = category.name
        }
        
        if category.parentBack {
            textLabel.text = "Назад"
        } else if let logo = category.logo {
            imageView.sd_setImage(with: API.imageURL("categories/logo", string: logo))
        }
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        cell.selectedBackgroundView = bgView
        
        if selectedCategory != nil && category.name == selectedCategory!.name {
            cell.isSelected = true
        }
        
        return cell
    }
    
    var level: Int = 1
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedCategory = categories[indexPath.row]
//        performSegueWithIdentifier("SelectCategory", sender: self)
        let category = categories[indexPath.row]
        var categoryId: String = ""
        
        if category.parentAll {
            selectedCategory = categories[indexPath.row]
            performSegue(withIdentifier: "SelectCategory", sender: self)
        }
        
        if (indexPath.row == 0 && level > 1) {
            if (!category.parentId.isEmpty) {
                categoryId = category.parentId
            } else {
                level = 1
            }
        } else {
            level += 1
            categoryId = category.id
        }
        loadData(categoryId)
    }
}
