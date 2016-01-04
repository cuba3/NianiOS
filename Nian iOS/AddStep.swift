//
//  AddTopic.swift
//  Nian iOS
//
//  Created by Sa on 15/9/10.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

class AddStep: SAViewController, UIActionSheetDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, LSYAlbumPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, upYunDelegate, ShareDelegate {
    
    @IBOutlet var viewDream: UIView!
    @IBOutlet var field2: UITextView!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var imageUpload: UIImageView!
    @IBOutlet var seperatorView2: UIView!
    @IBOutlet var labelPlaceholder: UILabel!
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageArrow: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    var collectionView: UICollectionView!
    let size_field_padding: CGFloat = 12
    let size_collectionview_padding: CGFloat = 8
    let size_height_contentsize: CGFloat = 100
    
    var actionSheet: UIActionSheet!
    var rowDelete = -1
    var dict = NSMutableDictionary()
    var id: String = ""
    var idDream: String = ""
    var imageArray: [ALAsset] = []
    
    var keyboardHeight: CGFloat = 0.0  // 键盘的高度
    var dataArray = NSMutableArray()
    var tableView: UITableView!
    
    var swipeGesuture: UISwipeGestureRecognizer?
    
    /* 多图上传 */
    let queue = NSOperationQueue()
    
    /* 多图上传传递给服务器的数组 */
    var uploadArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        _setTitle("新进展！")
        setBarButtonImage("newOK", actionGesture: "add")
        
        swipeGesuture = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard")
        swipeGesuture!.direction = UISwipeGestureRecognizerDirection.Down
        swipeGesuture!.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeGesuture!)
        
        /* 设置 scrollView */
        let rect = CGRectMake(0, self.seperatorView.bottom(), globalWidth, globalHeight - self.viewDream.height() - 64 - viewHolder.height() - seperatorView2.height() * 2)
        scrollView.frame = rect
        scrollView.contentSize = CGSizeMake(scrollView.width(), size_height_contentsize + size_field_padding * 2)
        
        /* 设置 UICollectionView */
        let w = (globalWidth - size_field_padding * 2 - size_collectionview_padding * 2) / 3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = size_collectionview_padding
        flowLayout.itemSize = CGSize(width: w, height: w)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: CGRectMake(size_field_padding, size_field_padding, rect.width - size_field_padding * 2, 0), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerNib(UINib(nibName: "AddStepImageCell", bundle: nil), forCellWithReuseIdentifier: "AddStepImageCell")
        scrollView.addSubview(collectionView)
        
        /* 设置 field2 */
        field2.frame = CGRectMake(size_field_padding, collectionView.bottom(), rect.width - size_field_padding * 2, scrollView.height() - size_field_padding * 2 - collectionView.height())
        labelPlaceholder.frame.origin = CGPointMake(field2.x() + 6, field2.y() + 6)
        
        seperatorView.setWidth(globalWidth)
        seperatorView.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        seperatorView2.setWidth(globalWidth)
        seperatorView2.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        
        seperatorView2.setY(self.scrollView.bottom())
        viewHolder.setY(seperatorView2.bottom())
        imageUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
        
        /* 初始化 UITableView*/
        tableView = UITableView(frame: CGRectMake(0, seperatorView.bottom(), globalWidth, 0))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "AddStepCell", bundle: nil), forCellReuseIdentifier: "AddStepCell")
        tableView.hidden = true
        tableView.separatorStyle = .None
        self.view.addSubview(tableView)
        
        
        /* 在缓存中获得最新的记本 */
        self.viewDream.setWidth(globalWidth)
        self.viewDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onViewDream"))
        if let NianDreams = Cookies.get("NianDreams") as? NSMutableArray {
            self.dataArray = NianDreams
            tableView.reloadData()
            var count = 0
            for d in dataArray {
                let id = (d as! NSDictionary).stringAttributeForKey("id")
                if id == Cookies.get("DreamNewest") as? String {
                    let data = d
                    let title = data.objectForKey("title") as! String
                    let image = data.objectForKey("image") as! String
                    let userImageURL = "http://img.nian.so/dream/\(image)!dream"
                    self.imageDream.setImage(userImageURL)
                    self.idDream = id
                    self.labelDream.text = title
//                    self.btnOK.enabled = true
                    count = 1
                    break
                }
            }
            if count == 0 {
                let data = dataArray[0] as! NSDictionary
                let id = data.stringAttributeForKey("id")
                let title = data.stringAttributeForKey("title")
                let image = data.stringAttributeForKey("image")
                let userImageURL = "http://img.nian.so/dream/\(image)!dream"
                self.imageDream.setImage(userImageURL)
                self.idDream = id
                self.labelDream.text = title
//                self.btnOK.enabled = true
            }
        }
        
        /* 设置箭头位置*/
        imageArrow.setX(globalWidth - 10 - imageArrow.width())
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.field2.delegate = self
        
        /* 如果传入的 dict 不为空，先提取出相关的内容 */
//        if dict.allKeys.count > 0 {
//            self.editTitle = self.dict["title"] as! String
//            self.editContent = self.dict["content"] as! String
//            self.tagsArray = self.dict["tags"] as! Array
//        }
//        
//        if self.isEdit == 1 {
//            self.field1!.text = self.editTitle.decode()
//            self.field2.text = self.editContent.decode()
//            self.uploadUrl = self.editImage
//        }
    }
    
    func dismissKeyboard() {
        self.field2.resignFirstResponder()
    }
}