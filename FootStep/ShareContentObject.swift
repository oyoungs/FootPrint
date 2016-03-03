//
//  ShareContentObject.swift
//  我的足迹
//
//  Created by oyoung on 16/2/29.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import Foundation
import CoreData

@objc(ShareContentObject)
class ShareContentObject: NSManagedObject {

    func fromModel(model: ShareContent) {
        address = model.address
        category = model.category
        date = model.date
        information = model.information
        latitude = model.latitude
        longitude = model.longitude
        photoPaths = model.photoPaths
    }
    
    func toModel() -> ShareContent {
        let model: ShareContent = ShareContent()
        model.address = address ?? ""
        model.category = category ?? "未分类"
        model.date = date ?? NSDate()
        model.information = information ?? ""
        model.latitude = latitude?.doubleValue ?? 0
        model.longitude = longitude?.doubleValue ?? 0
        model.photoPaths = photoPaths ?? ""
        return model
    }
}


