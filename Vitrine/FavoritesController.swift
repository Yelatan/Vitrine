//
//  FavoritesController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/11/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class FavoritesController: UIViewController, VTableViewDelegate, ProductsTableViewDelegate, UISearchBarDelegate {
    
    enum DisplayMode {
        case list, grid
    }
    
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIView!
    weak var productsTableView: ProductsTableView!
    
    @IBOutlet weak var unsignedPlaceholderView: UIView!
    
    var request: Alamofire.Request?
    var displayMode = DisplayMode.grid
    var searchParams = ProductSearchParams()
    var page = 1
    var pageSize = 5
    var searchString = ""
    
    func refreshList() {
        self.productsTableView.products = [Product]()
        self.productsTableView.moreDataAvailable = true
        page = 1
        vTableViewDidRequestMoreData()
    }
    
    @IBAction func didClickSearchbarButton(_ sender: AnyObject) {
        showSearchBar()
    }

    @IBAction func unwindFromProductSortController(_ segue: UIStoryboardSegue) {
        refreshList()
    }
    
    func showSearchBar() {
        searchBar.becomeFirstResponder()
        
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.rightBarButtonItems = []
    }
    
    func dismissSearchBar() {
        view.endEditing(true)
        
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = [self.searchButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if GlobalConstants.Person.hasToken() {
            productsTableView.delegate = self
            productsTableView.networkSelectDelegate = self
        }
        else {
            unsignedPlaceholderView.isHidden = false
            view.bringSubview(toFront: unsignedPlaceholderView)
            self.navigationItem.rightBarButtonItems = []
        }
    }
    
    func vTableView<Product>(didSelectItem item: Product) {
        performSegue(withIdentifier: "ProductDetail", sender: item as! AnyObject)
    }
    
    func vTableViewDidRequestMoreData() {
        let url = "users/favorite-products"
        var headers = [String: String]()
        let params = VitrineParams()
        
        headers["page"] = "\(page)"
        headers["page-size"] = "\(pageSize)"
        
        params.searchParams(searchParams)
        params.main("expand", value: "_networkId:name,_brandId:name")
        
        if (!searchString.isEmpty) {
//            params.find("search", value: searchString)
            params.find["search"] = searchString as AnyObject
        }
        
        if let r = request {
            r.cancel()
        }
        //request = Alamofire.request(url, parameters: params.get(), headers: headers).responseJSON { response in
        //"http://apivitrine.witharts.kz/api/\(url!)", parameters:params.get(),encoding:URLEncoding.default
        request = Alamofire.request("http://apivitrine.witharts.kz/api/\(url)", parameters:params.get(),encoding:URLEncoding.default).responseJSON { response in
            print("selected products")
            print("http://apivitrine.witharts.kz/api/\(url)")
            print(params.get())
            switch(response.result) {
            case .success(let JSON):
                let products = Product.fromJSONArray(JSON as AnyObject)
                print("products")
                print(products)
                self.productsTableView.products.append(contentsOf: products)
                if(products.count < self.pageSize) {
                    self.productsTableView.moreDataAvailable = false
                } else {
                    self.page += 1
                }
                if products.count == 0 && self.page == 1 {
                    self.productsTableView.showEmptyMessage("Ничего не найдено")
                }
            case .failure(let error):
                print(error)
                }
        }
        
        //shoudl be like above
//        request = API.get(url, params: params, encoding: <#URLEncoding.Destination#>, headers: headers) { response in switch(response.result) {
//        request = Alamofire.request(url, headers: headers,  parameters: params.get()){ response in
//            switch(response.result) {
//            case .success(let JSON):
//                let products = Product.fromJSONArray(JSON as AnyObject)
//                self.productsTableView.products.append(contentsOf: products)
//                
//                if(products.count < self.pageSize) {
//                    self.productsTableView.moreDataAvailable = false
//                } else {
//                    self.page += 1
//                }
//                
//                if products.count == 0 && self.page == 1 {
//                    self.productsTableView.showEmptyMessage("Ничего не найдено")
//                }
//            case .failure(let error):
//                print(error)
//                }
//        }
        

    }
    
    func productsTableView(didClickNetwork networkId: String) {
        performSegue(withIdentifier: "Products", sender: networkId)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissSearchBar()
        searchString = ""
        refreshList()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 2 || searchString.characters.count > searchText.characters.count) {
            searchString = searchText
            refreshList()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!) {
            case "ProductDetail":
                let controller = segue.destination as! ProductDetailController
                controller.product = sender as! Product
                controller.showVitrineButton = true
                controller.title = title
            case "SearchSettings":
                let controller = segue.destination as! ProductSortController
                controller.params = searchParams
            case "Products":
                let controller = segue.destination as! ProductsController
                controller.networkId = sender as! String
            default:
                return
        }
    }
}