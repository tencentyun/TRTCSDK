//
//  CustomCaptureViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import TXLiteAVSDK_TRTC
import UIKit

let MAX_REMOTE_USER_NUM_CC = 6

/// 使用本地视频通话。
class CustomCaptureViewController: UIViewController {
    
    @IBOutlet var remoteVideoViews: [UIView]!
    @IBOutlet var localVideoView: UIImageView!
    @IBOutlet var roomIdLabel: UILabel!
    
    var roomId: UInt32?
    var userId: String?
    
    private lazy var remoteUids = NSMutableOrderedSet.init(capacity: MAX_REMOTE_USER_NUM)
    
    /// 从本地视频采样
    public var localVideoAsset: AVAsset?
    private lazy var videoCaptureTester:TestSendCustomVideoData = {
        let videoCapture = TestSendCustomVideoData.init(trtcCloud: self.trtcCloud, mediaAsset: self.localVideoAsset ?? AVAsset())
        return videoCapture
    }()
    private lazy var renderTester:TestRenderVideoFrame = TestRenderVideoFrame()
    
    private lazy var trtcCloud: TRTCCloud = {
        let instance: TRTCCloud = TRTCCloud.sharedInstance()
        ///设置TRTCCloud的回调接口
        instance.delegate = self;
        return instance;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomIdLabel.text = "\(roomId!)"
        
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
        beautyManager.setBeautyStyle(TXBeautyStyle.nature)
        beautyManager.setBeautyLevel(5)
        beautyManager.setWhitenessLevel(1)
        
        /// 调整仪表盘显示位置
        trtcCloud.setDebugViewMargin(userId ?? "", margin: TXEdgeInsets.init(top: 80, left: 0, bottom: 0, right: 0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if let _ = localVideoAsset {
            /// 设置使用自定义视频
            _ = videoCaptureTester //初始化
            trtcCloud.enableCustomVideoCapture(true)
            trtcCloud.enableCustomAudioCapture(true)
            trtcCloud.setLocalVideoRenderDelegate(renderTester, pixelFormat: ._NV12, bufferType: .pixelBuffer)
            renderTester.addUser(nil, videoView: localVideoView)
            videoCaptureTester.start()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
        
    deinit {
        TRTCCloud.destroySharedIntance()
    }
    
    @IBAction func onExitRoomClicked(_ sender: UIButton) {
        /// 退出视频通话房间
        trtcCloud.exitRoom()
        navigationController?.popViewController(animated: true)
    }
}

extension CustomCaptureViewController: TRTCCloudDelegate {
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
        for i in from..<remoteVideoViews.count {
            if i < remoteUids.count {
                let remoteUid = remoteUids[i] as! String
                remoteVideoViews[i].isHidden = false
                /// 开始显示用户remoteUid的视频画面
                trtcCloud.startRemoteView(remoteUid, view: remoteVideoViews[i])
            } else {
                remoteVideoViews[i].isHidden = true
            }
        }
    }
}
