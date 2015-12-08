//
//  OriginalTabBarController.swift
//  AirMeet
//
//  Created by koooootake on 2015/11/29.
//  Copyright © 2015年 koooootake. All rights reserved.
//

import UIKit

//タブバー設定
class OriginalTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///（kmdr,momoka）
        
        // 選択時のタブバーアイコン・テキストの色
        let selectedColor:UIColor = UIColor(red: 65.0/255.0, green: 168.0/255.0, blue: 186.0/255.0, alpha: 1)//水色

        ///ボタンをいいかんじに
        let fontFamily: UIFont! = UIFont(name: "Hiragino Kaku Gothic ProN",size:10)
        
        // 文字色とフォント変えたい
        let selectedAttributes = [NSFontAttributeName: fontFamily, NSForegroundColorAttributeName: selectedColor]
        //let nomalAttributes = [NSFontAttributeName: fontFamily, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, forState: UIControlState.Selected)
        //UITabBarItem.appearance().setTitleTextAttributes(nomalAttributes, forState: UIControlState.Normal)
        
        // アイコンの色
        UITabBar.appearance().tintColor = selectedColor
        
        // 背景色
        UITabBar.appearance().barTintColor = UIColor(red: 128/255.0, green: 204/255.0, blue: 223/255.0, alpha: 1.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}