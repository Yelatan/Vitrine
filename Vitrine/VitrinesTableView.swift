//
//  VitrinesTableView.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/4/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class VitrinesTableView: VTableViewWrapper {
    enum DisplayMode {
        case `default`, alt
    }
    
    var displayMode = DisplayMode.default
    
    override var cellReuseIdentifiers: [String] {
        return [String(describing: VitrinesTableViewCell()), String(describing: VitrinesTableViewAltCell())]
    }
    var vitrines = [Vitrine]() {
        didSet {
            items = vitrines
        }
    }
    
    func reset() {
        vitrines = [Vitrine]()
        moreDataAvailable = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if displayMode == .default {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VitrinesTableViewCell") as! VitrinesTableViewCell
            cell.vitrine = vitrines[indexPath.row]
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VitrinesTableViewAltCell") as! VitrinesTableViewAltCell
            cell.vitrine = vitrines[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 230
    }
}


class VitrinesTableViewCell: UITableViewCell {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var logoView: RoundLogoView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    
    var vitrine: Vitrine! {
        didSet {
            titleLabel.text = vitrine.name
            detailLabel.text = vitrine.address
            if vitrine.photos.count > 0 {
                bgImageView.sd_setImage(with: API.imageURL("vitrines/photos", string: vitrine.photos[0]))
            }
            if vitrine.networkLogo != nil {
                logoView.imageURL = API.imageURL("networks/logo", string: vitrine.networkLogo!)
            }
            if vitrine.distance == -1 {
                rangeLabel.text = ""
            } else {
                rangeLabel.text = "\(String(format: "%.2f", vitrine.distance)) КМ"
            }
        }
    }
}


class VitrinesTableViewAltCell: UITableViewCell {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    
    var vitrine: Vitrine! {
        didSet {
            titleLabel.text = vitrine.name
            detailLabel.text = vitrine.address
            if vitrine.photos.count > 0 {
                bgImageView.sd_setImage(with: API.imageURL("vitrines/photos", string: vitrine.photos[0]))
            }
            if vitrine.distance == -1 {
                rangeLabel.text = ""
            } else {
                rangeLabel.text = "\(String(format: "%.2f", vitrine.distance)) КМ"
            }
        }
    }
}
