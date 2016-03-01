//
//  CoreDataManager.swift
//  FootStep
//
//  Created by oyoung on 16/2/26.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    func saveContext() {
        if let moc = self.managedObjectContext {
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let e as NSError {
                    print(e.userInfo)
                    abort()
                } catch {
                    print("Known Error!")
                    abort()
                }
            }
        }
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
       let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1] as NSURL
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
       let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ItemModel.sqlite")
        var failureReason: String = "创建或加载应用保存数据时出错"
        do {
            let options: NSMutableDictionary = NSMutableDictionary()
            options.setValue(true, forKey: NSMigratePersistentStoresAutomaticallyOption)
            options.setValue(true, forKey: NSInferMappingModelAutomaticallyOption)
            try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options:  nil)
        } catch {
            return nil
        }
        return coordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
       let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    func findAll()  -> [ShareContent]{
        var resultArray: [ShareContent] = []
        let cxt = self.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("ShareContentModel", inManagedObjectContext: cxt)
        
        let fetchRequest =  NSFetchRequest()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true) 
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let listData = try cxt.executeFetchRequest(fetchRequest) as! [ShareContentObject]
            for item in listData {
                let sc: ShareContent = ShareContent()
                /* 
                //method 1
                sc.category = item.valueForKey("category") as! String
                sc.date = item.valueForKey("date") as! NSDate
                sc.information = item.valueForKey("information") as! String
                sc.latitude = item.valueForKey("latitude") as! Double
                sc.longitude = item.valueForKey("longitude") as! Double
                sc.address = item.valueForKey("address") as! String
                */
                //method 2
                sc.address = item.address!
                sc.category = item.category!
                sc.date = item.date!
                sc.information = item.information!
                sc.latitude = item.latitude as! Double
                sc.longitude = item.longitude as! Double
                resultArray.append(sc)
            }
        } catch {
            
        }
        return resultArray
    }
    
    func create(model: ShareContent) -> Int {
        let cxt = self.managedObjectContext!
        /*
        let note = NSEntityDescription.insertNewObjectForEntityForName("ShareContentModel", inManagedObjectContext: cxt) as NSManagedObject
        note.setValue(model.category, forKey: "category")
        note.setValue(model.date, forKey: "date")
        note.setValue(model.information, forKey: "information")
        note.setValue(model.latitude, forKey: "latitude")
        note.setValue(model.longitude, forKey: "longitude")
        note.setValue(model.address, forKey: "address")
        */
        let note = NSEntityDescription.insertNewObjectForEntityForName("ShareContentModel", inManagedObjectContext: cxt) as! ShareContentObject
        note.address = model.address
        note.latitude = model.latitude
        note.longitude = model.longitude
        note.information = model.information
        note.category = model.category
        note.date = model.date
        
        if cxt.hasChanges {
            do {
                try cxt.save()
                return 0
            } catch {
                print("插入数据失败!")
                return -1
            }
        }
        return -1
    }
}