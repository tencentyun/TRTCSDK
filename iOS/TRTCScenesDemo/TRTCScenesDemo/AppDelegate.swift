//
//  AppDelegate.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/16/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit

//此处设置 IM 推送证书 ID 详情见：https://cloud.tencent.com/document/product/269/9154
#if DEBUG
    let timSdkBusiId: UInt32 = 0
#else
    let timSdkBusiId: UInt32 = 0
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    @objc var _deviceToken: Data?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registNotification()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        showLoginController()
        
        // setup navigation
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 1)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        (UINavigationBar.appearance()).setBackgroundImage(image, for: .default)
        (UINavigationBar.appearance()).shadowImage = UIImage()
        (UINavigationBar.appearance()).titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        (UINavigationBar.appearance()).barTintColor = .black
        (UINavigationBar.appearance()).tintColor = .white
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(error)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        _deviceToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        debugPrint("\(userInfo)")
    }
    
    //set unread badgenumber
    func applicationDidEnterBackground(_ application: UIApplication) {
        var bgTaskID = UIBackgroundTaskIdentifier(rawValue: 0)
        bgTaskID = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(bgTaskID)
            bgTaskID = .invalid
        })

//        var unRead: Int32 = 0
//        if let convs = TIMManager.sharedInstance()?.getConversationList() {
//            for conv in convs {
//                unRead += conv.getUnReadMessageNum()
//            }
//            UIApplication.shared.applicationIconBadgeNumber = Int(unRead)
//
//            //do background
//            let param = TIMBackgroundParam.init()
//            param.c2cUnread = unRead
//            TIMManager.sharedInstance()?.doBackground(param, succ: {
//                debugPrint("set unread badge success")
//            }, fail: { (code, errorDes) in
//                debugPrint("set unread badge failed, code: \(code), error: \(errorDes ?? "nil")")
//            })
//        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        //do background
        let param = TIMBackgroundParam.init()
        param.c2cUnread = 0
        TIMManager.sharedInstance()?.doBackground(param, succ: {
            debugPrint("set unread badge success")
        }, fail: { (code, errorDes) in
            debugPrint("set unread badge failed, code: \(code), error: \(errorDes ?? "nil")")
        })
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        TIMManager.sharedInstance()?.doForeground({
            
        }, fail: { (code, error) in
            
        })
    }
    
    // MARK: - main
    internal var portalVC: UIViewController {
        guard let protal = UIStoryboard(name: "Portal", bundle: nil).instantiateInitialViewController() else { return ViewController() }
        return protal
    }
    
    //MARK: - notification
    func registNotification() {
        if #available(iOS 8.0, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            UIApplication.shared.registerForRemoteNotifications(matching: [.sound, .alert, .badge])
        }
    }
    
}

