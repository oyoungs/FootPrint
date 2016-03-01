//
//  ShareContentObject+CoreDataProperties.swift
//  我的足迹
//
//  Created by oyoung on 16/2/29.
//  Copyright © 2016年 oyoung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ShareContentObject {

    @NSManaged var address: String?
    @NSManaged var category: String?
    @NSManaged var information: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var date: NSDate?

}
