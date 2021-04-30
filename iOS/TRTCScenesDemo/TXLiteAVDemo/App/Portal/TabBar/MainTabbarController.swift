//
//  MainTabbarController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

class MainTabbarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = MainNavigationController(rootViewController: portalVC)
        addChild(nav)
        
        let nav2 = MainNavigationController(rootViewController: mineVC)
        addChild(nav2)
        
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        UITabBar.appearance().clipsToBounds = true
        
        hidesBottomBarWhenPushed = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
    lazy var mineVC: MineViewController = {
        let vc = MineViewController()
        let item = UITabBarItem(title: .mineTitleText, image: UIImage(named: "main_mine_nor"), selectedImage: UIImage(named: "main_mine_sel"))
        vc.tabBarItem = item
        return vc
    }()
    
    lazy var portalVC: PortalViewController = {
        if let vc = UIStoryboard.init(name: "Portal", bundle: nil).instantiateInitialViewController() {
            let portal = vc as! PortalViewController
            let item = UITabBarItem(title: .homeTitleText, image: UIImage(named: "main_mine_nor"), selectedImage: UIImage(named: "main_mine_sel"))
            portal.tabBarItem = item
            return portal
        }
        return PortalViewController()
    }()
}

class MainNavigationController: UINavigationController {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let homeTitleText = AppPortalLocalize("Demo.TRTC.Portal.Main.home")
    static let mineTitleText = AppPortalLocalize("Demo.TRTC.Portal.Main.mine")
}
