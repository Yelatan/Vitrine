//
//  NewsController.swift
//  Vitrine
//
//  Created by Vitrine on 08.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire


class NewsController: UIViewController, VTableViewDelegate, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!

    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var favButton: UIBarButtonItem!
    
    @IBOutlet weak var tabsView: UIView!
    @IBOutlet weak var newsTableView: NewsTableView!
    @IBOutlet weak var tabEventsButton: UIButton!
    @IBOutlet weak var tabOffersButton: UIButton!
    
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
    }
    
    func vTableView<News>(didSelectItem item: News) {
        performSegue(withIdentifier: "NewsDetail", sender: item as? AnyObject)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! NewsDetailController
        controller.news = sender as! News
    }
    
    func vTableViewDidRequestMoreData() {
        var url = ""
        var headers = [String: String]()
        
        let params = VitrineParams()
        
//        headers["page"] = "\(page)"
//        headers["page-size"] = "\(pageSize)"
        headers["Authorization"] = nil
        
        params.main("expand", value: "_networkId:name logo,_vitrines:address")
//        params.find("disabled", value: "false")
        params.find["disabled"] = "false" as AnyObject
        
        if (favFilter) {
            url = "users/favorite-networks/news"
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
        } else {
            url = "news"
        }
        
        if (!searchString.isEmpty) {
//            params.find("search", value: searchString)
            params.find["search"] = searchString as AnyObject
        }
        
        if (type == "0") {
//            params.find("type", value: "stock")
            params.find["type"] = "stock" as AnyObject
            
        }
        
        if let r = request {
            r.cancel()
        }
        
//        request = API.get("\(url)", params: params, encoding: <#URLEncoding.Destination#>, headers: headers) { response in
//         request = Alamofire.request("http://apivitrine.witharts.kz/api/users/login", method: .get, parameters: params as [String : AnyObject], headers: headers).
       //Bakohttp://manager.vitrine.kz:3000/api
        Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)", parameters: params.get(),headers: headers).responseJSON { response in
            print("http://manager.vitrine.kz:3000/api/\(url)")
            switch(response.result) {
            case .success(let JSON):
                let news = News.fromJSONArray(JSON as AnyObject)
                self.newsTableView.news.append(contentsOf: news)
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
