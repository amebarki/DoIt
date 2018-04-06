//
//  ViewController.swift
//  DoIt
//
//  Created by iem on 30/03/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import UIKit

class ListViewController: UIViewController
{
    
    var items = ["Pain","Lait","Boeuf",
                 "Oeufs","Fromage","Poivrons",
                 "Blé","Coeurs de palmier","Tomates",
                 "Olives","Cornichons"]
    
    
    //MARK: - variables
    var filtered = [Item]()
    
    var dataManagerReference = DataManager.instance
    
    //MARK: - Outlets
    @IBOutlet weak var searchBarView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // in the case where it didn't specify in the storyboard
        //tableView.dataSource = self
        //tableView.delegate = self
    
        dataManagerReference.loadChecklist()
        
        filtered.append(contentsOf: dataManagerReference.cacheItems)
    }
    
    //MARK: - Actions
    @IBAction func editAction(_ sender: Any)
    {
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func addAction(_ sender: Any)
    {
        let alertController = UIAlertController(title: "DoIt", message: "New Item", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {(action) in
            
            let textField = alertController.textFields![0]
            
            if textField.text != "" {
                let item = Item(name: textField.text!)
                self.dataManagerReference.cacheItems.append(item)
                self.filtered.removeAll()
                self.filtered.append(contentsOf: self.dataManagerReference.filter(searchBarText: self.searchBarView.text!))
                self.dataManagerReference.saveChecklist()
                self.tableView.reloadData()
            }
        }
        
        alertController.addTextField{
            (textField) in textField.placeholder = "Name"
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}


//MARK: - Extension ListViewController
extension ListViewController: UITableViewDataSource, UITableViewDelegate
{
    
    //MARK:  - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCellIdentifier")
        let item = filtered[indexPath.row]
        
        configureCheckmark(for: cell!, withItem: item)
        configureName(for: cell!, withItem: item)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let sourceItem = dataManagerReference.cacheItems.remove(at:sourceIndexPath.row)
        dataManagerReference.cacheItems.insert(sourceItem, at: destinationIndexPath.row)
        filtered.removeAll()
        filtered.append(contentsOf: dataManagerReference.cacheItems)
        dataManagerReference.saveChecklist()
    }
    
    //MARK:  - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = filtered[indexPath.row % filtered.count]
        item.checked = !item.checked
        tableView.reloadRows(at: [indexPath], with: .automatic)
        DataManager.instance.saveChecklist()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) 
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            let item = filtered[indexPath.row]
            if let index = dataManagerReference.cacheItems.index(where: { (anItem) -> Bool in
                return anItem === item
            })
            {
                dataManagerReference.cacheItems.remove(at: index)
                filtered.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                dataManagerReference.saveChecklist()
            }
        }
    }
}

extension ListViewController {
    //MARK: - Configure Cell
    func configureCheckmark(for cell: UITableViewCell, withItem item: Item) {
        let myCell = cell as! ItemCell
        myCell.itemChecked.isHidden = (item.checked) ? false : true
    }
    
    func configureName(for cell: UITableViewCell, withItem item: Item){
        let myCell = cell as! ItemCell
        myCell.itemName.text = item.name
    }
}

extension ListViewController: UISearchBarDelegate
{
    //MARK: - SearchbarView
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == ""){
            filtered.removeAll()
            filtered.append(contentsOf: dataManagerReference.cacheItems)
        }
        else{
            filtered = dataManagerReference.filter(searchBarText: searchText)
        }
        self.tableView.reloadData()
    }
}
