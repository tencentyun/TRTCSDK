//
//  AppDelegate+VC.swift
//  TIMLite
//
//  Created by xcoderliu on 12/16/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    /// 展示主视图
    func showPortalConroller() {
        window?.rootViewController = UINavigationController.init(rootViewController: portalVC)
    }
    
    func showLoginController() {
        window?.rootViewController = UINavigationController.init(rootViewController: LoginViewController.init())
    }
    
}
