//
//  JMSWebExtUIImage.swift
//  JMSWebView
//
//  Created by James.xiao on 2017/1/5.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func jms_web_backButtonIcon(color: UIColor = .black) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 12, height: 21), false, UIScreen.main.scale)
        
        // 利用贝塞尔曲线，把后退按钮分为上下两部分
        let backPath = UIBezierPath()
        
        // 上部分
        backPath.move(to: CGPoint.init(x: 10.9, y: 0))
        backPath.addLine(to: CGPoint.init(x: 12, y: 1.1))
        backPath.addLine(to: CGPoint.init(x: 1.1, y: 11.75))
        backPath.addLine(to: CGPoint.init(x: 0, y: 10.7))
        backPath.addLine(to: CGPoint.init(x: 10.9, y: 0))
        backPath.close()
        
        // 下部分
        backPath.move(to: CGPoint.init(x: 11.98, y: 19.9))
        backPath.addLine(to: CGPoint.init(x: 10.88, y: 21))
        backPath.addLine(to: CGPoint.init(x: 0.54, y: 11.21))
        backPath.addLine(to: CGPoint.init(x: 1.64, y: 10.11))
        backPath.addLine(to: CGPoint.init(x: 11.98, y: 19.9))
        backPath.close()
        
        color.setFill()
        backPath.fill()
        
        let backImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return backImage!
    }

    class func jms_web_closeButtonIcon(color: UIColor = .black) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 19, height: 19), false, UIScreen.main.scale)
        
        // 利用贝塞尔曲线，把关闭按钮分为上下两部分
        let backPath = UIBezierPath()
        
        // 上部分
        backPath.move(to: CGPoint.init(x: 17.9, y: 0))
        backPath.addLine(to: CGPoint.init(x: 19, y: 1.1))
        backPath.addLine(to: CGPoint.init(x: 1.1, y: 19))
        backPath.addLine(to: CGPoint.init(x: 0, y: 17.9))
        backPath.addLine(to: CGPoint.init(x: 17.9, y: 0))
        backPath.close()
        
        // 下部分
        backPath.move(to: CGPoint.init(x: 0, y: 1.1))
        backPath.addLine(to: CGPoint.init(x: 1.1, y: 0))
        backPath.addLine(to: CGPoint.init(x: 19, y: 17.9))
        backPath.addLine(to: CGPoint.init(x: 17.9, y: 19))
        backPath.addLine(to: CGPoint.init(x: 0, y: 1.1))
        backPath.close()
        
        color.setFill()
        backPath.fill()
        
        let backImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return backImage!
    }
    
}
