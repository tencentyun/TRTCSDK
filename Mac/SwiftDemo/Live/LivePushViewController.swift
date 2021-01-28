//
//  LivePushViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

import TXLiteAVSDK_TRTC_Mac
import Cocoa

struct LiveVideoConfig {
    var bitrate: Int32 = 850
    var resolutionName = "高清"
    var resolutionDesc = "高清：540*960"
    var resolution = TRTCVideoResolution._960_540
}

/**
 * 主播视角下的RTC视频互动直播房间页面
 *
 * 包含如下简单功能：
 * - 进入/退出直播房间
 * - 打开/关闭摄像头
 * - 打开/关闭麦克风
 * - 打开/关闭屏幕分享
 * - 切换视频直播的画质（标清、高清、超清）
 * - 显示房间内连麦用户的视频画面（当前示例最多可显示6个连麦用户的视频画面）
 * - 打开/关闭连麦用户的声音和视频画面
 */
class LivePushViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet var resolutionListView: NSScrollView!
    @IBOutlet var resolutionButton: NSButton!
    @IBOutlet var remoteVideoViews: NSView!
    @IBOutlet var localVideoView: NSView!
    /// 屏幕分享画面的显示窗口
    var remoteScreenController: NSWindowController?
    
    var roomId: UInt32 = 0
    var userId: String = ""
    
    /// 直播画质配置参数（标清、高清、超清画质下的码率和分辨率）
    private lazy var videoConfigs: [LiveVideoConfig] = {
        return [
            LiveVideoConfig(bitrate: 900, resolutionName: "标清 ", resolutionDesc: "标清：360*640", resolution: TRTCVideoResolution._640_360),
            LiveVideoConfig(bitrate: 1200, resolutionName: "高清 ", resolutionDesc: "高清：540*960", resolution: TRTCVideoResolution._960_540),
            LiveVideoConfig(bitrate: 1500, resolutionName: "超清 ", resolutionDesc: "超清：720*1280", resolution: TRTCVideoResolution._1280_720)
        ]
    }()
    private lazy var remoteUids = NSMutableOrderedSet.init(capacity: MAX_REMOTE_USER_NUM)
    private let videoEncParam = TRTCVideoEncParam.init()
    
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
        
        /**
         * 设置参数，进入视频直播房间
         * 房间号param.roomId，当前用户id param.userId
         * param.role 指定以TRTCRoleType.anchor（主播角色）进入房间
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
        roomManager.createLiveRoom(roomId: "\(roomId)")
        
        /// 默认设置高清的直播画质（帧率 15fps，码率1200, 分辨率 540*960）
        videoEncParam.videoResolution = TRTCVideoResolution._960_540
        videoEncParam.videoBitrate = 1200
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
        
        /// 开启麦克风采集
        trtcCloud.startLocalAudio()
        /// 开启摄像头采集
        trtcCloud.startLocalPreview(localVideoView)
    }
    
    func windowWillClose(_ notification: Notification) {
        /// 关闭窗口，退出视频通话房间
        trtcCloud.exitRoom()
        remoteScreenController?.close()
        roomManager.destroyLiveRoom(roomId: "\(roomId)")
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
    
    @IBAction func onMuteRemoteVideoClicked(_ sender: NSButton) {
        let index = (sender.superview as! LiveSubVideoView).viewTag
        if index < remoteUids.count {
            /// 打开/关闭指定uid的远程用户的视频画面
            let remoteUid = remoteUids[index] as! String
            let mute = NSControl.StateValue.on == sender.state
            trtcCloud.muteRemoteVideoStream(remoteUid, mute: mute)
            (sender.superview as! LiveSubVideoView).muteVideo(mute)
        }
    }
    
    @IBAction func onMuteRemoteAudioClicked(_ sender: NSButton) {
        let index = (sender.superview as! LiveSubVideoView).viewTag
        if index < remoteUids.count {
            /// 打开/关闭指定uid的远程用户的声音
            let remoteUid = remoteUids[index] as! String
            let mute = NSControl.StateValue.on == sender.state
            trtcCloud.muteRemoteAudio(remoteUid, mute: mute)
            (sender.superview as! LiveSubVideoView).muteAudio(mute)
        }
    }
    
    @IBAction func onResolutionClicked(_ sender: NSButton) {
        if resolutionListView.isHidden {
            if let tableView = resolutionListView.contentView.documentView as? NSTableView {
                tableView.reloadData()
            }
        }
        resolutionListView.isHidden = !resolutionListView.isHidden
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

extension LivePushViewController: TRTCCloudDelegate {
    
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

extension LivePushViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        resolutionButton.title = videoConfigs[row].resolutionName
        resolutionListView.isHidden = true
        /// 切换视频直播的画质（标清、高清、超清）
        videoEncParam.videoResolution = videoConfigs[row].resolution
        videoEncParam.videoBitrate = videoConfigs[row].bitrate
        trtcCloud.setVideoEncoderParam(videoEncParam)
        return false
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return videoConfigs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ResolutionCellId"), owner: nil) as? NSTableCellView
        if row < videoConfigs.count {
            cellView?.textField?.stringValue = videoConfigs[row].resolutionDesc
            if videoConfigs[row].resolution == videoEncParam.videoResolution {
                cellView?.textField?.textColor = NSColor.init(red: 0, green: 166/255.0, blue: 107/255.0, alpha: 1)
            } else {
                cellView?.textField?.textColor = NSColor.white
            }
        }
        return cellView
    }
}
