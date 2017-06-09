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
        
        headers["page"] = "\(page)"
        headers["page-size"] = "\(pageSize)"
        
//        params.find("disabled", value: "false")
        params.find["disabled"] = "false" as AnyObject
        
//        params.find("_cityId", value: GlobalConstants.Person.CityID)
        params.find["_cityId"] = GlobalConstants.Person.CityID as AnyObject
        
        if !searchString.isEmpty {
//            params.find("search", value: searchString)
            params.find["search"] = searchString as AnyObject
        }
        
        if geoSort {
            location = [locManager.location!.coordinate.longitude, locManager.location!.coordinate.latitude]
//            params.find("coordinates", value: ["$near": location])
            params.find["coordinates"] = ["$near": location] as AnyObject
        }
        
        if let r = request {
            r.cancel()
        }
        
//        request = API.get("malls", params: params, encoding: <#URLEncoding.Destination#>, headers: headers) { response in
//        request = Alamofire.request("http://apivitrine.witharts.kz/api/malls", parameters: params.get()).responseJSON { response in
        request = Alamofire.request("http://manager.vitrine.kz:3000/api/malls", parameters: params.params, headers: headers).responseJSON { response in            
            switch(response.result) {
            case .success(let JSON):
                let malls = Mall.fromJSONArray(JSON as AnyObject, withLocation: location)                
                self.mallsTableView.malls.append(contentsOf: malls)
                if(malls.count < self.pageSize) {
                    self.mallsTableView.moreDataAvailable = false
                }else {
                    self.page += 1
                }
            case .failure(let error):
                print(error)
            }
        }
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
