//
//  VitriniController.swift
//  Vitrine
//
//  Created by Vitrine on 10.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

enum VitriniControllerDisplayMode {
    case networks, vitrines
}


class NetworksController: UIViewController, FilterDelegate, VTableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var cityButton: UIBarButtonItem!
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var vitrinesTableView: VitrinesTableView!
    @IBOutlet weak var networkTableView: NetworkTableView!
    @IBOutlet weak var drawerScrollView: DrawerScrollView!
    @IBOutlet weak var drawerScrollViewBottom: NSLayoutConstraint!
    @IBOutlet var networkTableViewBottom: NSLayoutConstraint!
    @IBOutlet var vitrinesTableViewBottom: NSLayoutConstraint!
    
    var request: Alamofire.Request?
    var favourite_shop: String = "0"
    var categoryId = ""
    var page = 0
    var pageSize = 9999
    var searchString = ""
    var favorite = false
    var locManager = CLLocationManager()
    var geoSort = false {
        didSet {
            cityButton.tintColor = geoSort ? UIColor(red: 1, green: 1, blue: 1, alpha: 1) : UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
//            networkTableView.isHidden = geoSort
//            vitrinesTableView.isHidden = !geoSort
        }
    }
    
    @IBAction func didClickSearchButton(_ sender: AnyObject) {
        showSearchBar()
    }
    
    @IBAction func didClickFilterToggle(_ sender: AnyObject) {
        drawerScrollView.toggle()
    }
    
    @IBAction func didClickGeoSort(_ sender: AnyObject) {
//        if !favorite{
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
                if locManager.location != nil || geoSort {
                    geoSort = !geoSort
                    if vitrinesTableView.delegate == nil {
                        networkTableView.reset()
//                        vitrinesTableView.reset()
                        //                    page = 1
//                        vitrinesTableView.delegate = self
                        networkTableView.delegate = self
                    } else {
                        refreshList()
                    }
                }
            }
    }
    
    func refreshList() {
        networkTableView.reset()
//        vitrinesTableView.reset()
//        page = 1
        vTableViewDidRequestMoreData()
    }
    
    func showSearchBar() {
        searchBar.setValue("Отмена", forKey:"cancelButtonText")
        searchBar.becomeFirstResponder()

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.rightBarButtonItems = []
    }
    
    func dismissSearchBar() {
        view.endEditing(true)

        self.navigationItem.leftBarButtonItem = self.menuButton
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = [self.cityButton, self.searchButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        geoSort = false
        networkTableView.delegate = self
        networkTableView.hiddenKeyboardPadding = 44
        vitrinesTableView.hiddenKeyboardPadding = 44
        
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        drawerScrollView.bottomConstraint = drawerScrollViewBottom
    }
    
//    func locationManager(manager: CLLocationManager) {
//        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!) {
        case "Products":
            let controller = segue.destination as! ProductsController
            
                let network = sender as? Network
                if network!.vitrines.count == 1 {
                    controller.vitrineId = network!.vitrines[0].id
                }
                else {
                    controller.network = sender as? Network
                }
            
        case "EmbeddedFilterSegue":
            let filterViewController = segue.destination as! FilterController
            filterViewController.filterDelegate = self
        default:
            return
        }
    }
    
    func vTableView<Network>(didSelectItem item: Network) {
        performSegue(withIdentifier: "Products", sender: item as? AnyObject)
    }
    
    func vTableViewDidRequestMoreData() {
        let params = VitrineParams()
        let location = [Double]()
        var headers = [String: String]()
        var url: String!
//        headers["page"] = "\(page)"
//        headers["page-size"] = "\(pageSize)"
        headers["Authorization"] = nil
        params.find["disabled"] = "false" as AnyObject
        params.main("expand", value: "_vitrines:address coordinates name _cityId")
        url = "networks"
        if let r = request {
            r.cancel()
        }
        if (!categoryId.isEmpty) {
            params.find["_categories"] = categoryId as AnyObject
        }
        if (favorite) {
            url = "users/favorite-networks"
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
        }
        
        if geoSort {
            GlobalConstants.needBool = true
            
        } else {
            GlobalConstants.needBool = false
            params.main("sort", value: "name")
        }
        if (!searchString.isEmpty) {
            params.find["search"] = searchString as AnyObject            
        }
        request =  Alamofire.request("http://manager.vitrine.kz:3000/api/\(url!)", parameters: params.get(), headers: headers).responseJSON { response in
            var tView = VTableViewWrapper()
            tView = self.networkTableView
            switch(response.result) {
            case .success(let JSON):
                if self.geoSort {
                    let data = Network.fromJSONArrayDis(JSON as AnyObject)
                    self.networkTableView.networks.append(contentsOf: data)
                    
                    if(data.count < self.pageSize) {
                        self.networkTableView.moreDataAvailable = false
                    } else {
                        self.page += 1
                    }
                    if data.count == 0 {
                        tView.showEmptyMessage("Ничего не найдено")
                    }
                } else {
                    tView = self.networkTableView
                    let data = Network.fromJSONArray(JSON as AnyObject)
                    self.networkTableView.networks.append(contentsOf: data)
                    if(data.count < self.pageSize) {
                        self.networkTableView.moreDataAvailable = false
                    } else {
                        self.page += 1
                    }
                    if data.count == 0 {
                        tView.showEmptyMessage("Ничего не найдено")
                    }
                }
            case .failure(let error):                
                print(error)
                tView.showEmptyMessage("Не удалось получить ответ от сервера")
            }
        }
    }
    
    func onFilter(_ id: String) {
        categoryId = id
        refreshList()
    }
    
    func onFavorite() {
        favorite = !favorite
        refreshList()
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
}
