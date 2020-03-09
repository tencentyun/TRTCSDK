//
//  appUtil.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/24/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import Foundation

class appUtils: NSObject {
    @objc public static let shared = appUtils()
    private override init() {}
    
    @objc var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    @objc var curUserId: String {
        get {
            return TIMManager.sharedInstance()?.getLoginUser() ?? ""
        }
    }
    
    //MARK: - UI
    
    @objc func showMainController() {
        appDelegate.showPortalConroller()
    }
    
    @objc func showLoginController() {
        appDelegate.showLoginController()
    }
}
