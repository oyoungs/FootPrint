//
//  ShareViewController.swift
//  FootStep
//
//  Created by oyoung on 16/2/26.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit
import CoreLocation

class ShareViewController: UITableViewController {

    @IBOutlet weak var selectCategory: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var informationText: UITextField!
    
    private var geocoder: CLGeocoder = CLGeocoder()
    private var locationManager: CLLocationManager?
    
    var content: ShareContent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager(delegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        updateLoacation()
    }
    
    func loadInfomation() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        timeLabel.text = formatter.stringFromDate(NSDate())
        locationLabel.text = content?.information
        if let cnt = content {
            let lo = cnt.longitude
            let la = cnt.latitude
            longitudeLabel.text = String(format: "%.4f", lo)
            latitudeLabel.text = String(format: "%.4f", la)
        }
    }
    
    func setupLocationManager(delegate d: CLLocationManagerDelegate) {
        locationManager = CLLocationManager()
        if let lm = locationManager {
            lm.delegate = d
            lm.desiredAccuracy = kCLLocationAccuracyBest
            lm.distanceFilter = 50
            lm.requestAlwaysAuthorization()
        }
    }
    
    
    func updateLoacation() {
        if let lm = locationManager {
            if CLLocationManager.locationServicesEnabled() {
                lm.startUpdatingLocation()
            }
        }
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
        if let sender = sender {
            if sender.isKindOfClass(UIBarButtonItem) {
                if sender.tag > 0 {
                    saveShareContent()
                }
            } else if sender.isKindOfClass(UITableViewCell) {
                if let dvc = segue.destinationViewController as? CategorySelectViewController {
                    dvc.selectText = selectCategory.text
                }
            }
        }
    }
    
    //保存到本地
    func saveShareContent() {
        let manager = CoreDataManager()
        let shareContent: ShareContent = ShareContent()
        shareContent.address = locationLabel.text!
        shareContent.category = selectCategory.text!
        shareContent.date = NSDate()
        shareContent.information = informationText.text ?? ""
        manager.create(shareContent)
    }

}


extension ShareViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if content == nil {
            if let ln = locations.last {
                content = ShareContent()
                content?.latitude = ln.coordinate.latitude
                content?.longitude = ln.coordinate.longitude
                content?.date = NSDate()
                geocoder.reverseGeocodeLocation(ln) { (placemarks, error) -> Void in
                    if let e = error {
                        print(e.debugDescription)
                    } else {
                        if let ps = placemarks {
                            let pm = ps[0]
                            self.content?.information = pm.name!
                        }
                    }
                    self.loadInfomation()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
}

