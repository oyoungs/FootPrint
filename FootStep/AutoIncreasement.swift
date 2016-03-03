//
//  AutoIncreasement.swift
//  我的足迹
//
//  Created by oyoung on 16/3/2.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import Foundation
class AutoIncreasement {
    private var value: Int = 0
    class  var shareInstance: AutoIncreasement  {
        get {
            struct Static {
                static var onceToken : dispatch_once_t = 0
                static var instance : AutoIncreasement? = nil
            }
            dispatch_once(&Static.onceToken) {
                Static.instance = AutoIncreasement()
            }
            return Static.instance!
        }
    }
    
    func next() -> Int {
        let n = value++
        return n
    }
    
    private init() {}
}