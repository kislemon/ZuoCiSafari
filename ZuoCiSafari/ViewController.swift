//
//  ViewController.swift
//  ZuoCiSafari
//
//  Created by 张椋萌 on 16/4/7.
//  Copyright © 2016年 Lemon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(frame: CGRectMake(100, 100, 50, 50))
        button.backgroundColor = UIColor.grayColor()
        button.addTarget(self, action: #selector(self.get), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func get() {
        SafariViewController.openUrlStr("http://www.baidu.com")
    }



}

