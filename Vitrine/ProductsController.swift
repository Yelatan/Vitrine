//
//  VitriniDetailController.swift
//  Vitrine
//
//  Created by Vitrine on 10.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit
import Alamofire


class ProductsController: UIViewController, vCollectionViewDelegate {
    
    // Navbar
    @IBOutlet var likeButton: UIBarButtonItem!
    
    // Header
    
    @IBOutlet weak var swipeImages: CLabsImageSlider!
    @IBOutlet var headerView: UIView!
    @IBOutlet var logoView: RoundLogoView!
    @IBOutlet var imagePagerView: ImagePagerView!
    @IBOutlet weak var pickAddressButton: UIButton!
    @IBOutlet weak var addressPickerView: UIView!
    @IBOutlet weak var addressPickerViewTop: NSLayoutConstraint!
    
    // Network info
    @IBOutlet var infoView: UIScrollView!
    @IBOutlet var networkInfoContentHeight: NSLayoutConstraint!
    @IBOutlet var networkTitleLabel: UILabel!
    @IBOutlet var networkDetailLabel: UILabel!
    
    // Products collection
    @IBOutlet var toolbar: UIView!
    @IBOutlet var listButton: UIButton!
    @IBOutlet var gridButton: UIButton!
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var favButton: UIButton!
    @IBOutlet weak var productsCollectionView: ProductsCollectionView!

    var request: Alamofire.Request?
    var searchParams = ProductSearchParams()
    var initialRequest = true
    var vitrine: Vitrine?
    var network: Network?
    var networkId: String?
    var vitrineId: String?
    var mall: Mall?
    var page = 1
    var pageSize = 5
    var vitrinesPin = [MapObject]()
    
    func refreshList() {
        self.productsCollectionView.products = [Product]()
        self.productsCollectionView.moreDataAvailable = true
        page = 1
        vCollectionViewDidRequestMoreData()
    }
    
    @IBAction func Call(_ sender: AnyObject) {
        var phones = [String]()
        if vitrine != nil {
            phones = vitrine!.phones
        }
        else if network != nil {
            phones = network!.phones
        }
        
        if phones.count > 0 {
            let url = URL(string: "tel://\(phones[0])")!
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func map(_ sender: AnyObject) {
        
    }
    
    @IBAction func addLikeACtion(_ sender: AnyObject) {
        GlobalConstants.Person.authenticated(fromController: self) {
            
            
            let url = "users/favorite-network"
            let type = User.FAV_NETWORKS
            var id: String!
            
            if self.vitrine != nil {
                id = self.vitrine!.networkId
            } else if self.network != nil {
                id = self.network!.id
            }
            
            let params = ["_id": id]
            
            var headers = [String: String]()
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
            
            if (GlobalConstants.Person.getFavs(type).contains(id)) {
//                API.delete("\(url)/\(id)", encoding: <#URLEncoding.Destination#>) { response in
                Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)/\(id!)", method: .delete, parameters: params as [String : AnyObject], headers: headers).responseJSON { response in                    
                switch(response.result) {
                case .success(_):
                    GlobalConstants.Person.delFav(id, forKey: type)
                    self.likeButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
                case .failure(let error):
                    print(error)
                    }
                }
            } else {
//                API.post(url, params: params as [String : AnyObject], encoding: <#URLEncoding.Destination#>) { response in switch(response.result) {
                Alamofire.request("http://manager.vitrine.kz:3000/api/\(url)", method: .post, parameters: params as [String : AnyObject], headers: headers).responseJSON { response in
                switch(response.result) {
                case .success(_):
                    GlobalConstants.Person.setFav(id, forKey: type)
                    self.likeButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                case .failure(let error):
                    print(error)
                    }
                }
            }
        }
    }
    
    @IBAction func filterFavs(_ sender: AnyObject) {
        GlobalConstants.Person.authenticated(fromController: self) {
            self.favButton.isSelected = !self.favButton.isSelected
            self.refreshList()
        }
    }

    @IBAction func didClickListButton(_ sender: UIButton) {
        productsCollectionView.displayMode = .list
        listButton.isSelected = true
        gridButton.isSelected = false
    }
    
    @IBAction func didClickGridButton(_ sender: UIButton) {
        productsCollectionView.displayMode = .grid
        gridButton.isSelected = true
        listButton.isSelected = false
    }
    
    @IBAction func unwindFromProductSortController(_ segue: UIStoryboardSegue) {
        refreshList()
    }
    
    @IBAction func pickAddress(_ segue: UIStoryboardSegue) {
        print("address picked")
        let controller = segue.source as! NetworkAddressController
        vitrine = controller.selectedVitrine
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        productsCollectionView.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func initialize() {
        productsCollectionView.products = []
        initialRequest = true
        if (GlobalConstants.Person.token == nil) {
            likeButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }

        if vitrine != nil {
            title = vitrine!.name
            networkId = vitrine!.networkId
            if network != nil {
                logoView.imageURL = API.imageURL("networks/logo", string: network!.logo!)
            }
            else {
//                logoView.imageURL = API.imageURL("networks/logo", string: vitrine!.networkLogo!)
            }
//            if vitrine!.photos.count > 0 && imagePagerView.imageCount == 0 {
//                for photo in vitrine!.photos {
//                    imagePagerView.addImageURL(API.imageURL("vitrines/photos", string: photo))
//                }
//            }
            
            var vitrinePhotoUrls = [String]()
            for photo in vitrine!.photos {
                vitrinePhotoUrls.append(String(describing: API.imageURL("vitrines/photos", string: photo)))
            }            
            swipeImages.setUpView(imageSource: .Url(imageArray:vitrinePhotoUrls,placeHolderImage:UIImage(named:"ryba_vitrine_logo")),slideType:.ManualSwipe,isArrowBtnEnabled: true)
            pickAddressButton.setTitle(vitrine?.address, for: UIControlState())
            productsCollectionView.delegate = self
        }
        else if network != nil {
            title = network!.name
            networkId = network!.id
            logoView.imageURL = API.imageURL("networks/logo", string: network!.logo!)
//            if network!.photos.count > 0 && imagePagerView.imageCount == 0 {
//                for photo in network!.photos {
//                    imagePagerView.addImageURL(API.imageURL("networks/photos", string: photo))
//                }
//            }
            
            
            var vitrinePhotoUrls = [String]()
            for photo in network!.photos {
                vitrinePhotoUrls.append(String(describing: API.imageURL("networks/photos", string: photo)))
            }
            swipeImages.setUpView(imageSource: .Url(imageArray:vitrinePhotoUrls,placeHolderImage:UIImage(named:"ryba_vitrine_logo")),slideType:.ManualSwipe,isArrowBtnEnabled: true)
            
            
            productsCollectionView.delegate = self
        }
        else if vitrineId != nil {
            let params = VitrineParams()
            params.main("expand", value: "_networkId:logo name description")
            
//            API.get("vitrines/\(vitrineId!)", params: params, encoding: <#URLEncoding.Destination#>) {
            Alamofire.request("http://manager.vitrine.kz:3000/api/vitrines/\(vitrineId!)", parameters: params.get()).responseJSON { response in
                
               switch(response.result) {
                case .success(let JSON):
                    self.vitrine = Mapper<Vitrine>().map(JSON as AnyObject)
                    self.initialize()
                case .failure(let error):
                    print(error)
                }
            }
        }
        else if networkId != nil {
//            API.get("networks/\(networkId!)", encoding: <#URLEncoding.Destination#>) {response in
            Alamofire.request("http://manager.vitrine.kz:3000/api/networks/\(networkId!)").responseJSON { response in                
            switch(response.result) {
                case .success(let JSON):
                    
                    self.network = Mapper<Network>().map(JSON as AnyObject)
                    self.initialize()
                case .failure(let error):
                    print(error)
                }
            }
            return
        }
        
        if networkId != nil && (GlobalConstants.Person.getFavs(User.FAV_NETWORKS).contains(networkId!)) {
            likeButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            likeButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .bordered, target: nil, action: nil)

        switch(segue.identifier!) {
        case "ProductDetail":
            let controller = segue.destination as! ProductDetailController
            controller.product = sender as! Product
            controller.title = title
        case "SearchSettings":
            let controller = segue.destination as! ProductSortController
            controller.vitrine = vitrine
            controller.network = network
            controller.params = searchParams
        case "NetworkDetail":
            let controller = segue.destination as! NetworkDetailController
            controller.id = vitrine != nil ? vitrine!.networkId : network!.id
        case "AddressPicker":
            let controller = segue.destination as! NetworkAddressController
            controller.networkId = networkId
            controller.title = network?.name
        case "Map":
            if let v = self.vitrine {
                self.vitrinesPin = [v]
            } else {
                self.vitrinesPin = [Vitrine]()
                for v in self.network!.vitrines {
                    self.vitrinesPin.append(v)
                }
            }
            
            let controller = segue.destination as! MapController
            controller.pins = vitrinesPin
            controller.title = title
        default:
            return
        }
    }
    
    func vCollectionViewDidRequestMoreData() {
        // Еще надо различать мы сейчас в витрине или в сети находимся
        // Тут надо сгенерить параметры запроса на основе стракта self.productSortParams
        var url: String!
        var headers = [String: String]()
        let params = VitrineParams()
        
        headers["page"] = "\(page)"
        headers["page-size"] = "\(pageSize)"        
        if (GlobalConstants.Person.token != nil){
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
        }
        
        params.searchParams(searchParams)
        params.main("expand", value: "_networkId:name,_brandId:name,_vitrines:coordinates name")
        
        if favButton.isSelected {
            url = "users/favorite-products"
            if vitrine != nil {
//                params.find("_vitrines", value: vitrine!.id)
                params.find["_vitrines"] = vitrine!.id as AnyObject
                
            } else {
//                params.find("_networkId", value: network!.id)
                params.find["_networkId"] = network!.id as AnyObject
            }
        } else {
            if vitrine != nil {
                url = "vitrines/\(vitrine!.id as AnyObject)/products"
            } else {
                url = "networks/\(network!.id as AnyObject)/products"
            }
        }
        
        if let r = request {
            r.cancel()
        }
//        request = API.get(url, params: params, encoding: <#URLEncoding.Destination#>) {response in
        request = Alamofire.request("http://manager.vitrine.kz:3000/api/\(url!)", parameters: params.find).responseJSON {
            response in
                switch(response.result) {
                case .success(let JSON):
                    let products = Product.fromJSONArray(JSON as AnyObject)
                    if products.count > 0 || !self.initialRequest {
                        self.initialRequest = false
                        self.productsCollectionView.addStickyHeaderView(self.toolbar, withInitialTopOffset: 200)
                        self.productsCollectionView.collectionView.addParallax(with: self.headerView, andHeight: 200, andShadow: false)
                        self.productsCollectionView.products.append(contentsOf: products)
                        self.productsCollectionView.isHidden = false
                        self.infoView.isHidden = true
                        
                        if(products.count < self.pageSize) {
                            self.productsCollectionView.moreDataAvailable = false
                        } else {
                            self.page += 1
                        }
                    } else {
                        self.infoView.addParallax(with: self.headerView, andHeight: 200, andShadow: false)
                        self.infoView.contentOffset = CGPoint(x: 0, y: -200)
                        self.infoView.isHidden = false
                        self.productsCollectionView.isHidden = true
                        if self.network != nil {
                            self.networkTitleLabel.text = self.network?.name
                            self.networkDetailLabel.text = self.network?.description
                        }
                        if self.vitrine != nil {
                            self.networkTitleLabel.text = self.vitrine?.networkName
                            self.networkDetailLabel.text = self.vitrine?.networkDescription
                        }
                        self.networkInfoContentHeight.constant = self.networkDetailLabel.frame.origin.y + self.networkDetailLabel.frame.size.height
                        self.toolbar.isHidden = true
                        self.productsCollectionView.isHidden = true
                        self.view.bringSubview(toFront: self.infoView)
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func vCollectionView<Product>(didSelectItem item: Product) {
        performSegue(withIdentifier: "ProductDetail", sender: item as? AnyObject)
    }
}
