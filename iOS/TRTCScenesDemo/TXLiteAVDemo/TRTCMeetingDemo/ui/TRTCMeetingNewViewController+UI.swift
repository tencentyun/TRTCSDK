//
//  TRTCMeetingNewViewController+UI.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/22/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import Toast_Swift

extension TRTCMeetingNewViewController {
    func setupUI() {
        // 获取屏幕的高度
        let screenHeight = UIScreen.main.bounds.size.height
        
        ToastManager.shared.position = .center
        title = "多人视频会议"
        
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.colors = [UIColor(rgb: 0x13294b).cgColor,UIColor(rgb: 0x050c17).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // input Panel
        let inputPanel = UIView()
        view.addSubview(inputPanel)
        inputPanel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(15)
            make.height.equalTo(screenHeight * 113.0/667)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        // 输入框底色
        let inputGradientLayer = CAGradientLayer.init()
        inputGradientLayer.colors = [UIColor(rgb: 0x0d2c5b).cgColor,UIColor(rgb: 0x122755).cgColor]
        inputGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        inputGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        inputGradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 40, height: screenHeight * 113.0/667)
        inputPanel.layer.insertSublayer(inputGradientLayer, at: 0)
        
        let line = UIView()
        line.backgroundColor = .white
        inputPanel.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.centerY.equalTo(inputPanel)
            make.height.equalTo(0.5)
        }
        
        let roomTip = UILabel()
        roomTip.backgroundColor = .clear
        roomTip.textColor = UIColor(rgb: 0xebf4ff)
        roomTip.font = UIFont.systemFont(ofSize: 16)
        roomTip.text = "会议号"
        inputPanel.addSubview(roomTip)
        roomTip.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.width.equalTo(50)
            make.height.equalTo(24)
            make.centerY.equalTo(inputPanel).multipliedBy(0.5)
        }
        
        let userNameTip = UILabel()
        userNameTip.backgroundColor = .clear
        userNameTip.textColor = UIColor(rgb: 0xebf4ff)
        userNameTip.font = UIFont.systemFont(ofSize: 16)
        userNameTip.text = "用户名"
        inputPanel.addSubview(userNameTip)
        userNameTip.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.width.equalTo(50)
            make.height.equalTo(24)
            make.centerY.equalTo(inputPanel).multipliedBy(1.5)
        }
        
        roomInput.backgroundColor = .clear
        roomInput.textColor = UIColor(rgb: 0xebf4ff)
        roomInput.font = UIFont.systemFont(ofSize: 16)
        roomInput.attributedPlaceholder = NSAttributedString(string: "请输入会议号",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        roomInput.keyboardType = .numberPad
        inputPanel.addSubview(roomInput)
        roomInput.snp.makeConstraints { (make) in
            make.leading.equalTo(roomTip.snp.trailing).offset(30)
            make.trailing.equalTo(-16)
            make.centerY.height.equalTo(roomTip)
        }
        
        
        userNameInput.backgroundColor = .clear
        userNameInput.textColor = UIColor(rgb: 0xebf4ff)
        userNameInput.font = UIFont.systemFont(ofSize: 16)
        userNameInput.attributedPlaceholder = NSAttributedString(string: "请输入用户名",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        inputPanel.addSubview(userNameInput)
        userNameInput.snp.makeConstraints { (make) in
            make.leading.equalTo(userNameTip.snp.trailing).offset(30)
            make.trailing.equalTo(-16)
            make.centerY.height.equalTo(userNameTip)
        }
        
        
        let openCameraTip = UILabel()
        view.addSubview(openCameraTip)
        openCameraTip.backgroundColor = .clear
        openCameraTip.textColor = UIColor(rgb: 0xebf4ff)
        openCameraTip.font = UIFont.systemFont(ofSize: 16)
        openCameraTip.text = "开启摄像头"
        openCameraTip.snp.makeConstraints { (make) in
            make.top.equalTo(inputPanel.snp.bottom).offset(32)
            make.leading.equalTo(inputPanel.snp.leading).offset(16)
            make.width.equalTo(100)
            make.height.equalTo(24)
        }
        
        view.addSubview(openCameraSwitch)
        openCameraSwitch.isOn = true
        openCameraSwitch.onTintColor = .blue
        openCameraSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(openCameraTip)
            make.trailing.equalTo(inputPanel.snp.trailing).offset(-16)
            make.width.equalTo(50)
            make.height.equalTo(24)
        }
        
        let openMicTip = UILabel()
        view.addSubview(openMicTip)
        openMicTip.backgroundColor = .clear
        openMicTip.textColor = UIColor(rgb: 0xebf4ff)
        openMicTip.font = UIFont.systemFont(ofSize: 16)
        openMicTip.text = "开启麦克风"
        openMicTip.snp.makeConstraints { (make) in
            make.top.equalTo(openCameraTip.snp.bottom).offset(34)
            make.leading.equalTo(openCameraTip.snp.leading)
            make.width.equalTo(100)
            make.height.equalTo(24)
        }
        
        view.addSubview(openMicSwitch)
        openMicSwitch.isOn = true
        openMicSwitch.onTintColor = .blue
        openMicSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(openMicTip)
            make.trailing.equalTo(inputPanel.snp.trailing).offset(-16)
            make.width.equalTo(50)
            make.height.equalTo(24)
        }
        
        
        let audioQualityLabel = UILabel()
        view.addSubview(audioQualityLabel)
        audioQualityLabel.backgroundColor = .clear
        audioQualityLabel.textColor = UIColor(rgb: 0xebf4ff)
        audioQualityLabel.font = UIFont.systemFont(ofSize: 16)
        audioQualityLabel.text = "音质选择"
        audioQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(openMicSwitch.snp.bottom).offset(34)
            make.leading.equalTo(openMicTip)
            make.width.equalTo(100)
            make.height.equalTo(24)
        }
        
        // 音质选择
        // UIButton的imageEdgeInsets和titleEdgeInsets在iPhone6上有兼容问题，这里用label+button
        // 语音
        view.addSubview(speechQualityButton)
        speechQualityButton.setImage(UIImage(named: "meeting_select_on"), for: .normal)
        speechQualityButton.tag = 1
        speechQualityButton.addTarget(self, action: #selector(selectAudioQuality), for: .touchUpInside)
        speechQualityButton.snp.makeConstraints { (make) in
            make.top.equalTo(audioQualityLabel.snp.bottom).offset(16)
            make.leading.equalTo(inputPanel.snp.leading).offset(16)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        let speechQualityLabel = UILabel()
        speechQualityLabel.text = "语音"
        speechQualityLabel.textColor = UIColor(rgb: 0xebf4ff)
        view.addSubview(speechQualityLabel)
        speechQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(speechQualityButton)
            make.leading.equalTo(speechQualityButton.snp.trailing).offset(5)
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
        
        // 标准
        view.addSubview(defaultQualityButton)
        defaultQualityButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
        defaultQualityButton.tag = 0
        defaultQualityButton.addTarget(self, action: #selector(selectAudioQuality), for: .touchUpInside)
        defaultQualityButton.snp.makeConstraints { (make) in
            make.top.equalTo(speechQualityButton)
            make.leading.equalTo(inputPanel.snp.trailing).offset(32).multipliedBy(1/3.0)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        let defaultQualityLabel = UILabel()
        defaultQualityLabel.text = "标准"
        defaultQualityLabel.textColor = UIColor(rgb: 0xebf4ff)
        view.addSubview(defaultQualityLabel)
        defaultQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(defaultQualityButton)
            make.leading.equalTo(defaultQualityButton.snp.trailing).offset(5)
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
        
        // 音乐
        view.addSubview(musicQualityButton)
        musicQualityButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
        musicQualityButton.tag = 0
        musicQualityButton.addTarget(self, action: #selector(selectAudioQuality), for: .touchUpInside)
        musicQualityButton.snp.makeConstraints { (make) in
            make.top.equalTo(speechQualityButton)
            make.leading.equalTo(inputPanel.snp.trailing).offset(32).multipliedBy(2/3.0)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        let musicQualityLabel = UILabel()
        musicQualityLabel.text = "音乐"
        musicQualityLabel.textColor = UIColor(rgb: 0xebf4ff)
        view.addSubview(musicQualityLabel)
        musicQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(musicQualityButton)
            make.leading.equalTo(musicQualityButton.snp.trailing).offset(5)
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
        

        let enterBtn = UIButton()
        enterBtn.setTitle("进入会议", for: .normal)
        enterBtn.setBackgroundImage(UIColor.init(0x0062E3).trans2Image(), for: .normal)
        enterBtn.layer.cornerRadius = 6
        enterBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        enterBtn.setTitleColor(.white, for: .normal)
        view.addSubview(enterBtn)
        enterBtn.snp.makeConstraints { (make) in
            make.top.equalTo(speechQualityButton.snp.bottom).offset(30)
            make.leading.equalTo(32)
            make.trailing.equalTo(-32)
            make.height.equalTo(50)
        }
        enterBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.enterRoom()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        // tap to resign
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.resignInput()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        view.addGestureRecognizer(tap)
        
        // fill with record
        if let roomID = UserDefaults.standard.object(forKey: TRTCMeetingRoomIDKey) as? UInt32 {
            roomInput.text = String(roomID)
        }
        
        if let userName = UserDefaults.standard.object(forKey: TRTCMeetingUserNameKey) as? String {
            userNameInput.text = userName
        }
        
        if let isOpenCamera = UserDefaults.standard.object(forKey: TRTCMeetingOpenCameraKey) as? Bool {
            openCameraSwitch.isOn = isOpenCamera
        }
        
        if let isOpenMic = UserDefaults.standard.object(forKey: TRTCMeetingOpenMicKey) as? Bool {
            openMicSwitch.isOn = isOpenMic
        }
        
        if let audioQuality = UserDefaults.standard.object(forKey: TRTCMeetingAudioQualityKey) as? Int {
            setAudioQuality(audioQuality: audioQuality)
        }
    }
    
    @objc func selectAudioQuality(btn: UIButton) {
        if btn == speechQualityButton {
            self.audioQuality = 1
            
            speechQualityButton.tag = 1
            speechQualityButton.setImage(UIImage(named: "meeting_select_on"), for: .normal)
            
            defaultQualityButton.tag = 0
            defaultQualityButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
            
            musicQualityButton.tag = 0
            musicQualityButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
            
        } else if btn == defaultQualityButton {
            self.audioQuality = 2
            
            speechQualityButton.tag = 0
            speechQualityButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
            
            defaultQualityButton.tag = 1
            defaultQualityButton.setImage(UIImage(named: "meeting_select_on"), for: .normal)
            
            musicQualityButton.tag = 0
            musicQualityButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
            
        } else if btn == musicQualityButton {
            self.audioQuality = 3
            
            speechQualityButton.tag = 0
            speechQualityButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
            
            defaultQualityButton.tag = 0
            defaultQualityButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
            
            musicQualityButton.tag = 1
            musicQualityButton.setImage(UIImage(named: "meeting_select_on"), for: .normal)
        }
    }
    
    func setAudioQuality(audioQuality: Int) {
        switch audioQuality {
        case 1:
            selectAudioQuality(btn: speechQualityButton)
            break
        case 2:
            selectAudioQuality(btn: defaultQualityButton)
            break
        case 3:
            selectAudioQuality(btn: musicQualityButton)
            break
        default:
            selectAudioQuality(btn: speechQualityButton)
        }
    }
    
    func autoCheck() -> (Bool, UInt32, String) {
        if (roomInput.text?.count ?? 0) <= 0 {
            view.makeToast("请输入会议号")
            return (false, 0, "")
        }
        if (userNameInput.text?.count ?? 0) <= 0 {
            view.makeToast("请输入用户名")
            return (false, 0, "")
        }
        guard let roomID = UInt32(roomInput.text ?? "") else {
            view.makeToast("请输入合法的会议ID")
            return (false, 0, "")
        }
        
        if roomID <= 0 {
            view.makeToast("请输入合法的会议ID")
            return (false, 0, "")
        }
        
        guard let userName = userNameInput.text else {
            view.makeToast("请输入用户名")
            return (false, 0, "")
        }
        
        resignInput()
        return (true, roomID, userName)
    }
    
    func enterRoom() {
        let params = autoCheck()
        
        if !params.0 {
            return;
        }
        
        // 设置用户昵称和头像等信息
        let userName = userNameInput.text!
        let avatar = ProfileManager.shared.curUserModel?.avatar
        TRTCMeeting.sharedInstance().setSelfProfile(userName, avatarURL: avatar ?? "") { (code, msg) in
            print("setSelfProfile" + "\(code)" + msg!)
        }
        
        // 保存当前的配置
        UserDefaults.standard.set(params.1, forKey: TRTCMeetingRoomIDKey)
        UserDefaults.standard.set(params.2, forKey: TRTCMeetingUserNameKey)
        UserDefaults.standard.set(self.openCameraSwitch.isOn, forKey: TRTCMeetingOpenCameraKey)
        UserDefaults.standard.set(self.openMicSwitch.isOn, forKey: TRTCMeetingOpenMicKey)
        UserDefaults.standard.set(self.audioQuality, forKey: TRTCMeetingAudioQualityKey)
        
        // 进入房间主界面
        var config = TRTCMeetingStartConfig()
        config.roomId = UInt32(roomInput.text ?? "0") ?? 0
        config.isVideoOn = self.openCameraSwitch.isOn
        config.isAudioOn = self.openMicSwitch.isOn
        config.audioQuality = audioQuality
        
        let vc = TRTCMeetingMainViewController(config: config)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func resignInput() {
        if roomInput.isFirstResponder {
            roomInput.resignFirstResponder()
        }
        if userNameInput.isFirstResponder {
            userNameInput.resignFirstResponder()
        }
    }
}
