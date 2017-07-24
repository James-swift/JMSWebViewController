//
//  ViewController.swift
//  JMSWebView
//
//  Created by James.xiao on 2017/1/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var btn1: UIButton = {
        let tempBtn = UIButton.init(type: .system)
        tempBtn.frame = CGRect.init(x: 50, y: 100, width: 150, height: 50)
        tempBtn.setTitle("跳转到百度1", for: .normal)
        tempBtn.backgroundColor = UIColor.green
        tempBtn.setTitleColor(UIColor.white, for: .normal)
        tempBtn.layer.cornerRadius = 10
        tempBtn.clipsToBounds      = true
        tempBtn.tag                = 1
        
        return tempBtn
    }()
    
    private var btn2: UIButton = {
        let tempBtn = UIButton.init(type: .system)
        tempBtn.frame = CGRect.init(x: 50, y: 180, width: 150, height: 50)
        tempBtn.setTitle("跳转到本地测试页面1", for: .normal)
        tempBtn.backgroundColor = UIColor.green
        tempBtn.setTitleColor(UIColor.white, for: .normal)
        tempBtn.layer.cornerRadius = 10
        tempBtn.clipsToBounds      = true
        tempBtn.tag                = 2
        
        return tempBtn
    }()
    
    private var btn3: UIButton = {
        let tempBtn = UIButton.init(type: .system)
        tempBtn.frame = CGRect.init(x: 50, y: 260, width: 150, height: 50)
        tempBtn.setTitle("跳转到百度1", for: .normal)
        tempBtn.backgroundColor = UIColor.green
        tempBtn.setTitleColor(UIColor.white, for: .normal)
        tempBtn.layer.cornerRadius = 10
        tempBtn.clipsToBounds      = true
        tempBtn.tag                = 3

        return tempBtn
    }()
    
    private var btn4: UIButton = {
        let tempBtn = UIButton.init(type: .system)
        tempBtn.frame = CGRect.init(x: 50, y: 340, width: 150, height: 50)
        tempBtn.setTitle("跳转到本地测试页面2", for: .normal)
        tempBtn.backgroundColor = UIColor.green
        tempBtn.setTitleColor(UIColor.white, for: .normal)
        tempBtn.layer.cornerRadius = 10
        tempBtn.clipsToBounds      = true
        tempBtn.tag                = 4
        
        return tempBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupViews()
        btn1.center.x = self.view.center.x
        btn2.center.x = self.view.center.x
        btn3.center.x = self.view.center.x
        btn4.center.x = self.view.center.x
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        self.title                = "WKWebView封装"
        self.view.backgroundColor = .white
        self.view.addSubview(self.btn1)
        self.view.addSubview(self.btn2)
        self.view.addSubview(self.btn3)
        self.view.addSubview(self.btn4)

        self.btn1.addTarget(self, action: #selector(pushVC), for: .touchUpInside)
        self.btn2.addTarget(self, action: #selector(pushVC), for: .touchUpInside)
        self.btn3.addTarget(self, action: #selector(pushVC), for: .touchUpInside)
        self.btn4.addTarget(self, action: #selector(pushVC), for: .touchUpInside)
    }
    
    func pushVC(btn: UIButton) {
        if btn.tag == 1 {
            let webVC = JMSWebViewController.init(positionAt: .backBarBtnItem(backIconImage: UIImage.init(named: "JMS_Back_Icon"), backTintColor: UIColor.black, closeTitleColor: .black, closeIconColor: .black, navTitleFont: UIFont.boldSystemFont(ofSize: 19), navTitleColor: .black), isNavBarHidden: false, progressTintColor: .black, reqPath: "https://www.baidu.com")
            webVC.reqErrorBlk = { (webView, reqPath, error) in
                webVC.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(webVC, animated: true)
        }else if btn.tag == 2 {
            let path = Bundle.main.path(forResource: "js_api_test.html", ofType: nil)!

            let webVC = JMSWebViewController.init(positionAt: .backBarBtnItem(backIconImage: UIImage.init(named: "JMS_Back_Icon"), backTintColor: UIColor.black, closeTitleColor: .black, closeIconColor: nil, navTitleFont: UIFont.boldSystemFont(ofSize: 19), navTitleColor: .black), isNavBarHidden: false, progressTintColor: .black, reqPath: path, scriptMsgNames: ["testApp"])

            webVC.scriptDidReceiveMsgBlk = { [weak self] (webView, userContentController, message) in
                let dict = message.body as? Dictionary<String, Any>
                let methodName = dict?["methodName"] as? String ?? ""
                if methodName == "getToken" {
                    let newVC = ViewController()
                    self?.navigationController?.pushViewController(newVC, animated: true)
                }
            }
            
            self.navigationController?.pushViewController(webVC, animated: true)
        }else if btn.tag == 3 {
            let webVC = JMSWebViewController.init(positionAt: .leftBarBtnItem(backTintColor: .black, closeTitleColor: .black, closeIconColor: .black), isNavBarHidden: false, progressTintColor: .black, reqPath: "https://www.baidu.comd")
            self.navigationController?.pushViewController(webVC, animated: true)
        }else {
            let path = Bundle.main.path(forResource: "js_api_test.html", ofType: nil)!
            let webVC = JMSWebViewController.init(positionAt: .leftBarBtnItem(backTintColor: .black, closeTitleColor: .black, closeIconColor: nil),  isNavBarHidden: false, progressTintColor: .black, reqPath: path, scriptMsgNames: ["testApp"])
            webVC.scriptDidReceiveMsgBlk = { [weak self] (webView, userContentController, message) in
                let dict = message.body as? Dictionary<String, Any>
                let methodName = dict?["methodName"] as? String ?? ""
                if methodName == "getToken" {
                    let newVC = ViewController()
                    self?.navigationController?.pushViewController(newVC, animated: true)
                }
            }
            self.navigationController?.pushViewController(webVC, animated: true)
        }
    }
}

