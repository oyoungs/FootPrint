//
//  ShareViewController.swift
//  FootStep
//
//  Created by oyoung on 16/2/26.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit

class ShareViewController: UITableViewController {

    @IBOutlet weak var selectCategory: UILabel!
    
    var content: ShareContent?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToShareViewController(segue: UIStoryboardSegue) {
        if let svc = segue.sourceViewController as? CategorySelectViewController {
            selectCategory.text = svc.selectText
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? CategorySelectViewController {
           dvc.selectText =  selectCategory.text
        }
    }
}
