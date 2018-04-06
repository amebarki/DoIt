//
//  CategoryViewController.swift
//  DoIt
//
//  Created by iem on 06/04/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarView: UISearchBar!
    
    var dataManagerReference = DataManager.instance
    var filtered = [Category]()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        filtered.append(contentsOf: dataManagerReference.loadCategoryData())

        // Do any additional setup after loading the view.
    }

    @IBAction func addAction(_ sender: Any) {
        let alertController = UIAlertController(title: "DoIt", message: "New Category", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {(action) in
            
            let textField = alertController.textFields![0]
            
            if textField.text != "" {
                self.dataManagerReference.addCategoryData(nameCategory: textField.text!)
                self.filtered.removeAll()
                self.filtered.append(contentsOf: self.dataManagerReference.loadCategoryData(text: self.searchBarView.text!))
                self.tableView.reloadData()
            }
        }
        
        alertController.addTextField{
            (textField) in textField.placeholder = "Name"
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func FilterAction(_ sender: Any) {
    }
    

}
    
    



//MARK: Extension ListViewController
extension CategoryViewController: UITableViewDataSource, UITableViewDelegate
{
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return section == 0 ? 1 : filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewCellIdentifier")
        if indexPath.section == 0
        {
            cell?.textLabel?.text = "None"
        }
        else
        {
            let category = filtered[indexPath.row]
            cell?.textLabel?.text = category.name
            
        }
        return cell!
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        dataManagerReference.saveData()
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            let category = filtered[indexPath.row]
            dataManagerReference.deleteCategoryData(category: category)
            filtered.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension CategoryViewController: UISearchBarDelegate
{
    //MARK: SearchbarView
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
            filtered.append(contentsOf: dataManagerReference.loadCategoryData())
        }
        else{
            filtered = dataManagerReference.loadCategoryData(text: searchText)
        }
        self.tableView.reloadData()
    }
}
