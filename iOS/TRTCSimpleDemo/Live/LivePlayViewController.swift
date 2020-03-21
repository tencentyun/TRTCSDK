//
//  LivePlayViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import TXLiteAVSDK_TRTC
import UIKit

/**
 * 观众视角下的RTC视频互动直播房间页面
 *
 * 包含如下简单功能：
 * - 进入/退出直播房间
 * - 显示房间内连麦用户的视频画面（当前示例最多可显示6个连麦用户的视频画面）
 * - 打开/关闭主播以及房间内其他连麦用户的声音和视频画面
 * - 发起/停止连麦
 * - 发起连麦之后，可以切换自己的前置/后置摄像头
 * - 发起连麦之后，可以控制打开/关闭自己的摄像头和麦克风
 */
class LivePlayViewController: UIViewController {
    
    @IBOutlet var remoteVideoViews: [LiveSubVideoView]!
    @IBOutlet var localVideoView: LiveSubVideoView!
    @IBOutlet var switchCameraButton: UIButton!
    @IBOutlet var roomOwnerVideoView: UIView!
    @IBOutlet var videoMutedTipsView: UIView!
    @IBOutlet var roomIdLabel: UILabel!
    
    var roomId: UInt32 = 0
    var userId: String = ""
    var roomOwner: String = ""
    
    private lazy var remoteUids = NSMutableOrderedSet.init(capacity: MAX_REMOTE_USER_NUM)
    private var isOwnerVideoStopped: Bool = true
    private var isFrontCamera: Bool = true
    
    private lazy var roomManager = LiveRoomManager.sharedInstance
    private lazy var trtcCloud: TRTCCloud = {
        let instance: TRTCCloud = TRTCCloud.sharedInstance()
        ///设置TRTCCloud的回调接口
        instance.delegate = self;
        return instance;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 房主的uid就是房间id
        roomOwner = "\(roomId)"
        roomIdLabel.text = roomOwner
        
        /**
         * 设置参数，进入视频直播房间
         * 房间号param.roomId，当前用户id param.userId
         * param.role 指定以TRTCRoleType.audience（观众角色）进入房间
         */
        let param = TRTCParams.init()
        param.sdkAppId = UInt32(SDKAppID)
        param.roomId   = roomId
        param.userId   = userId
        param.role     = TRTCRoleType.audience
        /// userSig是进入房间的用户签名，相当于密码（这里生成的是测试签名，正确做法需要业务服务器来生成，然后下发给客户端）
        param.userSig  = GenerateTestUserSig.genTestUserSig(param.userId)
        /// 指定以“在线直播场景”（TRTCAppScene.LIVE）进入房间
        trtcCloud.enterRoom(param, appScene: TRTCAppScene.LIVE)
        
        /// 设置直播房间的画质（帧率 15fps，码率400, 分辨率 270*480）
        let videoEncParam = TRTCVideoEncParam.init()
        videoEncParam.videoResolution = TRTCVideoResolution._480_270
        videoEncParam.videoBitrate = 400
        videoEncParam.videoFps = 15
        trtcCloud.setVideoEncoderParam(videoEncParam)
        
        /**
         * 设置默认美颜效果（美颜效果：光滑，美颜级别：5, 美白级别：1）
         * 互动直播场景推荐使用“光滑”美颜效果
         */
        let beautyManager = trtcCloud.getBeautyManager()
        beautyManager?.setBeautyStyle(TXBeautyStyle.smooth)
        beautyManager?.setBeautyLevel(5)
        beautyManager?.setWhitenessLevel(1)
        
        /// 调整仪表盘显示位置
        trtcCloud.setDebugViewMargin(roomOwner, margin: TXEdgeInsets.init(top: 80, left: 0, bottom: 0, right: 0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        TRTCCloud.destroySharedIntance()
    }
    
    @IBAction func onExitLiveClicked(_ sender: UIButton) {
        /// 退出视频直播房间
        trtcCloud.exitRoom()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onLinkMicClicked(_ sender: UIButton) {
        if sender.isSelected { /// 停止连麦
            trtcCloud.switch(TRTCRoleType.audience)
            trtcCloud.stopLocalAudio()
            trtcCloud.stopLocalPreview()
            localVideoView.reset()
            localVideoView.isHidden = true
            switchCameraButton.isHidden = true
        } else { /// 发起连麦
            localVideoView.isHidden = false
            switchCameraButton.isHidden = false
            trtcCloud.switch(TRTCRoleType.anchor)
            trtcCloud.startLocalAudio()
            trtcCloud.startLocalPreview(isFrontCamera, view: localVideoView)
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func onMuteRoomOwnerVideoClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        /// 打开/关闭当前房主的直播视频画面
        trtcCloud.muteRemoteVideoStream(roomOwner, mute: sender.isSelected)
        roomManager.muteRemoteVideo(forUser: roomOwner, muted: sender.isSelected)
        videoMutedTipsView.isHidden = !(sender.isSelected || isOwnerVideoStopped)
    }
    
    @IBAction func onMuteRoomOwnerAudioClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        /// 打开/关闭当前房主的声音
        trtcCloud.muteRemoteAudio(roomOwner, mute: sender.isSelected)
        roomManager.muteRemoteAudio(forUser: roomOwner, muted: sender.isSelected)
    }
    
    @IBAction func onSwitchCameraClicked(_ sender: UIButton) {
        /// 连麦之后，切换自己的前置/后置摄像头
        trtcCloud.switchCamera()
        isFrontCamera = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func onMuteRemoteVideoClicked(_ sender: UIButton) {
        if localVideoView == sender.superview {
            /// 连麦之后，打开/关闭自己的摄像头
            if sender.isSelected {
                trtcCloud.startLocalPreview(isFrontCamera, view: localVideoView)
            } else {
                trtcCloud.stopLocalPreview()
            }
            localVideoView.muteVideo(!sender.isSelected)
        } else {
            let index = sender.superview!.tag
            if index < remoteUids.count {
                /// 打开/关闭指定uid的远程用户的视频画面
                let remoteUid = remoteUids[index] as! String
                trtcCloud.muteRemoteVideoStream(remoteUid, mute: !sender.isSelected)
                (sender.superview as! LiveSubVideoView).muteVideo(!sender.isSelected)
            }
        }
    }
    
    @IBAction func onMuteRemoteAudioClicked(_ sender: UIButton) {
        if localVideoView == sender.superview {
            /// 连麦之后，打开/关闭自己的麦克风
            if sender.isSelected {
                trtcCloud.startLocalAudio()
            } else {
                trtcCloud.stopLocalAudio()
            }
            localVideoView.muteAudio(!sender.isSelected)
        } else {
            let index = sender.superview!.tag
            if index < remoteUids.count {
                /// 打开/关闭指定uid的远程用户的声音
                let remoteUid = remoteUids[index] as! String
                trtcCloud.muteRemoteAudio(remoteUid, mute: !sender.isSelected)
                (sender.superview as! LiveSubVideoView).muteAudio(!sender.isSelected)
            }
        }
    }
    
    @IBAction func onDashboardClicked(_ sender: UIButton) {
        /// 显示调试信息
        sender.tag += 1
        if sender.tag > 2 {
            sender.tag = 0
        }
        trtcCloud.showDebugView(sender.tag)
        sender.isSelected = sender.tag > 0
    }
}

extension LivePlayViewController: TRTCCloudDelegate {
    
    /**
     * 当前视频通话房间里的其他用户开启/关闭摄像头时会收到这个回调
     * 此时可以根据这个用户的视频available状态来 “显示或者关闭” Ta的视频画面
     */
    func onUserVideoAvailable(_ userId: String, available: Bool) {
        guard userId != roomOwner else {
            refreshRoomOwnerVideoView(available: available)
            return
        }
        let index = remoteUids.index(of: userId)
        if available {
            guard NSNotFound == index else { return }
            remoteUids.add(userId)
            refreshRemoteVideoViews(from: remoteUids.count - 1)
        } else {
            guard NSNotFound != index else { return }
            /// 关闭用户userId的视频画面
            trtcCloud.stopRemoteView(userId)
            remoteUids.removeObject(at: index)
            refreshRemoteVideoViews(from: index)
        }
    }
    
    func refreshRemoteVideoViews(from: Int) {
        for i in from..<remoteVideoViews.count {
            if i < remoteUids.count {
                let remoteUid = remoteUids[i] as! String
                remoteVideoViews[i].reset(with: remoteUid)
                remoteVideoViews[i].isHidden = false
                /// 开始显示用户remoteUid的视频画面
                trtcCloud.startRemoteView(remoteUid, view: remoteVideoViews[i])
            } else {
                remoteVideoViews[i].reset()
                remoteVideoViews[i].isHidden = true
            }
        }
    }
    
    /// 打开/关闭房主的视频画面
    func refreshRoomOwnerVideoView(available: Bool) {
        if available {
            trtcCloud.startRemoteView(roomOwner, view: roomOwnerVideoView)
        } else {
            trtcCloud.stopRemoteView(roomOwner)
        }
        isOwnerVideoStopped = !available
        videoMutedTipsView.isHidden = !(roomManager.isVideoMuted(forUser: roomOwner) || isOwnerVideoStopped)
    }
    
    /// 有用户进入当前视频直播房间
    func onRemoteUserEnterRoom(_ userId: String) {
        roomManager.onRemoteUserEnterRoom(userId: userId)
    }
    
    /// 有用户离开当前视频直播房间
    func onRemoteUserLeaveRoom(_ userId: String, reason: Int) {
        roomManager.onRemoteUserLeaveRoom(userId: userId)
    }
}
