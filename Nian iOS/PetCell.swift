//
//  PetCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 7/21/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

// MARK: - pet cell
class PetCell: UITableViewCell {
    @IBOutlet var imgView: UIImageView!
    
    var info: NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    func _layoutSubviews() {
        // 刷新界面
        let imgF = self.info?.stringAttributeForKey("image")
        let owned = self.info?.stringAttributeForKey("owned")
        if owned == "0" {
            self.imgView.setImageGray("http://img.nian.so/pets/\(imgF!)!d")
        } else {
            self.imgView.setImage("http://img.nian.so/pets/\(imgF!)!d", placeHolder: UIColor.clearColor(), bool: false, ignore: true)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imgView?.cancelImageRequestOperation()
        self.imgView?.image = nil
    }
}
