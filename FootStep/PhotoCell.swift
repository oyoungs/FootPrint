//
//  PhotoCell.swift
//  我的足迹
//
//  Created by oyoung on 16/3/2.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit

enum PhotoCellStyle {
    case Text
    case Media
}


protocol PhotoCellDelegate {
    func photoCellImageButtonTouched(cell: PhotoCell, forIndex: Int)
    func photoCellAddButtonTouced(cell: PhotoCell)
}

class PhotoCell: UITableViewCell {
    @IBOutlet weak var imageCollectionView: UIView!
    @IBOutlet weak var collectionTop: NSLayoutConstraint!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    var collection: [NSURL]?
    var rowHeight: CGFloat {
        get {
            switch style {
            case .Text:
                return 44
            case .Media:
                return collectionHeight.constant + 1
            }
        }
    }
    
    var delegate: PhotoCellDelegate? = nil
    var style: PhotoCellStyle = .Text {
        didSet {
            if oldValue != style {
                styleChanged(style)
            }
        }
    }
    
    func addImageWithUrl(url: NSURL, shouldUpdateLayout: Bool = false) {
        if collection == nil {
            collection = [NSURL]()
        }

        guard !collection!.contains(url) else { return }
        if  let data  = NSData(contentsOfURL: url) {
            if let image = UIImage(data: data) {
                collection?.append(url)
                addImageButton(image)
            }
        }
        
        if shouldUpdateLayout {
            autoLayoutButtons()
        }
    }
    
    private func styleChanged(style: PhotoCellStyle) {
        switch style {
        case .Text:
            textStyleSelected()
        case .Media:
            mediaStyleSelected()
        }
    }
    //MARK: 设置为文本风格
    private func textStyleSelected() {
        var f = frame
        f.size.height = 45
        frame = f
        collectionTop.constant = 45
    }
    //MARK: 设置为图片风格
    private func mediaStyleSelected() {
        collectionTop.constant = 0
        var frm = frame
        frm.size.height = collectionHeight.constant + 1

        addImageButton(nil)
    }
    private var addButton: UIButton?
    private var buttons: [UIButton] = []
    private func addImageButton(image: UIImage?) {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.addTarget(self, action: Selector("buttonTouchUpInside:"), forControlEvents: .TouchUpInside)
        if let _ = image {
            button.setImage(image, forState: .Normal)
            button.tag = 0
            buttons.append(button)
        } else {
            button.setTitle("点击添加图片", forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(10)
            button.backgroundColor = UIColor.grayColor()
            button.titleLabel?.textColor = UIColor.blackColor()
            button.tag = -1
            addButton = button
        }
        imageCollectionView.addSubview(button)
        
    }
    
    @IBAction func buttonTouchUpInside(sender: UIButton) {
        if let d = delegate {
            if sender.tag < 0 {
                d.photoCellAddButtonTouced(self)
            } else {
                let index = sender.tag
                d.photoCellImageButtonTouched(self, forIndex: index)
            }
        }
    }
    
    func autoLayoutButtons() {
        let width = bounds.width
        var btframe = CGRect(x: 0, y: 0, width: 60, height: 60)
        btframe.origin = CGPoint(x: 8, y: 8)
        collectionHeight.constant = 80
        for (i, bt) in buttons.enumerate() {
            bt.frame = btframe
            bt.tag = i
            btframe.origin.x += 68
            if btframe.origin.x  + 68 > width {
                btframe.origin.x = 8
                btframe.origin.y += 68
                collectionHeight.constant += 68
                increaseHeight(68)
            }
            
            addButton?.frame = btframe
        }
        
    }
    
    func increaseHeight(delta: CGFloat) {
        var f = frame
        f.size.height += delta
        frame = f
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
