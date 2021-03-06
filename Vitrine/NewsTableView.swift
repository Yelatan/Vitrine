//
//  NewsTableView.swift
//  Vitrine
//
//  Created by Viktor Ten on 4/4/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


class NewsTableView: VTableViewWrapper {
    override var cellReuseIdentifiers: [String] {
        return [String(describing: NewsTableViewCell())]
    }
    var news = [News]() {
        didSet {
            items = news
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = Bundle.main.loadNibNamed("NewsTableViewCell", owner: self, options: nil)?.first as! NewsTableViewCell
        cell1.news = news[indexPath.row]
        return cell1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 230
    }
}

@IBDesignable class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var logoView: RoundLogoView!
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var news: News! {
        didSet {
            selectionStyle = UITableViewCellSelectionStyle.none
            titelLabel.text = news.name
            
            if news.createdAt != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd yyyy"
                let newDate = dateFormatter.string(from: (news.createdAt! as NSDate) as Date)
                detailLabel.text = "\(newDate)"                
//                detailLabel.text = "\((news.createdAt! as NSDate).timeIntervalSinceNow)"
            }
            
            if news.photos.count > 0 {
                picView.sd_setImage(with: API.imageURL("news/photos", string: news.photos[0]))
            }
            
            if news.networkLogo != nil {
                logoView.imageURL = API.imageURL("networks/logo", string: news.networkLogo!)
            }
        }
    }
}
