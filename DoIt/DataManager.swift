//
//  DataManager.swift
//  DoIt
//
//  Created by iem on 30/03/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import Foundation


class DataManager{
    
    var cacheItems = [Item]()
    
    var documentDirectory: URL {
        let fm = FileManager.default
        return try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    var dataFileUrl : URL {
        return documentDirectory.appendingPathComponent("checklist").appendingPathExtension("json")
    }
    
    
    static let instance = DataManager()
    
    
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
        
        if(FileManager.default.fileExists(atPath: dataFileUrl.path))
        {
            let jsonData = try! Data(contentsOf: dataFileUrl, options: .alwaysMapped)
            let decoder = JSONDecoder()
            let data = try! decoder.decode([Item].self, from: jsonData)
            for checklist in data {
                cacheItems.append(checklist)
            }
        }
    }
    
    func filter(searchBarText: String) -> [Item]
    {
        if(searchBarText != "")
        {
            return cacheItems.filter({ (item) -> Bool in
                let nameItem = item.name
                let range = nameItem.range(of: searchBarText, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil)
                return range != nil
            })
        }
        else
        {
            return cacheItems
        }
        
    }
}
