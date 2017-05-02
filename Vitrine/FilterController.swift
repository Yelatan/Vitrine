import UIKit
import Alamofire


protocol FilterDelegate {
    func onFilter(_ id: String)
    func onFavorite()
}

class FilterController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var mall: Mall?
    var network: Network?
    
    var filterDelegate: FilterDelegate? = nil
    var shopping_mall_id: String!
    var shop_id: String!
    
    var shown: Bool = false
    
    @IBOutlet weak var favorite: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var scrollView: UIScrollView!
    
    fileprivate var categories = [ProductCategory]() {
        didSet {
            collectionView.performBatchUpdates({ () -> Void in
                self.collectionView.reloadSections(IndexSet(integer: 0))
                }, completion: nil)
        }
    }

    @IBAction func favorite(_ sender: AnyObject) {
        GlobalConstants.Person.authenticated(fromController: self) {
            self.filterDelegate?.onFavorite()
            self.favorite.isSelected = !self.favorite.isSelected
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /*
        if scrollView.contentOffset.y < -100 && shown {
            shown = false
            scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y + 280)
            delegate!.filterViewController(self, show: shown, animated: false)
        }
*/
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FilterCategoryCell
        let category = categories[indexPath.row]
        cell.textLabel.text = category.name
        
        if category.parentBack {
            cell.imageView.image = UIImage(named: "icon_sort_back")
        } else if category.logo != nil {
            cell.imageView.sd_setImage(with: API.imageURL("categories/logo", string: category.logo!))
        }
        
        return cell
    }
    
    var level: Int = 1
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        var categoryId: String = ""
        
        if (indexPath.row == 0 && level > 1) {
            if (!category.parentId.isEmpty) {
                categoryId = category.parentId
            } else {
                level = 1
            }
        } else {
            level += 1
            categoryId = category.id
        }
        
        self.filterDelegate?.onFilter(categoryId)
        loadData(categoryId)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/5, height: 100)
    }
    
    internal func loadData(_ id: String = "") {
        let params = VitrineParams()
        var url = "categories"
        
        if (!id.isEmpty) {
            url += "/\(id)"
            params.main("children", value: "1")
            if let m = mall {
//                params.find("_mallId", value: m.id)
                params.find["_mallId"] = m.id as AnyObject
                
            }
            
            if let n = network {
//                params.find("_networkId", value: n.id)
                params.find["_networkId"] = n.id as AnyObject
            }
        } else {
            params.main("top", value: "1")
            if let m = mall {
                url = "malls/\(m.id)/\(url)"
            }
            
            if let n = network {
                url = "networks/\(n.id)/\(url)"
            }
        }
        //TO-DO
        //Bako
        //API.get(url, params: params, encoding: URLEncoding.Destination) { response in
        
        Alamofire.request(url, parameters: params.get()).responseJSON { response in
            switch response.result {
            case .success(let JSON):
                if (id.isEmpty) {
                    self.categories = ProductCategory.fromJSONArray(JSON as AnyObject)
                } else {
                    var newCategories = [ProductCategory]()
                    let parentCategory = Mapper<ProductCategory>().map((JSON as! Dictionary<String, AnyObject>)["category"])!
                    parentCategory.name = "Назад"
                    parentCategory.parentBack = true
                    newCategories.append(parentCategory)
                    newCategories.append(contentsOf: ProductCategory.fromJSONArray((JSON as! Dictionary<String, AnyObject>)["children"]!))
                    self.categories = newCategories
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
