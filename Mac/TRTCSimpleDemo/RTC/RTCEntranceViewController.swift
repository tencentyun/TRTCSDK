//
//  RTCEntranceViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

import Cocoa

/**
 * RTC视频通话的入口页面（可以设置房间id和用户id）
 *
 * RTC视频通话是基于房间来实现的，通话的双方要进入一个相同的房间id才能进行视频通话
 */
class RTCEntranceViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var roomIdTextField: NSTextField!
    @IBOutlet weak var userIdTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        roomIdTextField.stringValue = "1256732"
        userIdTextField.stringValue = "\(UInt32(CACurrentMediaTime() * 1000))"
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let textField = control as? NSTextField else {
            return true
        }
        if roomIdTextField == textField {
            let roomId = roomIdTextField.integerValue
            if roomId > 0 {
                roomIdTextField.stringValue = "\(roomId)"
            } else {
                roomIdTextField.stringValue = "1256732"
            }
        } else if userIdTextField == textField {
            if 0 == userIdTextField.stringValue.count {
                userIdTextField.stringValue = "\(UInt32(CACurrentMediaTime() * 1000))"
            }
        }
        return true
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        if "enterRTCRoom" == segueId {
            view.window?.makeFirstResponder(nil)
            (NSApp.delegate as? AppDelegate)?.closeAllWindows()
            
            guard let winController = segue.destinationController as? NSWindowController else {
                return
            }
            let rtcVC = winController.contentViewController as? RTCViewController
            rtcVC?.userId = userIdTextField.stringValue
            rtcVC?.roomId = UInt32(roomIdTextField.intValue)
        }
    }
}
