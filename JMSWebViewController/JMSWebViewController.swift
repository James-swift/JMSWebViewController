//
//  HGYWebViewController.swift
//  HGYTenant
//
//  Created by James on 2016/12/17.
//  Copyright © 2016年 Shenzhen Haogongyu Information Technology co.,LTD. All rights reserved.
//

import UIKit
import WebKit

private let kWebViewEstimatedProgress   =  "estimatedProgress"
private let kWebViewTitle               =  "title"
private let backTitle: String           = JMSWebViewUtils.getLocalizedString(key: "back")

open class JMSWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate {
    
    private(set) var webView: WKWebView = {
        let tempConfiguration           = WKWebViewConfiguration()
        tempConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let tempWebView                 = WKWebView.init(frame: .zero, configuration: tempConfiguration)
        tempWebView.allowsBackForwardNavigationGestures = false
        tempWebView.backgroundColor     = .clear
        
        return tempWebView
    }()
    
    private(set) var progressView: UIProgressView?
    
    private var reqPath: String         = ""
    private var  isNavBarHidden         = true
    
    /**
        The name of the message processing array
     */
    private var scriptMsgNames: Array<String>   = []
    
    /**
        The name of the message processing block
     */
    public  var scriptDidReceiveMsgBlk: ((_ userContentController: WKUserContentController, _ message: WKScriptMessage) -> ())?
    
    private(set) var backBarButton: UIBarButtonItem = {
        let tempBarBtn      = UIBarButtonItem.init()
        tempBarBtn.title    = backTitle
        
        return tempBarBtn
    }()
    
    private(set) var backTitleColor: UIColor  = .black
    private(set) var backTintColor: UIColor   = .black
    private      var closeTitle: String       = JMSWebViewUtils.getLocalizedString(key: "close")
    private(set) var closeIconColor: UIColor  = .clear
    private(set) var closeTitleColor: UIColor = .black
    private(set) var closeBtn: UIButton?
    private var cacheCloseHidden: Bool        = false
    
    private      var backSizeW                = 34
    private      var closeSizeW               = 34

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = self.isNavBarHidden
        self.closeBtn?.isHidden = false
        
        self.webView.addObserver(self, forKeyPath: kWebViewEstimatedProgress, options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: kWebViewTitle, options: .new, context: nil)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.closeBtn?.isHidden = true
        
        self.webView.removeObserver(self, forKeyPath: kWebViewEstimatedProgress)
        self.webView.removeObserver(self, forKeyPath: kWebViewTitle)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.fillDatas()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: Initialization
    /// Initialization
    ///
    ///     let webViewVC =  JMSWebViewController.init(reqPath: path, scriptMsgNames: [], backTintColor: .red, closeTitleColor: .red)
    ///
    /// - Parameters:
    ///     - isNavBarHidden: Whether to hide the navigation bar
    ///     - reqPath: Request path
    ///     - scriptMsgNames: The name of the message processing array
    ///     - backTintColor: Back views Color
    ///     - closeTitleColor: Close title Color
    ///     - closeIconColor: Close icon Color
    public init(isNavBarHidden: Bool = false, reqPath: String, scriptMsgNames: Array<String> = [], backTintColor: UIColor = UIColor.black, closeTitleColor: UIColor = UIColor.black, closeIconColor: UIColor = .clear) {
        self.reqPath         = reqPath
        self.isNavBarHidden  = isNavBarHidden
        self.scriptMsgNames  = scriptMsgNames
        self.backTintColor   = backTintColor
        self.closeTitleColor = closeTitleColor
        self.closeIconColor  = closeIconColor
        if closeIconColor == .clear {
            backSizeW       = 50
            closeSizeW      = 44
        }else {
            closeTitle      = ""
            backTitleColor  = .clear
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - UI
    private func setupViews() {
        self.view.backgroundColor           = .white
        self.edgesForExtendedLayout         = UIRectEdge()
        
        self.webView.navigationDelegate     = self
        self.webView.uiDelegate             = self
        self.view.addSubview(self.webView)
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.setNeedsUpdateConstraints()
        self.webView.updateConstraints()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            
        if !self.isNavBarHidden {
            progressView = UIProgressView.init(progressViewStyle: .bar)
            progressView!.frame = CGRect.init(x: 0, y: 64 - progressView!.bounds.size.height, width: self.view.bounds.size.width, height: progressView!.bounds.size.height)
            progressView?.isHidden          = true
            progressView!.progressTintColor = backTintColor
            progressView?.trackTintColor    = .clear
            self.navigationController?.view.addSubview(progressView!)
        }
        
        self.setupCloseBtn()
    }
    
    open override func updateViewConstraints() {
        super.updateViewConstraints()
        let leftConstraint = NSLayoutConstraint(item: self.webView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.webView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        let topConstraint =  NSLayoutConstraint(item: self.webView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint =  NSLayoutConstraint(item: self.webView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.view.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    private func setupCloseBtn(isHiddenCloseBtn: Bool = true) {
        let customView = UIView.init(frame: .init(x: 0, y: 0, width: isHiddenCloseBtn ? backSizeW : (backSizeW + closeSizeW), height: 44))

        let backBtn    = UIButton.jms_web_backButton(frame: .init(x: 0, y: 0, width: backSizeW, height: 44), imageColor: backTintColor, title: backTitle, titleColor: backTitleColor, target: self, action: #selector(clickBackBtn), for: .touchUpInside)
        customView.addSubview(backBtn)
        
        if !isHiddenCloseBtn {
            self.closeBtn = UIButton.jms_web_closeButton(frame: .init(x: backSizeW, y: 0, width: closeSizeW, height: 44), imageColor: closeIconColor, title: closeTitle, titleColor: closeTitleColor, target: self, action: #selector(close), for: .touchUpInside)
            customView.addSubview(self.closeBtn!)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: customView)
    }
    
    // MARK: - Datas
    private func fillDatas() {
        if self.isNavBarHidden && self.reqPath == "" {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        for item in scriptMsgNames {
            self.webView.configuration.userContentController.add(self, name: item)
        }
        
        let tempUrl = URL.init(string: self.reqPath)!
        if tempUrl.host != nil && tempUrl.scheme != nil {
            self.webView.load(URLRequest.init(url: tempUrl))
        }else {
            self.webView.load(URLRequest.init(url: URL.init(fileURLWithPath: self.reqPath)))
        }
    }
    
    // MARK: - Event Response
    func clickBackBtn() {
        if self.webView.canGoBack {
            self.setupCloseBtn(isHiddenCloseBtn: false)
            self.webView.goBack()
        }else {
            self.close()
        }
    }
    
    func close() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        if self.webView.isLoading {
            self.webView.stopLoading()
        }
        
        self.progressView?.removeFromSuperview()
    }
    
    // MARK: - Private
    private func didStartLoad() {
        self.progressView?.progress = 0
        self.progressView?.isHidden = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func didFinishLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.progressView?.isHidden = true
        }
    }
    
    private func didFailProvisionalNavigation() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        self.progressView?.isHidden = true
        self.progressView?.progress = 0
    }
    
    private func didFailNavigation() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        self.progressView?.isHidden = true
        self.progressView?.progress = 0
    }
    
    // MARK: - WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if self.scriptDidReceiveMsgBlk != nil && self.scriptMsgNames.contains(message.name) {
            self.scriptDidReceiveMsgBlk!(userContentController, message)
        }
    }
    
    // MARK: - Observer
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == kWebViewEstimatedProgress {
            self.progressView?.progress = Float(self.webView.estimatedProgress)
        }else if keyPath == kWebViewTitle {
            self.title = webView.title
        }
    }
    
    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.didStartLoad()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.didFinishLoad()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.didFailProvisionalNavigation()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.didFailNavigation()
    }
    
    // MARK: - WKUIDelegate
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let host = webView.url?.host

        let alert = UIAlertController(title: host ?? JMSWebViewUtils.getLocalizedString(key: "messages"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: JMSWebViewUtils.getLocalizedString(key: "confirm"), style: .default, handler: { (_) -> Void in
            // We must call back js
            alert.dismiss(animated: true, completion: nil)
            completionHandler()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let host = webView.url?.host

        let alert = UIAlertController(title: host ?? JMSWebViewUtils.getLocalizedString(key: "messages"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: JMSWebViewUtils.getLocalizedString(key: "cancel"), style: .cancel, handler: { (_) -> Void in
            completionHandler(false)
        }))
        alert.addAction(UIAlertAction(title: JMSWebViewUtils.getLocalizedString(key: "confirm"), style: .default, handler: { (_) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completionHandler(true)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let host = webView.url?.host

        let alert = UIAlertController(title: prompt, message: host ?? defaultText, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) -> Void in
            textField.placeholder = defaultText ?? JMSWebViewUtils.getLocalizedString(key: "input")
            textField.font = UIFont.systemFont(ofSize: 12.0)
        }
        alert.addAction(UIAlertAction(title: JMSWebViewUtils.getLocalizedString(key: "cancel"), style: .cancel, handler: { (_) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completionHandler(alert.textFields?.first?.text ?? defaultText)
        }))
        alert.addAction(UIAlertAction(title: JMSWebViewUtils.getLocalizedString(key: "confirm"), style: .default, handler: { (_) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completionHandler(alert.textFields?.first?.text ?? defaultText)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let count = self.navigationController?.viewControllers.count ?? 0
        if count <= 1 {
            return false
        }
        
        return true
    }

}
