//
//  MoreViewController.swift
//  FootStep
//
//  Created by oyoung on 16/2/24.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit
import CoreLocation


class MoreViewController: UIViewController {

    var dataSource: [ShareContent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToHere(segue: UIStoryboardSegue) {
        tableViewReloadData()
    }
    
    func tableViewReloadData() {
        dataSourceUpdate()
        
    }
    
    func dataSourceUpdate() {
        
    }
  
}


extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    //dataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "shareCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        
        return cell!
    }
}
