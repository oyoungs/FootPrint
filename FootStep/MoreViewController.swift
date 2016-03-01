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
    @IBOutlet weak var tableView: UITableView!

    var dataSource: [ShareContent] = []
    var coreDataManager: CoreDataManager = CoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        tableViewReloadData()
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
        tableView.reloadData()
    }
    
    func dataSourceUpdate() {
            dataSource = coreDataManager.findAll()
    }
  
}


extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    //dataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "shareCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: identifier)
        }
        
        cell?.textLabel?.text = dataSource[indexPath.row].information
        cell?.detailTextLabel?.text = dataSource[indexPath.row].address
        return cell!
    }
}
