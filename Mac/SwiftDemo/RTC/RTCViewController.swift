//
//  RTCViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

import TXLiteAVSDK_TRTC_Mac
import Cocoa

let MAX_REMOTE_USER_NUM = 6

/**
 * RTC视频通话的主页面
 *
 * 包含如下简单功能：
 * - 进入/退出视频通话房间
 * - 打开/关闭摄像头
 * - 打开/关闭麦克风
 * - 打开/关闭屏幕分享
 * - 显示房间内其他用户的视频画面（当前示例最多可显示6个其他用户的视频画面）
 */
class RTCViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet var remoteVideoView: NSView!
    @IBOutlet var localVideoView: NSView!
    /// 屏幕分享画面的显示窗口
    var remoteScreenController: NSWindowController?
    
    var roomId: UInt32?
    var userId: String?
    
    private lazy var remoteUids = NSMutableOrderedSet.init(capacity: MAX_REMOTE_USER_NUM)
    
    private lazy var trtcCloud: TRTCCloud = {
        let instance: TRTCCloud = TRTCCloud.sharedInstance()
        ///设置TRTCCloud的回调接口
        instance.delegate = self;
        return instance;
    }()
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.delegate = self
        view.window?.title = "视频通话--房间\(roomId!)"
        
        /**
         * 设置参数，进入视频通话房间
         * 房间号param.roomId，当前用户id param.userId
         * param.role 指定以什么角色进入房间（anchor主播，audience观众）
         */
        let param = TRTCParams.init()
        param.sdkAppId = UInt32(SDKAppID)
        param.roomId   = roomId!
        param.userId   = userId!
        param.role     = TRTCRoleType.anchor
        /// userSig是进入房间的用户签名，相当于密码（这里生成的是测试签名，正确做法需要业务服务器来生成，然后下发给客户端）
        param.userSig  = GenerateTestUserSig.genTestUserSig(param.userId)
        /// 指定以“视频通话场景”（TRTCAppScene.videoCall）进入房间
        trtcCloud.enterRoom(param, appScene: TRTCAppScene.videoCall)
        
        /// 设置视频通话的画质（帧率 15fps，码率550, 分辨率 360*640）
        let videoEncParam = TRTCVideoEncParam.init()
        videoEncParam.videoResolution = TRTCVideoResolution._640_360
        videoEncParam.videoBitrate = 550
        videoEncParam.videoFps = 15
        trtcCloud.setVideoEncoderParam(videoEncParam)
        
        /**
         * 设置默认美颜效果（美颜效果：自然，美颜级别：5, 美白级别：1）
         * 视频通话场景推荐使用“自然”美颜效果
         */
        let beautyManager = trtcCloud.getBeautyManager()
        beautyManager?.setBeautyStyle(TXBeautyStyle.nature)
        beautyManager?.setBeautyLevel(5)
        beautyManager?.setWhitenessLevel(1)
        
        /// 开启麦克风采集
        trtcCloud.startLocalAudio()
        /// 开启摄像头采集
        trtcCloud.startLocalPreview(localVideoView)
    }
    
    func windowWillClose(_ notification: Notification) {
        /// 关闭窗口，退出视频通话房间
        trtcCloud.exitRoom()
        remoteScreenController?.close()
    }
    
    deinit {
        TRTCCloud.destroySharedIntance()
    }
    
    @IBAction func onExitRoomClicked(_ sender: NSButton) {
        view.window?.close()
    }
    
    @IBAction func onVideoCaptureClicked(_ sender: NSButton) {
        if NSControl.StateValue.on == sender.state { /// 关闭摄像头采集
            trtcCloud.stopLocalPreview()
        } else { /// 开启摄像头采集
            trtcCloud.startLocalPreview(localVideoView)
        }
        sender.image = TRTC_DEMO_CAMERA_ICON[sender.state]!
    }
    
    @IBAction func onMicCaptureClicked(_ sender: NSButton) {
        if NSControl.StateValue.on == sender.state { /// 关闭麦克风采集
            trtcCloud.stopLocalAudio()
        } else { /// 开启麦克风采集
            trtcCloud.startLocalAudio()
        }
        sender.image = TRTC_DEMO_MIC_ICON[sender.state]!
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

extension RTCViewController: TRTCCloudDelegate {
    /**
     * 当前视频通话房间里的其他用户开启/关闭摄像头时会收到这个回调
     * 此时可以根据这个用户的视频available状态来 “显示或者关闭” Ta的视频画面
     */
    func onUserVideoAvailable(_ userId: String, available: Bool) {
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
        for i in from..<remoteVideoView.subviews.count {
            if i < remoteUids.count {
                let remoteUid = remoteUids[i] as! String
                remoteVideoView.subviews[i].isHidden = false
                /// 开始显示用户remoteUid的视频画面
                trtcCloud.startRemoteView(remoteUid, view: remoteVideoView.subviews[i])
            } else {
                remoteVideoView.subviews[i].isHidden = true
            }
        }
    }
    
    /**
     * 当前房间里的其他用户开启/关闭屏幕分享时会收到这个回调
     */
    func onUserSubStreamAvailable(_ userId: String, available: Bool) {
        if available {
            if nil == remoteScreenController {
                let storyboard = NSStoryboard.init(name: "RTC", bundle: nil)
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
