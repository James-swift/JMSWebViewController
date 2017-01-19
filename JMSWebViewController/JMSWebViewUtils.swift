//
//  JMSWebViewUtils.swift
//  JMSWebViewController
//
//  Created by James.xiao on 2017/1/19.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

struct JMSWebViewUtils {
    static var bundle: Bundle?

    static func getLocalizedString(key: String, value: String = "") -> String {
        if bundle == nil {
            var language = Locale.preferredLanguages.first ?? ""
            
            if language.hasPrefix("en") {
                language = "en"
            }else if language.hasPrefix("zh") {
                if language.range(of: "Hans") != nil {
                    language = "zh-Hans" // 简体中文
                }
            }else {
                language = "en"
            }
            
            bundle = Bundle.init(path: Bundle.init(for: JMSWebViewController.self).resourcePath?.appending("/JMSWebViewController.bundle/\(language).lproj") ?? "")
        }
        
        let newValue = bundle?.localizedString(forKey: key, value: value, table: "JMSWebViewController")
        return Bundle.main.localizedString(forKey: key, value: newValue, table: nil)
    }
    
}
