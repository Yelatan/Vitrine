//
//  ProductSortController.swift
//  Vitrine
//
//  Created by Viktor Ten on 3/1/16.
//  Copyright © 2016 Vitrine. All rights reserved.
//

import Foundation
import UIKit


enum ProductSortMethod : String {
    case Default = "Не выбрано"
    case PriceAscending = "Цена по возрастанию"
    case PriceDescending = "Цена по убыванию"
    
    var value : String {
        switch self {
            case .Default: return ""
            case .PriceAscending: return "priceWithDiscount"
            case .PriceDescending: return "-priceWithDiscount"
        }
    }
    
    static let all = [Default, PriceAscending, PriceDescending]
}

struct ProductSearchPriceRangeParam {
    var from: String
    var to: String
    
    func toString() -> String {
        return "\(from)..\(to)"
    }
}

struct ProductSearchParams {
    var method: ProductSortMethod
    var category: ProductCategory?
    var brand: Brand?
    var text: String?
    var priceRange: ProductSearchPriceRangeParam?
    var sale: Bool
    
    init() {
        method = ProductSortMethod.Default
        category = nil
        brand = nil
        text = nil
        priceRange = nil
        sale = false
    }
}

class ProductSortController: UIViewController, UITableViewDelegate, UITableViewDataSource, MultiPickerViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var vitrine: Vitrine?
    var network: Network?
    var params = ProductSearchParams()
    
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var sortMethodPicker: MultiPickerView!
    @IBOutlet weak var sortMethodPickerBottom: NSLayoutConstraint!
    @IBOutlet weak var sortMethodPickerHeight: NSLayoutConstraint!
    @IBOutlet weak var priceRangePicker: MultiPickerView!
    @IBOutlet weak var priceRangePickerBottom: NSLayoutConstraint!
    @IBOutlet weak var priceRangePickerHeight: NSLayoutConstraint!
    
    @IBAction func unwindToProductSortController(_ segue: UIStoryboardSegue) {
        if segue.identifier! == "SelectCategory" {
            let controller = segue.source as! ProductSortCategoriesController
            params.category = controller.selectedCategory
        }
        else {
            let controller = segue.source as! ProductSortBrandsController
            params.brand = controller.selectedBrand
        }
        tableView.reloadData()
    }
    
    @IBAction func didClickClearButton(_ sender: AnyObject) {
        setDefaults()
    }
    
    @IBAction func didClickAnyRangeButton(_ sender: UIButton) {
        params.priceRange = nil
        hidePriceRangePicker()
        tableView.reloadData()
    }
    
    @IBAction func didClickSaleSwitch(_ sender: UISwitch) {
        params.sale = sender.isOn
    }
    
    func setDefaults() {
        params = ProductSearchParams()
    }
    
    func tableParams() -> NSArray {
        return [
            ["Сортировка", params.method.rawValue],
            ["Категории", params.category == nil ? "Все категории" : params.category!.name],
            ["Бренды", params.brand == nil ? "Все бренды" : params.brand!.name],
            ["Диапазон цен", params.priceRange == nil ? "Любой" : params.priceRange!.toString()],
            ["Только товары со скидкой", params.sale]
        ]
    }
    
    func getPriceSteps() -> [String] {
        var steps: [String] = []
        for i in 1...20 {
            steps.append(String(i*5000))
        }
        return steps
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
//        setDefaults()
        
        sortMethodPicker.delegate = self        
        let sortArray = ProductSortMethod.all.map({(m) -> String in m.rawValue as! String}) as NSArray
        sortMethodPicker.options = [sortArray]
        sortMethodPicker.initialSelected = [0]
        
        priceRangePicker.delegate = self
        var steps1 = getPriceSteps()
        var steps2 = ["Ниже"]
        steps2.append(contentsOf: steps1)
        steps1.append("И выше")
        
        priceRangePicker.options = [steps2 as NSArray, steps1 as NSArray]
        priceRangePicker.initialSelected = [0, 10]
        
        if let t = params.text {
            searchField.text = t
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableParams().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxCell", for: indexPath)
            let checkbox = cell.viewWithTag(2) as! UISwitch
            checkbox.isOn = params.sale
            checkbox.addTarget(self, action: #selector(ProductSortController.didClickSaleSwitch(_:)), for: .valueChanged)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            let param = tableParams()[indexPath.row] as! NSArray
            
            cell.textLabel!.text = param[0] as? String
            cell.detailTextLabel!.text = param[1] as? String
        }
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        cell.selectedBackgroundView = bgView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            sortMethodPicker.triggerSelection()
            hidePriceRangePicker()
            showSortMethodPicker()
        case 1:
            performSegue(withIdentifier: "Category", sender: nil)
        case 2:
            performSegue(withIdentifier: "Brand", sender: nil)
        case 3:
            priceRangePicker.triggerSelection()
            hideSortMethodPicker()
            showPriceRangePicker()
        default:
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func multiPickerView(_ multiPickerView: MultiPickerView, didSelectValues selectedValues: NSArray) {
        if multiPickerView == sortMethodPicker {
            params.method = ProductSortMethod.init(rawValue: selectedValues[0]  as! String)!
        }
        if multiPickerView == priceRangePicker {
            params.priceRange = ProductSearchPriceRangeParam(from: selectedValues[0] as! String, to: selectedValues[1] as! String)
        }
        tableView.reloadData()
    }
    
    func multiPickerViewDone(_ multiPickerView: MultiPickerView) {
        if multiPickerView == sortMethodPicker {
            hideSortMethodPicker()
        }
        if multiPickerView == priceRangePicker {
            hidePriceRangePicker()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideSortMethodPicker()
        hidePriceRangePicker()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        if segue.destination .isKind(of: ProductsController.self) {
            let c = segue.destination as! ProductsController
            c.searchParams = self.params
        } else if segue.destination .isKind(of: FavoritesController.self) {
            let c = segue.destination as! FavoritesController
            c.searchParams = self.params
        } else if segue.destination .isKind(of: GlobalSearchController.self) {
            let c = segue.destination as! GlobalSearchController
            c.searchParams = self.params
        } else {
            switch(segue.identifier!) {
            case "Category":
                let controller = segue.destination as! ProductSortCategoriesController
                controller.network = network
                controller.vitrine = vitrine
            case "Brand":
                let controller = segue.destination as! ProductSortBrandsController
                controller.vitrine = vitrine
                controller.network = network
            default:
                return
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        params.text = searchText == "" ? nil : searchText
    }
    
    func showSortMethodPicker() {
        resignFirstResponder()
        sortMethodPickerBottom.constant = 0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in self.view.layoutIfNeeded()}) 
    }
    
    func hideSortMethodPicker() {
        sortMethodPickerBottom.constant = -sortMethodPickerHeight.constant
        UIView.animate(withDuration: 0.3, animations: { () -> Void in self.view.layoutIfNeeded()}) 
    }
    
    func showPriceRangePicker() {
        resignFirstResponder()
        priceRangePickerBottom.constant = 0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in self.view.layoutIfNeeded()}) 
    }
    
    func hidePriceRangePicker() {
        priceRangePickerBottom.constant = -priceRangePickerHeight.constant
        UIView.animate(withDuration: 0.3, animations: { () -> Void in self.view.layoutIfNeeded()}) 
    }
}
