//
//  SafariViewController.swift
//  ZuoCiSafari
//
//  Created by 张椋萌 on 16/4/7.
//  Copyright © 2016年 Lemon. All rights reserved.
//

import UIKit

class SafariViewController: UIViewController, UIWebViewDelegate {
    
    var webView = UIWebView()
    var currentRequest = NSURLRequest()
    var requestArray = [NSURLRequest]()
    
    
    var backItem = UIBarButtonItem()
    var closeItem = UIBarButtonItem()
    
    //弹出选项框
    let chooseView = UIView()
    //背景按钮
    let backViewButton = UIButton()
    
    // 单例
    class var sharedInstance : SafariViewController {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : SafariViewController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SafariViewController()
        }
        return Static.instance!
    }
    
    //打开urlString
    class func openUrlStr(urlStr:String) {
        let nav = UINavigationController(rootViewController: SafariViewController.sharedInstance)
        nav.navigationBar.translucent = false
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(nav, animated: true, completion: nil)
        SafariViewController.sharedInstance.requestArray = [NSURLRequest]()
        let request = NSURLRequest(URL: NSURL(string: urlStr)!)
        SafariViewController.sharedInstance.webView.loadRequest(request)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = true
        self.initializeUserInterface()
    }
    
    
    //导航栏添加按钮
    func addNavigationItems() {
        backItem = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.popEvent(_:)))
        closeItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.closeEvent(_:)))
        let chooseItem = UIBarButtonItem(image: UIImage(named: "item"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.chooseEvent(_:)))
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationItem.rightBarButtonItem = chooseItem
    }
    
    //添加webview
    func initializeUserInterface() {
        self.addNavigationItems()
        webView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 64)
        webView.delegate = self;
        self.view.addSubview(webView)
        
        chooseView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 64, UIScreen.mainScreen().bounds.width, 0)
        chooseView.backgroundColor = UIColor.blueColor()
        for i in 0..<3 {
            let button = UIButton(frame: CGRectMake(50, 10 * (CGFloat(i) + 1) + 30 * CGFloat(i), UIScreen.mainScreen().bounds.width - 100, 30))
            button.tag = 10000 + i
            button .setTitle(i == 0 ? "用Safari打开" : i == 1 ? "复制链接" : "取消", forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(self.chooseOneEvent(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            chooseView.addSubview(button)
        }
        self.view.addSubview(chooseView)
    }
    
    
    //后退
    func popEvent(_:UIBarButtonItem) {
        if requestArray.count > 1 {
            webView.loadRequest(requestArray[requestArray.count - 2])
            requestArray.removeLast()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //关闭浏览器
    func closeEvent(_:UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //弹出选项窗口
    func chooseEvent(_:UIBarButtonItem) {
        backViewButton.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 64)
        backViewButton.addTarget(self, action: #selector(self.removeChooseView), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backViewButton)
        self.view.bringSubviewToFront(chooseView)
        
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions.LayoutSubviews, animations: {
            self.chooseView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 194, UIScreen.mainScreen().bounds.width, 130)
            }, completion: nil)
    }
    
    //选择一个选项
    func chooseOneEvent(sender:UIButton) {
        self.removeChooseView()
        switch sender.tag {
        case 10000:
            //用safari打开
            UIApplication.sharedApplication().openURL(NSURL(string: (requestArray.last?.mainDocumentURL?.absoluteString)!)!)
            break
        case 10001:
            //复制链接
            UIPasteboard.generalPasteboard().string = requestArray.last?.mainDocumentURL?.absoluteString
            break
        default:
            //取消
            break
        }
    }
    
    //移除选项视图
    func removeChooseView() {
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions.LayoutSubviews, animations: {
            self.chooseView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 64, UIScreen.mainScreen().bounds.width, 0)
        }) { (succeed) in
            self.backViewButton.removeFromSuperview()
        }
    }

    
    //MARK:-WebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        currentRequest = request
        if requestArray.count > 0  && requestArray.last!.mainDocumentURL?.absoluteString != request.mainDocumentURL?.absoluteString{
            requestArray.append(request)
        }
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        if requestArray.count == 0 {
            requestArray.append(currentRequest)
        }
        if requestArray.count > 1 && self.navigationItem.leftBarButtonItems?.count < 2 {
            self.navigationItem.leftBarButtonItems = [backItem, closeItem]
        }
        if requestArray.count == 1 && self.navigationItem.leftBarButtonItems?.count >= 2 {
            self.navigationItem.leftBarButtonItems = [backItem]
        }
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        //提示url存在问题
    }


}
