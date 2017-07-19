//
//  NetworkTableView.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/4/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

@IBDesignable class NetworkTableView: VTableViewWrapper {
    override var cellReuseIdentifiers: [String] {
        return [String(describing: NetworkTableViewCell.self)]
    }
    var networks = [Network]() {
        didSet {
            items = networks
        }
    }
    
    func reset() {
        networks = [Network]()
        moreDataAvailable = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkTableViewCell") as! NetworkTableViewCell
//        cell.network = networks[indexPath.row]
//        return cell        
        let cell1 = Bundle.main.loadNibNamed("NetworkTableViewCell", owner: self, options: nil)?.first as! NetworkTableViewCell
        cell1.network = networks[indexPath.row]
        return cell1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 230
    }
}


class NetworkTableViewCell: UITableViewCell {
    var locManager = CLLocationManager()
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var logoView: RoundLogoView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    
    var network: Network! {
        didSet {
            titleLabel.text = network.name
            if network.photos.count > 0 {
                bgImageView.sd_setImage(with: API.imageURL("networks/photos", string: network.photos[0]))
            }
            if network.logo != nil {
                logoView.imageURL = API.imageURL("networks/logo", string: network.logo!)
            }
            rangeLabel.text = "asd asd"
            let locValue:CLLocationCoordinate2D = locManager.location!.coordinate
            let locDouble = [locValue.latitude, locValue.longitude]
            
            var rangeLab = 0.0
            if !network.vitrines.isEmpty{
                rangeLab = network.vitrines[0].calcDistance(network.vitrines[0].coordinates)
            }
            
            let roundedValue1 = NSString(format: "%.1f KM", rangeLab)
            let boolGlob = GlobalConstants.needBool
//            if rangeLab  0.0 || !boolGlob{

            if rangeLab < 0.0 || !boolGlob{
                //            if rangeLab < 0.0{
                rangeLabel.text = ""
            } else {
                rangeLabel.text = roundedValue1 as String
            }
            
            if network.vitrines.count == 1 {
                detailLabel.text = "\(network.vitrines[0].address)"
            } else if network.vitrines.count > 1 {
                detailLabel.text = "Витрин: \(network.vitrines.count)"
            }
            
        }
    }
}
