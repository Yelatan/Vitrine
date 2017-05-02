//
//  PickCityController.swift
//  Vitrine
//
//  Created by viktorten on 4/19/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class PickCityController: UITableViewController {
    
    var cities = [City]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        loadCities()
    }
    
    func loadCities() {
        Alamofire.request("http://apivitrine.witharts.kz/api/cities").responseJSON { response in
//        API.get("cities") { response in
            switch(response.result) {
            case .success(let JSON):
                self.cities = City.fromJSONArray(JSON as AnyObject)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        let city = cities[indexPath.row]
        cell.textLabel?.text = city.name
        
        let bgView = UIView(frame: CGRect.zero)
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        cell.selectedBackgroundView = bgView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = cities[indexPath.row]
        
        GlobalConstants.Person.setUserCityName(city.name)
        GlobalConstants.Person.setUserCityId(city.id)
        
        dismiss(animated: true, completion: nil)
    }
}
