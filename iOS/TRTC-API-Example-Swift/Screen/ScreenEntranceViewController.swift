//
//  ScreenViewController.swift
//  TRTCSimpleDemo
//
//  Created by J J on 2020/6/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import TXLiteAVSDK_TRTC

class ScreenEntranceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
        // Do any additional setup after loading the view.
        
        setUpUI()
    }
    
    func setUpUI() {
        title = "屏幕分享"
        let roomLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width * 32.0/375, y: 144, width: UIScreen.main.bounds.size.width * 311.0/375, height: 35))
        roomLabel.text = "请输入房间号:"
        roomLabel.textColor = UIColor(red: -0.32, green: 0.66, blue: 0.4, alpha: 1)
        roomLabel.textAlignment = NSTextAlignment.left
        self.view.addSubview(roomLabel)
        
        //房间号textfield
        let roomInputTextField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width * 32.0/375, y: 179, width: UIScreen.main.bounds.size.width * 311.0/375, height: 35))
        roomInputTextField.text = "1256732"
        roomInputTextField.borderStyle = UITextField.BorderStyle.roundedRect
        self.view.addSubview(roomInputTextField)
        
        //用户名label
        let userNameLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width * 32.0/375, y: 234, width: UIScreen.main.bounds.size.width * 311.0/375, height: 35))
        userNameLabel.text = "请输入用户名:"
        userNameLabel.textColor = UIColor(red: -0.32, green: 0.66, blue: 0.4, alpha: 1)
        userNameLabel.textAlignment = NSTextAlignment.left
        self.view.addSubview(userNameLabel)
        
        //用户名textfield
        let userInputTextfield = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width * 32.0/375, y: 269, width: UIScreen.main.bounds.size.width * 311.0/375, height: 35))
        userInputTextfield.text = "\(UInt32(CACurrentMediaTime() * 1000))"
        userInputTextfield.borderStyle = UITextField.BorderStyle.roundedRect
        self.view.addSubview(userInputTextfield)
        
        //进入房间按钮
        let enterRoomButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width * 32.0/375, y: UIScreen.main.bounds.size.height * 560.0/667, width: UIScreen.main.bounds.size.width * 311.0/375, height: 45))
        enterRoomButton.layer.masksToBounds = true
        enterRoomButton.layer.cornerRadius = 4.0
        enterRoomButton.backgroundColor = UIColor(red: -0.32, green: 0.66, blue: 0.4, alpha: 1)
        enterRoomButton.setTitle("进入房间", for: .normal)
        enterRoomButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        enterRoomButton.addTarget(self, action: #selector(enterRoom), for: .touchUpInside)
        self.view.addSubview(enterRoomButton)
    }

    @objc func enterRoom() {
        let screenVC = ScreenViewController()
        self.navigationController?.pushViewController(screenVC, animated: true)
    }
}
