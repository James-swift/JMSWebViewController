//
//  HGYWebViewController.swift
//  HGYTenant
//
//  Created by James on 2016/12/17.
//  Copyright © 2016年 Shenzhen Haogongyu Information Technology co.,LTD. All rights reserved.
//

import UIKit
import WebKit
import JMSNavBackButtonHandler

private let kWebViewEstimatedProgress           =  "estimatedProgress"
private let kWebViewTitle                       =  "title"

private let kStatusBarHeight: CGFloat           = 20.0
private let kNavBarHeight: CGFloat              = 44.0
private let kStatusAndNavBarHeight: CGFloat     = 64.0

public enum JMSWebViewBackPositionAt {
    case backBarBtnItem(backIconImage: UIImage?, backTintColor: UIColor?, closeTitleColor: UIColor, closeIconColor: UIColor?, navTitleFont: UIFont, navTitleColor: UIColor)      /// 返回按钮添加到导航栏backBarButtonItem（默认）
    case leftBarBtnItem(backTintColor: UIColor, closeTitleColor: UIColor, closeIconColor: UIColor?)      /// 返回按钮添加到导航栏leftBarButtonItem
}

open class JMSWebViewController: UIViewController {
    
    public var viewWillAppearBlk: ((_ pageId: String, _ webView: WKWebView)->())?
    public var viewDidAppearBlk: ((_ pageId: String, _ webView: WKWebView)->())?
    public var viewWillDisappearBlk: ((_ pageId: String, _ webView: WKWebView)->())?
    public var viewDidDisappearBlk: ((_ pageId: String, _ webView: WKWebView)->())?

    /// 收到消息处理
    public var scriptDidReceiveMsgBlk: ((_ webView: WKWebView, _ userContentController: WKUserContentController, _ message: WKScriptMessage) -> ())?
    /// 请求路径错误处理
    public var reqErrorBlk: ((_ webView: WKWebView, _ reqPath: String, _ error: Error?)->())?
    /// 自定义导航栏titleView
    public var cstNavTitleViewBlk: ((_ webView: WKWebView, _ title: String?)->(UIView?))?
    /// 给webView添加约束
    public var addWebViewConstraintsBlk: ((_ webView: WKWebView, _ webSuperView: UIView)->())?

    fileprivate var reqPath: String                 = ""
    fileprivate var  isNavBarHidden                 = false
    fileprivate var scriptMsgNames: Array<String>   = []
    fileprivate var positionAt: JMSWebViewBackPositionAt = .backBarBtnItem(backIconImage: nil, backTintColor: nil, closeTitleColor: .black, closeIconColor: .clear, navTitleFont: UIFont.boldSystemFont(ofSize: 19), navTitleColor: .black)

    /// 唯一标识
    private(set) var pageId: String           = ""

    private(set) var backTitleColor: UIColor  = .black
    private(set) var backTitle: String        = JMSWebViewUtils.getLocalizedString(key: "back")
    
    private      var closeTitle: String       = JMSWebViewUtils.getLocalizedString(key: "close")
    private      var closeBtnOffX: CGFloat    = 0
    private(set) var closeBtn: UIButton?
    
    private      var backSizeW: CGFloat       = 0
    private      var closeSizeW: CGFloat      = 0
    
    fileprivate lazy var webView: WKWebView = {
        let tempConfiguration           = WKWebViewConfiguration()
        tempConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let tempWebView                 = WKWebView.init(frame: .zero, configuration: tempConfiguration)
        tempWebView.allowsBackForwardNavigationGestures = true
        tempWebView.backgroundColor     = .white
        
        return tempWebView
    }()
    
    fileprivate var progressView: UIProgressView?
    private(set) var progressTintColor: UIColor = .clear

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addScriptMsgNames()
        
        self.navigationController?.isNavigationBarHidden = self.isNavBarHidden
        self.closeBtn?.isHidden = false
        self.progressView?.isHidden = false

        self.webView.addObserver(self, forKeyPath: kWebViewEstimatedProgress, options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: kWebViewTitle, options: .new, context: nil)
        
        self.viewWillAppearBlk?(self.pageId, self.webView)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewDidAppearBlk?(self.pageId, self.webView)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeScriptMsgNames()
        
        self.navigationController?.isNavigationBarHidden = false
        self.closeBtn?.isHidden = true
        self.progressView?.isHidden = true
        
        self.webView.removeObserver(self, forKeyPath: kWebViewEstimatedProgress)
        self.webView.removeObserver(self, forKeyPath: kWebViewTitle)
        
        self.viewWillDisappearBlk?(self.pageId, self.webView)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.viewDidDisappearBlk?(self.pageId, self.webView)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.fillDatas()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.webView.uiDelegate = nil
        self.webView.navigationDelegate = nil
        self.backDelegate   = nil
        
        if self.webView.isLoading {
            self.webView.stopLoading()
        }
        
        self.closeBtn?.removeFromSuperview()
        self.closeBtn = nil
        self.progressView?.removeFromSuperview()
    }
    
    //  MARK: Initialization
    /// Initialization
    ///
    ///     let webViewVC = JMSWebViewController.init(isNavBarHidden: false, positionAt: .leftBarBtnItem(backTintColor: .black, closeTitleColor: .black, closeIconColor: nil), progressTintColor: .black, reqPath: path, scriptMsgNames: ["testApp"])
    ///
    /// - Parameters:
    ///     - positionAt:        返回按钮位置
    ///     - isNavBarHidden:    是否隐藏导航栏
    ///     - progressTintColor: ProgressView的tintColor属性设置
    ///     - reqPath:           请求路径
    ///     - scriptMsgNames:    消息处理数组
    public init(positionAt: JMSWebViewBackPositionAt = .backBarBtnItem(backIconImage: nil, backTintColor: nil, closeTitleColor: .black, closeIconColor: .clear, navTitleFont: UIFont.boldSystemFont(ofSize: 19), navTitleColor: .black), isNavBarHidden: Bool = false, pageId: String = "", progressTintColor: UIColor = .clear, reqPath: String, scriptMsgNames: Array<String> = []) {
        self.pageId             = pageId
        self.reqPath            = reqPath
        self.isNavBarHidden     = isNavBarHidden
        self.scriptMsgNames     = scriptMsgNames
        self.positionAt         = positionAt
        self.progressTintColor  = progressTintColor
        
        switch positionAt {
        case .backBarBtnItem( _, _, _, let closeIconColor, _, _):
            if closeIconColor == nil || closeIconColor == .clear {
                self.backSizeW          = 50
                self.closeSizeW         = 50
                self.closeBtnOffX       = self.backSizeW + 10
            }else {
                self.backSizeW          = 34
                self.closeSizeW         = 34
                
                self.closeTitle         = ""
                self.backTitleColor     = .clear
                self.backTitle          = ""
                self.closeBtnOffX       = self.backSizeW + 2
            }
        case .leftBarBtnItem( _, _, let closeIconColor):
            if closeIconColor == nil || closeIconColor == .clear {
                self.backSizeW          = 50
                self.closeSizeW         = 50
                self.closeBtnOffX       = self.backSizeW
            }else {
                self.backSizeW          = 30
                self.closeSizeW         = 34
                
                self.closeTitle         = ""
                self.backTitleColor     = .clear
                self.backTitle          = ""
                self.closeBtnOffX       = self.backSizeW
            }
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
        
        if !self.isNavBarHidden {
            progressView = UIProgressView.init(progressViewStyle: .bar)
            progressView!.frame = CGRect.init(x: 0, y: kStatusAndNavBarHeight - progressView!.bounds.size.height, width: self.view.bounds.size.width, height: progressView!.bounds.size.height)
            progressView?.isHidden          = true
            progressView!.progressTintColor = progressTintColor
            progressView?.trackTintColor    = .clear
            self.navigationController?.view.addSubview(progressView!)
        }
        
        self.addWebViewConstraintsBlk?(self.webView, self.view)
        
        self.setupCloseBtn(true)
    }
    
    open override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.addWebViewConstraintsBlk == nil {
            let leftConstraint = NSLayoutConstraint(item: self.webView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: self.webView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
            let topConstraint =  NSLayoutConstraint(item: self.webView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
            let bottomConstraint =  NSLayoutConstraint(item: self.webView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            
            self.view.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        }
    }
    
    fileprivate func setupCloseBtn(_ isFirstLoad: Bool = false) {
        if self.isNavBarHidden {
            return
        }
        
        var isHiddenCloseBtn = true
        if webView.canGoBack {
            isHiddenCloseBtn = false
        }
        
        switch self.positionAt {
        case .leftBarBtnItem(let backTintColor, let closeTitleColor, let closeIconColor):
            let customView = UIView.init(frame: .init(x: 0, y: 0, width: isHiddenCloseBtn ? backSizeW : (closeBtnOffX + closeSizeW), height: kNavBarHeight))
            
            let backBtn    = UIButton.jms_web_backButton(frame: .init(x: 0, y: 0, width: backSizeW, height: kNavBarHeight), imageColor: backTintColor, title: self.backTitle, titleColor: backTitleColor, target: self, action: #selector(clickBackBtn), for: .touchUpInside)
            customView.addSubview(backBtn)
            
            if !isHiddenCloseBtn {
                self.closeBtn = UIButton.jms_web_closeButton(frame: .init(x: closeBtnOffX, y: 0, width: closeSizeW, height: kNavBarHeight), imageColor: closeIconColor ?? .clear, title: closeTitle, titleColor: closeTitleColor, target: self, action: #selector(close), for: .touchUpInside)
                customView.addSubview(self.closeBtn!)
            }
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: customView)
        case .backBarBtnItem(let backIconImage, let backTintColor, let closeTitleColor, let closeIconColor, _, _):
            //主要是以下两个图片设置
            if isFirstLoad {
                self.backDelegate = self

                navigationController?.navigationBar.tintColor = backTintColor

                navigationController?.navigationBar.backIndicatorImage = backIconImage
                navigationController?.navigationBar.backIndicatorTransitionMaskImage = backIconImage
                
                let backItem = UIBarButtonItem()
                backItem.title = self.backTitle
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
            }
            
            self.closeBtn?.removeFromSuperview()

            if !isHiddenCloseBtn {
                self.closeBtn = UIButton.jms_web_closeButton(frame: .init(x: self.closeBtnOffX, y: kStatusBarHeight, width: self.closeSizeW, height: kNavBarHeight), imageColor: closeIconColor ?? .clear, title: closeTitle, titleColor: closeTitleColor, target: self, action: #selector(close), for: .touchUpInside)
                self.navigationController?.view.addSubview(self.closeBtn!)
            }
        }
        
    }
    
    // MARK: - Datas
    private func fillDatas() {
        if let tempUrl = URL.init(string: self.reqPath) {
            if tempUrl.host != nil && tempUrl.scheme != nil {
                self.webView.load(URLRequest.init(url: tempUrl))
            }else {
                let tempFileURL = URL.init(fileURLWithPath: self.reqPath)
                if #available(iOS 9.0, *) {
                    self.webView.loadFileURL(tempFileURL, allowingReadAccessTo: tempFileURL)
                } else {
                    self.webView.load(URLRequest.init(url: URL.init(fileURLWithPath: self.reqPath)))
                }
            }
        }else {
            self.reqErrorBlk?(self.webView,self.reqPath, nil)
        }
    }
    
    // MARK: - Event Response
    func clickBackBtn() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }else {
            self.close()
        }
    }
    
    func close() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Observer
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == kWebViewEstimatedProgress {
            self.progressView?.progress = Float(self.webView.estimatedProgress)
        }else if keyPath == kWebViewTitle {
            if self.cstNavTitleViewBlk != nil {
                self.navigationItem.titleView = self.cstNavTitleViewBlk!(self.webView, self.webView.title)
            }else {
                switch self.positionAt {
                case .backBarBtnItem(_, _, _, _, let navTitleFont, let navTitleColor):
                    self.jms_setupNavTitle(webView.title ?? "", textColor: navTitleColor, titleFont: navTitleFont, offX: (self.closeBtnOffX + self.closeSizeW), delayShow: true)
                default:
                    self.title = webView.title
                }
            }
        }
    }

}

// MARK: - Title
extension JMSWebViewController {
    
    fileprivate func jms_setupNavTitle(_ navTitle: String, textColor: UIColor = .white, titleFont: UIFont = UIFont.boldSystemFont(ofSize: 19), offX: CGFloat = 105, delayShow: Bool = false) {
        let maxWidth        = UIScreen.main.bounds.width - 2 * offX
        
        let titleView       = UIView.init(frame: CGRect.init(x: 0, y: 0, width: maxWidth, height: kNavBarHeight))
        titleView.backgroundColor = .clear
        
        let label           = UILabel.init(frame: titleView.bounds)
        label.text          = navTitle
        label.font          = titleFont
        label.textColor     = textColor
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.sizeToFit()
        
        var tempCenter        = label.center
        tempCenter.y          = titleView.center.y
        label.center          = tempCenter
        
        var viewFrame:CGRect  = titleView.frame
        var labelFrame:CGRect = label.frame
        if labelFrame.width > maxWidth {
            labelFrame.size.width = maxWidth
        }
        
        viewFrame.size.width  = labelFrame.width
        label.frame           = labelFrame
        titleView.frame       = viewFrame
        titleView.addSubview(label)
        
        if delayShow {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.navigationItem.titleView = titleView
            })
        }else {
            self.navigationItem.titleView = titleView
        }
    }
    
}

// MARK: - WKScriptMessageHandler
extension JMSWebViewController: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if self.scriptDidReceiveMsgBlk != nil && self.scriptMsgNames.contains(message.name) {
            self.scriptDidReceiveMsgBlk!(self.webView, userContentController, message)
        }
    }
    
    fileprivate func addScriptMsgNames() {
        for name in self.scriptMsgNames {
            self.webView.configuration.userContentController.add(self, name: name)
        }
    }
    
    fileprivate func removeScriptMsgNames() {
        for name in self.scriptMsgNames {
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: name)
        }
    }
    
}

// MARK: - JMSNavBackButtonHandlerProtocol
extension JMSWebViewController: JMSNavBackButtonHandlerProtocol {
    
    public func navigationShouldPopOnBackButton() -> Bool {
        if self.webView.canGoBack {
            self.webView.goBack()
            return false
        }
        
        return true
    }

    
}

// MARK: - WKNavigationDelegate
extension JMSWebViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.setupCloseBtn()
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.didStartLoad()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.didFinishLoad()
        self.setupCloseBtn()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.didFailProvisionalNavigation()
        self.reqErrorBlk?(webView, webView.url?.absoluteString ?? "", error)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.didFailNavigation()
        self.reqErrorBlk?(webView, webView.url?.absoluteString ?? "", error)
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    fileprivate func didStartLoad() {
        self.progressView?.progress = 0
        self.progressView?.isHidden = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    fileprivate func didFinishLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.progressView?.isHidden = true
            self.progressView?.progress = 0
        }
    }
    
    fileprivate func didFailProvisionalNavigation() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.progressView?.isHidden = true
        self.progressView?.progress = 0
    }
    
    fileprivate func didFailNavigation() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.progressView?.isHidden = true
        self.progressView?.progress = 0
    }

}

// MARK: - WKUIDelegate
extension JMSWebViewController: WKUIDelegate {
    
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
    
}
