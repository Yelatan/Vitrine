//
//  NewsController.swift
//  Vitrine
//
//  Created by Vitrine on 08.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire


class NewsController: UIViewController, VTableViewDelegate, FilterDelegate, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!

    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var favButton: UIBarButtonItem!
    
    @IBOutlet var drawerScrollViewBottom: NSLayoutConstraint!
    @IBOutlet var drawerScrollView: DrawerScrollView!
    @IBOutlet weak var tabsView: UIView!
    @IBOutlet weak var newsTableView: NewsTableView!
    @IBOutlet weak var tabEventsButton: UIButton!
    @IBOutlet weak var tabOffersButton: UIButton!
    var locManager = CLLocationManager()
    
    var categoryId = ""
    var favorite = false
    var request: Alamofire.Request?
    var favFilter = false {
        didSet {
            favButton.tintColor = favFilter ? UIColor(red: 1, green: 1, blue: 1, alpha: 1) : UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }
    }
    var page = 1
    var pageSize = 5
    var type = "1"
    var searchString = ""
    
    @IBAction func didClickTabButton(_ sender: UIButton) {
        switch(sender) {
        case tabEventsButton:
            tabEventsButton.isSelected = true
            tabOffersButton.isSelected = false
            type = "1"
        default:
            tabEventsButton.isSelected = false
            tabOffersButton.isSelected = true
            type = "0"
        }
        
        refreshList()
    }
    
    @IBAction func didClickFavButton(_ sender: UIBarButtonItem) {
        GlobalConstants.Person.authenticated(fromController: self) {
            self.favFilter = !self.favFilter
            self.refreshList()
        }
    }
    
    @IBAction func didClickFilterToggle(_ sender: Any) {
        drawerScrollView.toggle()
    }
    @IBAction func didClickSearchButton(_ sender: AnyObject) {
        showSearchBar()
    }
    
    func refreshList() {
        self.newsTableView.news = [News]()
        self.newsTableView.moreDataAvailable = true
        page = 1
        vTableViewDidRequestMoreData()
    }
    
    func showSearchBar() {
        searchBar.becomeFirstResponder()
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.rightBarButtonItems = []
    }
    
    func dismissSearchBar() {
        view.endEditing(true)
        
        self.navigationItem.leftBarButtonItem = self.menuButton
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = [self.favButton, self.searchButton]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        view.bringSubview(toFront: tabsView)
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        favFilter = false
        newsTableView.delegate = self
        newsTableView.hiddenKeyboardPadding = 44
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locManager.delegate = self as! CLLocationManagerDelegate
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        drawerScrollView.bottomConstraint = drawerScrollViewBottom
    }
    
    func vTableView<News>(didSelectItem item: News) {
        performSegue(withIdentifier: "NewsDetail", sender: item as? AnyObject)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!) {
        case "NewsDetail":
            let controller = segue.destination as! NewsDetailController
            controller.news = sender as! News
//            let controller = segue.destination as! ProductsController
//            let network = sender as? Network
//            if network!.vitrines.count == 1 {
//                controller.vitrineId = network!.vitrines[0].id
//            }
//            else {
//                controller.network = sender as? Network
//            }

        case "EmbeddedFilterSegue":
            let filterViewController = segue.destination as! FilterController
            filterViewController.filterDelegate = self
        default:
            return
        }
    }
    
    func vTableViewDidRequestMoreData() {
        var url = ""
        var headers = [String: String]()
        let params = VitrineParams()
//        headers["page"] = "\(page)"
//        headers["page-size"] = "\(pageSize)"
        headers["Authorization"] = nil
        params.find["disabled"] = "false" as AnyObject
        
        params.main("expand", value: "_networkId:name logo,_vitrines:address name _cityId")
        if GlobalConstants.Person.CityID != nil {
            params.find["_cityId"] = GlobalConstants.Person.CityID! as AnyObject
        }
        
        
        if let r = request {
            r.cancel()
        }
        
        if (!categoryId.isEmpty) {
//            params.find["_categories"] = categoryId as AnyObject
            params.find["categoryId"] = categoryId as AnyObject
        }
        if (favFilter) {
            url = "users/favorite-networks/news"
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
        } else {
            url = "news"
        }
        
        if (!searchString.isEmpty) {
            params.find["search"] = searchString as AnyObject
        }
        
        if (type == "0") {
            params.find["type"] = "stock" as AnyObject
        }
        
        request = Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)", parameters: params.get(),headers: headers).responseJSON { response in
            print(params.get())
            switch(response.result) {
            case .success(let JSON):
                let news = News.fromJSONArray(JSON as AnyObject)
                self.newsTableView.news = news
                
                if(news.count < self.pageSize) {
                    self.newsTableView.moreDataAvailable = false
                }else {
                    self.page += 1
                }
            
                if news.count == 0 && self.page == 1 {
                    self.newsTableView.showEmptyMessage("Нет новостей в данной категории")
                }
            case .failure(let error):
                print(error)
                self.newsTableView.showEmptyMessage("Не удалось получить ответ от сервера")
            }
        }
    }
    
    func onFilter(_ id: String) {
        categoryId = id
        refreshList()
    }
    func onFavorite() {
        favFilter = !favFilter
        refreshList()
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
