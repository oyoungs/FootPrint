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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let cell = sender as? ShareCell, let dvc = segue.destinationViewController as? ShareViewController else { return  }
        dvc.navigationTitle = "详情页"
        dvc.controllerType = ControllerType.Edit
        if let indexPath = tableView.indexPathForCell(cell) {
            let shareContent = dataSource[indexPath.section]
            dvc.content = shareContent
        }
    }
  
}


extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    //dataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "shareCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ShareCell
        if cell == nil {
            cell = ShareCell(style: .Subtitle, reuseIdentifier: identifier)
        }
        
        cell?.informationLabel.text = dataSource[indexPath.section].information
        cell?.locationLabel.text = dataSource[indexPath.section].address
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            removeShareContent(forRowAtIndexPath: indexPath)
        default:break
        }
    }
    
    func removeShareContent(forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.section
        let shareContent = dataSource[index]
        let manager = CoreDataManager()
        manager.remove(shareContent)
        tableViewReloadData()
    }

}
