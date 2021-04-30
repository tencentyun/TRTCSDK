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
    
    @objc func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        // 获取屏幕的高度
        let screenHeight = UIScreen.main.bounds.size.height
        
        ToastManager.shared.position = .center
        title = .titleText
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "meeting_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let item = UIBarButtonItem(customView: backBtn)
        item.tintColor = .black
        navigationItem.leftBarButtonItem = item
        
        // input Panel
        let inputPanel = UIView()
        inputPanel.backgroundColor = UIColor(hex: "F4F5F9")
        inputPanel.layer.cornerRadius = 10
        inputPanel.clipsToBounds = true
        view.addSubview(inputPanel)
        inputPanel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(15)
            make.height.equalTo(screenHeight * 137.0*0.5/812)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        let roomTip = UILabel()
        roomTip.backgroundColor = .clear
        roomTip.textColor = UIColor(hex: "333333")
        roomTip.font = UIFont(name: "PingFangSC-Medium", size: 16)
        roomTip.text = .meetingNumberText
        roomTip.adjustsFontSizeToFitWidth = true
        roomTip.minimumScaleFactor = 0.5
        inputPanel.addSubview(roomTip)
        roomTip.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.width.lessThanOrEqualTo(80)
            make.height.equalTo(24)
            make.centerY.equalTo(inputPanel)
        }
        
        roomInput.backgroundColor = .clear
        roomInput.textColor = UIColor(hex: "333333")
        roomInput.font = UIFont.systemFont(ofSize: 16)
        roomInput.attributedPlaceholder = NSAttributedString(string: .enterMeetingNumText,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BBBBBB") ?? UIColor.lightGray])
        roomInput.keyboardType = .numberPad
        inputPanel.addSubview(roomInput)
        roomInput.snp.makeConstraints { (make) in
            make.leading.equalTo(roomTip.snp.trailing).offset(30)
            make.trailing.equalTo(-16)
            make.centerY.height.equalTo(roomTip)
        }
        
        let openCameraTip = UILabel()
        view.addSubview(openCameraTip)
        openCameraTip.backgroundColor = .clear
        openCameraTip.textColor = UIColor(hex: "666666")
        openCameraTip.font = UIFont.systemFont(ofSize: 16)
        openCameraTip.text = .openCameraText
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
        openMicTip.textColor = UIColor(hex: "666666")
        openMicTip.font = UIFont.systemFont(ofSize: 16)
        openMicTip.text = .openMicText
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
        audioQualityLabel.textColor = UIColor(hex: "666666")
        audioQualityLabel.font = UIFont.systemFont(ofSize: 16)
        audioQualityLabel.text = .soundQualitySelectText
        audioQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(openMicSwitch.snp.bottom).offset(34)
            make.leading.equalTo(openMicTip)
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
        speechQualityLabel.text = .voiceText
        speechQualityLabel.textColor = UIColor(hex: "333333")
        view.addSubview(speechQualityLabel)
        speechQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(speechQualityButton)
            make.leading.equalTo(speechQualityButton.snp.trailing).offset(5)
            make.height.equalTo(20)
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
        defaultQualityLabel.text = .standardText
        defaultQualityLabel.textColor = UIColor(hex: "333333")
        view.addSubview(defaultQualityLabel)
        defaultQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(defaultQualityButton)
            make.leading.equalTo(defaultQualityButton.snp.trailing).offset(5)
            make.height.equalTo(20)
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
        musicQualityLabel.text = .musicText
        musicQualityLabel.textColor = UIColor(hex: "333333")
        view.addSubview(musicQualityLabel)
        musicQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(musicQualityButton)
            make.leading.equalTo(musicQualityButton.snp.trailing).offset(5)
            make.height.equalTo(20)
        }
        
        // 画质选择
        let videoQualityLabel = UILabel()
        view.addSubview(videoQualityLabel)
        videoQualityLabel.backgroundColor = .clear
        videoQualityLabel.textColor = UIColor(hex: "666666")
        videoQualityLabel.font = UIFont.systemFont(ofSize: 16)
        videoQualityLabel.text = .picQualitySelectText
        videoQualityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(speechQualityLabel.snp.bottom).offset(34)
            make.leading.equalTo(openMicTip)
            make.height.equalTo(24)
        }
        
        // 流畅
        view.addSubview(fluencyVideoButton)
        fluencyVideoButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
        fluencyVideoButton.setImage(UIImage(named: "meeting_select_on"), for: .selected)
        fluencyVideoButton.tag = 10
        fluencyVideoButton.isSelected = true // 默认流畅
        fluencyVideoButton.addTarget(self, action: #selector(selectVideoQuality(button:)), for: .touchUpInside)
        fluencyVideoButton.snp.makeConstraints { (make) in
            make.top.equalTo(videoQualityLabel.snp.bottom).offset(16)
            make.leading.equalTo(inputPanel.snp.leading).offset(16)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        let fluencyVideoLabel = UILabel()
        fluencyVideoLabel.text = .smoothText
        fluencyVideoLabel.textColor = UIColor(hex: "333333")
        view.addSubview(fluencyVideoLabel)
        fluencyVideoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fluencyVideoButton)
            make.leading.equalTo(fluencyVideoButton.snp.trailing).offset(5)
            make.height.equalTo(20)
        }
        
        // 清晰
        view.addSubview(distinctVideoButton)
        distinctVideoButton.setImage(UIImage(named: "meeting_select_off"), for: .normal)
        distinctVideoButton.setImage(UIImage(named: "meeting_select_on"), for: .selected)
        distinctVideoButton.tag = 11
        distinctVideoButton.addTarget(self, action: #selector(selectVideoQuality(button:)), for: .touchUpInside)
        distinctVideoButton.snp.makeConstraints { (make) in
            make.top.equalTo(fluencyVideoButton)
            make.leading.equalTo(inputPanel.snp.trailing).offset(32).multipliedBy(1/3.0)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        let distinctVideoLabel = UILabel()
        distinctVideoLabel.text = .clearText
        distinctVideoLabel.textColor = UIColor(hex: "333333")
        view.addSubview(distinctVideoLabel)
        distinctVideoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(distinctVideoButton)
            make.leading.equalTo(distinctVideoButton.snp.trailing).offset(5)
            make.height.equalTo(20)
        }
        
        

        let enterBtn = UIButton()
        enterBtn.setTitle(.enterMeetingText, for: .normal)
        enterBtn.setBackgroundImage(UIColor.buttonBackColor.trans2Image(), for: .normal)
        enterBtn.layer.cornerRadius = 25
        enterBtn.clipsToBounds = true
        enterBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        enterBtn.setTitleColor(.white, for: .normal)
        view.addSubview(enterBtn)
        enterBtn.snp.makeConstraints { (make) in
            make.top.equalTo(distinctVideoButton.snp.bottom).offset(30)
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
        
        if let isOpenCamera = UserDefaults.standard.object(forKey: TRTCMeetingOpenCameraKey) as? Bool {
            openCameraSwitch.isOn = isOpenCamera
        }
        
        if let isOpenMic = UserDefaults.standard.object(forKey: TRTCMeetingOpenMicKey) as? Bool {
            openMicSwitch.isOn = isOpenMic
        }
        
        if let audioQuality = UserDefaults.standard.object(forKey: TRTCMeetingAudioQualityKey) as? Int {
            setAudioQuality(audioQuality: audioQuality)
        }
        
        if let videoQuality = UserDefaults.standard.object(forKey: TRTCMeetingVideoQualityKey) as? Int {
            // 初始化设置视频质量参数
            setVideoQuality(videoQuality: videoQuality)
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
    
    // 初始化设置
    func setVideoQuality(videoQuality: Int) {
        self.videoQuality = videoQuality
        fluencyVideoButton.isSelected = videoQuality == 1 // 流畅
        distinctVideoButton.isSelected = videoQuality != 1 // 清晰
    }
    
    @objc
    func selectVideoQuality(button: UIButton) {
        if button.isSelected {
            return
        }
        button.isSelected = true
        if button == distinctVideoButton {
            fluencyVideoButton.isSelected = false
            videoQuality = 2 // 设置为清晰
        } else if button == fluencyVideoButton {
            distinctVideoButton.isSelected = false
            videoQuality = 1 // 设置为流畅
        }
    }
    
    func autoCheck() -> (Bool, UInt32) {
        if (roomInput.text?.count ?? 0) <= 0 {
            view.makeToast(.enterMeetingNumText)
            return (false, 0)
        }
        guard let roomID = UInt32(roomInput.text ?? "") else {
            view.makeToast(.enterLegitMeetingNumText)
            return (false, 0)
        }
        
        if roomID <= 0 {
            view.makeToast(.enterLegitMeetingNumText)
            return (false, 0)
        }
        
        resignInput()
        return (true, roomID)
    }
    
    func enterRoom() {
        let params = autoCheck()
        
        if !params.0 {
            return;
        }
        
        // 设置用户昵称和头像等信息
        guard let userName = ProfileManager.shared.curUserModel?.name, let avatar = ProfileManager.shared.curUserModel?.avatar else {
            return
        }
        TRTCMeeting.sharedInstance().setSelfProfile(userName, avatarURL: avatar) { (code, msg) in
            
        }
        
        // 保存当前的配置
        UserDefaults.standard.set(params.1, forKey: TRTCMeetingRoomIDKey)
        UserDefaults.standard.set(self.openCameraSwitch.isOn, forKey: TRTCMeetingOpenCameraKey)
        UserDefaults.standard.set(self.openMicSwitch.isOn, forKey: TRTCMeetingOpenMicKey)
        UserDefaults.standard.set(self.audioQuality, forKey: TRTCMeetingAudioQualityKey)
        UserDefaults.standard.set(self.videoQuality, forKey: TRTCMeetingVideoQualityKey)
        // 进入房间主界面
        var config = TRTCMeetingStartConfig()
        config.roomId = UInt32(roomInput.text ?? "0") ?? 0
        config.isVideoOn = self.openCameraSwitch.isOn
        config.isAudioOn = self.openMicSwitch.isOn
        config.audioQuality = audioQuality
        config.videoQuality = videoQuality
        
        let vc = TRTCMeetingMainViewController(config: config)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func resignInput() {
        if roomInput.isFirstResponder {
            roomInput.resignFirstResponder()
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = TRTCLocalize("Demo.TRTC.Meeting.multivideoconference")
    static let meetingNumberText = TRTCLocalize("Demo.TRTC.Meeting.meetingnum")
    static let userIdText = TRTCLocalize("Demo.TRTC.Salon.userid")
    static let enterMeetingNumText = TRTCLocalize("Demo.TRTC.Meeting.entermeetingnum")
    static let enterUserNameText = TRTCLocalize("Demo.TRTC.Meeting.enterusername")
    static let openCameraText = TRTCLocalize("Demo.TRTC.Meeting.opencamera")
    static let openMicText = TRTCLocalize("Demo.TRTC.Meeting.openmic")
    static let soundQualitySelectText = TRTCLocalize("Demo.TRTC.VoiceRoom.soundqualityselect")
    static let voiceText = TRTCLocalize("Demo.TRTC.VoiceRoom.voice")
    static let standardText = TRTCLocalize("Demo.TRTC.LiveRoom.standard")
    static let musicText = TRTCLocalize("Demo.TRTC.LiveRoom.music")
    static let picQualitySelectText = TRTCLocalize("Demo.TRTC.Meeting.picqualityselect")
    static let smoothText = TRTCLocalize("Demo.TRTC.Meeting.smooth")
    static let clearText = TRTCLocalize("Demo.TRTC.Meeting.clear")
    static let enterMeetingText = TRTCLocalize("Demo.TRTC.Meeting.entermeeting")
    static let enterLegitMeetingNumText = TRTCLocalize("Demo.TRTC.Meeting.enterlegitmeetingnum")
    static let shareText = TRTCLocalize("Demo.TRTC.Meeting.share")
}
