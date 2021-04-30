//
//  TRTCMeetingMainViewController+UI.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/23/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
import Toast_Swift

extension TRTCMeetingMainViewController {
    func setupUI() {
        ToastManager.shared.position = .bottom
        view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        
        attendeeCollectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        view.addSubview(attendeeCollectionView)
        
        view.addSubview(pageControl)
        pageControl.currentPage = 0
        pageControl.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(30)
            make.centerX.equalTo(view)
            make.bottomMargin.equalTo(view).offset(-40)
        }
        
        setupTabs()
        setupControls()
        
        reloadData()
    }
    
    func setupTabs() {
        // 背景
        let backView = UIView()
        view.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(view)
            make.height.equalTo(topPadding + 45)
        }
        backView.backgroundColor = .clear
        
        
        // 房间号label
        roomIdLabel.frame = CGRect(x: UIScreen.main.bounds.size.width / 3.0, y: topPadding + 10, width: UIScreen.main.bounds.size.width / 3.0, height: 25)
        roomIdLabel.textAlignment = .center
        roomIdLabel.text = String(startConfig.roomId)
        roomIdLabel.font = UIFont.systemFont(ofSize: 18)
        roomIdLabel.textColor = .white
        roomIdLabel.isUserInteractionEnabled = true
        
        
        roomIdLabel.addGestureRecognizer(longGesture)
        backView.addSubview(roomIdLabel)
        
        // 扬声器切换
        switchAudioRouteButton.setImage(UIImage(named: "meeting_speaker"), for: .normal)
        backView.addSubview(switchAudioRouteButton)
        switchAudioRouteButton.snp.remakeConstraints { (make) in
            make.leading.equalTo(20)
            make.top.equalTo(topPadding + 5)
            make.width.height.equalTo(32)
        }
        switchAudioRouteButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.isUseSpeaker = !self.isUseSpeaker
            TRTCMeeting.sharedInstance().setSpeaker(self.isUseSpeaker)
            self.switchAudioRouteButton.setImage(UIImage(named: self.isUseSpeaker ? "meeting_speaker" : "meeting_earphone"), for: .normal)
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        // 摄像头切换
        switchCameraButton.setImage(UIImage(named: "meeting_switch_camera"), for: .normal)
        backView.addSubview(switchCameraButton)
        switchCameraButton.snp.remakeConstraints { (make) in
            make.leading.equalTo(switchAudioRouteButton.snp.trailing).offset(10)
            make.top.equalTo(switchAudioRouteButton)
            make.width.height.equalTo(32)
        }
        switchCameraButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.isFrontCamera = !self.isFrontCamera
            TRTCMeeting.sharedInstance().switchCamera(self.isFrontCamera)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        // 退出
        exitButton.setTitle(.exitMeetingText, for: .normal)
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        exitButton.backgroundColor = UIColor(red: 232 / 255.0, green: 75 / 255.0, blue: 64 / 255.0, alpha: 1.0)
        exitButton.layer.cornerRadius = 19
        backView.addSubview(exitButton)
        exitButton.snp.remakeConstraints { (make) in
            make.trailing.equalTo(-25)
            make.top.equalTo(topPadding + 9)
            make.width.equalTo(80)
            make.height.equalTo(38)
        }
        exitButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            let alertVC = UIAlertController(title: .promptText, message: .sureExitText, preferredStyle: UIAlertController.Style.alert)
            
            let okView = UIAlertAction(title: .confirmText, style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) -> Void in
                print("exit success\n")
                TRTCMeeting.sharedInstance().leave { (code, msg) in
                    debugPrint("log: exitMeeting: code \(code), msg: \(String(describing: msg))")
                }
                self.navigationController?.popViewController(animated: true)
            })
            
            let cancelView = UIAlertAction(title: .cancelText, style: UIAlertAction.Style.cancel, handler: {
                (action: UIAlertAction!) -> Void in
                print("cancel btn click\n")
            })
            
            alertVC.addAction(okView)
            alertVC.addAction(cancelView)
            self.present(alertVC, animated: true, completion: nil)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func setupControls() {
        // 背景
        let backView = UIView()
        view.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(view)
            make.height.equalTo(55)
        }
        backView.backgroundColor = .clear
        
        
        // 开关麦克风
        muteAudioButton.setImage(UIImage(named: startConfig.isAudioOn ? "meeting_mic_open" : "meeting_mic_close"), for: .normal)
        backView.addSubview(muteAudioButton)
        muteAudioButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(-150)
            make.bottom.equalTo(view).offset(-10)
            make.width.height.equalTo(50)
        }
        
        muteAudioButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            let render = self.getRenderView(userId: self.selfUserId)!
            let isAudioAvailable = !render.isAudioAvailable()
            
            render.refreshAudio(isAudioAvailable: isAudioAvailable)
            self.muteAudioButton.setImage(UIImage(named: isAudioAvailable ? "meeting_mic_open" : "meeting_mic_close"), for: .normal)
            TRTCMeeting.sharedInstance().muteLocalAudio(!isAudioAvailable)
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        // 开关摄像头
        muteVideoButton.setImage(UIImage(named: startConfig.isVideoOn ? "meeting_camera_open" : "meeting_camera_close"), for: .normal)
        backView.addSubview(muteVideoButton)
        muteVideoButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(-90)
            make.bottom.equalTo(view).offset(-10)
            make.width.height.equalTo(50)
        }
        
        muteVideoButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            let render = self.getRenderView(userId: self.selfUserId)!
            let isVideoAvailable = !render.isVideoAvailable()
            self.setLocalVideo(isVideoAvailable: isVideoAvailable)
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        // 美颜设置
        let bottomOffset: CGFloat = 55
        let height = CGFloat(TCBeautyPanel.getHeight())
        let theme = TCBeautyPanelTheme()
        
        let cyanColor = UIColor(red: 11.0/255, green: 204.0/255, blue: 172.0/255, alpha: 1.0)
        theme.beautyPanelSelectionColor = cyanColor;
        theme.beautyPanelMenuSelectionBackgroundImage = UIImage(named: "beauty_selection_bg")!
        theme.sliderThumbImage = UIImage(named: "slider")!
        theme.sliderValueColor = theme.beautyPanelSelectionColor;
        theme.sliderMinColor = cyanColor;
        
        let frame = CGRect(x: 0, y: view.frame.height - height - bottomOffset, width: view.frame.width, height: height)
        beautyPannel = TCBeautyPanel(frame: frame, theme: theme, actionPerformer: TCBeautyPanelActionProxy.init(sdkObject: TRTCMeeting.sharedInstance()))
        beautyPannel.bottomOffset = 0
        beautyPannel.isHidden = true
        view.addSubview(beautyPannel)
        
        beautyButton.setImage(UIImage(named: "meeting_beauty"), for: .normal)
        backView.addSubview(beautyButton)
        beautyButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(-30)
            make.bottom.equalTo(view).offset(-10)
            make.width.height.equalTo(50)
        }
        
        beautyButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            self.beautyPannel.isHidden = !self.beautyPannel.isHidden
            if self.beautyPannel.isHidden {
                self.view.sendSubviewToBack(self.beautyPannel)
            } else {
                self.view.bringSubviewToFront(self.beautyPannel)
            }
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        // 成员列表
        membersButton.setImage(UIImage(named: "metting_member"), for: .normal)
        backView.addSubview(membersButton)
        membersButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(30)
            make.bottom.equalTo(view).offset(-10)
            make.width.height.equalTo(50)
        }
        
        membersButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            let vc = TRTCMeetingMemberViewController(attendeeList: self.attendeeList)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        // 屏幕分享按钮
        shareScreen.setImage(UIImage(named: "meeting_screen"), for: .normal)
        backView.addSubview(shareScreen)
        shareScreen.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(90)
            make.bottom.equalTo(view).offset(-10)
            make.width.height.equalTo(50)
        }
        
        shareScreen.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            // 防止重复设置
            if !self.isScreenPushing {
                self.isOpenCamera = self.getRenderView(userId: self.selfUserId)!.isVideoAvailable()
                
                // 录屏前必须先关闭摄像头采集
                self.setLocalVideo(isVideoAvailable: false)
            }
            
            self.isScreenPushing = true
            
            if #available(iOS 12.0, *) {
                // 屏幕分享
                let params = TRTCVideoEncParam()
                params.videoResolution = TRTCVideoResolution._1280_720
                params.resMode = TRTCVideoResolutionMode.portrait
                params.videoFps = 10
                params.enableAdjustRes = false
                params.videoBitrate = 1500
                TRTCMeeting.sharedInstance().startScreenCapture(params)
                TRTCBroadcastExtensionLauncher.launch()
            } else {
                self.view.makeToast(.versionLowText)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        // 更多设置按钮
        moreSettingButton.setImage(UIImage(named: "meeting_more"), for: .normal)
        backView.addSubview(moreSettingButton)
        moreSettingButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(150)
            make.bottom.equalTo(view).offset(-10)
            make.width.height.equalTo(50)
        }
        
        moreSettingButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.presentBottom(self.moreSettingVC)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
    }
    
    func setLocalVideo(isVideoAvailable: Bool) {
        if let render = self.getRenderView(userId: self.selfUserId) {
            render.refreshVideo(isVideoAvailable: isVideoAvailable)
        }
        self.muteVideoButton.setImage(UIImage(named: isVideoAvailable ? "meeting_camera_open" : "meeting_camera_close"), for: .normal)
        
        // 先关闭录屏
        var needDelay = false
        if self.isScreenPushing {
            if #available(iOS 11.0, *) {
                TRTCMeeting.sharedInstance().stopScreenCapture()
            }
            self.isScreenPushing = false
            needDelay = true
        }
        
        if isVideoAvailable {
            AppUtils.shared.alertUserTips(self)
            
            // 开启摄像头预览
            // TODO 关闭录屏后，要延迟一会才能打开摄像头，SDK bug ?
            if needDelay {
                let localPreviewView = self.getRenderView(userId: self.selfUserId)!
                TRTCMeeting.sharedInstance().startCameraPreview(true, view: localPreviewView)
            } else {
                let localPreviewView = self.getRenderView(userId: self.selfUserId)!
                TRTCMeeting.sharedInstance().startCameraPreview(true, view: localPreviewView)
            }
            
        } else {
            TRTCMeeting.sharedInstance().stopCameraPreview()
        }
    }
    
    @objc func showlogView(gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizer.State.began {
            return
        }
        if !self.isLogViewShow {
            TRTCCloud.sharedInstance()?.setDebugViewMargin(selfUserId, margin: TXEdgeInsets.init(top: 70, left: 10, bottom: 30, right: 10))
            TRTCCloud.sharedInstance()?.showDebugView(2) // 显示全量版的Log视图
            self.isLogViewShow = true
        } else {
            TRTCCloud.sharedInstance()?.showDebugView(0) // 显示全量版的Log视图
            self.isLogViewShow = false
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let exitMeetingText = TRTCLocalize("Demo.TRTC.Meeting.exitmeeting")
    static let promptText = TRTCLocalize("Demo.TRTC.LiveRoom.prompt")
    static let sureExitText = TRTCLocalize("Demo.TRTC.Meeting.suretoexitmeeting")
    static let confirmText = TRTCLocalize("Demo.TRTC.LiveRoom.confirm")
    static let cancelText = TRTCLocalize("Demo.TRTC.LiveRoom.cancel")
    static let versionLowText = TRTCLocalize("Demo.TRTC.Meeting.versiontoolow")
}
