//
//  JMExtUIViewController.swift
//  JMSExtension
//
//  Created by James.xiao on 2017/1/4.
//  Copyright © 2017年 James. All rights reserved.
//
import UIKit

// MARK: - 返回按钮重写
public protocol JMSNavBackButtonHandlerProtocol: NSObjectProtocol {
    
    func navigationShouldPopOnBackButton() -> Bool

}

extension UIViewController {
    
    fileprivate struct RuntimeKey {
        static let jm_backButtonHandlerKey     = UnsafeRawPointer.init(bitPattern: "jm_backButtonHandlerKey".hashValue)
    }
    
    weak open var backDelegate: JMSNavBackButtonHandlerProtocol? {
        set {
            objc_setAssociatedObject(self, UIViewController.RuntimeKey.jm_backButtonHandlerKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, UIViewController.RuntimeKey.jm_backButtonHandlerKey!) as? JMSNavBackButtonHandlerProtocol
        }
    }
    
}

