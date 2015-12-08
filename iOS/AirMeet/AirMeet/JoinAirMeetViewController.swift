//
//  JoinAirMeetViewController.swift
//  AirMeet
//
//  Created by koooootake on 2015/11/28.
//  Copyright © 2015年 koooootake. All rights reserved.
//

import UIKit

class JoinAirMeetViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,NSURLSessionDelegate,NSURLSessionDataDelegate,UIScrollViewDelegate {
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    
    @IBOutlet weak var TagSettingTableView: UITableView!
    
    var selectIndex:NSIndexPath = NSIndexPath()
    var selectTextFiled:UITextField = UITextField()
    
    var tags:[TagModel] = [TagModel]()
    
    var tagCount:Int = 0
    var sessionTag:Int = 0
    
    var tagDics = [String:String]()
    
    @IBOutlet weak var eventBackView: UIView!
    
    //くるくる
    let indicator:SpringIndicator = SpringIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ナビゲーションバーの色
        self.navigationController?.navigationBar.barTintColor=UIColor(red: 128.0/255.0, green: 204.0/255.0, blue: 223.0/255.0, alpha: 1)//水色
        self.navigationController?.navigationBar.tintColor=UIColor.whiteColor()
        
        TagSettingTableView.delegate = self
        TagSettingTableView.dataSource = self
        
        scrollView.delegate = self
        
        eventLabel.text = "\(appDelegate.selectEvent!.eventName)"
        roomLabel.text = "\(appDelegate.selectEvent!.roomName)"
        
        //アイコンまる
        imageImageView.layer.cornerRadius = imageImageView.frame.size.width/2.0
        imageImageView.layer.masksToBounds = true
        imageImageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageImageView.layer.borderWidth = 3.0
        
        //event情報
        eventBackView.layer.cornerRadius = 3.0
        eventBackView.layer.masksToBounds = true
        eventBackView.layer.borderColor = UIColor.lightGrayColor().CGColor
        eventBackView.layer.borderWidth = 1.0
        
        let defaults = NSUserDefaults.standardUserDefaults()
        //画像
        let imageData:NSData = defaults.objectForKey("image") as! NSData
        imageImageView.image = UIImage(data:imageData)
        let backData:NSData = defaults.objectForKey("back") as! NSData
        backImageView.image = UIImage(data: backData)
        
        //ぐるぐる
        indicator.frame = CGRectMake(self.view.frame.width/2-self.view.frame.width/8,self.view.frame.height/2-self.view.frame.width/8,self.view.frame.width/4,self.view.frame.width/4)
        indicator.lineWidth = 3
        
        tagDics = defaults.objectForKey("tag") as! [String:String]
        print(tagDics)

        //tagテーブルに値いれる
        for name in appDelegate.selectEvent!.eventTag{
            
            if (tagDics["\(name)"] != nil){
                let tagModel:TagModel = TagModel(name: "\(name)", detail: "\(tagDics["\(name)"]!)")
                tags.append(tagModel)
                
            }else{
                let tagModel:TagModel = TagModel(name: "\(name)", detail: "")
                tags.append(tagModel)
            }
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        //キーボード
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        //mainに戻る
        if appDelegate.isChild == true {
            
            appDelegate.isChild = false
            appDelegate.childID = nil
            appDelegate.isBeacon = true
            
        }
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
        //キーボード
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //スクロールをはじめたらキーボードを閉じる
        selectTextFiled.resignFirstResponder()
        
    }
    
    
    //自動スクロール（にしゅうスクロール、可変にする？要検討）
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        let cell: SettingTagTableViewCell = TagSettingTableView.dequeueReusableCellWithIdentifier("TagSettingTableViewCell", forIndexPath: selectIndex) as! SettingTagTableViewCell
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        
        let txtLimit = cell.frame.origin.y + cell.frame.height + 8.0
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
        
        if txtLimit >= kbdLimit {
            scrollView.contentOffset.y = txtLimit - kbdLimit
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        scrollView.contentOffset.y = 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let cell: SettingTagTableViewCell = tableView.dequeueReusableCellWithIdentifier("TagSettingTableViewCell", forIndexPath: indexPath) as! SettingTagTableViewCell
        
        cell.setCell(tags[indexPath.row])
        //入力されたテキストを取得するタグとデリゲート
        cell.TagTextField.delegate = self
        cell.TagTextField.tag = indexPath.row
        
        return cell
    }
    
    // セクション数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
   
    
    //UITextFieldが編集開始する直前に呼ばれる
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        //選択されたindexを保存
        selectIndex = NSIndexPath(forRow: textField.tag, inSection: 0)
        //スクロールしたらキーボードが消える用
        selectTextFiled = textField
        return true
    }
    
    //UITextFieldが編集終了する直前に呼ばれる
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        //tag保存
        print("Save Tag Detail : \(textField.placeholder!) -> \(textField.text!)")
        tagDics.updateValue("\(textField.text!)", forKey: "\(textField.placeholder!)")
        
        return true
    }
    
    //改行ボタンが押された際に呼ばれる
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func ChildStartButton(sender: AnyObject) {
        
        //初期の初期設定
        let defaults = NSUserDefaults.standardUserDefaults()
        
        
        //いい感じに配列にして渡す
        var tagString:String = "{"
        
        for tag in tags{
            
            tagString = tagString + "'\(tag.name)'" + ":" + "'\(tag.detail)',"
        }
        
        tagString = tagString + "}"
        
        // 通信用のConfigを生成.
        let myConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        // Sessionを生成.
        let mySession:NSURLSession = NSURLSession(configuration: myConfig, delegate: self, delegateQueue: nil)
        
        let post = "major=\(appDelegate.selectEvent!.eventID)&name=\(defaults.stringForKey("name")!)&profile=\(defaults.stringForKey("detail")!)&image=test&image_header=test&items=\(tagString)"
        let postData = post.dataUsingEncoding(NSUTF8StringEncoding)
        
        let url = NSURL(string: "http://airmeet.mybluemix.net/register_user")
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        
        request.addValue("a", forHTTPHeaderField: "X-AccessToken")
        
        let task:NSURLSessionDataTask = mySession.dataTaskWithRequest(request)
        print("Start Session")
        //くるくるスタート
        sessionTag = 0
        self.view.addSubview(indicator)
        self.indicator.startAnimation()
        
        task.resume()
        
    }
    
    //通信終了
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        //Json解析
        let json = JSON(data:data)
        let code:String = "\(json["code"])"
        let message = json["message"]
        
        switch sessionTag{
        case 0:
            
            appDelegate.childID = "\(json["id"])"
            
            //成功
            if code == "200"{
                
                print("User Login Sucsess : \(json["message"])")
                
                //メインスレッドで表示
                dispatch_async(dispatch_get_main_queue(), {
                    
                    //くるくるストップ
                    self.indicator.stopAnimation(true, completion: nil)
                    self.indicator.removeFromSuperview()
                    //画面遷移
                    self.performSegueWithIdentifier("ShowDetailChild",sender: nil)
                    
                })
                
                appDelegate.isChild = true
                
                //失敗
            }else{
                print("User Login Error : \(json["message"])")
                
                let alert = UIAlertController(title:"False Make AirMeet",message:"\(message)",preferredStyle:UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default) {
                    action in
                }
                alert.addAction(okAction)
                //メインスレッドで表示
                dispatch_async(dispatch_get_main_queue(), {
                    //くるくるストップ
                    self.indicator.stopAnimation(true, completion: nil)
                    self.indicator.removeFromSuperview()
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
            break
        case 1:
            
            
            //成功
            if code == "200"{
                
                print("User Delete Sucsess : \(json["message"])")
                appDelegate.isChild = false
                appDelegate.childID = nil
                
                //非同期
                dispatch_async(dispatch_get_main_queue(), {
                    //くるくるストップ
                    self.indicator.stopAnimation(true, completion: nil)
                    self.indicator.removeFromSuperview()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            //失敗
            }else{
                
                print("User Delete Error : \(json["message"])")
                
                let alert = UIAlertController(title:"False Delete User",message:"\(message)",preferredStyle:UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default) {
                    action in
                }
                alert.addAction(okAction)
                
                //非同期
                dispatch_async(dispatch_get_main_queue(), {
                    //くるくるストップ
                    self.indicator.stopAnimation(true, completion: nil)
                    self.indicator.removeFromSuperview()
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
                
            }
            
            break
            
        default:
            break
            
            
        }
    }

    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}