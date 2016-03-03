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
        var failure: Bool = true
         repeat {
            do {
                let options: NSMutableDictionary = NSMutableDictionary()
                options.setValue(true, forKey: NSMigratePersistentStoresAutomaticallyOption)
                options.setValue(true, forKey: NSInferMappingModelAutomaticallyOption)
                try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options:  nil)
                failure = false
            } catch {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(url)
                } catch {
                    return nil
                }
            }
         } while failure
        return coordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
       let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
}
extension CoreDataManager {
    func findAll(completeHanlder: ((NSError)->Void)? = nil)  -> [ShareContent]{
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
                let sc: ShareContent = item.toModel()
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
               
                resultArray.append(sc)
            }
            
        } catch {
            print("查询出错")
            let err = NSError(domain: "数据库查询出错", code: 1, userInfo: nil)
            if let handler = completeHanlder {
                handler(err)
            }
        }
        return resultArray
    }
    
    func create(model: ShareContent, completeHandler: ((NSError)-> Void)?) {
       
        if let cxt = self.managedObjectContext {
            /*
            //method 1
            let note = NSEntityDescription.insertNewObjectForEntityForName("ShareContentModel", inManagedObjectContext: cxt) as NSManagedObject
            note.setValue(model.category, forKey: "category")
            note.setValue(model.date, forKey: "date")
            note.setValue(model.information, forKey: "information")
            note.setValue(model.latitude, forKey: "latitude")
            note.setValue(model.longitude, forKey: "longitude")
            note.setValue(model.address, forKey: "address")
            */
            let note = NSEntityDescription.insertNewObjectForEntityForName("ShareContentModel", inManagedObjectContext: cxt) as! ShareContentObject
            note.fromModel(model)
            
            if cxt.hasChanges {
                do {
                    try cxt.save()
                    
                } catch {
                    print("插入数据失败!\( __FUNCTION__) : \(__LINE__)")
                   let err = NSError(domain: "插入数据失败", code:2,  userInfo: nil)
                    if let handler = completeHandler {
                        handler(err)
                    }
                }
            }
        }
        print("获取ManaedObjectContext失败\( __FUNCTION__) : \(__LINE__)")
        let err = NSError(domain: "获取ManaedObjectContext失败", code: 1,  userInfo: nil)
        if let handler = completeHandler {
            handler(err)
        }
    }
    
    func remove(model: ShareContent, completeHandler: ((NSError) -> Void)? = nil) {
        if let ctx = self.managedObjectContext {
            let entity = NSEntityDescription.entityForName("ShareContentModel", inManagedObjectContext: ctx)
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = entity
            fetchRequest.predicate = NSPredicate(format: "date = %@", model.date)
            do {
                if let array = try ctx.executeFetchRequest(fetchRequest) as? [ShareContentObject] {
                    if array.count > 0 {
                        ctx.deleteObject(array.last!)
                    }
                    if ctx.hasChanges {
                        do {
                            try ctx.save()
                           
                        } catch {
                            if let handler = completeHandler {
                                let err = NSError(domain: "数据修改失败", code: 3 , userInfo: nil)
                                handler(err)
                            }
                        }
                    }
                }
            } catch {
                print("查询出错")
                if let handler = completeHandler {
                    let err = NSError(domain: "查询出错", code: 2, userInfo: nil)
                    handler(err)
                }
            }
        }
        print("获取ManaedObjectContext失败\( __FUNCTION__) : \(__LINE__)")
        if let handler = completeHandler {
            let error = NSError(domain: "获取ManaedObjectContext失败", code: 1, userInfo: nil)
            handler(error)
        }
    }
    
    func modify(model:ShareContent, completeHandler: ((NSError) ->Void)? = nil) {
        if let ctx = self.managedObjectContext {
            let entity = NSEntityDescription.entityForName("ShareContentModel", inManagedObjectContext: ctx)
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = entity
            fetchRequest.predicate = NSPredicate(format: "date = %@", model.date)
            do {
                if let array: [ShareContentObject] = try ctx.executeFetchRequest(fetchRequest) as? [ShareContentObject] {
                   let m = array[0]
                    m.fromModel(model)
                    if ctx.hasChanges {
                        do {
                            try ctx.save()
                        } catch {
                            if let handler = completeHandler {
                                let err = NSError(domain: "数据修改失败", code: 3 , userInfo: nil)
                                handler(err)
                            }
                        }
                    }
                }
            } catch {
                print("查询出错")
                if let handler = completeHandler {
                    let err = NSError(domain: "查询出错", code: 2, userInfo: nil)
                    handler(err)
                }
            }
        }
        print("获取ManaedObjectContext失败\( __FUNCTION__) : \(__LINE__)")
        if let handler = completeHandler {
            let error = NSError(domain: "获取ManaedObjectContext失败", code: 1, userInfo: nil)
            handler(error)
        }
    }
}