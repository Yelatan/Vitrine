//
//  GlobalSearchController.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/6/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class GlobalSearchController: UIViewController, VTableViewDelegate, CLLocationManagerDelegate {
    enum SearchMode {
        case products, vitrines
    }
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var productsButton: UIButton!
    @IBOutlet weak var vitrinesButton: UIButton!
    @IBOutlet weak var productsTab: UIView!
    @IBOutlet weak var vitrinesTab: UIView!
    @IBOutlet weak var productsTableView: ProductsTableView!
    @IBOutlet weak var vitrinesTableView: NetworkTableView!
    
    
    var request: Alamofire.Request?
    var initialSearchString = ""
    var page = 1
    var pageSize = 5
    var searchParams = ProductSearchParams()
    var locManager = CLLocationManager()
    var geoSort = false
    var searchMode = SearchMode.products {
        didSet {
            if searchMode == .products {
                productsButton.isSelected = true
                vitrinesButton.isSelected = false
                productsTab.isHidden = false
                vitrinesTab.isHidden = true
            }
            if searchMode == .vitrines {
                productsButton.isSelected = false
                vitrinesButton.isSelected = true
                productsTab.isHidden = true
                vitrinesTab.isHidden = false
            }
            
            if vitrinesTableView.delegate == nil {
                productsTableView.reset()
                vitrinesTableView.reset()
                page = 1
                vitrinesTableView.delegate = self
            } else {
                refreshList()
            }
        }
    }
    
    @IBAction func didClickBackButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didClickTab(_ sender: UIButton) {
        searchMode = sender == productsButton ? .products : .vitrines
    }
    
    @IBAction func didClickGeoSort(_ sender: AnyObject) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            if locManager.location != nil || geoSort {
                geoSort = !geoSort
                refreshList()
            }
        }
    }
    
    func refreshList() {
        productsTableView.reset()
        vitrinesTableView.reset()
        page = 1        
        vTableViewDidRequestMoreData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.searchBar
        
        if !initialSearchString.isEmpty {
            searchParams.text = initialSearchString
            initialSearchString = ""
        }
        searchBar.text = searchParams.text
        productsTableView.delegate = self
        
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
    }
    
    @IBAction func unwindFromProductSortController(_ segue: UIStoryboardSegue) {
        searchBar.text = searchParams.text
        refreshList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!) {
        case "ProductDetail":
            let controller = segue.destination as! ProductDetailController
            controller.product = sender as! Product
            controller.title = title
        case "Vitrine":
            let controller = segue.destination as! ProductsController
            controller.vitrine = sender as! Vitrine
            controller.network = sender as! Network
        case "SearchSettings":
            let controller = segue.destination as! ProductSortController
            controller.params = searchParams
        default:
            return
        }
    }
    
    func vTableView<AnyObject>(didSelectItem item: AnyObject) {
        if searchMode == .products {
            let product = item as! Product
            performSegue(withIdentifier: "ProductDetail", sender: product)
        } else {
            let vitrine = item as! Network
            performSegue(withIdentifier: "Vitrine", sender: vitrine)
        }
    }
    
    func vTableViewDidRequestMoreData() {
        let params = VitrineParams()
        var headers = [String: String]()
        var location = [Double]()
        var url: String!
        
        headers["page"] = "\(page)"
        headers["page-size"] = "\(pageSize)"
        
        if searchMode == .products {
            url = "products"
            params.searchParams(searchParams)
            params.main("expand", value: "_networkId:name,_brandId:name")
        } else {
            
            params.main("expand", value: "_vitrines:address coordinates name _cityId")
//            url = "vitrines"
            url = "networks"

            if geoSort {
                print("near sort")
            }
        }
        
        if (searchParams.text != nil) {
            params.find["search"] = searchParams.text! as AnyObject
        }
        
        if let r = request {
            r.cancel()
        }        
        request = Alamofire.request("http://manager.vitrine.kz:3000/api/\(url!)", parameters: params.get(), encoding:URLEncoding.default).responseJSON { response in
            switch(response.result) {
            case .success(let JSON):
                var tView = VTableViewWrapper()
                if self.searchMode == .products {
                    tView = self.productsTableView
                    let data = Product.fromJSONArray(JSON as AnyObject)
                    self.productsTableView.products = data
                    if data.count == 0  {
                        tView.showEmptyMessage("Ничего не найдено")
                    }
                } else {
                    tView = self.vitrinesTableView
                    var data = Network.fromJSONArray(JSON as AnyObject)
                    self.vitrinesTableView.networks = data
                    if data.count == 0  {
                        tView.showEmptyMessage("Ничего не найдено")
                    }
//                    if(data.count < self.pageSize) {
//                        self.vitrinesTableView.moreDataAvailable = false
//                    } else {
//                        self.page += 1
//                    }
//                    self.vitrinesTableView.vitrines.append(contentsOf: data)
                    
                }
            case .failure(let error):
                print(error)
                }
            }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchParams.text = ""
        refreshList()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 1 || searchParams.text!.characters.count > searchText.characters.count) {
            searchParams.text = searchText
            refreshList()
        }
    }
}
