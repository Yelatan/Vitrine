//
//  MallsController.swift
//  Vitrine
//
//  Created by Vitrine on 10.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class MallsController: UIViewController, VTableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var mallsTableView: MallsTableView!    
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var cityButton: UIBarButtonItem!
    
    var request: Alamofire.Request?
    var malls = [Mall]()
    
    var category_id: String = "0"
    var sub_category_id: String = "0"
    var favourite_shopping_mall: String = "0"
    var locManager = CLLocationManager()
    
    var page = 1
    var pageSize = 9999
    var searchString = ""
    
    var geoSort = false {
        didSet {
            cityButton.tintColor = geoSort ? UIColor(red: 1, green: 1, blue: 1, alpha: 1) : UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBAction func didClickSearchButton(_ sender: AnyObject) {
        showSearchBar()
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
        self.mallsTableView.malls = [Mall]()
        self.mallsTableView.moreDataAvailable = true
        page = 1
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
        mallsTableView.delegate = self
        
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "MallDetail"){
            let controller = segue.destination as! MallsDetailController
            controller.mall = sender as! Mall
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func vTableView<Mall>(didSelectItem item: Mall) {
        performSegue(withIdentifier: "MallDetail", sender: item as? AnyObject)
    }
    
    func vTableViewDidRequestMoreData() {
        var headers = [String: String]()
        var location = [Double]()
        let params = VitrineParams()
        
//        headers["page"] = "\(page)"
//        headers["page-size"] = "\(pageSize)"
        headers["Authorization"] = nil
        
        params.find["disabled"] = "false" as AnyObject
        
        if let r = request {
            r.cancel()
        }
        
        if geoSort {
            GlobalConstants.needBool = true
            location = [locManager.location!.coordinate.longitude, locManager.location!.coordinate.latitude]
////            params.find["coordinates"] = ["$near": location] as AnyObject
//            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token)"
            
        }else{
            GlobalConstants.needBool = false
            params.main("sort", value: "name")
//            params.main("expand", value: "_vitrines:\(GlobalConstants.Person.CityID!)")
//            params.main("_cityId", value: "ObjectId('\(GlobalConstants.Person.CityID!)')")
            params.find["_cityId"] = GlobalConstants.Person.CityID as AnyObject
            
        }
        if (!searchString.isEmpty) {
            params.find["search"] = searchString as AnyObject
        }
        request = Alamofire.request("http://manager.vitrine.kz:3000/api/malls", parameters:params.get(), headers: headers).responseJSON { response in
            var tView = VTableViewWrapper()
            tView = self.mallsTableView
            switch(response.result) {
            case .success(let JSON):
                self.mallsTableView.moreDataAvailable = false
                if self.geoSort{
                    let malls = Mall.fromJSONArray(JSON as AnyObject, withLocation: location)
                    self.mallsTableView.malls.append(contentsOf: malls)
                    if self.mallsTableView.malls.count == 0 {
                        tView.showEmptyMessage("Ничего не найдено")
                    }
                }else{
                    let malls = Mall.fromJSONArray(JSON as AnyObject)
                    self.mallsTableView.malls.append(contentsOf: malls)
                    if self.mallsTableView.malls.count == 0 {
                        tView.showEmptyMessage("Ничего не найдено")
                    }
                }                
//                if(malls.count < self.pageSize) {
//                    self.mallsTableView.moreDataAvailable = false
//                }else {
//                    self.page += 1
//                }
            case .failure(let error):
                print(error)                
                tView.showEmptyMessage("Не удалось получить ответ от сервера")
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissSearchBar()
        searchString = ""
        refreshList()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 1 || searchString.characters.count > searchText.characters.count) {
            searchString = searchText
            refreshList()
        }
    }
}
