//
//  LivePlayViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

import TXLiteAVSDK_TRTC_Mac
import Cocoa

/**
 * 观众视角下的RTC视频互动直播房间页面
 *
 * 包含如下简单功能：
 * - 进入/退出直播房间
 * - 显示房间内连麦用户的视频画面（当前示例最多可显示6个连麦用户的视频画面）
 * - 打开/关闭主播以及房间内其他连麦用户的声音和视频画面
 * - 发起/停止连麦
 * - 发起连麦之后，可以打开/关闭屏幕分享
 * - 发起连麦之后，可以控制打开/关闭自己的摄像头和麦克风
 */
class LivePlayViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet var roomOwnerVideoView: NSView!
    @IBOutlet var remoteVideoViews: NSView!
    @IBOutlet var shareScreenButton: NSButton!
    @IBOutlet var localVideoView: LiveSubVideoView!
    /// 屏幕分享画面的显示窗口
    var remoteScreenController: NSWindowController?
    
    var roomId: UInt32 = 0
    var userId: String = ""
    var roomOwner: String = ""
    
    private lazy var remoteUids = NSMutableOrderedSet.init(capacity: MAX_REMOTE_USER_NUM)
    
    private lazy var roomManager = LiveRoomManager.sharedInstance
    private lazy var trtcCloud: TRTCCloud = {
        let instance: TRTCCloud = TRTCCloud.sharedInstance()
        ///设置TRTCCloud的回调接口
        instance.delegate = self;
        return instance;
    }()
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.delegate = self
        view.window?.title = "视频互动直播--房间\(roomId)"
        
        // 房主的uid就是房间id
        roomOwner = "\(roomId)"
        
        /**
         * 设置参数，进入视频直播房间
         * 房间号param.roomId，当前用户id param.userId
         * param.role 指定以什么角色进入房间（anchor主播，audience观众）
         */
        let param = TRTCParams.init()
        param.sdkAppId = UInt32(SDKAppID)
        param.roomId   = roomId
        param.userId   = userId
        param.role     = TRTCRoleType.anchor
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
    }
    
    func windowWillClose(_ notification: Notification) {
        /// 退出视频直播房间
        trtcCloud.exitRoom()
        remoteScreenController?.close()
    }
    
    deinit {
        TRTCCloud.destroySharedIntance()
    }
    
    @IBAction func onExitRoomClicked(_ sender: NSButton) {
        view.window?.close()
    }
    
    @IBAction func onLinkMicClicked(_ sender: NSButton) {
        if NSControl.StateValue.off == sender.state { /// 停止连麦
            trtcCloud.stopLocalAudio()
            trtcCloud.stopLocalPreview()
            localVideoView.isHidden = true
            shareScreenButton.isHidden = true
        } else { /// 发起连麦
            localVideoView.isHidden = false
            shareScreenButton.isHidden = false
            trtcCloud.startLocalAudio()
            trtcCloud.startLocalPreview(localVideoView.videoView)
        }
        sender.image = TRTC_DEMO_LINKMIC_ICON[sender.state]!
    }
    
    @IBAction func onMuteRoomOwnerVideoClicked(_ sender: NSButton) {
        if NSControl.StateValue.on == sender.state { /// 关闭当前房主的直播视频画面
            trtcCloud.muteRemoteVideoStream(roomOwner, mute: true)
            roomManager.muteRemoteVideo(forUser: roomOwner, muted: true)
        } else { /// 打开当前房主的直播视频画面
            trtcCloud.muteRemoteVideoStream(roomOwner, mute: false)
            roomManager.muteRemoteVideo(forUser: roomOwner, muted: false)
        }
        sender.image = TRTC_DEMO_CAMERA_ICON[sender.state]!
    }
    
    @IBAction func onMuteRoomOwnerAudioClicked(_ sender: NSButton) {
        if NSControl.StateValue.on == sender.state { /// 关闭当前房主的声音
            trtcCloud.muteRemoteAudio(roomOwner, mute: true)
            roomManager.muteRemoteAudio(forUser: roomOwner, muted: true)
        } else { /// 打开当前房主的声音
            trtcCloud.muteRemoteAudio(roomOwner, mute: false)
            roomManager.muteRemoteAudio(forUser: roomOwner, muted: false)
        }
        sender.image = TRTC_DEMO_MIC_ICON[sender.state]!
    }
    
    @IBAction func onMuteRemoteVideoClicked(_ sender: NSButton) {
        let mute = NSControl.StateValue.on == sender.state
        if localVideoView == sender.superview {
            /// 连麦之后，打开/关闭自己的摄像头
            if !mute {
                trtcCloud.startLocalPreview(localVideoView.videoView)
            } else {
                trtcCloud.stopLocalPreview()
            }
            localVideoView.muteVideo(mute)
        } else {
            let index = (sender.superview as! LiveSubVideoView).viewTag
            if index < remoteUids.count {
                /// 打开/关闭指定uid的远程用户的视频画面
                let remoteUid = remoteUids[index] as! String
                trtcCloud.muteRemoteVideoStream(remoteUid, mute: mute)
                (sender.superview as! LiveSubVideoView).muteVideo(mute)
            }
        }
    }
    
    @IBAction func onMuteRemoteAudioClicked(_ sender: NSButton) {
        let mute = NSControl.StateValue.on == sender.state
        if localVideoView == sender.superview {
            /// 连麦之后，打开/关闭自己的麦克风
            if !mute {
                trtcCloud.startLocalAudio()
            } else {
                trtcCloud.stopLocalAudio()
            }
            localVideoView.muteAudio(mute)
        } else {
            let index = (sender.superview as! LiveSubVideoView).viewTag
            if index < remoteUids.count {
                /// 打开/关闭指定uid的远程用户的声音
                let remoteUid = remoteUids[index] as! String
                trtcCloud.muteRemoteAudio(remoteUid, mute: mute)
                (sender.superview as! LiveSubVideoView).muteAudio(mute)
            }
        }
    }
    
    @IBAction func onShareScreenClicked(_ sender: NSButton) {
        if NSControl.StateValue.on == sender.state { /// 开启屏幕分享
            let captureSources = trtcCloud.getScreenCaptureSources(withThumbnailSize: CGSize(width: 10, height: 10),
                                                                            iconSize: CGSize(width: 10, height: 10))
            let windowSource = captureSources?.filter({ (sourceInfo) -> Bool in
                return TRTCScreenCaptureSourceType.screen == sourceInfo.type
            }).first
            if nil != windowSource {
                trtcCloud.selectScreenCaptureTarget(windowSource,
                                                    rect: CGRect(x: 0, y: 0, width: 0, height: 0),
                                                    capturesCursor: true, highlight: true)
                trtcCloud.startScreenCapture(nil)
            }
        } else { ///停止屏幕分享
            trtcCloud.stopScreenCapture()
        }
        sender.image = TRTC_DEMO_SCREENSHARE_ICON[sender.state]!
    }
    
    @IBAction func onDashboardClicked(_ sender: NSButton) {
        /// 显示调试信息
        if NSControl.StateValue.on == sender.state {
            trtcCloud.showDebugView(2)
        } else {
            trtcCloud.showDebugView(0)
        }
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
        for i in from..<remoteVideoViews.subviews.count {
            let remoteVideoView = remoteVideoViews.subviews[i] as! LiveSubVideoView
            
            if i < remoteUids.count {
                let remoteUid = remoteUids[i] as! String
                remoteVideoView.reset(with: remoteUid)
                remoteVideoView.isHidden = false
                /// 开始显示用户remoteUid的视频画面
                trtcCloud.startRemoteView(remoteUid, view: remoteVideoView.videoView)
            } else {
                remoteVideoView.reset()
                remoteVideoView.isHidden = true
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
    }
    
    /// 有用户进入当前视频直播房间
    func onRemoteUserEnterRoom(_ userId: String) {
        roomManager.onRemoteUserEnterRoom(userId: userId)
    }
    
    /// 有用户离开当前视频直播房间
    func onRemoteUserLeaveRoom(_ userId: String, reason: Int) {
        roomManager.onRemoteUserLeaveRoom(userId: userId)
    }
    
    /**
     * 当前房间里的其他用户开启/关闭屏幕分享时会收到这个回调
     */
    func onUserSubStreamAvailable(_ userId: String, available: Bool) {
        if available {
            if nil == remoteScreenController {
                let storyboard = NSStoryboard.init(name: "Live", bundle: nil)
                remoteScreenController = storyboard.instantiateController(withIdentifier: "ShareScreenWindowControllerId") as? NSWindowController
            }
            let vc = remoteScreenController?.contentViewController
            trtcCloud.startRemoteSubStreamView(userId, view: vc!.view)
            remoteScreenController?.showWindow(nil)
        } else {
            trtcCloud.stopRemoteSubStreamView(userId)
            remoteScreenController?.close()
        }
    }
}
