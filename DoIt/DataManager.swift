//
//  DataManager.swift
//  DoIt
//
//  Created by iem on 30/03/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import Foundation
import CoreData

class DataManager{
    
    
    //MARK: Declaration Property and variables
    var context: NSManagedObjectContext
    {
        return persistentContainer.viewContext
    }
    
    private var cachedItems = [Item]()
    private var cachedCategories = [Category]()
    static let instance = DataManager()
    
   
    

    func saveData()
    {
        saveContext()
    }
    
    
   
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DoIt")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

//MARK: Manage Category
extension DataManager
{
    func loadCategoryData(text:String? = "") ->[Category]
    {
        let fetchRequest: NSFetchRequest<Category> = NSFetchRequest(entityName: "Category")
        if text != nil, text!.count > 0
        {
            let predicate = NSPredicate(format: "name contains[cd] %@", text!)
            fetchRequest.predicate = predicate
            
        }
            
        do{
            cachedCategories = try context.fetch(fetchRequest)
        }catch{
            print("error")
        }
        return cachedCategories
    }
    
    func addCategoryData(nameCategory: String)
    {
        let category = Category(context: DataManager.instance.context)
        category.name = nameCategory
        category.createdAt = Date()
        cachedCategories.append(category)
        saveData()
    }
    
    func deleteCategoryData(category: Category)
    {
        if let index = cachedCategories.index(where: { (anCategory) -> Bool in
            return anCategory === category
        })
        {
            cachedCategories.remove(at: index)
        }
        context.delete(category)
        self.saveData()
    }
    
    
    func retrieveCategoryItemsData(categoryName: String) -> [Item]
    {
        let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Item.category.name),categoryName)
        fetchRequest.predicate = predicate
        do{
            cachedItems = try context.fetch(fetchRequest)
        }catch{
            print("error")
        }
        return cachedItems
    }
    

}


//MARK: Manage Item
extension DataManager
{
    func moveItemAt(sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> [Item]
    {
        let sourceItem = cachedItems.remove(at:sourceIndexPath.row)
        cachedItems.insert(sourceItem, at: destinationIndexPath.row)
        return cachedItems
    }
    
    func loadItemsData(text:String? = "") -> [Item]
    {
        let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
        if text != nil, text!.count > 0
        {
            let predicate = NSPredicate(format: "name contains[cd] %@", text!)
            fetchRequest.predicate = predicate
        }

        do{
            cachedItems = try context.fetch(fetchRequest)
        }catch{
            print("error")
        }

        return cachedItems
    }
    
    
    func addItemData(nameItem: String)
    {
        let item = Item(context: DataManager.instance.context)
        item.name = nameItem
        item.checked = false
        cachedItems.append(item)
        saveData()
    }
    

    func deleteItemData(item: Item)
    {
        if let index = cachedItems.index(where: { (anItem) -> Bool in
            return anItem === item
        })
        {
            cachedItems.remove(at: index)
        }
        context.delete(item)
        self.saveData()
    }
    
    
    func retrieveItemData(index: Int) -> Item
    {
        return cachedItems[index]
    }
}



// MARK: Manage Json
extension DataManager
{
    var documentDirectory: URL
    {
        let fm = FileManager.default
        return try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    var dataFileUrl : URL
    {
        return documentDirectory.appendingPathComponent("checklist").appendingPathExtension("json")
    }
    
    //MARK: methods JSON old save
    func saveChecklist()
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(cachedItems)
        try! data.write(to: dataFileUrl)
        //print(String(data: data, encoding: .utf8)!)
    }
    
    func loadChecklist()
    {
        if(FileManager.default.fileExists(atPath: dataFileUrl.path))
        {
            let jsonData = try! Data(contentsOf: dataFileUrl, options: .alwaysMapped)
            let decoder = JSONDecoder()
            let data = try! decoder.decode([Item].self, from: jsonData)
            for checklist in data {
                cachedItems.append(checklist)
            }
        }
    }
    func filter(searchBarText: String) -> [Item]
    {
        if(searchBarText != "")
        {
            return cachedItems.filter({ (item) -> Bool in
                let nameItem = item.name
                let range = nameItem?.range(of: searchBarText, options: [String.CompareOptions.caseInsensitive,String.CompareOptions.diacriticInsensitive], range: nil, locale: nil)
                return range != nil
            })
        }
        else
        {
            return cachedItems
        }
    }
}
