//
//  TRTCVoiceRoomImp.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/4.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation

@objc
class TRTCVoiceRoomImp: NSObject {
    private static var _instance: TRTCVoiceRoomImp?
    private override init() {
        super.init()
        TXRoomService.getInstance().setDelegate(self)
        VoiceRoomTRTCService.getInstance().setDelegate(self)
    }
    
    @objc
    static func shared() -> TRTCVoiceRoomImp {
        guard let instance = _instance else {
            _instance = TRTCVoiceRoomImp.init()
            return _instance!
        }
        return instance
    }
    
    @objc
    static func destroySharedInstance() {
        _instance?.destroy()
        _instance = nil
    }
    
    // MARK: - 私有属性（set）
    private weak var delegate: TRTCVoiceRoomDelegate?
    private(set) var mSDKAppID: Int32 = 0 // SDK APP ID
    private(set) var userId: String = ""
    private(set) var userSig: String = "" // 用户鉴权签名
    private(set) var roomID: String = ""
    
    private(set) var roomInfo: VoiceRoomInfo?
    private(set) var anchorSeatList: Set<String> = [] // 主播列表
    private(set) var audienceList: Set<String> = [] // 观众列表（以抛出）
    private(set) var seatInfoList: [VoiceRoomSeatInfo] = [] // 座位列表
    private var enterSeatCallback: ActionCallback?
    private var leaveSeatCallback: ActionCallback?
    private var pickSeatCallback: ActionCallback?
    private var kickSeatCallback: ActionCallback?
    private(set) var takeSeatIndex: Int = -1
    
    private var delegateQueue: DispatchQueue = DispatchQueue.main // 默认回调在主线程
    
    private var roomService: TXRoomService {
        return TXRoomService.getInstance()
    }
    
    private var roomTRTCService: VoiceRoomTRTCService {
        return VoiceRoomTRTCService.getInstance()
    }
    
    private func isOnSeat(_ userId: String) -> Bool {
        if self.seatInfoList.count == 0 {
            return false
        }
        for seatInfo in self.seatInfoList {
            if seatInfo.userId == userId {
                return true
            }
        }
        return false
    }
    
    private func runOnMainThread(action: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.async {
            action()
        }
    }
    
    private func runOnDelegateThread(action: @escaping () -> Void) {
        self.delegateQueue.async {
            action()
        }
    }
    
    private func destroy() {
        TXRoomService.getInstance().destroy()
    }
    
    private func clearList() {
        seatInfoList.removeAll()
        anchorSeatList.removeAll()
        audienceList.removeAll()
    }
    
    private func exitRoomInternal(callback: ActionCallback?) {
        roomTRTCService.exitRoom { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code != 0 {
                self.runOnDelegateThread { [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.onError(code: code, message: message)
                }
            }
        }
        TRTCLog.out("start exit room service.")
        roomService.exitRoom { [weak self] (code, message) in
            TRTCLog.out("exit room finish, code + \(code), message: \(message)")
            guard let `self` = self else { return }
            self.runOnDelegateThread {
                callback?(code, message)
            }
        }
        clearList()
        self.roomID = ""
    }
    
    private func getAudienceList(callback: VoiceRoomUserListCallback?) {
        self.runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomService.getAudienceList { (code, message, userList) in
                TRTCLog.out("get audience list finish. code:\(code), message:\(message), userListCount:\(userList.count)")
                self.runOnDelegateThread {
                    let userInfoList = userList.map { (info) -> VoiceRoomUserInfo in
                        let userInfo = VoiceRoomUserInfo.init(userId: info.userId, userName: info.userName, userAvatar: info.avatarURL)
                        return userInfo
                    }
                    callback?(code, message, userInfoList)
                }
            }
        }
    }
    
    private func enterTRTCRoomInner(roomId: String, userId: String, userSig: String, role: Int, callback: ActionCallback?) {
        // 进入TRTC房间
        TRTCLog.out("enter trtc room.")
        roomTRTCService.enterRoom(sdkAppId: mSDKAppID, roomId: roomId, userId: userId, userSign: userSig, role: role) { [weak self] (code, message) in
            guard let `self` = self else { return }
            self.runOnDelegateThread {
                callback?(code, message)
            }
        }
    }
}

// MARK: - TRTCVoiceRoom实现
extension TRTCVoiceRoomImp: TRTCVoiceRoom {
    static func sharedInstance() -> TRTCVoiceRoom {
        return TRTCVoiceRoomImp.shared()
    }
    
    
    func setDelegate(delegate: TRTCVoiceRoomDelegate) {
        self.delegate = delegate
    }
    
    func setDelegateQueue(queue: DispatchQueue) {
        self.delegateQueue = queue
    }
    
    @objc
    public func login(sdkAppID: Int32, userId: String, userSig: String, callback: ActionCallback?) {
        runOnMainThread {
            TRTCLog.out("start login, sdkAppId: \(sdkAppID), userId: \(userId), sig is empty: \(userSig == "")")
            guard sdkAppID != 0 && userId != "" && userSig != "" else {
                TRTCLog.out("start login fail. parms invalid.")
                return
            }
            self.mSDKAppID = sdkAppID
            self.userId = userId
            self.userSig = userSig
            TRTCLog.out("start login room service")
            self.roomService.login(sdkAppId: sdkAppID, userId: userId, userSig: userSig) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.roomService.getSelfInfo()
                self.runOnDelegateThread {
                    callback?(code, message)
                }
            }
        }
    }
    
    public func logout(callback: ActionCallback?) {
        runOnMainThread {
            TRTCLog.out("start logout")
            self.mSDKAppID = 0
            self.userId = ""
            self.userSig = ""
            TRTCLog.out("start logout room service.")
            self.roomService.logout { [weak self] (code, message) in
                guard let `self` = self else { return }
                TRTCLog.out("logout room service finish, code: \(code), msg:\(message)")
                self.runOnDelegateThread {
                     callback?(code, message)
                }
            }
        }
    }
    
    @objc
    public func setSelfProfile(userName: String, avatarURL: String, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("set profile, userName: \(userName), avatarURL: \(avatarURL)")
            self.roomService.setSelfProfile(userName: userName, avatarUrl: avatarURL) { (code, message) in
                 TRTCLog.out("set profile finish, code: \(code), msg:\(message)")
                self.runOnDelegateThread {
                    callback?(code, message)
                }
            }
        }
    }
    
    public func createRoom(roomID: Int, roomParam: VoiceRoomParam, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            // 获取正确的用户名
            self.roomService.getSelfInfo()
            TRTCLog.out("create room, room id: \(roomID), info: \(roomParam)")
            guard roomID != 0 else {
                TRTCLog.out("create room fail. params invalid.")
                return
            }
            self.roomID = "\(roomID)"
            self.clearList()
            let roomName = roomParam.roomName
            let roomCover = roomParam.coverUrl
            let isNeedRequest = roomParam.needRequest
            let seatCount = roomParam.seatCount
            var seatInfoList: [TXSeatInfo] = []
            if roomParam.seatInfoList.count > 0 {
                for trtcSeatInfo in roomParam.seatInfoList {
                    let seatInfo = TXSeatInfo.init()
                    seatInfo.status = trtcSeatInfo.status
                    seatInfo.mute = trtcSeatInfo.mute
                    seatInfo.user = trtcSeatInfo.userId
                    seatInfoList.append(seatInfo)
                    self.seatInfoList.append(trtcSeatInfo)
                }
            } else {
                for _ in 0..<seatCount {
                    seatInfoList.append(TXSeatInfo.init())
                    self.seatInfoList.append(VoiceRoomSeatInfo.init(status: 0, mute: false, userId: ""))
                }
            }
            // 创建房间
            self.roomService.createRoom(roomId: self.roomID,
                                        roomName: roomName,
                                        coverUrl: roomCover,
                                        needRequest: isNeedRequest,
                                        seatInfoList: seatInfoList) { [weak self] (code, message) in
                                            guard let `self` = self else { return }
                                            if code == 0 {
                                                // TODO: - 进入TRTCRoom
                                                self.enterTRTCRoomInner(roomId: self.roomID, userId: self.userId, userSig: self.userSig, role: TRTCRoleType.anchor.rawValue, callback: callback)
                                                return;
                                            } else {
                                                self.runOnDelegateThread {
                                                     self.delegate?.onError(code: code, message: message)
                                                }
                                            }
                                            self.runOnDelegateThread {
                                                callback?(code, message)
                                            }
            }
        }
    }
    
    @objc
    func destroyRoom(callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("start destroy room.")
            TRTCLog.out("start exit trtc room.")
            // TRTC退房结果不关心
            self.roomTRTCService.exitRoom { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code != 0 {
                    self.runOnDelegateThread { [weak self] in
                        guard let `self` = self else { return }
                        self.delegate?.onError(code: code, message: message)
                    }
                }
            }
            self.roomService.exitRoom { [weak self] (code, message) in
                guard let `self` = self else { return }
                TRTCLog.out("exit trtc room finish. code: \(code), message:\(message)")
                if code != 0 {
                    self.runOnDelegateThread {
                        self.delegate?.onError(code: code, message: message)
                    }
                }
            }
            TRTCLog.out("start destroy room service.")
            self.roomService.destroyRoom { [weak self] (code, message) in
                guard let `self` = self else { return }
                TRTCLog.out("destroy room finsih, code: \(code), message: \(message)")
                self.runOnDelegateThread {
                    callback?(code, message)
                }
            }
            self.clearList() // 恢复设定
        }
    }
    
    @objc
    func enterRoom(roomID: Int, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            // 恢复设定
            self.clearList()
            self.roomID = "\(roomID)"
            TRTCLog.out("start enter room, room id is \(roomID)")
            //TODO - 进入TRTC房间
            self.enterTRTCRoomInner(roomId: self.roomID, userId: self.userId, userSig: self.userSig, role: TRTCRoleType.audience.rawValue) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.runOnMainThread {
                    callback?(code, message)
                }
            }
            self.roomService.enterRoom(roomId: self.roomID) { [weak self] (code, message) in
                guard let `self` = self else { return }
                TRTCLog.out("enter room service finish, room id is \(roomID)")
                self.runOnDelegateThread {
                    self.delegate?.onError(code: code, message: message)
                }
            }
        }
    }
    
    @objc
    func exitRoom(callback: ActionCallback?) {
        self.runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("start exit room.")
            if self.isOnSeat(self.userId) {
                self.leaveSeat { [weak self] (code, message) in
                    guard let `self` = self else { return }
                    self.exitRoomInternal(callback: callback)
                }
            } else {
                self.exitRoomInternal(callback: callback)
            }
        }
    }
    
    @objc
    func getRoomInfoList(roomIdList: [Int], callback: VoiceRoomInfoCallback?) {
        self.runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("start get room info:\(roomIdList)")
            let roomIdStringList = roomIdList.map { (identifier) -> String in
                return "\(identifier)"
            }
            self.roomService.getRoomInfoList(roomIds: roomIdStringList) { (code, message, roomInfos) in
                if code == 0 {
                    TRTCLog.out("roomInfos: \(roomInfos)")
                    let trtcRoomInfos = roomInfos.filter({ (info) -> Bool in
                        return Int.init(info.roomId) != nil
                    }).map { (info) -> VoiceRoomInfo in
                        let roomID: Int = Int.init(info.roomId) ?? 0
                        let roomInfo = VoiceRoomInfo.init(roomID: roomID, ownerId: info.ownerId, memberCount: Int(info.memberCount))
                        roomInfo.roomName = info.roomName
                        roomInfo.coverUrl = info.cover
                        roomInfo.ownerName = info.ownerName
                        return roomInfo
                    }
                    callback?(code, message, trtcRoomInfos)
                } else {
                    callback?(code, message, [])
                }
            }
        }
    }
    
    @objc
    func getUserInfoList(userIDList: [String]?, callback: VoiceRoomUserListCallback?) {
        self.runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            guard let userIds = userIDList else {
                self.getAudienceList(callback: callback)
                return
            }
            self.roomService.getUserInfo(userList: userIds) { (code, message, userInfos) in
                TRTCLog.out("get audience list finish, code:\(code), message: \(message), listSize: \(userInfos.count)")
                self.runOnDelegateThread {
                    let userList = userInfos.map { (userInfo) -> VoiceRoomUserInfo in
                        let info = VoiceRoomUserInfo.init(userId: userInfo.userId, userName: userInfo.userName, userAvatar: userInfo.avatarURL)
                        return info
                    }
                    callback?(code, message, userList)
                }
            }
        }
    }
    
    @objc
    func enterSeat(seatIndex: Int, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            if self.isOnSeat(self.userId) {
                self.runOnDelegateThread {
                    callback?(-1, "you are alread in the seat.")
                }
                return
            }
            self.enterSeatCallback = callback
            self.roomService.takeSeat(index: seatIndex) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    TRTCLog.out("take seat callback success, and wait attrs changed.")
                } else {
                    // 出错了，恢复Callback
                    self.enterSeatCallback = nil
                    self.takeSeatIndex = -1
                    callback?(code, message)
                }
            }
        }
    }
    
    func leaveSeat(callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("leave seat: \(self.takeSeatIndex)")
            if self.takeSeatIndex == -1 {
                // 已经不再座位上了
                self.runOnDelegateThread {
                    callback?(-1, "you are not in the seat")
                }
            }
            self.leaveSeatCallback = callback
            self.roomService.leaveSeat(index: self.takeSeatIndex) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    TRTCLog.out("leave seat callback success, and wait attrs changed.")
                } else {
                    self.leaveSeatCallback = nil // 出错了恢复Callback
                    callback?(code, message)
                }
            }
        }
    }
    
    func pickSeat(seatIndex: Int, userId: String, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            // 判断用户是否已经在麦上
            if self.isOnSeat(userId) {
                self.runOnDelegateThread {
                    callback?(-1, "该用户已经是上麦主播了")
                }
                return
            }
            self.pickSeatCallback = callback
            self.roomService.pickSeat(index: seatIndex, userId: userId) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    TRTCLog.out("pick seat callback success, and wait attrs changed.")
                } else {
                    // 出错了，恢复Callback
                    self.pickSeatCallback = nil
                    callback?(code, message)
                }
            }
        }
    }
    
    func kickSeat(seatIndex: Int, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            TRTCLog.out("kick seat: \(seatIndex)")
            guard let `self` = self else { return }
            self.kickSeatCallback = callback
            self.roomService.kickSeat(index: seatIndex) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    TRTCLog.out("kick seat callback success, and wait attrs changed.")
                } else {
                    // 出错了，恢复Callback
                    self.kickSeatCallback = nil
                    callback?(code, message)
                }
            }
        }
    }
    
    func muteSeat(seatIndex: Int, isMute: Bool, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            TRTCLog.out("mute seat: \(seatIndex), isMute:\(isMute)")
            guard let `self` = self else { return }
            self.roomService.muteSeat(index: seatIndex, mute: isMute) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.runOnDelegateThread {
                    callback?(code, message)
                }
            }
        }
    }
    
    func closeSeat(seatIndex: Int, isClose: Bool, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            TRTCLog.out("close seat: \(seatIndex), isClose:\(isClose)")
            guard let `self` = self else { return }
            self.roomService.closeSeat(index: seatIndex, isClose: isClose) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.runOnDelegateThread {
                    callback?(code, message)
                }
            }
        }
    }
    
    func startMicrophone() {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.startMicrophone()
        }
    }
    
    func stopMicrophone() {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.stopMicrophone()
        }
    }
    
    func setAuidoQuality(quality: Int) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.setAuidoQuality(quality: quality)
        }
    }
    
    func muteLoaclAudio(mute: Bool) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.muteLocalAudio(isMute: mute)
        }
    }
    
    func setSpeaker(userSpeaker: Bool) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.setSpeaker(useSpeaker: userSpeaker)
        }
    }
    
    func setAudioCaptureVolume(volume: Int) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.setAudioCaptureVolume(volume: volume)
        }
    }
    
    func setAudioPlayoutVolume(volume: Int) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.setAudioPlayoutVolume(volume: volume)
        }
    }
    
    func muteRemoteAudio(userId: String, mute: Bool) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.muteRemoteAudio(userId: userId, mute: mute)
        }
    }
    
    func muteAllRemoteAudio(isMute: Bool) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.roomTRTCService.muteAllRemoteAudio(isMute: isMute)
        }
    }
    
    func getAudioEffectManager() -> TXAudioEffectManager? {
        return TRTCCloud.sharedInstance()?.getAudioEffectManager()
    }
    
    func sendRoomTextMsg(message: String, callback: ActionCallback?) {
        runOnMainThread {
            TRTCLog.out("send room text msg.")
            self.roomService.sendRoomTextMsg(msg: message) { (code, message) in
                callback?(code, message)
            }
        }
    }
    
    func sendRoomCustomMsg(cmd: String, message: String, callback: ActionCallback?) {
        runOnMainThread {
            TRTCLog.out("send room custom message")
            self.roomService.sendRoomCustomMsg(cmd: cmd, message: message) { (code, message) in
                callback?(code, message)
            }
        }
    }
    
    func sendInvitation(cmd: String, userId: String, content: String, callback: ActionCallback?) -> String {
        TRTCLog.out("send invitation to \(userId), cmd: \(cmd), content: \(content)")
        return roomService.sendInvitation(cmd: cmd, userId: userId, content: content) { (code, message) in
            callback?(code, message)
        }
    }
    
    func acceptInvitation(identifier: String, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("accept invitaiton \(identifier)")
            self.roomService.acceptInvitation(identifier: identifier) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.runOnDelegateThread {
                    callback?(code, message)
                }
            }
        }
    }
    
    func rejectInvitation(identifier: String, callback: ActionCallback?) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("reject invitation \(identifier)")
            self.roomService.rejectInvitation(identifier: identifier) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.runOnDelegateThread {
                    callback?(code, message)
                }
            }
        }
    }
    
    func cancelInvitation(identifier: String, callback: ActionCallback?) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("cancel invitation \(identifier)")
            self.roomService.cancelInvitation(identifier: identifier) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.runOnDelegateThread {
                    callback?(code, message)
                }
            }
        }
    }
}

extension TRTCVoiceRoomImp: ITXRoomServiceDelegate {
    func onRoomDestroy(roomID: String) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            self.exitRoom(callback: nil)
            self.runOnDelegateThread { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.onRoomDestroy(message: roomID)
            }
        }
    }
    
    func onRoomRecvRoomTextMsg(roomID: String, message: String, userInfo: TXUserInfo) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            let throwUser = VoiceRoomUserInfo.init(userId: userInfo.userId, userName: userInfo.userName, userAvatar: userInfo.avatarURL)
            self.delegate?.onRecvRoomTextMsg(message: message, userInfo: throwUser)
        }
    }
    
    func onRoomRecvRoomCustomMsg(roomID: String, cmd: String, message: String, userInfo: TXUserInfo) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            let throwUser = VoiceRoomUserInfo.init(userId: userInfo.userId, userName: userInfo.userName, userAvatar: userInfo.avatarURL)
            self.delegate?.onRecvRoomCustomMsg(cmd: cmd, message: message, userInfo: throwUser)
        }
    }
    
    func onRoomInfoChange(roomInfo: TXRoomInfo) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            guard let roomID = Int.init(self.roomID) else { return }
            let throwRoom = VoiceRoomInfo.init(roomID: roomID, ownerId: roomInfo.ownerId, memberCount: Int(roomInfo.memberCount))
            throwRoom.ownerName = roomInfo.ownerName
            throwRoom.coverUrl = roomInfo.cover
            throwRoom.needRequest = roomInfo.needRequest == 1
            throwRoom.roomName = roomInfo.roomName
            self.delegate?.onRoomInfoChange(roomInfo: throwRoom)
        }
    }
    
    func onSeatInfoListChange(seatInfoList: [TXSeatInfo]) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            let roomSeatInfoList = seatInfoList.map { (info) -> VoiceRoomSeatInfo in
                let seatInfo = VoiceRoomSeatInfo.init()
                seatInfo.userId = info.user
                seatInfo.mute = info.mute
                seatInfo.status = info.status
                return seatInfo
            }
            self.seatInfoList = roomSeatInfoList
            self.delegate?.onSeatListChange(seatInfoList: roomSeatInfoList)
        }
    }
    
    func onRoomAudienceEnter(userInfo: TXUserInfo) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            let throwUser = VoiceRoomUserInfo.init(userId: userInfo.userId, userName: userInfo.userName, userAvatar: userInfo.avatarURL)
            self.delegate?.onAudienceEnter(userInfo: throwUser)
        }
    }
    
    func onRoomAudienceLeave(userInfo: TXUserInfo) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            let throwUser = VoiceRoomUserInfo.init(userId: userInfo.userId, userName: userInfo.userName, userAvatar: userInfo.avatarURL)
            self.delegate?.onAudienceExit(userInfo: throwUser)
        }
    }
    
    func onSeatTake(index: Int, userInfo: TXUserInfo) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            if userInfo.userId == self.userId {
                // 是自己上线了，切换角色
                self.takeSeatIndex = index
                self.roomTRTCService.switchToAnchor()
                self.roomTRTCService.muteLocalAudio(isMute: self.seatInfoList[index].mute)
            }
            self.runOnDelegateThread { [weak self] in
                guard let `self` = self else { return }
                let throwUser = VoiceRoomUserInfo.init(userId: userInfo.userId, userName: userInfo.userName, userAvatar: userInfo.avatarURL)
                self.delegate?.onAnchorEnterSeat(index: index, user: throwUser)
                self.pickSeatCallback?(0, "pick seat success")
                self.pickSeatCallback = nil
            }
            if userInfo.userId == self.userId {
                self.runOnDelegateThread { [weak self] in
                    guard let `self` = self else { return }
                    self.enterSeatCallback?(0, "enter Seat success")
                    self.enterSeatCallback = nil
                }
            }
        }
    }
    
    func onSeatClose(index: Int, isClose: Bool) {
        runOnMainThread { [weak self] in
            guard let `self` = self else { return }
            if self.takeSeatIndex == index {
                self.roomTRTCService.switchToAudience()
                self.takeSeatIndex = -1
            }
            self.runOnDelegateThread { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.onSeatClose(index: index, isClose: isClose)
            }
        }
    }
    
    func onSeatLeave(index: Int, userInfo: TXUserInfo) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            if self.userId == userInfo.userId {
                // 是自己下线了，切换角色
                self.takeSeatIndex = -1
                self.roomTRTCService.switchToAudience()
            }
            self.runOnDelegateThread { [weak self] in
                guard let `self` = self else { return }
                let throwUser = VoiceRoomUserInfo.init(userId: userInfo.userId, userName: userInfo.userName, userAvatar: userInfo.avatarURL)
                self.delegate?.onAnchorLeaveSeat(index: index, user: throwUser)
                self.kickSeatCallback?(0, "kick seat success.")
                self.kickSeatCallback = nil
            }
            if self.userId == userInfo.userId {
                self.runOnDelegateThread { [weak self] in
                    guard let `self` = self else { return }
                    self.leaveSeatCallback?(0, "leave seat success.")
                    self.leaveSeatCallback = nil
                }
            }
            
        }
    }
    
    func onSeatMute(index: Int, mute: Bool) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            if self.takeSeatIndex == index {
                self.roomTRTCService.muteLocalAudio(isMute: mute)
            }
            self.delegate?.onSeatMute(index: index, isMute: mute)
        }
    }
    
    func onReceiveNewInvitation(identifier: String, inviter: String, cmd: String, content: String) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.onReceiveNewInvitation(identifier: identifier, inviter: inviter, cmd: cmd, content: content)
        }
    }
    
    func onInviteeAccepted(identifier: String, invitee: String) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.onInviteeAccepted(identifier: identifier, invitee: invitee)
        }
    }
    
    func onInviteeRejected(identifier: String, invitee: String) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.onInviteeRejected(identifier: identifier, invitee: invitee)
        }
    }
    
    func onInviteeCancelled(identifier: String, invitee: String) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.onInvitationCancelled(identifier: identifier, invitee: invitee)
        }
    }
}

extension TRTCVoiceRoomImp: VoiceRoomTRTCServiceDelegate {
    func onTRTCAnchorEnter(userId: String) {
        self.anchorSeatList.insert(userId)
    }
    
    func onTRTCAnchorExit(userId: String) {
        if roomService.isOwner {
            // 主播是房主
            if self.seatInfoList.count > 0 {
                var kickSeatIndex = -1
                for index in 0..<seatInfoList.count {
                    if userId == seatInfoList[index].userId {
                        kickSeatIndex = index
                        break
                    }
                }
                if kickSeatIndex != -1 {
                    kickSeat(seatIndex: kickSeatIndex, callback: nil)
                }
            }
        }
        self.anchorSeatList.remove(userId)
    }
    
    func onTRTCAudioAvailable(userId: String, available: Bool) {
        
    }
    
    func onError(errorCode: Int, message: String) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.onError(code: Int32(errorCode), message: message)
        }
    }
    
    func onNetWorkQuality(trtcQuality: TRTCQualityInfo, arrayList: [TRTCQualityInfo]) {
        
    }
    
    func onUserVoiceVolume(userVolumes: [TRTCVolumeInfo], totalVolume: Int) {
        runOnDelegateThread { [weak self] in
            guard let `self` = self else { return }
            userVolumes.forEach { (info) in
                if let userId = info.userId {
                    self.delegate?.onUserVolumeUpdate(userId: userId, volume: Int(info.volume))
                }
                
            }
        }
    }
}
