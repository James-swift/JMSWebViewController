//
//  JMSExtUINavigationController.swift
//  JMSExtension
//
//  Created by James.xiao on 2017/1/4.
//  Copyright © 2017年 James. All rights reserved.
//

import UIKit

// MARK: - 返回按钮重写
extension UINavigationController: UINavigationBarDelegate {
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if self.viewControllers.count < (navigationBar.items?.count)! {
            return true
        }

        let topVC        = self.topViewController
        if (topVC?.backDelegate?.navigationShouldPopOnBackButton() ?? true) {
            DispatchQueue.main.async {
                topVC?.backDelegate = nil
                self.popViewController(animated: true)
            }
        }else {
            for subview in navigationBar.subviews {
                if subview.alpha < 1 {
                    UIView.animate(withDuration: 0.25, animations: {
                        subview.alpha = 1
                    })
                }
            }
        }
        
        return false
    }
    
}
