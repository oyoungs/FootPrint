//
//  ShareContent.swift
//  FootStep
//
//  Created by oyoung on 16/2/26.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit
import CoreLocation



class ShareContent {
    var longitude: Double = 0   //经度
    var latitude: Double = 0    // 纬度
    var date: NSDate = NSDate() //时间
    var information: String = "" //描述信息
    var category: String = "未分类"    //分类
    var address: String = ""            //地址信息
    var photoPaths: String = ""  //照片路径
}
