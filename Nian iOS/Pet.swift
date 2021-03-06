//
//  Pet.swift
//  Nian iOS
//
//  Created by Sa on 15/7/26.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit


class PetViewController: SAViewController, ShareDelegate {
    var tableView: UITableView!
    var tableViewPet: UITableView!
    let NORMAL_WIDTH: CGFloat  = 72.0
    var dataArray = NSMutableArray()
    var btnUpgrade: NIButton!
    var upgradeView: NIAlert?
    var petDetailView: NIAlert?
    var upgradeResultView: NIAlert?
    var evolutionView: NIAlert?
    var giftView: NIAlert?
    var current: Int = 0
    var pre: Int = -1
    var cellString: String = ""
    var imageView: UIImageView!
    var tapOnTableView: UITapGestureRecognizer?  // 绑定在 table 上
    var labelName: UILabel!
    var labelLevel: UILabel!
    var labelLeft: UILabel!
    var labelRight: UILabel!
    var isUpgradeSuccess: Bool = false
    var energy: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        load()
    }
    
    func setupViews() {
        self._setTitle("宠物")
        self.setBarButton("抽蛋", actionGesture: #selector(PetViewController.onEgg))
        setupTable()
    }
    
    @objc func onEgg() {
        let v = SAEgg()
        v.delegateShare = self
        v.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "抽蛋", "要以 3 念币抽一次\n宠物吗？", [" 嗯！", "不要"]],
                                     forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
        v.showWithAnimation(.flip)
    }
    
    func onShare(_ avc: UIActivityViewController) {
        self.present(avc, animated: true, completion: nil)
    }
}
