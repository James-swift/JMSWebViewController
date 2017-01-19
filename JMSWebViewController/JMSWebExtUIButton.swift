//
//  JMSWebExtUIButton.swift
//  JMSWebView
//
//  Created by James.xiao on 2017/1/5.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

extension UIButton {
    
    class func jms_web_backButton(frame: CGRect = .zero, imageColor: UIColor = .black, title: String = "", titleColor: UIColor = .black, target: Any?, action: Selector, for controlEvents: UIControlEvents) -> UIButton {
        let btn = UIButton.init(type: .custom)
        
        btn.setImage(UIImage.jms_web_backButtonIcon(color: imageColor), for: .normal)
        btn.setImage(UIImage.jms_web_backButtonIcon(color: imageColor.withAlphaComponent(0.5)), for: .highlighted)
        btn.sizeToFit()
        
        btn.frame = frame
        btn.addTarget(target, action: action, for: controlEvents)
        btn.titleLabel?.font    = UIFont.systemFont(ofSize: 16)

        if titleColor != .clear {
            btn.setTitle(title, for: .normal)
            btn.setTitle(title, for: .highlighted)
            btn.setTitleColor(titleColor, for: .normal)
            btn.setTitleColor(titleColor.withAlphaComponent(0.5), for: .highlighted)

            btn.contentEdgeInsets   = UIEdgeInsetsMake(0, -10, 0, 0)
            btn.titleEdgeInsets     = UIEdgeInsetsMake(0, 10, 0, 0)
        }else {
            btn.contentEdgeInsets   = UIEdgeInsetsMake(0, -20, 0, 0)
            btn.titleEdgeInsets     = UIEdgeInsetsMake(0, 10, 0, 0)
        }
        
        return btn
    }

    class func jms_web_closeButton(frame: CGRect = .zero, imageColor: UIColor = .clear, title: String = "", titleColor: UIColor = .black, target: Any?, action: Selector, for controlEvents: UIControlEvents) -> UIButton {
        let btn = UIButton.init(type: .custom)
        
        if imageColor != .clear {
            btn.setImage(UIImage.jms_web_closeButtonIcon(color: imageColor), for: .normal)
            btn.setImage(UIImage.jms_web_closeButtonIcon(color: imageColor.withAlphaComponent(0.5)), for: .highlighted)
            btn.sizeToFit()
        }
        
        btn.frame = frame
        btn.setTitle(title, for: .normal)
        btn.setTitle(title, for: .highlighted)
        btn.setTitleColor(titleColor, for: .normal)
        btn.setTitleColor(titleColor.withAlphaComponent(0.5), for: .highlighted)
        btn.addTarget(target, action: action, for: controlEvents)
        btn.titleLabel?.font    = UIFont.systemFont(ofSize: 16)

        return btn
    }
    
}
