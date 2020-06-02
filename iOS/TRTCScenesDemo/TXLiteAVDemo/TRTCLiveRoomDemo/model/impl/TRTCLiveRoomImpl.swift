//
//  TRTCLiveRoomImpl.swift
//  TRTCLiveRoom
//
//  Created by Xiaoya Liu on 2020/2/7.
//  Copyright © 2020 Xiaoya Liu. All rights reserved.
//

import UIKit

/// 发送请求等待回复超时时间
let trtcLiveSendMsgTimeOut: Double = 15
/// 接收请求等待处理超时时间
let trtcLiveHandleMsgTimeOut: Double = 10
/// 检查是否进房状态超时时间
let trtcLiveCheckStatusTimeOut: Double = 3

public class TRTCLiveRoomImpl: NSObject, TRTCLiveRoom {
    
    /// trtc 管理实例
    let trtcAction = TRTCCloudAction()
    
    /// 成员管理实例
    let memberManager = TRTCLiveRoomMemberManager()
    
    /// TRTCLiveRoom 回调代理
    @objc public weak var delegate: TRTCLiveRoomDelegate?
    
    /// 当前 TRTCLiveRoom 配置信息
    var config: TRTCLiveRoomConfig?
    
    /// 当前用户
    var me: TRTCLiveUserInfo?
    
    /// PK是否混流
    var mixingPKStream: Bool = true
    
    /// 连麦是否混流
    var mixingLinkMicStream: Bool = true
    
    /// 当前房间信息
    var curRoomInfo: TRTCLiveRoomInfo?
    
    /// 美颜管理实例
    @objc private var beautyManager: TXBeautyManager {
        get {
            return trtcAction.beautyManager
        }
    }
    
    @objc public func getBeautyManager() -> TXBeautyManager {
        return beautyManager
    }
    
    /// BGM管理实例
    @objc private var aeManager = TRTCCustomAudioEffectManagerImpl()
    
    /// 7.3以后版本废弃
    /// - Returns: 音效管理
    public func getCustomAudioEffectManager() -> TRTCCustomAudioEffectManagerImpl {
        return aeManager
    }
    
    public func getAudioEffectManager() -> TXAudioEffectManager? {
        return TRTCCloud.sharedInstance()?.getAudioEffectManager()
    }
    
    
    /// 当前房间状态，详情见 TRTCLiveRoomLiveStatus
    var status: TRTCLiveRoomLiveStatus = .none {
        didSet {
            if status != oldValue {
                if let roomInfo = self.curRoomInfo {
                    self.curRoomInfo?.roomStatus = status
                    delegate?.trtcLiveRoom?(self, onRoomInfoChange: roomInfo)
                } else {
                    let roomInfo = TRTCLiveRoomInfo(roomId: roomID ?? "",
                                                roomName: "",
                                                coverUrl: "",
                                                ownerId: me?.userId ?? "",
                                                ownerName: me?.userName ?? "",
                                                streamUrl: "\(me?.userId ?? "")_stream",
                                                memberCount: memberManager.audience.count,
                                                roomStatus: status)
                    delegate?.trtcLiveRoom?(self, onRoomInfoChange: roomInfo)
                }
            }
        }
    }
    
    /// 当前 trtc 房间ID
    var roomID: String? { return trtcAction.roomId }
    
    /// 当前房间的主播信息
    var ownerId: String? { return memberManager.ownerId }
    
    /// 进房回调
    var enterRoomCallback: Callback?
    
    /// 请求连麦回调
    var requestJoinAnchorCallback: ResponseCallback?
    
    /// 请求PK回调
    var requestRoomPKCallback: ResponseCallback?
    
    /// 记录PK信息实例
    var pkAnchorInfo = TRTCPKAnchorInfo()
    
    /// 记录连麦信息实例
    var joinAnchorInfo = TRTCJoinAnchorInfo()
    
    public override init() {
        super.init()
        memberManager.delegate = self
        TRTCCloud.sharedInstance()?.delegate = self
    }
    
    deinit {
        print("[Release] - TRTCLiveRoomImpl")
    }
    
    // MARK: - 用户
    
    public func login(sdkAppID: Int,
                      userID: String,
                      userSig: String,
                      config: TRTCLiveRoomConfig,
                      callback: TRTCLiveRoomImpl.Callback?) {
        logApi("login", data: sdkAppID, userID, userSig, config)
        guard TRTCLiveRoomIMAction.setupSdk(sdkAppId: Int32(sdkAppID), userSig: userSig, messageLister: self) else {
            callback?(-1, "IM初始化失败")
            return
        }
        TRTCLiveRoomIMAction.login(userID: userID, userSig: userSig) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if (code == 0) {
                let user = TRTCLiveUserInfo()
                user.userId = userID
                self.me = user
                self.config = config
                self.trtcAction.setup(userId: userID,
                                      urlDomain: config.cdnPlayDomain,
                                      sdkAppId: sdkAppID,
                                      userSig: userSig)
            }
            callback?(0, "")
        }
    }
    
    public func logout(_ callback: TRTCLiveRoomImpl.Callback?) {
        logApi("logout")
        TRTCLiveRoomIMAction.logout { [weak self] (code, message) in
            // 无论是否登出成功，都会清理本地信息
            self?.me = nil
            self?.config = nil
            self?.trtcAction.reset()
            callback?(code, message)
            TRTCLiveRoomIMAction.releaseSdk()
        }
    }
    
    public func setSelfProfile(name: String, avatarURL: String?, callback: TRTCLiveRoomImpl.Callback?) {
        logApi("setSelfProfile", data: name, avatarURL)
        guard let me = checkUserLogined(callback) else { return }
        
        me.avatarURL = avatarURL
        me.userName = name
        TRTCLiveRoomIMAction.setProfile(name: name, avatar: avatarURL) { [weak self] (code, message) in
            if (code == 0) {
                self?.memberManager.updateProfile(me.userId, name: name, avatar: avatarURL)
            }
            callback?(code, message)
        }
    }
    
    // MARK: - 房间
    
    public func createRoom(roomID: UInt32, roomParam: TRTCCreateRoomParam, callback: TRTCLiveRoomImpl.Callback?) {
        logApi("createRoom", data: roomID, roomParam.roomName)
        guard let me = checkUserLogined(callback) else { return }
        guard checkRoomUnjoined(callback) else { return }
        
        curRoomInfo = TRTCLiveRoomInfo(roomId: String(roomID),
                                       roomName: roomParam.roomName,
                                       coverUrl: roomParam.coverUrl,
                                       ownerId: me.userId,
                                       ownerName: me.userName,
                                       streamUrl: "\(me.userId)_stream",
                                       memberCount: 0,
                                       roomStatus: .single)
        
        TRTCLiveRoomIMAction.createRoom(roomID: String(roomID), roomParam: roomParam, success: { [weak self] (members, groupInfo, _) in
            guard let self = self else { return }
            self.status = .single
            self.trtcAction.roomId = String(roomID)
            self.memberManager.setMembers(members, groupInfo: groupInfo)
            self.memberManager.setOwner(me)
            callback?(0,"")
        }, error: callback)
    }
    
    public func destroyRoom(callback: TRTCLiveRoomImpl.Callback?) {
        logApi("destroyRoom")
        guard let _ = checkUserLogined(callback) else { return }
        guard let roomID = checkRoomJoined(callback) else { return }
        guard checkIsOwner(callback) else { return }
        
        reset()
        TRTCLiveRoomIMAction.destroyRoom(roomID: roomID, callback: callback)
    }
    
    public func enterRoom(roomID: UInt32, callback: TRTCLiveRoomImpl.Callback?) {
        logApi("enterRoom", data: roomID)
        guard let me = checkUserLogined(callback) else { return }
        guard checkRoomUnjoined(callback) else { return }
        
        /// im 进房
        /// - Parameter callback: 进房回调
        func imEnter(callback: TRTCLiveRoomImpl.Callback?) {
            TRTCLiveRoomIMAction.enterRoom(roomID: String(roomID), success: { [weak self] (members, customInfo, roomInfo) in
                guard let self = self else { return }
                self.memberManager.setMembers(members, groupInfo: customInfo)
                self.curRoomInfo = roomInfo
                self.status = roomInfo?.roomStatus ?? .single
                callback?(0, "")
                if self.shouldPlayCdn {
                    self.notifyAvailableStreams()
                }
                }, error: callback )
        }
        
        /// trtc 进房
        /// - Parameter callback: 进房回调
        func trtcEnter(callback: TRTCLiveRoomImpl.Callback?) {
            trtcAction.roomId = String(roomID)
            enterRoomCallback = callback
            trtcAction.enterRoom(roomID: String(roomID), userId: me.userId, role: .audience)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [id = trtcAction.curRoomUUID] in //enter room 10s 超时
                if id == self.trtcAction.curRoomUUID, let enterRoomCallback = self.enterRoomCallback {
                    enterRoomCallback(-1, "enterRoom请求超时")
                    self.enterRoomCallback = nil
                }
            }
        }
        
        // cdn 进房需要依赖 IM 进房，trtc 进房通过 trtc 回调，
        // IM 作为辅助并列进行，减短进房时间
        if shouldPlayCdn {
            trtcAction.roomId = String(roomID)
            imEnter(callback: callback)
        } else {
            trtcEnter(callback: callback)
            imEnter{ [weak self] (code, error) in
                guard let self = self else {return}
                if code != 0 {
                     self.delegate?.trtcLiveRoom?(self, onError: code, message: error)
                }
            }
        }
    }
    
    public func exitRoom(callback: TRTCLiveRoomImpl.Callback?) {
        logApi("exitRoom")
        guard let _ = checkUserLogined(callback) else { return }
        guard let roomID = checkRoomJoined(callback) else { return }
        guard !isOwner else {
            callback?(-1, "只有普通成员才能退出房间")
            return
        }
        
        reset()
        TRTCLiveRoomIMAction.exitRoom(roomID: roomID, callback: callback)
    }
    
    public func getRoomInfos(roomIDs: [UInt32], callback: RoomInfoCallback?) {
        logApi("getRoomInfo", data: roomIDs)
        let strRoomIds = roomIDs.map {
            "\($0)"
        }
        TRTCLiveRoomIMAction.getRoomInfo(roomIds: strRoomIds, success: { info in
            var sortInfo: [TRTCLiveRoomInfo] = []
            var resultMap: [String:TRTCLiveRoomInfo] = [:]
            for room in info {
                resultMap[room.roomId] = room
            }
            for roomId in strRoomIds {
                if resultMap.keys.contains(roomId) {
                    if let room = resultMap[roomId] {
                        sortInfo.append(room)
                    }
                }
            }
            callback?(0, "", sortInfo)
        }) { (code, message) in
            callback?(code, message, [])
        }
    }
    
    public func getAnchorList(callback: UserListCallback?) {
        logApi("getAnchorList")
        callback?(0, "", memberManager.anchors.map { $1 })
    }
    
    public func getAudienceList(callback: UserListCallback?) {
        logApi("getAudienceList")
        guard let roomID = checkRoomJoined(nil) else {
            callback?(-1, "没有进入房间", self.memberManager.audience)
            return
        }
        TRTCLiveRoomIMAction.getAllMembers(roomID: roomID, success: { [weak self] (users) in
            guard let self = self else {return}
            for user in users {
                // 此处更新一次观众列表
                if self.memberManager.anchors[user.userId] == nil {
                    self.memberManager.addAudience(user)
                }
            }
            callback?(0, "", self.memberManager.audience)
        }) { [weak self] (code, error) in
            guard let self = self else {return}
            callback?(0, "", self.memberManager.audience)
        }
    }
    
    // MARK: - 推拉流
    
    public func startCameraPreview(frontCamera: Bool, view: UIView, callback: TRTCLiveRoomImpl.Callback?) {
        logApi("startCameraPreview", data: frontCamera, view)
        guard let _ = checkUserLogined(callback) else { return }
        trtcAction.startLocalPreview(frontCamera: frontCamera, view: view)
        callback?(0, "")
    }
    
    public func stopCameraPreview() {
        logApi("stopCameraPreview")
        trtcAction.stopLocalPreview()
    }
    
    public func startPublish(streamID: String?, callback: TRTCLiveRoomImpl.Callback?) {
        logApi("startPublish", data: streamID)
        guard let me = checkUserLogined(callback) else { return }
        guard let roomID = checkRoomJoined(callback) else { return }
        trtcAction.setupVideoParam(isOwner: isOwner)
        trtcAction.startPublish(streamID: streamID)
        
        let streamId = (streamID?.isEmpty ?? true) ? trtcAction.cdnUrlForUser(me.userId, roomId: roomID) : streamID!
        if isOwner {
            memberManager.updateStream(me.userId, streamId: streamId)
            callback?(0, "")
        } else if let ownerId = ownerId {
            // 观众端连麦成功后，将推流的地址发给主播
            trtcAction.switchRole(role: .anchor)
            TRTCLiveRoomIMAction.notifyStreamToAnchor(userID: ownerId, streamId: streamId, callback: callback)
        } else {
            assert(false)
        }
    }
    
    public func stopPublish(callback: TRTCLiveRoomImpl.Callback?) {
        logApi("stopPublish")
        guard let me = checkUserLogined(callback), isAnchor else { return }
        guard let _ = checkRoomJoined(callback) else { return }
        
        trtcAction.stopPublish()
        memberManager.updateStream(me.userId, streamId: nil)
        
        if !isOwner {
            // 观众端结束连麦
            stopCameraPreview()
            switchRoleOnLinkMic(isLinkMic: false)
        } else {
            // 主持人关闭推流
            trtcAction.exitRoom()
        }
    }
    
    public func startPlay(userID: String, view: UIView, callback: TRTCLiveRoomImpl.Callback?) {
        logApi("startPlay", data: userID, view)
        guard let _ = checkUserLogined(callback) else { return }
        guard let _ = checkRoomJoined(callback) else { return }

        if let user = memberManager.pkAnchor, let pkAnchorRoomId = pkAnchorInfo.roomId {
            trtcAction.startPlay(userID: user.userId, streamID: user.streamId, view: view, usesCDN: shouldPlayCdn, roomId: pkAnchorRoomId, callback: callback)
        } else if let user = memberManager.anchors[userID] {
            trtcAction.startPlay(userID: user.userId, streamID: user.streamId, view: view, usesCDN: shouldPlayCdn, callback: callback)
        } else {
            callback?(-1, "未找到该主播")
        }
    }
    
    public func stopPlay(userID: String, callback: TRTCLiveRoomImpl.Callback?) {
        logApi("stopPlay", data: userID)
        
        trtcAction.stopPlay(userId: userID, usesCDN: shouldPlayCdn)
        callback?(0, "")
    }
    
    // MARK: - 连麦
    
    public func requestJoinAnchor(reason: String?,
                                  responseCallback: TRTCLiveRoomImpl.ResponseCallback?) {
        logApi("requestJoinAnchor", data: reason)
        guard let _ = checkUserLogined(nil) else {
            responseCallback?(false, "还未登录")
            return
        }
        guard let _ = checkRoomJoined(nil) else {
            responseCallback?(false, "没有进入房间")
            return
        }
        guard !isAnchor else {
            responseCallback?(false, "当前已经是连麦状态")
            return
        }
        if status == .roomPK || pkAnchorInfo.userId != nil {
            responseCallback?(false, "当前主播正在PK")
            return
        }
        if joinAnchorInfo.userId != nil {
            responseCallback?(false, "当前用户正在等待连麦回复")
            return
        }
        if status == .none {
            responseCallback?(false, "出错请稍候尝试")
            return
        }
        guard let ownerId = ownerId else { fatalError() }

        requestJoinAnchorCallback = responseCallback
        joinAnchorInfo.userId = me?.userId ?? ""
        joinAnchorInfo.uuid = UUID().uuidString
        
        TRTCLiveRoomIMAction.requestJoinAnchor(userID: ownerId, reason: reason, callback: { (code, message) in
            // 只处理失败时的回调，成功的回调要等收到主播的responseJoinAnchor消息
            if (code != 0) {
                responseCallback?(false, message)
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + trtcLiveSendMsgTimeOut) { [id = joinAnchorInfo.uuid] in //连麦发起方检查 15s 内超时回应
            if let callback = self.requestJoinAnchorCallback, id == self.joinAnchorInfo.uuid {
                callback(false, "主播未回应连麦请求")
                self.requestJoinAnchorCallback = nil
                self.clearJoinState()
            }
        }
    }
    
    public func responseJoinAnchor(userID: String, agree: Bool, reason: String?) {
        logApi("responseJoinAnchor", data: userID, agree, reason)
        guard let _ = checkUserLogined(nil), isOwner else { return }
        guard let _ = checkRoomJoined(nil) else { return }
        if joinAnchorInfo.userId == userID {
            joinAnchorInfo.isResponsed = true
            if agree {
                DispatchQueue.main.asyncAfter(deadline: .now() + trtcLiveCheckStatusTimeOut) { [id = joinAnchorInfo.uuid] in //检查 连麦 主播是否进房
                    if self.memberManager.anchors[userID] == nil && id == self.joinAnchorInfo.uuid { //连麦未进房
                        self.kickoutJoinAnchor(userID: userID, callback: nil)
                        self.clearJoinState()
                    } else {
                        self.clearJoinState(shouldRemove: false)
                    }
                }
            } else {
                clearJoinState()
            }
        }
        TRTCLiveRoomIMAction.respondJoinAnchor(userID: userID, agreed: agree, reason: reason, callback: nil)
    }
    
    public func kickoutJoinAnchor(userID: String, callback: TRTCLiveRoomImpl.Callback?) {
        logApi("kickoutJoinAnchor", data: userID)
        guard let _ = checkUserLogined(callback) else { return }
        guard let _ = checkRoomJoined(callback) else { return }
        guard memberManager.anchors[userID] != nil else {
            callback?(-1, "该用户尚未连麦")
            return
        }
        
        TRTCLiveRoomIMAction.kickoutJoinAnchor(userID: userID, callback: callback)
        stopLinkMic(userId: userID)
    }
    
    // MARK: - 跨房PK
    
    public func requestRoomPK(roomID: UInt32,
                              userID: String,
                              responseCallback: TRTCLiveRoomImpl.ResponseCallback?) {
        logApi("requestRoomPK", data: roomID, userID)
        guard let _ = checkUserLogined(nil) else {
            responseCallback?(false, "还未登录")
            return
        }
        guard let myRoomId = checkRoomJoined(nil) else {
            responseCallback?(false, "没有进入房间")
            return
        }
        guard checkIsOwner(nil) else {
            responseCallback?(false, "只有主播才能操作")
            return
        }
        guard let streamId = checkIsPublishing(nil) else {
            responseCallback?(false, "只有推流后才能操作")
            return
        }
        if status == .linkMic || joinAnchorInfo.userId != nil {
            responseCallback?(false, "当前正在连麦中，无法开启PK")
            return
        }
        if status == .roomPK {
            responseCallback?(false, "当前主播正在PK")
            return
        }
        if pkAnchorInfo.userId != nil {
            responseCallback?(false, "当前主播正在等待PK回复")
            return
        }
        if status == .none {
            responseCallback?(false, "出错请稍候尝试")
            return
        }
        requestRoomPKCallback = responseCallback
        pkAnchorInfo.userId = userID
        pkAnchorInfo.roomId = String(roomID)
        pkAnchorInfo.uuid = UUID().uuidString

        TRTCLiveRoomIMAction.requestRoomPK(userID: userID, fromRoomID: myRoomId, fromStreamId: streamId, callback: { (code, message) in
            // 只处理失败时的回调，成功的回调要等收到主播的responseRoomPK消息
            if (code != 0) {
                responseCallback?(false, message)
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + trtcLiveSendMsgTimeOut) { [id = pkAnchorInfo.uuid] in //PK发起方 15s 内超时回应
            if let callback = self.requestRoomPKCallback, id == self.pkAnchorInfo.uuid {
                callback(false, "对方主播未回应跨房PK请求")
                self.requestRoomPKCallback = nil
                self.clearPKState()
            }
        }
    }
    
    public func responseRoomPK(userID: String, agree: Bool, reason: String?) {
        logApi("responseRoomPK", data: userID, agree, reason)
        guard let _ = checkUserLogined(nil) else { return }
        guard let _ = checkRoomJoined(nil) else { return }
        guard checkIsOwner(nil) else { return }
        guard let streamId = checkIsPublishing(nil) else { return }
        
        if pkAnchorInfo.userId == userID {
            pkAnchorInfo.isResponsed = true
            if !agree {
                clearPKState()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + trtcLiveCheckStatusTimeOut) { [id = pkAnchorInfo.uuid] in //检查 PK 主播是否进房
                    if self.status != .roomPK && id == self.pkAnchorInfo.uuid {
                        self.quitRoomPK(callback: nil)
                        self.clearPKState()
                    }
                }
            }
        }
        
        TRTCLiveRoomIMAction.responseRoomPK(userID: userID, agreed: agree, reason: reason, streamId: streamId, callback: nil)
    }
    
    public func quitRoomPK(callback: TRTCLiveRoomImpl.Callback?) {
        logApi("quitRoomPK")
        guard let _ = checkUserLogined(callback), isOwner else { return }
        guard let _ = checkRoomJoined(callback) else { return }
        guard status == .roomPK, let pkAnchor = memberManager.pkAnchor else {
            callback?(-1, "当前不是PK状态")
            return
        }
        pkAnchorInfo.reset()
        status = .single
        TRTCCloud.sharedInstance()?.disconnectOtherRoom()
        memberManager.removeAnchor(pkAnchor.userId)
        TRTCLiveRoomIMAction.quitRoomPK(userID: pkAnchor.userId, callback: callback)
    }
    
    // MARK: - 音视频设置
    
    public func switchCamera() {
        TRTCCloud.sharedInstance()?.switchCamera()
    }
    
    public func setMirror(_ isMirror: Bool) {
        TRTCCloud.sharedInstance()?.setVideoEncoderMirror(isMirror)
    }
    
    public func muteLocalAudio(_ isMuted: Bool) {
        TRTCCloud.sharedInstance()?.muteLocalAudio(isMuted)
    }
    
    public func muteRemoteAudio(userID: String, isMuted: Bool) {
        TRTCCloud.sharedInstance()?.muteRemoteAudio(userID, mute: isMuted)
    }
    
    public func muteAllRemoteAudio(_ isMuted: Bool) {
        TRTCCloud.sharedInstance()?.muteAllRemoteAudio(isMuted)
    }
    
    public func setAudioQuality(_ quality: Int) {
        if 3 == quality {
            TRTCCloud.sharedInstance()?.setAudioQuality(.music)
        } else if 2 == quality {
            TRTCCloud.sharedInstance()?.setAudioQuality(.default)
        } else {
            TRTCCloud.sharedInstance()?.setAudioQuality(.speech)
        }
    }
    
    public func showVideoDebugLog(_ isShow: Bool) {
        TRTCCloud.sharedInstance()?.showDebugView(isShow ? 2 : 0)
    }

    // MARK: - 发送消息
    
    public func sendRoomTextMsg(message: String, callback: TRTCLiveRoomImpl.Callback?) {
        guard let _ = checkUserLogined(callback) else { return }
        guard let roomID = checkRoomJoined(callback) else { return }
        
        TRTCLiveRoomIMAction.sendRoomTextMsg(roomID: roomID, message: message, callback: callback)
    }
    
    public func sendRoomCustomMsg(command: String, message: String, callback: TRTCLiveRoomImpl.Callback?) {
        guard let _ = checkUserLogined(callback) else { return }
        guard let roomID = checkRoomJoined(callback) else { return }
        
        TRTCLiveRoomIMAction.sendRoomCustomMsg(roomID: roomID, command: command, message: message, callback: callback)
    }
}

// MARK: - TRTCCloudDelegate

extension TRTCLiveRoomImpl: TRTCCloudDelegate {
    public func onError(_ errCode: TXLiteAVError, errMsg: String?, extInfo: [AnyHashable : Any]?) {
        delegate?.trtcLiveRoom?(self, onError: Int(errCode.rawValue), message: errMsg)
    }
    
    public func onWarning(_ warningCode: TXLiteAVWarning, warningMsg: String?, extInfo: [AnyHashable : Any]?) {
        delegate?.trtcLiveRoom?(self, onWarning: Int(warningCode.rawValue), message: warningMsg)
    }
    
    public func onEnterRoom(_ result: Int) {
        logApi("onEnterRoom")
        enterRoomCallback?(0, "")
        enterRoomCallback = nil
    }
    
    public func onRemoteUserEnterRoom(_ userId: String) {
        logApi("onRemoteUserEnterRoom", data: userId)
        if shouldPlayCdn { return }
        if joinAnchorInfo.userId == userId {
            clearJoinState(shouldRemove: false)
        }
        // 观众端从CDN播放切到低延时后，对于之前正在播放的视频流，不应再通知给用户，而要在内部转移到低延时播放
        if trtcAction.isUserPlaying(userId) {
            trtcAction.startTrtcPlay(userId: userId)
            return
        }
        
        if isOwner {
            if memberManager.pkAnchor?.userId == userId {
                // 收到PK主播的视频流，开始PK
                status = .roomPK
                memberManager.confirmPKAnchor(userId)
            } else if memberManager.anchors[userId] == nil {
                // 可能是连麦的观众
                status = .linkMic
                addTempAnchor(userId)
            }
            delegate?.trtcLiveRoom?(self, onAnchorEnter: userId)
            trtcAction.updateMixingParams(shouldMix: shouldMixStream)
        } else {
            // 观众在收到主播进房消息前，先收到TRTC的视频流
            if memberManager.anchors[userId] == nil {
                addTempAnchor(userId)
            }
            delegate?.trtcLiveRoom?(self, onAnchorEnter: userId)
        }
    }
    
    public func onRemoteUserLeaveRoom(_ userId: String, reason: Int) {
        logApi("onRemoteUserLeaveRoom", data: userId)
        if shouldPlayCdn { return }
        if isOwner {
            // 判断是否要从连麦或PK状态恢复到normal
            if memberManager.anchors[userId] != nil && memberManager.anchors.count <= 2 {
                if pkAnchorInfo.userId != nil && pkAnchorInfo.roomId != nil {
                    delegate?.trtcLiveRoomOnQuitRoomPK?(self)
                }
                clearPKState()
                clearJoinState()
                status = .single
            }
            memberManager.removeAnchor(userId)
        }
        
        delegate?.trtcLiveRoom?(self, onAnchorExit: userId)
        
        if isOwner {
            trtcAction.updateMixingParams(shouldMix: shouldMixStream)
        }
    }
    
    //play
    public func onFirstVideoFrame(_ userId: String, streamType: TRTCVideoStreamType, width: Int32, height: Int32) {
        trtcAction.onFirstVideoFrame(userId: userId)
    }
}

// MARK: - TRTCLiveRoomMemberManagerDelegate

extension TRTCLiveRoomImpl: TRTCLiveRoomMemberManagerDelegate {
    func memberManager(_ manager: TRTCLiveRoomMemberManager, onUserEnter user: TRTCLiveUserInfo, isAnchor: Bool) {
        if isAnchor {
            if configCdn {
                delegate?.trtcLiveRoom?(self, onAnchorEnter: user.userId)
            }
        } else {
            delegate?.trtcLiveRoom?(self, onAudienceEnter: user)
        }
    }
    
    func memberManager(_ manager: TRTCLiveRoomMemberManager, onUserLeave user: TRTCLiveUserInfo, isAnchor: Bool) {
        if isAnchor {
            delegate?.trtcLiveRoom?(self, onAnchorExit: user.userId)
        } else {
            delegate?.trtcLiveRoom?(self, onAudienceExit: user)
        }
    }
    
    func memberManager(_ manager: TRTCLiveRoomMemberManager, onChangeStreamId streamID: String?, userId: String) {
        // 如果当前是低延时播放，忽略IM通知的主播流变更
        if !shouldPlayCdn { return }
        
        // 主播开启混流时，CDN播放只拉主播的流
        if shouldMixStream && userId != ownerId { return }
        
        if let streamID = streamID, streamID != "" {
            delegate?.trtcLiveRoom?(self, onAnchorEnter: userId)
        } else {
            delegate?.trtcLiveRoom?(self, onAnchorExit: userId)
        }
    }
    
    func memberManager(_ manager: TRTCLiveRoomMemberManager, onChangeAnchorList userList: [[String : Any]]) {
        // 大主播收到主播列表变更的通知后，更新房间信息
        guard isOwner else { return }
        guard let roomID = checkRoomJoined(nil) else { return }
        
        let data: [String: Any] = [ "type": status.rawValue, "list": userList ]
        TRTCLiveRoomIMAction.updateGroupInfo(roomID: roomID, groupInfo: data, callback: nil)
    }
}

// MARK: - Actions

extension TRTCLiveRoomImpl {
    // 观众端进房后，查看可播放的流并回调给用户
    func notifyAvailableStreams() {
        if shouldMixStream {
            if let ownerId = ownerId {
                delegate?.trtcLiveRoom?(self, onAnchorEnter: ownerId)
            }
        } else {
            self.memberManager.anchors.keys.forEach { userId in
                self.delegate?.trtcLiveRoom?(self, onAnchorEnter: userId)
            }
        }
    }
    
    // 处理房间销毁的事件
    func handleRoomDismissed(isOwnerDeleted: Bool) {
        guard let roomID = checkRoomJoined(nil) else { return }

        if isOwner && !isOwnerDeleted {
            destroyRoom(callback: nil)
        } else {
            exitRoom(callback: nil)
        }
        delegate?.trtcLiveRoom?(self, onRoomDestroy: roomID)
    }
    
    // 主播收到观众的连麦请求
    func handleJoinAnchorRequest(from user: TRTCLiveUserInfo, reason: String?) {
        if status == .roomPK || pkAnchorInfo.userId != nil {
            responseJoinAnchor(userID: user.userId, agree: false, reason: "主播正在跨房PK中")
            return
        }
        
        if joinAnchorInfo.userId != nil {
            if joinAnchorInfo.userId != user.userId {
                responseJoinAnchor(userID: user.userId, agree: false, reason: "主播正在处理他人连麦中")
            }
            return
        }
            
        delegate?.trtcLiveRoom?(self, onRequestJoinAnchor: user, reason: reason, timeout: trtcLiveHandleMsgTimeOut)
        joinAnchorInfo.userId = user.userId
        joinAnchorInfo.uuid = UUID().uuidString
        DispatchQueue.main.asyncAfter(deadline: .now() + trtcLiveHandleMsgTimeOut) { [id = joinAnchorInfo.uuid] in //连麦接收方 10s 内回复否则超时
            if !self.joinAnchorInfo.isResponsed && self.joinAnchorInfo.uuid == id {
                self.responseJoinAnchor(userID: user.userId, agree: false, reason: "超时未回应")
                self.clearJoinState()
            }
        }
    }
    
    // 主播收到观众连麦的streamId后，开始连麦
    func startLinkMic(userId: String, streamId: String) {
        status = .linkMic
        memberManager.switchMember(userId, toAnchor: true, streamId: streamId)
    }
    
    // 主播结束某个观众的连麦
    func stopLinkMic(userId: String) {
        status = memberManager.anchors.count <= 2 ? .single : .linkMic
        memberManager.switchMember(userId, toAnchor: false, streamId: nil)
    }
    
    // 观众收到自己的连麦状态后，将自己的身份进行切换，并切换播放方式
    func switchRoleOnLinkMic(isLinkMic: Bool) {
        guard let me = checkUserLogined(nil) else { return }
        memberManager.switchMember(me.userId, toAnchor: isLinkMic, streamId: nil)
        
        // 从低延时切到CDN时，如果房间创建者开了云端混流，通知用户关闭非创建者的流
        if configCdn && shouldMixStream && !isLinkMic {
            memberManager.anchors.forEach { (userId, user) in
                if userId != ownerId && trtcAction.isUserPlaying(userId) {
                    delegate?.trtcLiveRoom?(self, onAnchorExit: userId)
                }
            }
        }
        
        // 将播放的流进行切换
        let usesCdn = configCdn && !isLinkMic
        trtcAction.togglePlay(usesCDN: usesCdn)
    }
    
    // 主播收到其它主播的跨房PK请求
    func handleRoomPKRequest(from user: TRTCLiveUserInfo, roomId: String, streamId: String) {
        if status == .linkMic || joinAnchorInfo.userId != nil {
            responseRoomPK(userID: user.userId, agree: false, reason: "主播正在连麦中")
            return
        }
        if (pkAnchorInfo.userId != nil && pkAnchorInfo.roomId != roomId) || status == .roomPK {
            responseRoomPK(userID: user.userId, agree: false, reason: "主播正在PK中")
            return
        }
        if pkAnchorInfo.userId == user.userId {
            return
        }
        pkAnchorInfo.userId = user.userId
        pkAnchorInfo.roomId = roomId
        pkAnchorInfo.uuid = UUID().uuidString
        prepareRoomPK(with: user, streamId: streamId)
        delegate?.trtcLiveRoom?(self, onRequestRoomPK: user, timeout: trtcLiveHandleMsgTimeOut)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + trtcLiveHandleMsgTimeOut) {[id = pkAnchorInfo.uuid] in //PK接收方 10s 内回复否则超时
            if !self.pkAnchorInfo.isResponsed && self.pkAnchorInfo.uuid == id {
                self.responseRoomPK(userID: user.userId, agree: false, reason: "超时未响应")
                self.clearPKState()
            }
        }
    }
    
    func clearPKState() {
        pkAnchorInfo.reset()
        memberManager.removePKAnchor()
    }
    
    /// 清除当前连麦用户信息
    /// - Parameter shouldRemove: 是否要从主播列表移除
    /// - Note:
    /// - 默认会从主播列表移除
    func clearJoinState(shouldRemove: Bool = true) {
        if shouldRemove, let anchor = joinAnchorInfo.userId {
            memberManager.removeAnchor(anchor)
        }
        joinAnchorInfo.reset()
    }
    
    /// TRTC收到主播的视频流，但该主播尚未从IM获取到
    func addTempAnchor(_ userId: String) {
        let user = TRTCLiveUserInfo()
        user.userId = userId
        memberManager.addAnchor(user)
    }
    
    // 预先保存待PK的主播，等收到视频流后，再确认PK状态
    func prepareRoomPK(with user: TRTCLiveUserInfo, streamId: String) {
        user.streamId = streamId
        memberManager.preparePKAnchor(user)
    }
    
    // 发起PK的主播，收到确认回复后，调到该函数开启跨房PK
    func startRoomPK(with user: TRTCLiveUserInfo, streamId: String) {
        guard let roomId = pkAnchorInfo.roomId else { return }
        prepareRoomPK(with: user, streamId: streamId)
        trtcAction.startRoomPK(roomId: roomId, userId: user.userId)
    }
}

//MARK: - inter struct
extension TRTCLiveRoomImpl {
    struct TRTCPKAnchorInfo {
        /// 用户标识
        var userId: String? = nil
        /// 房间ID
        var roomId: String? = nil
        /// 是否回复
        var isResponsed: Bool = false
        /// UUID
        var uuid: String = ""
        
        mutating func reset() {
            userId = nil
            roomId = nil
            isResponsed = false
            uuid = ""
        }
    }

    struct TRTCJoinAnchorInfo {
        /// 用户标识
        var userId: String? = nil
        /// 是否回复
        var isResponsed: Bool = false
        /// UUID
        var uuid: String = ""
        
        mutating func reset() {
            userId = nil
            isResponsed = false
            uuid = ""
        }
    }
}


//MARK: - Beauty
extension TRTCLiveRoomImpl {
    @objc public func setFilter(image: UIImage) {
        trtcAction.setFilter(image: image)
    }
    
    @objc public func setFilterConcentration(concentration: Float) {
        trtcAction.setFilterConcentration(concentration: concentration)
    }
    
    @objc public func setGreenScreenFile(file: URL?) {
        trtcAction.setGreenScreenFile(file: file)
    }
}

// MARK: - Utils

extension TRTCLiveRoomImpl {
    func logApi(_ api: String, data: Any?...) {
        let log = "[LiveRoom] - API: \(api), params: \(data)"
        NSLog(log)
        delegate?.trtcLiveRoom?(self, onDebugLog: log)
    }
    
    func checkUserLogined(_ callback: TRTCLiveRoomImpl.Callback?) -> TRTCLiveUserInfo? {
        guard let me = me else {
            callback?(-1, "还未登录")
            return nil
        }
        return me
    }
    
    func checkRoomJoined(_ callback: TRTCLiveRoomImpl.Callback?) -> String? {
        guard let roomID = roomID else {
            callback?(-1, "没有进入房间")
            return nil
        }
        return roomID
    }
    
    func checkRoomUnjoined(_ callback: TRTCLiveRoomImpl.Callback?) -> Bool {
        guard roomID == nil else {
            callback?(-1, "当前在房间中")
            return false
        }
        return true
    }
    
    func checkIsOwner(_ callback: TRTCLiveRoomImpl.Callback?) -> Bool {
        guard isOwner else {
            callback?(-1, "只有主播才能操作")
            return false
        }
        return true
    }
    
    func checkIsPublishing(_ callback: TRTCLiveRoomImpl.Callback?) -> String? {
        guard let streamId = me?.streamId else {
            callback?(-1, "只有推流后才能操作")
            return nil
        }
        return streamId
    }
    
    var shouldPlayCdn: Bool {
        return configCdn && !isAnchor
    }
    
    var configCdn: Bool {
        return (config?.useCDNFirst ?? false)
    }
    
    var isOwner: Bool {
        if let userId = me?.userId {
            return userId == memberManager.ownerId
        }
        return false
    }
    
    var isAnchor: Bool {
        if let userId = me?.userId {
            return memberManager.anchors[userId] != nil
        }
        return false
    }
    
    var shouldMixStream: Bool {
        switch status {
        case .none:
            return false
        case .single:
            return false
        case .linkMic:
            return mixingLinkMicStream
        case .roomPK:
            return mixingPKStream
        }
    }
    
    func reset() {
        enterRoomCallback = nil
        trtcAction.exitRoom()
        trtcAction.stopAllPlay(usesCDN: shouldPlayCdn)
        trtcAction.roomId = nil
        status = .none
        clearPKState()
        clearJoinState()
        memberManager.clearMembers()
        curRoomInfo = nil
    }
}
