//
//  MallsTableView.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/5/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class MallsTableView: VTableViewWrapper {
    
    
    let locDouble = [CLLocationManager().location!.coordinate.latitude, CLLocationManager().location!.coordinate.longitude]
    override var cellReuseIdentifiers: [String] {
        return [String(describing: MallsTableViewCell.self)]
    }
    var malls = [Mall]() {
        didSet {
            items = malls
        }
    }
    
    func reset() {
        malls = [Mall]()
        moreDataAvailable = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("MallsTableViewCell", owner: self, options: nil)?.first as! MallsTableViewCell
        cell.mall = malls[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
}


class MallsTableViewCell: UITableViewCell {
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var mallLogo: RoundLogoView!
    var locManager = CLLocationManager()
    
    var mall: Mall! {
        didSet {
            let locValue:CLLocationCoordinate2D = locManager.location!.coordinate
            let locDouble = [locValue.longitude, locValue.latitude]            
            if mall.photos.count > 0 {
                picView.sd_setImage(with: API.imageURL("malls/photos", string: mall.photos[0]))
            }
            if mall.logo != nil {
//                mallLogo.imageURL = API.imageURL("malls/logo", string: mall.logo!)
            }
            rangeLabel.text = ""
            titleLabel.text = mall.name
            detailLabel.text = mall.address
            
            var rangeLab: Double
            rangeLab = mall.calcDistance(locDouble)
            let boolGlob = GlobalConstants.needBool
            if rangeLab < 0.0 || !boolGlob{
//            if rangeLab < 0.0{
                rangeLabel.text = ""
            } else {
                let roundedValue1 = NSString(format: "%.1f KM", rangeLab)
                rangeLabel.text = roundedValue1 as String
            }
        }
    }
}
