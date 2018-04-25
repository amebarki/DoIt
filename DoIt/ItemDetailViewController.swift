//
//  ItemDetailViewController.swift
//  DoIt
//
//  Created by Florian Van Den Berghe on 06/04/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import UIKit

class ItemDetailViewController: UITableViewController, UITextFieldDelegate {
    
    let nameImage: [String] = ["sunrise.png", "sunrise2.png"]
    var change = false;
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameText: UITextField!
    @IBOutlet weak var itemCategoryText: UILabel!
    @IBOutlet weak var itemDateCreatedText: UILabel!
    @IBOutlet weak var itemDateModifiedText: UILabel!
    var delegate: ItemDetailViewControllerDelegate?
    var itemToEdit: Item?
    var category: Category?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let itemToEdit = itemToEdit {
            itemNameText.text = itemToEdit.name
            navigationItem.title = "Edit Item"
        }
    }
    
    @IBAction func changeImage() {
    
        if change{
            let image : UIImage = UIImage(named: nameImage[0])!
            change = false
            itemImageView.image = image
        }else{
            let image : UIImage = UIImage(named: nameImage[1])!
            change = true
            itemImageView.image = image
        }
    }
    
    @IBAction func done() {
        if let itemToEdit = itemToEdit {
            itemToEdit.name = itemNameText.text!
            delegate?.ItemDetailViewController(self, didFinishEditingItem: itemToEdit)
        } else {
            if category != nil
            {
                DataManager.instance.addItemData(nameItem: itemNameText.text!, category: category!)
                delegate?.ItemDetailViewController(self, didFinishAddingItem: itemNameText.text!)
            }
           // let item = Item(context: DataManager.instance.persistentContainer.viewContext)
           // item.name = itemNameText.text
        }
    }
    
    @IBAction func cancel() {
        delegate?.ItemDetailViewControllerDidCancel(self)
       // navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        itemNameText.becomeFirstResponder()
        itemNameText.delegate = self
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if let oldString = textField.text {
            let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!,with: string)
            if(newString.count == 0)
            {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            else
            {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
        return true
    }
    
}

protocol ItemDetailViewControllerDelegate : class {
    func ItemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func ItemDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: String)
    func ItemDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: Item)
}
