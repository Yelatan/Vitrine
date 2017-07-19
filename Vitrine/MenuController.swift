//
//  MenuController.swift
//  Vitrine
//
//  Created by Vitrine on 01.12.15.
//  Copyright © 2015 Vitrine. All rights reserved.
//

import UIKit

class MenuController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var favBadgeView: BadgeView!
    @IBOutlet weak var searchField: UITextField!
    
    var overlay = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        overlay.addTarget(self, action: #selector(MenuController.hideMenu), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (GlobalConstants.Person.hasAvatar()) {
            photoView.sd_setImage(with: GlobalConstants.Person.getAvatarUrl())
        } else {
            photoView.image = UIImage(named: "guest")
        }
        
        if (GlobalConstants.Person.hasName()) {
            name.text = GlobalConstants.Person.getFirstName() + " " +  GlobalConstants.Person.getLastName()
        } else {
            name.text = "Введите имя"
        }
        
        if (GlobalConstants.Person.hasCityName()){
            print(GlobalConstants.Person.hasCityName())
            detail.text = GlobalConstants.Person.getCityName()
            print(GlobalConstants.Person.getCityName())
        }else{
            detail.text = "Введите city"
        }
        
        detail.text = GlobalConstants.Person.CityName
        if (GlobalConstants.Person.getFavProds().count > 0) {
            favBadgeView.text = String(GlobalConstants.Person.getFavProds().count)
            favBadgeView.isHidden = false            
        }
        else {
            favBadgeView.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overlay.frame = revealViewController().frontViewController.view.bounds
        revealViewController().frontViewController.view.addSubview(overlay)
        revealViewController().view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overlay.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != nil && segue.identifier == "search" {
            let controller = segue.destination as! UINavigationController
            let searchController = controller.viewControllers.first as! GlobalSearchController
            searchController.initialSearchString = searchField.text!
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        switch(indexPath.row) {
        case 2:
            super.performSegue(withIdentifier: "search", sender: nil)
        case 1:
//            GlobalConstants.Person.authenticated(fromController: self) {
//                super.performSegue(withIdentifier: "profile", sender: nil)
//            }
            if GlobalConstants.Person.hasToken(){
                super.performSegue(withIdentifier: "profile", sender: nil)
            }else{
                GlobalConstants.fromReveal = false
                super.performSegue(withIdentifier: "authentication", sender: nil)
            }
        case 3:
            super.performSegue(withIdentifier: "news", sender: nil)
        case 4:
            super.performSegue(withIdentifier: "vitrines", sender: nil)
        case 5:
            super.performSegue(withIdentifier: "malls", sender: nil)
        case 6:
            super.performSegue(withIdentifier: "favourites", sender: nil)
        default:
            print("WTF?")
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        cell.selectedBackgroundView = bgView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchField {
            performSegue(withIdentifier: "search", sender: nil)
        }
        
        return true
    }
    
    func hideMenu() {
        revealViewController().revealToggle(nil)
    }
}
