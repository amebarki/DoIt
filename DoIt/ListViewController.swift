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

    //MARK: variables
    var filtered = [Item]()
    var category: Category?
    var dataManagerReference = DataManager.instance
    
    @IBOutlet weak var editItemBarView: UIBarButtonItem!
    
    //MARK:  Outlets
    @IBOutlet weak var searchBarView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // in the case where it didn't specify in the storyboard
        //tableView.dataSource = self
        //tableView.delegate = self
        filtered.append(contentsOf: dataManagerReference.loadItemsData())
    }
    
    //MARK: Actions
    @IBAction func editAction(_ sender: Any)
    {
        tableView.isEditing = !tableView.isEditing
        if(tableView.isEditing)
        {
            let doneButtonView = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editAction(_:)))
            navigationItem.setLeftBarButton(doneButtonView, animated: true)
        }
        else
        {
            let editButtonView = UIBarButtonItem(barButtonSystemItem: .edit , target: self, action: #selector(editAction(_:)))
            navigationItem.setLeftBarButton(editButtonView, animated: true)
        }
    }
    
    @IBAction func addAction(_ sender: Any)
    {
        let alertController = UIAlertController(title: "DoIt", message: "New Item", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {(action) in
            
            let textField = alertController.textFields![0]
            
            if textField.text != "" {
              
                self.dataManagerReference.addItemData(nameItem: textField.text!)
                self.filtered.removeAll()
                self.filtered.append(contentsOf: self.dataManagerReference.loadItemsData(text: self.searchBarView.text!))
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


//MARK: Extension ListViewController
extension ListViewController: UITableViewDataSource, UITableViewDelegate
{
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCellIdentifier")
        let item = filtered[indexPath.row]
        cell?.textLabel?.text = item.name
        cell?.accessoryType = item.checked ? .checkmark : .none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        
     /*   dataManagerReference.moveItemAt(sourceIndexPath: sourceIndexPath, to: destinationIndexPath)

       */
        filtered.removeAll()
        filtered.append(contentsOf: dataManagerReference.moveItemAt(sourceIndexPath: sourceIndexPath, to: destinationIndexPath))
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = filtered[indexPath.row % filtered.count]
        item.checked = !item.checked
        tableView.reloadRows(at: [indexPath], with: .automatic)
        dataManagerReference.saveData()

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) 
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            let item = filtered[indexPath.row]
            dataManagerReference.deleteItemData(item: item)
            filtered.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
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
            filtered.append(contentsOf: dataManagerReference.loadItemsData())
        }
        else{
            //filtered = dataManagerReference.filter(searchBarText: searchText)
            filtered = dataManagerReference.loadItemsData(text: searchText)
        }
        self.tableView.reloadData()
    }
}


