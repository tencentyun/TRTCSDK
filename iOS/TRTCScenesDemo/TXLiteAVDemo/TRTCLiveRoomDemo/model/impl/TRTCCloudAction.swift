//
//  TRTCCloudAction.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/8.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

let trtcLivePlayTimeOut: Double = 5

class TRTCCloudAction: NSObject {
    
    /// 播放回调存储
    private var playCallBackMap: [String: TRTCLiveRoomImpl.Callback] = [:]
    private var userPlayInfo = [String: PlayInfo]()
    var roomId: String?
    
    private var userId: String?
    private var urlDomain: String?
    private var sdkAppId = SDKAPPID
    private var userSig: String?
    var curRoomUUID: String? = nil
    
    /// 是否进房标志，避免重复进房
    private var isEnterRoom: Bool = false
    
    @objc public var beautyManager: TXBeautyManager {
        get {
            return TRTCCloud.sharedInstance()!.getBeautyManager()
        }
    }
    
    func setup(userId: String, urlDomain: String?, sdkAppId: Int, userSig: String) {
        self.userId = userId
        self.urlDomain = urlDomain
        self.sdkAppId = Int32(sdkAppId)
        self.userSig = userSig
    }
    
    func reset() {
        userId = nil
        urlDomain = nil
        sdkAppId = 0
        userSig = nil
    }
    
    func enterRoom(roomID: String, userId: String, role: TRTCRoleType) {
        guard let userSig = userSig, sdkAppId != 0, !isEnterRoom  else {
            return
        }
        isEnterRoom = true
        curRoomUUID = UUID().uuidString
        let params = TRTCParams()
        params.sdkAppId = UInt32(sdkAppId)
        params.userSig = userSig
        params.userId = userId
        params.roomId = UInt32(roomID) ?? 0
        params.role = role
        TRTCCloud.sharedInstance()?.enterRoom(params, appScene: .LIVE)
    }
    
    func switchRole(role: TRTCRoleType) {
        TRTCCloud.sharedInstance()?.switch(role)
    }
    
    func exitRoom() {
        playCallBackMap.removeAll()
        TRTCCloud.sharedInstance()?.exitRoom()
        isEnterRoom = false
        curRoomUUID = nil
    }
    
    func setupVideoParam(isOwner: Bool) {
        let videoParam = TRTCVideoEncParam()
        if isOwner {
            videoParam.videoResolution = ._960_540
            videoParam.videoBitrate = 1200
            videoParam.videoFps = 15
        } else {
            videoParam.videoResolution = ._480_270
            videoParam.videoBitrate = 400
            videoParam.videoFps = 15
        }
        TRTCCloud.sharedInstance()?.setVideoEncoderParam(videoParam)
    }
    
    /// 本地预览
    /// - Parameters:
    ///   - frontCamera: 前置摄像头/后置摄像头
    ///   - view: 渲染 view
    func startLocalPreview(frontCamera: Bool, view: UIView) {
        TRTCCloud.sharedInstance()?.startLocalPreview(frontCamera, view: view)
    }
    
    /// 停止本地预览
    func stopLocalPreview() {
        TRTCCloud.sharedInstance()?.stopLocalPreview()
    }
    
    /// 推流
    /// - Parameter streamID: 推流id
    func startPublish(streamID: String?) {
        guard let userId = userId, let roomId = roomId else { return }
        enterRoom(roomID: roomId, userId: userId, role: .anchor)
        TRTCCloud.sharedInstance()?.startLocalAudio()
        if let streamId = streamID, !streamId.isEmpty {
            TRTCCloud.sharedInstance()?.startPublishing(streamId, type: .big)
        }
    }
    
    /// 结束推流
    func stopPublish() {
        TRTCCloud.sharedInstance()?.stopLocalAudio()
        TRTCCloud.sharedInstance()?.stopPublishCDNStream()
    }
    
    func startPlay(userID: String, streamID: String?, view: UIView, usesCDN: Bool, roomId: String? = nil, callback: TRTCLiveRoomImpl.Callback? = nil) {
        if let _ = userPlayInfo[userID] {
            callback?(-1, "请勿重复播放")
            return
        }
        
        let playInfo = PlayInfo(videoView: view, streamId: streamID, roomId: roomId)
        userPlayInfo[userID] = playInfo
        
        if usesCDN {
            if let streamId = streamID, let call = callback {
                playCallBackMap[streamId] = call
            }
            startCdnPlay(playInfo.cdnPlayer, streamId: streamID, view: view)
        } else {
            if let call = callback {
                playCallBackMap[userID] = call
            }
            TRTCCloud.sharedInstance()?.startRemoteView(userID, view: view)
            DispatchQueue.main.asyncAfter(deadline: .now() + trtcLivePlayTimeOut) { [id = curRoomUUID] in
                if id == self.curRoomUUID {
                    self.playCallBack(userId: userID, code: -1, message: "超时未播放")
                }
            }
        }
    }
    
    func startTrtcPlay(userId: String) {
        if let view = userPlayInfo[userId]?.videoView {
            TRTCCloud.sharedInstance()?.startRemoteView(userId, view: view)
        }
    }
    
    func stopPlay(userId: String, usesCDN: Bool) {
        guard let userInfo = userPlayInfo[userId] else { return }
        if usesCDN {
            if let streamId = userInfo.streamId {
                playCallBack(userId: streamId, code: -1, message: "停止播放")
            }
            stopCdnPlay(userInfo.cdnPlayer)
        } else {
            playCallBack(userId: userId, code: -1, message: "停止播放")
            TRTCCloud.sharedInstance()?.stopRemoteView(userId)
        }
        userPlayInfo[userId] = nil
    }
    
    func stopAllPlay(usesCDN: Bool) {
        if usesCDN {
            userPlayInfo.values.forEach { info in
                stopCdnPlay(info.cdnPlayer)
            }
        } else {
            TRTCCloud.sharedInstance()?.stopAllRemoteView()
        }
        userPlayInfo.removeAll()
    }
    
    func onFirstVideoFrame(userId: String) {//首帧画面进入
        playCallBack(userId: userId, code: 0, message: nil)
    }
    
    /// startPlay 回调
    /// - Parameters:
    ///   - userId: 用户标志
    ///   - code: 代码
    ///   - message: 信息
    func playCallBack(userId: String, code: Int, message: String?) {
        if let call = playCallBackMap[userId] {
            playCallBackMap.removeValue(forKey: userId)
            call(code, message)
        }
    }
    
    func togglePlay(usesCDN: Bool) {
        if usesCDN {
            exitRoom()
            userPlayInfo.forEach { (userId, info) in
                startCdnPlay(info.cdnPlayer, streamId: info.streamId, view: info.videoView)
            }
        } else {
            userPlayInfo.forEach { (userId, info) in
                stopCdnPlay(info.cdnPlayer)
            }
            switchRole(role: .audience)
        }
    }
    
    func isUserPlaying(_ userId: String) -> Bool {
        return userPlayInfo[userId] != nil
    }
    
    func startRoomPK(roomId: String, userId: String) {
        let params = [ "strRoomId": roomId, "userId": userId ]
        TRTCCloud.sharedInstance()?.connectOtherRoom(params.toJsonString())
    }
    
    func updateMixingParams(shouldMix: Bool) {
        guard let userId = userId else { return }
        
        if !shouldMix || userPlayInfo.count == 0 {
            TRTCCloud.sharedInstance()?.setMix(nil)
            return
        }
        
        let config = TRTCTranscodingConfig()
        config.appId = sdkAppId
        config.videoWidth = 544
        config.videoHeight = 960
        config.videoGOP = 1
        config.videoFramerate = 15
        config.videoBitrate = 1000
        config.audioSampleRate = 48000
        config.audioBitrate = 64
        config.audioChannels = 1
        
        var users = [TRTCMixUser]()
        var index = 0
        
        let me = TRTCMixUser()
        me.userId = userId
        me.zOrder = Int32(index)
        me.rect = CGRect(x: 0, y: 0, width: 544, height: 960)
        
        users.append(me)
        users.append(contentsOf: userPlayInfo.map { (userId, info) -> TRTCMixUser in
            index += 1
            let user = TRTCMixUser()
            user.userId = userId
            user.zOrder = Int32(index)
            user.rect = rect(with: index, width: 160, height: 288, padding: 10)
            user.roomID = info.roomId
            return user
        })
        config.mixUsers = users
        TRTCCloud.sharedInstance()?.setMix(config)
    }
    
    func rect(with index: Int, width: Int, height: Int, padding: Int) -> CGRect {
        let subWidth = (width - padding * 2) / 3
        let subHeight = (height - padding * 2) / 3
        let x = (9 - index) % 3 * (subWidth + padding)
        let y = (9 - index) / 3 * (subHeight + padding)
        return CGRect(x: x, y: y, width: subWidth, height: subHeight)
    }
    
    func cdnUrlForUser(_ userId: String, roomId: String) -> String {
        guard sdkAppId != 0 else { return "" }
        return "\(sdkAppId)_\(roomId)_\(userId)_main.flv"
    }
}

private extension TRTCCloudAction {
    func startCdnPlay(_ cdnPlayer: TXLivePlayer, streamId: String?, view: UIView) {
        guard let urlDomain = urlDomain, let streamId = streamId else { return }
        let streamUrl = urlDomain.last == "/" ? urlDomain + streamId : urlDomain + "/" + streamId + ".flv"
        cdnPlayer.setupVideoWidget(view.bounds, contain: view, insert: 0)
        let trtcCdnDelegate = TRTCCloudCdnDelegate(streamId: streamId)
        trtcCdnDelegate.action = self
        cdnPlayer.delegate = trtcCdnDelegate
        let result = cdnPlayer.startPlay(streamUrl, type: .PLAY_TYPE_LIVE_FLV)
        if result != 0 {
            playCallBack(userId: streamId, code: Int(result), message: "播放失败")
        }
    }
    
    func stopCdnPlay(_ cdnPlayer: TXLivePlayer) {
        cdnPlayer.delegate = nil
        cdnPlayer.stopPlay()
        cdnPlayer.removeVideoWidget()
    }
    
    class TRTCCloudCdnDelegate: NSObject, TXLivePlayListener {
        var streamId: String
        weak var action: TRTCCloudAction? = nil
        init(streamId: String) {
            self.streamId = streamId
            super.init()
        }
        
        func onPlayEvent(_ EvtID: Int32, withParam param: [AnyHashable : Any]!) {
            if EvtID == PLAY_EVT_RCV_FIRST_I_FRAME.rawValue { //播放成功
                action?.playCallBack(userId: streamId, code: 0, message: nil)
                action = nil
            } else if EvtID < 0 {
                action?.playCallBack(userId: streamId, code: -1, message: nil)
                action = nil
            }
        }
        
        func onNetStatus(_ param: [AnyHashable : Any]!) {
            
        }
    }
}

extension TRTCCloudAction {
    @objc public func setFilter(image: UIImage) {
        TRTCCloud.sharedInstance()?.setFilter(image)
    }
    
    @objc public func setFilterConcentration(concentration: Float) {
        TRTCCloud.sharedInstance()?.setFilterConcentration(concentration)
    }
    
    @objc public func setGreenScreenFile(file: URL?) {
        TRTCCloud.sharedInstance()?.setGreenScreenFile(file)
    }
}

private class PlayInfo: NSObject {
    var videoView: UIView
    var streamId: String?
    let roomId: String?
    
    required init(videoView: UIView, streamId: String?, roomId: String?) {
        self.videoView = videoView
        self.streamId = streamId
        self.roomId = roomId
        super.init()
    }
    
    lazy var cdnPlayer: TXLivePlayer = {
        let player = TXLivePlayer()
        return player
    }()
}
