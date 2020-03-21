//
//  RTCEntranceViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit

/**
 * RTC视频通话的入口页面（可以设置房间id和用户id）
 *
 * RTC视频通话是基于房间来实现的，通话的双方要进入一个相同的房间id才能进行视频通话
 */
class RTCEntranceViewController: UIViewController {
    
    @IBOutlet weak var roomIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomIdTextField.text = "1256732"
        userIdTextField.text = "\(UInt32(CACurrentMediaTime() * 1000))"
        
        let sel = #selector(RTCEntranceViewController.onTapGestureAction(_:))
        let tapGesture = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        /// 设置 roomId 和 userId，切换到视频通话主界面 RTCViewController
        if "enterRTCRoom" == segueId {
            let rtcVC = segue.destination as? RTCViewController
            rtcVC?.roomId = UInt32(roomIdTextField.text ?? "1256732")
            rtcVC?.userId = userIdTextField.text ?? "\(UInt32(CACurrentMediaTime() * 1000))"
        }
    }
    
    /// 隐藏键盘
    @objc func onTapGestureAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
