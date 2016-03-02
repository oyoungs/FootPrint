//
//  ShareCell.swift
//  我的足迹
//
//  Created by oyoung on 16/3/1.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit

class ShareCell: UITableViewCell {
    @IBOutlet weak var headImage: UIView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
