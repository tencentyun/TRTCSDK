//
//  TRTCMeetingMainViewController.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/23/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation

struct TRTCMeetingStartConfig {
    var roomId: UInt32 = 0
    var isVideoOn: Bool = true
    var isAudioOn: Bool = true
    var audioQuality: Int = 0
    var videoQuality: Int = 1 // 1 流畅 2 清晰
}

class MeetingAttendeeModel: TRTCMeetingUserInfo {
    var networkQuality: Int = 0
    var audioVolume: Int = 0
}

protocol TRTCMeetingRenderViewDelegate: class {
    func getRenderView(userId: String) -> MeetingRenderView?
}

class TRTCMeetingMainViewController: UIViewController, TRTCMeetingDelegate,
                                        TRTCMeetingMemberVCDelegate, TRTCMeetingRenderViewDelegate {
    let disposeBag = DisposeBag()
    let pageControl = UIPageControl()
    
    var startConfig: TRTCMeetingStartConfig
    var selfUserId: String = ""
    
    // |renderViews|和|attendeeList|的第一个元素表示自己
    var renderViews: [MeetingRenderView] = []
    var attendeeList: [MeetingAttendeeModel] = []
    
    // 如果设置了全体静音，新进入的人需要设置静音
    var isMuteAllAudio: Bool = false
    
    var isUseSpeaker: Bool = true
    var isFrontCamera: Bool = true
    
    // 记录录屏前是否在进行摄像头推流，用于录屏结束后恢复摄像头
    var isOpenCamera: Bool = false
    var isScreenPushing: Bool = false

    // 顶部按钮
    let exitButton = UIButton()
    let switchCameraButton = UIButton()
    let switchAudioRouteButton = UIButton()
    
    // 房间号label
    let roomIdLabel = UILabel()
    lazy var longGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer.init(target: self, action: #selector(showlogView(gesture:)))
        gesture.minimumPressDuration = 3
        return gesture
    }()
    
    // 底部按钮
    var beautyPannel = TCBeautyPanel()
    let muteAudioButton = UIButton()
    let muteVideoButton = UIButton()
    let beautyButton = UIButton()
    let membersButton = UIButton()
    let shareScreen = UIButton()
    let moreSettingButton = UIButton()
    let moreSettingVC = TRTCMeetingMoreControllerUI()
    
    // 标记是否显示Log视图
    var isLogViewShow: Bool = false
    
    var topPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.top
        }
        return 0
    }()
    
    lazy var attendeeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width), collectionViewLayout: layout)
        collection.register(MeetingAttendeeCell.classForCoder(), forCellWithReuseIdentifier: "MeetingAttendeeCell")
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collection.contentMode = .scaleToFill
        collection.backgroundColor = .pannelBackColor
        collection.dataSource = self
        collection.delegate = self

        return collection
    }()
    
    func getRenderView(userId: String) -> MeetingRenderView? {
        for renderView in renderViews {
            if  renderView.attendeeModel.userId == userId {
                return renderView
            }
        }
        return nil
    }
    
    init(config: TRTCMeetingStartConfig) {
        startConfig = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        selfUserId = ProfileManager.shared.curUserModel?.userId ?? ""
        resetAttendeeList()
        
        // 布局UI
        setupUI()
        
        // 设置进房参数 && 进入会议
        applyConfigs()
        createOrEnterMeeting()
        
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        beautyPannel.resetAndApplyValues() // 销毁时重置美颜参数
        UIApplication.shared.isIdleTimerDisabled = false
        debugPrint("deinit \(self)")
    }
    
    func resetAttendeeList() {
        let curUser = MeetingAttendeeModel()
        curUser.userId = ProfileManager.shared.curUserModel?.userId
        curUser.userName = ProfileManager.shared.curUserModel?.name
        curUser.avatarURL = ProfileManager.shared.curUserModel?.avatar
        curUser.isAudioAvailable = startConfig.isAudioOn
        curUser.isVideoAvailable = startConfig.isVideoOn
        curUser.isMuteAudio = false
        curUser.isMuteVideo = false
        attendeeList = [curUser]
        
        let renderView = MeetingRenderView()
        renderView.attendeeModel = curUser
        renderViews.append(renderView)
    }
    
    func applyConfigs() {
        // 设置音质（需要在startMicrophone前设置）
        TRTCMeeting.sharedInstance().setAudioQuality(TRTCAudioQuality(rawValue: startConfig.audioQuality)!)
        
        // 开启音量计算
        TRTCMeeting.sharedInstance().enableAudioEvaluation(true)
        
        // 开启摄像头和麦克风
        if startConfig.isVideoOn {
            AppUtils.shared.alertUserTips(self)
            let localPreviewView = getRenderView(userId: selfUserId)!
            TRTCMeeting.sharedInstance().startCameraPreview(true, view: localPreviewView)
        } else {
            TRTCMeeting.sharedInstance().stopCameraPreview()
        }
        TRTCMeeting.sharedInstance().startMicrophone();
        TRTCMeeting.sharedInstance().muteLocalAudio(!startConfig.isAudioOn)
        
        // 使用默认的美颜参数
        beautyPannel.resetAndApplyValues()
        
        // 开启镜像
        TRTCMeeting.sharedInstance().setLocalViewMirror(TRTCLocalVideoMirrorType.enable)
        
        // 设置视频采集参数
        changeResolution()
    }
    
    func createOrEnterMeeting() {
        TRTCMeeting.sharedInstance().delegate = self;
        
        let roomId = UInt32(startConfig.roomId)
        TRTCMeeting.sharedInstance().createMeeting(roomId) { (code, msg) in
            if code == 0 {
                // 创建房间成功
                self.view.makeToast(.meetingCreateSuccessText)
                return;
            }
            
            // 会议创建不成功，表示会议已经存在，那就直接进入会议
            TRTCMeeting.sharedInstance().enter(roomId) { (code, msg) in
                if code == 0{
                    self.view.makeToast(.meetingEnterSuccessText)
                } else {
                    self.view.makeToast(.meetingEnterFailedText + msg!)
                }
            }
        }
    }
    
    func changeResolution() {
        guard !isScreenPushing else {
            return
        }
        // 流畅设置
        func fluencySetting(memeberCount: Int) {
            let qosParam = TRTCNetworkQosParam.init()
            qosParam.preference = TRTCVideoQosPreference.smooth
            TRTCMeeting.sharedInstance().setNetworkQosParam(qosParam)
            if memeberCount < 5 {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._640_360)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(700)
            } else {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._480_270)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(350)
            }
        }
        // 清晰设置
        func distinctSetting(memberCount: Int) {
            let qosParam = TRTCNetworkQosParam.init()
            qosParam.preference = TRTCVideoQosPreference.clear
            TRTCMeeting.sharedInstance().setNetworkQosParam(qosParam)
            if memberCount <= 2 {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._960_540)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(1300)
            } else if memberCount >= 3 && memberCount <= 4 {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._640_360)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(800)
            } else if memberCount > 4 {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._480_270)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(400)
            }
        }
        if startConfig.videoQuality == 1 {
            // 流畅
            fluencySetting(memeberCount: attendeeList.count)
        } else {
            // 清晰
            distinctSetting(memberCount: attendeeList.count)
        }
    }
    
    // MARK: - TRTCMeetingDelegate
    
    func onError(_ code: Int, message: String?) {
        if code == -1308 {
            self.view.makeToast(.startRecordingFailedText)
        } else {
            self.view.makeToast(LocalizeReplace(.wentWrongxxyyText, String(code), message!))
        }
    }
    
    func onNetworkQuality(_ localQuality: TRTCQualityInfo, remoteQuality: [TRTCQualityInfo]) {
        let render = getRenderView(userId: selfUserId)
        render?.attendeeModel.networkQuality = localQuality.quality.rawValue
        render?.refreshSignalView()
        
        for remote in remoteQuality {
            let render = getRenderView(userId: remote.userId!)
            render?.attendeeModel.networkQuality = localQuality.quality.rawValue
            render?.refreshSignalView()
        }
    }
 
    func onUserEnterRoom(_ userId: String) {
        debugPrint("log: onUserEnterRoom userId: \(String(describing: userId))")
        let userModel = MeetingAttendeeModel()
        userModel.userId = userId
        userModel.userName = userId  // 先默认用userId，getUserInfo可能返回失败
        userModel.isMuteAudio = isMuteAllAudio
        userModel.isMuteVideo = false
        userModel.isAudioAvailable = false
        userModel.isVideoAvailable = false
        attendeeList.append(userModel)
        changeResolution()
        let renderView = MeetingRenderView()
        renderView.attendeeModel = userModel
        renderViews.append(renderView)
        
        TRTCMeeting.sharedInstance().muteRemoteAudio(userId, mute: isMuteAllAudio)
        TRTCMeeting.sharedInstance().getUserInfo(userId) { [weak self](code, message, userInfoList) in
            guard let self = self else {return}
            if code == 0 && userInfoList?.count ?? 0 > 0 {
                let userInfo = userInfoList![0];
                userModel.userName = userInfo.userName ?? userId // 如果没拿到用户名，则用UserID代替
                userModel.avatarURL = userInfo.avatarURL ?? ""
                
                // 通知列表更新UI
                NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
            }
            self.reloadData()
        }
    }
    
    func onUserVolumeUpdate(_ userId: String, volume: Int) {
        let render = getRenderView(userId: userId)
        render?.attendeeModel.audioVolume = volume
        render?.refreshVolumeProgress()
    }
    
    func onUserLeaveRoom(_ userId: String) {
        debugPrint("log: onUserLeaveRoom userId: \(String(describing: userId))")
        
        let renderView = getRenderView(userId: userId)
        renderView?.removeFromSuperview()
        
        renderViews = renderViews.filter{ (renderView) -> Bool in
            renderView.attendeeModel.userId != userId
        }
        attendeeList = attendeeList.filter{ (model) -> Bool in
            model.userId != userId
        }
        changeResolution()
        NotificationCenter.default.post(name: refreshUserListNotification, object: attendeeList)
        reloadData()
    }
    
    func onUserVideoAvailable(_ userId: String, available: Bool) {
        debugPrint("log: onUserVideoAvailable userId: \(String(describing: userId)), available: \(available)")
        let renderView = getRenderView(userId: userId)
        if available && renderView != nil {
            TRTCMeeting.sharedInstance().startRemoteView(userId, view: renderView!) { (code, message) in
                debugPrint("startRemoteView" + "\(code)" + message!)
            }
        } else {
            TRTCMeeting.sharedInstance().stopRemoteView(userId) { (code, message) in
                debugPrint("stopRemoteView" + "\(code)" + message!)
            }
        }
        renderView?.refreshVideo(isVideoAvailable: available)
    }
    
    func onUserAudioAvailable(_ userId: String, available: Bool) {
        debugPrint("log: onUserAudioAvailable userId: \(String(describing: userId)), available: \(available)")
        getRenderView(userId: userId)?.refreshAudio(isAudioAvailable: available)
    }
    
    func onRoomDestroy(_ roomId: String) {
        if startConfig.roomId == UInt32(roomId) {
            self.view.makeToast(.creatorEndMeetingText)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func onRecvRoomTextMsg(_ message: String?, userInfo: TRTCMeetingUserInfo) {
        debugPrint("log: onRecvRoomTextMsg: \(String(describing: message)) from userId: \(String(describing: userInfo.userId))")
    }
    
    func onRecvRoomCustomMsg(_ cmd: String?, message: String?, userInfo: TRTCMeetingUserInfo) {
        debugPrint("log: onRecvRoomCustomMsg: \(String(describing: cmd)) message:\(String(describing: message)) from userId: \(String(describing: userInfo.userId))")
    }
    
    func onScreenCaptureStarted() {
        debugPrint("log: onScreenCaptureStarted")
        if !self.isScreenPushing {
            self.isScreenPushing = true
        }
        self.view.makeToast(.screenSharingBeganText)
    }
    
    func onScreenCapturePaused(_ reason: Int32) {
        debugPrint("log: onScreenCapturePaused: " + "\(reason)")
        self.view.makeToast(.screenSharingPauseText)
    }
    
    func onScreenCaptureResumed(_ reason: Int32) {
        debugPrint("log: onScreenCaptureResumed: " + "\(reason)")
        self.view.makeToast(.screenSharingResumeText)
    }
    
    func onScreenCaptureStoped(_ reason: Int32) {
        debugPrint("log: onScreenCaptureStoped: " + "\(reason)")
        
        // 恢复摄像头采集
        if self.isOpenCamera {
            self.setLocalVideo(isVideoAvailable: true)
        } else {
            // 停止录屏
            self.isScreenPushing = false
            if #available(iOS 11.0, *) {
                TRTCMeeting.sharedInstance().stopScreenCapture()
            }
            changeResolution()
        }
    }
    
    
    // MARK: - TRTCMeetingMemberVCDelegate
    
    func onMuteAudio(userId: String, mute: Bool) {
        for item in attendeeList {
            if item.userId == userId {
                item.isMuteAudio = mute
            }
        }
        TRTCMeeting.sharedInstance().muteRemoteAudio(userId, mute: mute)
    }
    
    func onMuteVideo(userId: String, mute: Bool) {
        for item in attendeeList {
            if item.userId == userId {
                item.isMuteVideo = mute
            }
        }
        TRTCMeeting.sharedInstance().muteRemoteVideoStream(userId, mute: mute)
    }
    
    func onMuteAllAudio(mute: Bool) {
        for item in attendeeList {
            item.isMuteAudio = mute
            TRTCMeeting.sharedInstance().muteRemoteAudio(item.userId, mute: mute)
        }
        isMuteAllAudio = mute
        
        // 通知列表更新UI
        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
    }
    
    func onMuteAllVideo(mute: Bool) {
        for item in attendeeList {
            item.isMuteVideo = mute
            TRTCMeeting.sharedInstance().muteRemoteVideoStream(item.userId, mute: mute)
        }
        // 通知列表更新UI
        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let meetingCreateSuccessText = TRTCLocalize("Demo.TRTC.Meeting.meetingcreatsuccess")
    static let meetingEnterSuccessText = TRTCLocalize("Demo.TRTC.Meeting.meetingentersuccess")
    static let meetingEnterFailedText = TRTCLocalize("Demo.TRTC.Meeting.meetingenterfailed")
    static let startRecordingFailedText = TRTCLocalize("Demo.TRTC.Meeting.startrecordingfailed")
    static let wentWrongxxyyText = TRTCLocalize("Demo.TRTC.Meeting.wentwrongxxyy")
    static let creatorEndMeetingText = TRTCLocalize("Demo.TRTC.Meeting.creatorendmeeting")
    static let screenSharingBeganText = TRTCLocalize("Demo.TRTC.Meeting.screensharingbegan")
    static let screenSharingPauseText = TRTCLocalize("Demo.TRTC.Meeting.screensharingpause")
    static let screenSharingResumeText = TRTCLocalize("Demo.TRTC.Meeting.screensharingresume")
}
