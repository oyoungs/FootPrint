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
    @IBOutlet weak var informationText: UITextView!
    
    private var geocoder: CLGeocoder = CLGeocoder()
    private var locationManager: CLLocationManager?
    
    var content: ShareContent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager(delegate: self)
        addTouchHandler()
    }

    
    override func viewWillAppear(animated: Bool) {
        updateLoacation()
    }
    
    func addTouchHandler() {
        let tap = UITapGestureRecognizer(target: self, action: Selector("viewTouch:"))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func viewTouch(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        guard !view.isKindOfClass(UITextView) else { return}
        if informationText.isFirstResponder() {
            informationText.resignFirstResponder()
        }
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
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 1 else {return}
        showActionSheet()
    }
    
    func showActionSheet() {
        let action: UIActionSheet = UIActionSheet(title: "选择图片来源", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册选取", "拍照")
        action.showInView(view)
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

extension ShareViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "添加描述信息" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
}

extension ShareViewController: UIActionSheetDelegate {
  
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            localSelect()
        case 2:
            takePhoto()
        default:break
        }
    }
    
    func  takePhoto() {
        let sourceType: UIImagePickerControllerSourceType = .Camera
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let  picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = sourceType
            presentViewController(picker, animated: true, completion: nil)
        } else {
            let alert: UIAlertController = UIAlertController(title: "提示", message: "模拟器相机不可用，请使用真机", preferredStyle: UIAlertControllerStyle.Alert)
            let action: UIAlertAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func localSelect() {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
}

extension ShareViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        let type = info[UIImagePickerControllerMediaType] as? String
        if type == "public.image" {
            
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("取消选择")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ShareViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        guard let view = touch .view else { return  false}
        guard !view.isKindOfClass(UITextView) else { return false}
        if informationText.isFirstResponder() {
            informationText.resignFirstResponder()
        }
        return false
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

