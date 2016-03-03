 //
//  ShareViewController.swift
//  FootStep
//
//  Created by oyoung on 16/2/26.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit
import CoreLocation
enum ControllerType {
    case Add
    case Edit
}

class ShareViewController: UITableViewController {

    @IBOutlet weak var selectCategory: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var informationText: UITextView!
    @IBOutlet weak var photoCell: PhotoCell!
    
    private var geocoder: CLGeocoder = CLGeocoder()
    private var locationManager: CLLocationManager?
    
    var content: ShareContent?
    var navigationTitle: String = "添加足迹" {
        didSet {
            navigationItem.title = navigationTitle
        }
    }
    
    lazy var manager: CoreDataManager = CoreDataManager()
    var saveMethod: ImageSaveMethod = .Local

    var controllerType: ControllerType = .Add
    
    let informationPlacehold: String = "添加描述信息"
    var imageSource: [NSURL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager(delegate: self)
        addTouchHandler()
    }

    
    override func viewWillAppear(animated: Bool) {
        if let _ = content {
            loadInfomation()
        } else {
            updateLoacation()
        }
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
       
        if let cnt = content {
            let lo = cnt.longitude
            let la = cnt.latitude
            longitudeLabel.text = String(format: "%.4f", lo)
            latitudeLabel.text = String(format: "%.4f", la)
            if cnt.information == "" {
                informationText.text = informationPlacehold
                informationText.textColor = UIColor.grayColor()
            } else {
                informationText.text = cnt.information
                informationText.textColor = UIColor.blackColor()
            }
            selectCategory.text = cnt.category
            timeLabel.text = formatter.stringFromDate(cnt.date)
            locationLabel.text = cnt.address
            
            let urlStrings = cnt.photoPaths.componentsSeparatedByString(";")
            if urlStrings.count > 0 && !urlStrings[0].isEmpty{
                imageSource = urlStrings.map() {
                        return NSURL(string: $0)!
                }
                photoCell.style = .Media
                for url in imageSource {
                    photoCell.addImageWithUrl(url)
                }
                photoCell.autoLayoutButtons()
            }
            
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
            if let cnt = content {
                cnt.category = svc.selectText!
                loadInfomation()
            }
            
        }
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 1 else {return}
        showActionSheet()
    }
    
  
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return photoCell.rowHeight
        } else if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            return 120
        } else {
            return 44
        }
    }
    
    func showActionSheet() {
        let action: UIActionSheet = UIActionSheet(title: "选择图片来源", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册选取", "拍照")
        action.showInView(view)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sender = sender {
            if sender.isKindOfClass(UIBarButtonItem) {
                if sender.tag > 0 {
                    saveInformation()
                    saveShareContent()
                }
            } else if sender.isKindOfClass(UITableViewCell) {
                if let dvc = segue.destinationViewController as? CategorySelectViewController {
                    if let cnt = content {
                        if let information = informationText.text {
                            cnt.information = information == informationPlacehold ? "" : information
                        }
                        dvc.selectText = cnt.category
                        
                    }
                }
            }
        }
    }
    
    func     saveInformation() {
        if let cnt = content {
            if let information = informationText.text {
                cnt.information = information == informationPlacehold ? "" : information
                cnt.category = selectCategory.text!
                cnt.photoPaths = imageSource.map(){ return $0.absoluteString }.joinWithSeparator(";")
            }
        }
    }
        //保存到本地
    func saveShareContent() {
        if let shareContent = content {
            switch controllerType {
            case .Add:
                manager.create(shareContent) { error in
                    print(error)
                }
            case .Edit:
                manager.modify(shareContent) { error in
                    print(error)
                }
            }
            
        }
    }
    
    func updateCollectionCell() {
        if imageSource.count > 0 {
            photoCell.style = PhotoCellStyle.Media
            if let url  = imageSource.last {
                photoCell.addImageWithUrl(url)
            }
        }
    }
    
    func removeShareContent() {
        if let shareContent = content {
            manager.remove(shareContent) { error in
               print(error)                
            }
        }
    }

}

extension ShareViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == informationPlacehold {
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

enum ImageSaveMethod {
    case Local
    case Remote
}
extension ShareViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func saveSelectedImage(image: UrlImage?, completeHandler: ((NSURL?)->Void)? = nil) {
        switch saveMethod {
        case .Local:
            saveImageLocal(image) { url in
                if let handler = completeHandler {
                    handler(url)
                }
            }
        case .Remote:
            saveImageRemote(image) { url in
                if let handler = completeHandler {
                    handler(url)
                }
            }
        }
    }
    //MARK:  保存图片到本地并获取到URL
    func saveImageLocal(image: UrlImage?, completeHandler: ((NSURL?) -> Void)? = nil) {
        if let handler = completeHandler {
         
                let id = AutoIncreasement.shareInstance.next()
                let url = manager.applicationDocumentsDirectory.URLByAppendingPathComponent("foot_photo_\(id).png")
                if let img = image?.image {
                    let data = UIImagePNGRepresentation(img)
                    data?.writeToURL(url, atomically: true)
                    handler(url)
            }
        }
        
    }
    //MARK: 保存呢图片到远程服务器并获取URL, 暂未实现
    func saveImageRemote(image: UrlImage?, completeHandler: ((NSURL?)->Void)? = nil) {
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        
        let type = info[UIImagePickerControllerMediaType] as? String
        if type == "public.image" {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                let urlImage = UrlImage()
                urlImage.image = image
                urlImage.url = info[UIImagePickerControllerReferenceURL] as? NSURL  //去得到URL,说明是本地相册取图片，否则为拍照
                saveSelectedImage(urlImage) { url in
                    guard let url = url else {return}
                    guard !self.imageSource.contains(url) else { return }
                    self.imageSource.append(url)
                    self.saveInformation()
                    self.updateCollectionCell()
                }
                
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("取消选择")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
class UrlImage {
    var image: UIImage?
    var url: NSURL?
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
                content?.category = "未分类"
                content?.information = ""
                geocoder.reverseGeocodeLocation(ln) { (placemarks, error) -> Void in
                    if let e = error {
                        print(e.debugDescription)
                    } else {
                        if let ps = placemarks {
                            let pm = ps[0]
                            self.content?.address = pm.name!
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

