//
//  ViewController.swift
//  DoIt
//
//  Created by iem on 30/03/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    var documentDirectory: URL {
        let fm = FileManager.default
        return try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    var dataFileUrl : URL {
        return documentDirectory.appendingPathComponent("checklist").appendingPathExtension("json")
    }
    
    var items = ["Pain","Lait","Boeuf",
                 "Oeufs","Fromage","Poivrons",
                 "Blé","Coeurs de palmier","Tomates",
                 "Olives","Cornichons"]
    
    var cacheItems = [Item]()
    
    var filtered = [Item]()
    
    var searchActive : Bool = false
    
    
    //MARK:  Outlets
    
    @IBOutlet weak var searchBarView: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(FileManager.default.fileExists(atPath: dataFileUrl.path))
        {
            loadChecklist()
        }
        //createItems()
        // in the case where it didn't specify in the storyboard
        //tableView.dataSource = self
        //tableView.delegate = self
        
        filtered.append(contentsOf: cacheItems)
        
    }
    
    
    func createItems(){
        for item in items {
            let newElement = Item(name: item)
            cacheItems.append(newElement)
        }
    }
    
    
    //MARK: Actions
    
    @IBAction func editAction(_ sender: Any) {
        //   let editButton = sender as! UIBarButtonItem
        tableView.isEditing = !tableView.isEditing
        
    }
    @IBAction func addAction(_ sender: Any)
    {
        let alertController = UIAlertController(title: "DoIt", message: "New Item", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {(action) in
            
            let textField = alertController.textFields![0]
            
            if textField.text != "" {
                let item = Item(name: textField.text!)
                self.cacheItems.append(item)
                self.filtered.removeAll()
                self.filtered.append(contentsOf: self.cacheItems)
                self.saveChecklist()
                self.tableView.reloadData()
            }
        }
        
        alertController.addTextField{
            (textField) in textField.placeholder = "Name"
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: methods JSON
    
    func saveChecklist()
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(cacheItems)
        try! data.write(to: dataFileUrl)
        //print(String(data: data, encoding: .utf8)!)
    }
    
    func loadChecklist()
    {
        let jsonData = try! Data(contentsOf: dataFileUrl, options: .alwaysMapped)
        let decoder = JSONDecoder()
        let data = try! decoder.decode([Item].self, from: jsonData)
        for checklist in data {
            cacheItems.append(checklist)
        }
    }
    
    
}


extension ListViewController: UITableViewDataSource, UITableViewDelegate{
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCellIdentifier")
        
        let item = filtered[indexPath.row]
        //cell?.textLabel?.text = items2[indexPath.row]
        cell?.textLabel?.text = item.name
        cell?.accessoryType = item.checked ? .checkmark : .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceItem = cacheItems.remove(at:sourceIndexPath.row)
        cacheItems.insert(sourceItem, at: destinationIndexPath.row)
        filtered.removeAll()
        filtered.append(contentsOf: cacheItems)
        saveChecklist()
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        //cell?.accessoryType = (cell?.accessoryType == .checkmark) ? .none : .checkmark
        
        let item = filtered[indexPath.row % filtered.count]
        
        item.checked = !item.checked
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        saveChecklist()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let item = filtered[indexPath.row]
            let index = try? cacheItems.index(where: item){
                cacheItems.remove(at: index)
            }
            filtered.removeAll()
            filtered.append(contentsOf: cacheItems)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            saveChecklist()
        }
    }
}

extension ListViewController: UISearchBarDelegate
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
            filtered.append(contentsOf: cacheItems)
        }
        else{
            filtered = cacheItems.filter({ (item) -> Bool in
                let nameItem = item.name
                let range = nameItem.range(of: searchText, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil)
                return range != nil
            })
        }
        
        
        self.tableView.reloadData()
        
    }
    
    
    
}
