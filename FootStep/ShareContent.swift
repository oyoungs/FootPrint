//
//  ShareContent.swift
//  FootStep
//
//  Created by oyoung on 16/2/26.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit
import CoreLocation

enum ShareCategory {
    case None
    case Bar
}

class ShareContent {
    var location: CLLocation
    var desciption: String = ""
    var category: ShareCategory = .None
    init(location: CLLocation) {
        self.location = location
    }
}
