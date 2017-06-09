//
//  MallsDetailController.swift
//  Vitrine
//
//  Created by Vitrine on 10.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire

class MallsDetailController: UIViewController, UISearchBarDelegate, VTableViewDelegate, FilterDelegate {

    var mall: Mall!
    var filterController: FilterController!
    var categoryId = ""
    var page = 1
    var pageSize = 5
    var searchString = ""
    var favorite = false
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imagePagerView: ImagePagerView!
    @IBOutlet weak var logoView: RoundLogoView!
    
    @IBOutlet weak var drawerScrollView: DrawerScrollView!
    @IBOutlet weak var drawerScrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var vitrinesTableView: VitrinesTableView!
    
    @IBAction func didClickSearchButton(_ sender: AnyObject) {
        showSearchBar()
    }
    
    @IBAction func didClickToggleDrawerButton(_ sender: AnyObject) {
        drawerScrollView.toggle()
    }
    
    func refreshList() {
        self.vitrinesTableView.vitrines = [Vitrine]()
        self.vitrinesTableView.moreDataAvailable = true
        page = 1
        vTableViewDidRequestMoreData()
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        title = mall.name
        if mall.logo != nil {
            logoView.imageURL = API.imageURL("malls/logo", string: mall.logo!)
        }
        vitrinesTableView.delegate = self
        drawerScrollView.bottomConstraint = drawerScrollViewBottom
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.vitrinesTableView.tableView.addParallax(with: self.headerView, andHeight: 200, andShadow: false)
        self.vitrinesTableView.tableView.contentOffset = CGPoint(x: 0, y: -200)
        if mall.photos.count > 0 && imagePagerView.imageCount == 0 {
            for photo in mall.photos {
                imagePagerView.addImageURL(API.imageURL("malls/photos", string: photo))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!) {
        case "Products":
            let controller = segue.destination as! ProductsController
            controller.vitrine = sender as? Vitrine
            controller.mall = mall
        case "FilterEmbed":
            filterController = segue.destination as! FilterController
            filterController.mall = mall
            filterController.filterDelegate = self
        case "MallInfo":
            let controller = segue.destination as! MallInfoController
            controller.mall = mall
        case "Map":
            let controller = segue.destination as! MapController
            controller.pins.append(mall)
            controller.title = title
        case "MallMap":
            let controller = segue.destination as! MallMapController
            controller.mall = mall
            controller.title = title
        default:
            return
        }
    }
    
    func vTableView<Vitrine>(didSelectItem item: Vitrine) {
        performSegue(withIdentifier: "Products", sender: item as? AnyObject)
    }
    
    func vTableViewDidRequestMoreData() {
        let params = VitrineParams()
        var headers = [String: String]()
        var url = "vitrines"
        
//        headers["page"] = "\(page)"
//        headers["page-size"] = "\(pageSize)"
        headers["Authorization"] = nil
        
        if (favorite) {
            url = "users/favorite-vitrines"
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
        }
        
        if (mall != nil) {
//            params.find("_mallId", value: mall!.id)
            params.find["_mallId"] = mall!.id as AnyObject
        }
        
        if (!categoryId.isEmpty) {
//            params.find("_categoryId", value: categoryId)
            params.find["_categoryId"] = categoryId as AnyObject
        }
        
        if (!searchString.isEmpty) {
//            params.find("search", value: searchString)
            params.find["search"] = searchString as AnyObject
        }
        
        params.main("expand", value: "_networkId:logo name description")
        
//        Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON { (response) in
        Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)", parameters: params.get(), headers: headers).responseJSON { response in            
            switch response.result {
            case .success(let JSON):
                let data = Vitrine.fromJSONArray(JSON as AnyObject)
//                self.vitrinesTableView.vitrines.append(contentsOf: data)
                self.vitrinesTableView.vitrines = data
                
                if data.count == 0 {
                    self.notificationView.isHidden = false                    
                }else{
                    self.notificationView.isHidden = true
                }
                if(data.count < self.pageSize) {
                    self.vitrinesTableView.moreDataAvailable = false
                } else {
                    self.page += 1
                }                
            case .failure(let error):
                print(error)
                }
            }
        }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismissSearchBar()
        self.searchString = ""
        self.refreshList()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 2 || searchString.characters.count > searchText.characters.count) {
            searchString = searchText
            refreshList()
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
}
