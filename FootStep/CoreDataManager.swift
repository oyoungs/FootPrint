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
    var context: NSManagedObjectContext?
    var model: NSManagedObjectModel?
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    
    init() {
        
    }
    //存储数据
    func saveContext() {
        if let context = self.context {
            if context.hasChanges {
                do {
                    try context.save()
                } catch (let e as NSError ) {
                    print(e.userInfo)
                }
            }
        }
    }
    
    var applicationDocumentsDirectory: NSURL? {
        get {
            return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
        }
    }
    
    func insertCoreData(array: NSMutableArray?) {
        
    }
    
    func selectData() -> NSMutableArray {
        let array = NSMutableArray()
        return array
    }
    
    func updateData() {
        
    }
}