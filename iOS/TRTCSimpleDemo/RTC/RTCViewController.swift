//
//  RTCViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import TXLiteAVSDK_TRTC
import UIKit

let MAX_REMOTE_USER_NUM = 6

/**
 * RTC视频通话的主页面
 *
 * 包含如下简单功能：
 * - 进入/退出视频通话房间
 * - 切换前置/后置摄像头
 * - 打开/关闭摄像头
 * - 打开/关闭麦克风
 * - 显示房间内其他用户的视频画面（当前示例最多可显示6个其他用户的视频画面）
 */
class RTCViewController: UIViewController {
    
    @IBOutlet var remoteVideoViews: [UIView]!
    @IBOutlet var roomIdLabel: UILabel!
    
    var roomId: UInt32?
    var userId: String?
    
    private var isFrontCamera: Bool = true
    private lazy var remoteUids = NSMutableOrderedSet.init(capacity: MAX_REMOTE_USER_NUM)
    
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
        param.sdkAppId = UInt32(_SDKAppID)
        param.roomId   = roomId!
        param.userId   = userId!
        param.role     = TRTCRoleType.anchor
        /// userSig是进入房间的用户签名，相当于密码（这里生成的是测试签名，正确做法需要业务服务器来生成，然后下发给客户端）
        param.userSig  = GenerateTestUserSig.genTestUserSig(param.userId)
        /// 指定以“视频通话场景”（TRTCAppScene.videoCall）进入房间
        trtcCloud.enterRoom(param, appScene: TRTCAppScene.videoCall)
        
        /**
         * 设置默认美颜效果（美颜效果：自然，美颜级别：5, 美白级别：1）
         * 视频通话场景推荐使用“自然”美颜效果
         */
        let beautyManager = trtcCloud.getBeautyManager()
        beautyManager?.setBeautyStyle(TXBeautyStyle.nature)
        beautyManager?.setBeautyLevel(5)
        beautyManager?.setWhitenessLevel(1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        /// 开启麦克风采集
        trtcCloud.startLocalAudio()
        /// 开启摄像头采集
        trtcCloud.startLocalPreview(isFrontCamera, view: view)
    }
    
    deinit {
        TRTCCloud.destroySharedIntance()
    }
    
    @IBAction func onExitRoomClicked(_ sender: UIButton) {
        /// 退出视频通话房间
        trtcCloud.exitRoom()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onVideoCaptureClicked(_ sender: UIButton) {
        if sender.isSelected { /// 开启摄像头采集
            trtcCloud.startLocalPreview(isFrontCamera, view: view)
        } else { /// 关闭摄像头采集
            trtcCloud.stopLocalPreview()
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func onMicCaptureClicked(_ sender: UIButton) {
        if sender.isSelected { /// 开启麦克风采集
            trtcCloud.startLocalAudio()
        } else { /// 关闭麦克风采集
            trtcCloud.stopLocalAudio()
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func onSwitchCameraClicked(_ sender: UIButton) {
        /// 切换前置/后置摄像头
        trtcCloud.switchCamera()
        isFrontCamera = sender.isSelected
        sender.isSelected = !sender.isSelected
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
