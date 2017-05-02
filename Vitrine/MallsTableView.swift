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
    override var cellReuseIdentifiers: [String] {
        return [String(describing: MallsTableViewCell())]
    }
    var malls = [Mall]() {
        didSet {
            items = malls
        }
    }
    
    func reset() {
        malls = [Mall]()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MallsTableViewCell") as! MallsTableViewCell
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
    
    var mall: Mall! {
        didSet {
            //didn't fix ubral distance calc and photos
//            if mall.photos.count > 0 {
//                picView.sd_setImage(with: API.imageURL("malls/photos", string: mall.photos[0]))
//            }
            titleLabel.text = mall.name
            detailLabel.text = mall.address
            
//            if mall.distance == -1 {
//                rangeLabel.text = ""
//            } else {
//                rangeLabel.text = "\(String(format: "%.2f", mall.distance)) КМ"
//            }
            rangeLabel.text = "ошибка"
        }
    }
}
