//
//  TRTCBroadcastExtensionLauncher.swift
//  TRTCSimpleDemo
//
//  Created by J J on 2020/6/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import ReplayKit

@available(iOS 12.0, *)
class TRTCBroadcastExtensionLauncher: NSObject {
    var systemBroacastExtensionPicker = RPSystemBroadcastPickerView()
    var prevLaunchEventTime : CFTimeInterval = 0
    
    static let sharedInstance =  TRTCBroadcastExtensionLauncher()
    
    override init() {
        super.init()
        let picker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        picker.showsMicrophoneButton = false
        picker.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        systemBroacastExtensionPicker = picker
        
        if let pluginPath = Bundle.main.builtInPlugInsPath,
            let contents = try? FileManager.default.contentsOfDirectory(atPath: pluginPath) {
            
            for content in contents where content.hasSuffix(".appex") {
                guard let bundle = Bundle(path: URL(fileURLWithPath: pluginPath).appendingPathComponent(content).path),
                    let identifier : String = (bundle.infoDictionary?["NSExtension"] as? [String:Any])? ["NSExtensionPointIdentifier"] as? String
                    else {
                        continue
                }
                if identifier == "com.apple.broadcast-services-upload" {
                    picker.preferredExtension = bundle.bundleIdentifier
                    break
                }
            }
        }
    }
    
    static func launch() {
        TRTCBroadcastExtensionLauncher.sharedInstance.launch()
    }
    
    func launch() {
        // iOS 12 上弹出比较慢，如果快速点击会Crash
        let now = CFAbsoluteTimeGetCurrent()
        if now - prevLaunchEventTime < 1.0 {
            return;
        }
        prevLaunchEventTime = now

        for view in systemBroacastExtensionPicker.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .allTouchEvents)
                break
            }
        }
    }
}
