//
//  NetworkAddressController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/24/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class NetworkAddressController: UITableViewController {
    var networkId: String!
    var vitrines = [Vitrine]()
    var selectedVitrine: Vitrine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var headers = [String: String]()
        if (GlobalConstants.Person.hasToken()) {
            headers = [String: String]()
            headers["Authorization"] = "Bearer \(GlobalConstants.Person.token!)"
        }
        let params = VitrineParams()
        params.main("expand", value: "_networkId:logo name description")
        let  params2 = params.get()
        if networkId != nil {
//            API.get("networks/\(networkId)/vitrines", params: params) { response in
            Alamofire.request("http://manager.vitrine.kz:3000/api/networks/\(self.networkId!)", parameters:params.get(), headers: headers).responseJSON { response in                                
                switch(response.result) {
                case .success(let JSON):
                    print("json")
                    self.vitrines = Vitrine.fromJSONArray(JSON as AnyObject)
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        tableView.separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vitrines.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let vitrine = vitrines[indexPath.row]
        cell.textLabel!.text = vitrine.name
        cell.detailTextLabel!.text = vitrine.address
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        cell.selectedBackgroundView = bgView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVitrine = vitrines[indexPath.row]
        performSegue(withIdentifier: "PickAddress", sender: nil)
    }
}
