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
    var pageSize = 9999
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
        if (GlobalConstants.Person.hasToken()) {
            headers = [String: String]()
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
        }
        let params = VitrineParams()
        
        headers["page"] = "\(page)"
        headers["page-size"] = "\(pageSize)"
        
        params.searchParams(searchParams)
        params.main("expand", value: "_networkId:name,_brandId:name")
        
        if (!searchString.isEmpty) {
            params.find["search"] = searchString as AnyObject
        }
        
        if let r = request {
            r.cancel()
        }
        request = Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)", parameters:params.get(), headers: headers).responseJSON { response in
            print("http://manager.vitrine.kz:3000/api/\(url)")
            print(params.get())
            print(response)
            switch(response.result) {
            case .success(let JSON):
                let products = Product.fromJSONArray(JSON as AnyObject)
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
                self.productsTableView.showEmptyMessage("Не удалось получить ответ от сервера")
            }
        }
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
