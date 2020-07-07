//
//  TXRoomService.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/9.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation
import ImSDK
import SwiftyJSON

public class TXRoomService: NSObject {
    static let CODE_ERROR: Int32 = -1
    private static var instance: TXRoomService = TXRoomService.init()
    
    private weak var delegate: ITXRoomServiceDelegate?
    private var isInitIMSDK: Bool = false
    private var isLogin: Bool = false
    private var isEnterRoom: Bool = false
    
    private var roomId: String = ""
    private var selfUserId: String = ""
    private var ownerUserId: String = ""
    private var roomInfo: TXRoomInfo = TXRoomInfo.init()
    private var seatInfoList: [TXSeatInfo] = []
    private var selfUserName: String = ""

    private var imManager: V2TIMManager {
        return V2TIMManager.sharedInstance()!
    }
    // MARK: - public property
    public var isOwner: Bool {
        return selfUserId == ownerUserId
    }
    
    public static func getInstance() -> TXRoomService {
        return instance
    }
    
    public func setDelegate(_ delegate: ITXRoomServiceDelegate) {
        self.delegate = delegate
    }
    
    public func login(sdkAppId: Int32, userId: String, userSig: String, callback: TXCallback?) {
        // 未初始化 IM 先初始化 IM
        if !isInitIMSDK {
            let config: V2TIMSDKConfig = V2TIMSDKConfig.init()
            config.logLevel = V2TIMLogLevel.LOG_ERROR
            isInitIMSDK = imManager.initSDK(sdkAppId, config: config, listener: self)
            if !isInitIMSDK {
                if let callback = callback {
                    callback(TXRoomService.CODE_ERROR, "init im sdk error.")
                }
                return
            }
        }
        // 登录到 IM
        if let loginedUserId = imManager.getLoginUser() {
            if loginedUserId == userId {
                // 已经登录过了
                isLogin = true
                selfUserId = userId
                if let callback = callback {
                    callback(0, "login im success")
                }
                return
            }
        }
        if isLogin {
            if let callback = callback {
                callback(TXRoomService.CODE_ERROR, "start login fail, you have been login, can't login twice.")
            }
            return;
        }
        imManager.login(userId, userSig: userSig, succ: { [weak self] in
            guard let `self` = self else { return }
            self.isLogin = true
            self.selfUserId = userId
            if let callback = callback {
                callback(0, "login im success")
            }
        }) { (code, message) in
            if let callback = callback {
                callback(code, message ?? "im login error")
            }
        }
    }
    
    func getSelfInfo() {
        var userIds = [String]()
        userIds.append(selfUserId)
        imManager.getUsersInfo(userIds, succ: { [weak self] (infos: [V2TIMUserFullInfo]?) in
            guard let `self` = self else { return }
            guard let userFullInfos = infos else { return }
            self.selfUserName = userFullInfos.first?.nickName ?? ""
        }) { (code, error) in
            
        }
    }
    
    public func logout(callback: TXCallback?) {
        guard isLogin else {
            if let callback = callback {
                callback(TXRoomService.CODE_ERROR, "start logout fail, not login yet.")
            }
            return
        }
        if isEnterRoom {
            if let callback = callback {
                callback(TXRoomService.CODE_ERROR, "start logout fail, you are in room:" + roomId + ", please exit room before logout.")
            }
            return
        }
        imManager.logout({ [weak self] in
            guard let `self` = self else { return }
            self.isLogin = false
            self.selfUserId = ""
            callback?(0, "logout success.")
        }) { (code, message) in
            if let callback = callback {
                callback(code, message ?? "im logout failed.")
            }
        }
    }
    
    public func setSelfProfile(userName: String, avatarUrl: String, callback: TXCallback?) {
        guard isLogin else {
            if let callback = callback {
                callback(TXRoomService.CODE_ERROR, "set profile fail, not login yet.")
            }
            return
        }
        let userFullInfo = V2TIMUserFullInfo.init()
        userFullInfo.nickName = userName
        userFullInfo.faceURL = avatarUrl
        imManager.setSelfInfo(userFullInfo, succ: {
            callback?(0, "set profile success.")
        }) { (code, message) in
            callback?(code, message ?? "set profile failed.")
        }
    }
    
    public func createRoom(roomId: String, roomName: String, coverUrl: String, needRequest: Bool, seatInfoList: [TXSeatInfo], callback: TXCallback?) {
        guard isLogin else {
            callback?(TXRoomService.CODE_ERROR, "im not login yet, create room fail.")
            return
        }
        if isEnterRoom {
            callback?(TXRoomService.CODE_ERROR, "you have been in room: \(self.roomId), can't create another room: \(roomId)")
            return
        }
        self.roomId = roomId
        self.ownerUserId = self.selfUserId
        self.seatInfoList = seatInfoList
        roomInfo = TXRoomInfo.init()
        roomInfo.ownerId = selfUserId
        roomInfo.ownerName = selfUserName
        roomInfo.roomName = roomName
        roomInfo.cover = coverUrl
        roomInfo.seatSize = seatInfoList.count
        roomInfo.needRequest = needRequest ? 1 : 0
        imManager.createGroup("AVChatRoom", groupID: roomId, groupName: roomName, succ: { [weak self] (message) in
            guard let `self` = self else { return }
            self.setGroupInfo(roomId: roomId, roomName: roomName, coverUrl: coverUrl, userName: self.selfUserName)
            self.onCreateSuccess(callback: callback)
        }) { [weak self] (code, message) in
            guard let `self` = self else { return }
            TRTCLog.out("create room error: \(code), message:\(message ?? "")")
            var msg: String = message ?? "create room fialed."
            // 通用提示
            if code == 10036 {
                msg = "您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】，地址：https://cloud.tencent.com/document/product/269/11673"
            }
            if code == 10037 {
                msg = "单个用户可创建和加入的群组数量超过了限制，请购买相关套餐,价格地址：https://cloud.tencent.com/document/product/269/11673"
            }
            if code == 10038 {
                msg = "群成员数量超过限制，请参考，请购买相关套餐，价格地址：https://cloud.tencent.com/document/product/269/11673"
            }
            // 特殊处理
            if code == 10025 || code == 10021 {
                // 标明群主是自己，认为创建成功
                // 群组ID已被他人使用，此时走进入房间的逻辑
                self.setGroupInfo(roomId: roomId, roomName: roomName, coverUrl: coverUrl, userName: self.selfUserName)
                self.imManager.joinGroup(roomId, msg: "", succ: { [weak self] in
                    guard let `self` = self else { return }
                    TRTCLog.out("group has been created. join group success")
                    self.onCreateSuccess(callback: callback)
                }) { (code, message) in
                    TRTCLog.out("error: group has benn created. join group fail. code: \(code), message:\(message ?? "")")
                    callback?(code, message ?? "")
                }
            } else {
                callback?(code, msg)
            }
        }
    }
    
    public func destroyRoom(callback: TXCallback?) {
        guard isOwner else {
            callback?(-1, "only owner could destroy room")
            return
        }
        imManager.dismissGroup(roomId, succ: { [weak self] in
            guard let `self` = self else { return }
            self.unInitIMListener()
            self.cleanStatus()
            callback?(0, "destroy room success.")
        }) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 10007 {
                // 权限不足
                TRTCLog.out("you're not real owner, start logic destroy.")
                // 清空群属性
                self.cleanGroupAttr()
                self.sendGroupMsg(message: IMJsonHandle.getRoomDestroyMsg(), callback: callback)
                self.unInitIMListener()
                self.cleanStatus()
            } else {
                callback?(code, message ?? "destroy room failed.")
            }
        }
    }
    
    public func enterRoom(roomId: String, callback: TXCallback?) {
        self.cleanStatus()
        self.roomId = roomId
        imManager.joinGroup(roomId, msg: "", succ: { [weak self] in
            guard let `self` = self else { return }
            self.onJoinRoomSuccess(roomId:roomId, callback: callback)
        }) { (code, message) in
            if code == 10013 {
                self.onJoinRoomSuccess(roomId:roomId, callback: callback)
            } else {
                callback?(-1, "join group error, enter room fail. code:\(code), msg: \(message ?? "")")
            }
        }
    }
    
    public func exitRoom(callback: TXCallback?) {
        guard isEnterRoom else {
            callback?(TXRoomService.CODE_ERROR, "not enter room yet, can't exit room.")
            return
        }
        imManager.quitGroup(roomId, succ: { [weak self] in
            guard let `self` = self else { return }
            self.unInitIMListener()
            self.cleanStatus()
            callback?(0, "exit room success.")
        }) { [weak self] (code, message) in
            guard let `self` = self else { return }
            self.unInitIMListener()
            callback?(code, message ?? "exit room failed.")
        }
    }
    
    public func takeSeat(index: Int, callback: TXCallback?) {
        if index < seatInfoList.count && index >= 0 {
            let info = seatInfoList[index]
            if info.status == TXSeatInfo.STATUS_USED {
                callback?(-1, "seat is used")
                return
            }
            if info.status == TXSeatInfo.STATUS_CLOSE {
                callback?(-1, "seat is closed")
                return
            }
            // 修改属性列表
            let changeInfo = TXSeatInfo.init()
            changeInfo.status = TXSeatInfo.STATUS_USED
            changeInfo.user = selfUserId
            changeInfo.mute = info.mute
            let map = IMJsonHandle.getSeatInfoJsonStr(index: index, info: changeInfo)
            modeifyGroupAttrs(map: map, callback: callback)
        } else {
            callback?(-1, "seat info list is empty or index error")
        }
    }
    
    public func leaveSeat(index: Int, callback: TXCallback?) {
        if index < seatInfoList.count && index >= 0 {
            let info = seatInfoList[index]
            guard selfUserId == info.user else {
                callback?(-1, "\(selfUserId) not in the seat \(index)")
                return
            }
            let changeInfo = TXSeatInfo.init()
            changeInfo.status = TXSeatInfo.STATUS_UNUSED
            changeInfo.user = ""
            changeInfo.mute = false
            let map = IMJsonHandle.getSeatInfoJsonStr(index: index, info: changeInfo)
            modeifyGroupAttrs(map: map, callback: callback)
        } else {
            callback?(-1, "seat info list is empty or index error")
        }
    }
    
    public func pickSeat(index: Int, userId: String, callback: TXCallback?) {
        guard isOwner else {
            callback?(-1, "only owner could pick seat")
            return
        }
        guard index < seatInfoList.count && index >= 0 else {
            callback?(-1, "seat info list is empty or index error.")
            return
        }
        let info = seatInfoList[index]
        if info.status == TXSeatInfo.STATUS_USED {
            callback?(-1, "seat status is used.")
            return
        }
        if info.status == TXSeatInfo.STATUS_CLOSE {
            callback?(-1, "seat status is close.")
            return
        }
        let changeInfo = TXSeatInfo.init()
        changeInfo.status = TXSeatInfo.STATUS_USED
        changeInfo.user = userId
        changeInfo.mute = info.mute
        let map = IMJsonHandle.getSeatInfoJsonStr(index: index, info: changeInfo)
        modeifyGroupAttrs(map: map, callback: callback)
    }
    
    public func kickSeat(index: Int, callback: TXCallback?) {
        guard isOwner else {
            callback?(-1, "only owner could kick seat.")
            return
        }
        guard index < seatInfoList.count && index >= 0 else {
            callback?(-1, "seat info list is empty or index error.")
            return
        }
//        let info = seatInfoList[index]
        let changeInfo = TXSeatInfo.init()
        changeInfo.status = TXSeatInfo.STATUS_UNUSED
        changeInfo.user = ""
        changeInfo.mute = false
        let map = IMJsonHandle.getSeatInfoJsonStr(index: index, info: changeInfo)
        modeifyGroupAttrs(map: map, callback: callback)
    }
    
    public func muteSeat(index: Int, mute: Bool, callback: TXCallback?) {
        guard isOwner else {
            callback?(-1, "only owner could kick seat.")
            return
        }
        guard index < seatInfoList.count && index >= 0 else {
            callback?(-1, "seat info list is empty or index error.")
            return
        }
        let info = seatInfoList[index]
        let changeInfo = TXSeatInfo.init()
        changeInfo.status = info.status
        changeInfo.user = info.user
        changeInfo.mute = mute
        let map = IMJsonHandle.getSeatInfoJsonStr(index: index, info: changeInfo)
        modeifyGroupAttrs(map: map, callback: callback)
    }
    
    public func closeSeat(index: Int, isClose: Bool, callback: TXCallback?) {
        guard isOwner else {
            callback?(-1, "only owner could close seat.")
            return
        }
        guard index < seatInfoList.count && index >= 0 else {
            callback?(-1, "seat info list is empty or index error.")
            return
        }
        // FEXME: - 座位有人的情况
        let changeStatus = isClose ? TXSeatInfo.STATUS_CLOSE : TXSeatInfo.STATUS_UNUSED
        let info = seatInfoList[index]
        guard info.status != changeStatus else {
            callback?(0, "already in \(isClose ? "close" : "open" )")
            return
        }
        let changeInfo = TXSeatInfo.init()
        changeInfo.status = changeStatus
        changeInfo.user = ""
        changeInfo.mute = info.mute
        let map = IMJsonHandle.getSeatInfoJsonStr(index: index, info: changeInfo)
        modeifyGroupAttrs(map: map, callback: callback)
    }
    
    public func getUserInfo(userList: [String], callback: TXUserListCallback?) {
        guard isEnterRoom else {
            callback?(0, "get user info list fail, not enter room yet.", [])
            return
        }
        guard userList.count > 0 else {
            callback?(TXRoomService.CODE_ERROR, "get user info list fail, user list is empty.", [])
            return
        }
        imManager.getUsersInfo(userList, succ: { (userInfos) in
            var txUserInfos: [TXUserInfo] = []
            if let results = userInfos {
                txUserInfos = results.map { (v2TIMUserFullInfo) -> TXUserInfo in
                    let userInfo = TXUserInfo.init()
                    userInfo.userName = v2TIMUserFullInfo.nickName ?? ""
                    userInfo.userId = v2TIMUserFullInfo.userID ?? ""
                    userInfo.avatarURL = v2TIMUserFullInfo.faceURL ?? ""
                    return userInfo
                }
            }
            callback?(0, "success", txUserInfos)
        }) { (code, message) in
            callback?(code, message ?? "get user info failed.", [])
        }
    }
    
    public func sendRoomTextMsg(msg: String, callback: TXCallback?) {
        guard isEnterRoom else {
            callback?(-1, "send room text fail, not enter room yet")
            return
        }
        imManager.sendGroupTextMessage(msg, to: roomId, priority: V2TIMMessagePriority.PRIORITY_NORMAL, succ: {
            callback?(0, "send group message success.")
        }) { (code, message) in
            TRTCLog.out("error: send group text messge error: \(code), message: \(message ?? "")")
            callback?(code, message ?? "")
        }
    }
    
    public func sendRoomCustomMsg(cmd: String, message: String, callback: TXCallback?) {
        guard isEnterRoom else {
            callback?(-1, "send room custom msg fail, not enter room yet")
            return
        }
        sendGroupMsg(message: IMJsonHandle.getCusMsgJsonStr(cmd: cmd, msg: message), callback: callback)
    }
    
    public func sendGroupMsg(message: String, callback: TXCallback?) {
        guard let data = message.data(using: .utf8) else {
            callback?(-1, "message can't covert to data.")
            return
        }
        imManager.sendGroupCustomMessage(data, to: roomId, priority: .PRIORITY_NORMAL, succ: {
            callback?(-1, "send group message success.")
        }) { (code, message) in
            TRTCLog.out("error: send group messge error: \(code), message: \(message ?? "")")
            callback?(-1, message ?? "send custom message error.")
        }
    }
    
    public func getAudienceList(callback: TXUserListCallback?) {
        imManager.getGroupMemberList(self.roomId, filter: V2TIMGroupMemberFilter.GROUP_MEMBER_FILTER_COMMON, nextSeq: 0, succ: { (code, results: [V2TIMGroupMemberFullInfo]?) in
            guard let memberInfos = results else {
                callback?(-1, "get audience list fail. results is nil", [])
                return
            }
            let userInfos = memberInfos.map { (info) -> TXUserInfo in
                let userInfo =  TXUserInfo.init()
                userInfo.userId = info.userID
                userInfo.userName = info.nickName ?? ""
                userInfo.avatarURL = info.faceURL
                return userInfo
            }
            callback?(0, "", userInfos)
        }) { (code, message) in
            callback?(code, message ?? "get audience list fail.", [])
        }
    }
    
    public func getRoomInfoList(roomIds: [String], callback: TXRoomInfoListCallback?) {
        imManager.getGroupsInfo(roomIds, succ: { ( results :[V2TIMGroupInfoResult]?) in
            guard let v2TIMGroupInfoResult = results else {
                callback?(-1, "info is null", [])
                return
            }
            var groupInfo: [String: V2TIMGroupInfoResult] = [:]
            for result in v2TIMGroupInfoResult {
                groupInfo[result.info.groupID] = result
            }
            let txRoomInfos = roomIds.map { (roomId) -> TXRoomInfo in
                let roomInfo = TXRoomInfo.init()
                if let v2TIMGroupInfo = groupInfo[roomId] {
                    roomInfo.roomId = v2TIMGroupInfo.info.groupID ?? ""
                    roomInfo.cover = v2TIMGroupInfo.info.faceURL ?? ""
                    roomInfo.memberCount = v2TIMGroupInfo.info.memberCount
                    roomInfo.ownerId = v2TIMGroupInfo.info.owner ?? ""
                    roomInfo.roomName = v2TIMGroupInfo.info.groupName ?? ""
                    roomInfo.ownerName = v2TIMGroupInfo.info.introduction ?? ""
                }
                return roomInfo
            }
            callback?(0, "", txRoomInfos)
        }) { (code, message) in
            callback?(code, message ?? "get groupInfo failed", [])
        }
    }
    public func destroy() {
        
    }
    
    public func sendInvitation(cmd: String, userId: String, content: String, callback: TXCallback?) -> String {
        let jsonString = IMJsonHandle.getInvitationMsg(roomId: self.roomId, cmd: cmd, content: content)
        TRTCLog.out("send + \(userId), json: \(jsonString)")
        return imManager.invite(userId, data: jsonString, timeout: 0, succ: {
            TRTCLog.out("send invitation success.")
            callback?(0, "send invitation success.")
        }) { (code, message) in
            TRTCLog.out("send invitation error\(code), message:\(message ?? "")")
            callback?(code, message ?? "send invitation failed.")
        }
    }
    
    public func acceptInvitation(identifier: String, callback: TXCallback?) {
        TRTCLog.out("accept + \(identifier)")
        imManager.accept(identifier, data: nil, succ: {
            TRTCLog.out("accept invitation success.")
            callback?(0, "accept invitation success")
        }) { (code, message) in
            TRTCLog.out("accept invitation error\(code), message:\(message ?? "")")
            callback?(code, message ?? "accept invitaion fail.")
        }
    }
    
    public func rejectInvitation(identifier: String, callback: TXCallback?) {
        TRTCLog.out("reject + \(identifier)")
        imManager.reject(identifier, data: nil, succ: {
            TRTCLog.out("reject invitation success.")
            callback?(0, "reject invitation success.")
        }) { (code, message) in
            TRTCLog.out("reject invitation error\(code), message:\(message ?? "")")
            callback?(code , message ?? "reject invitation fail.")
        }
    }
    
    public func cancelInvitation(identifier: String, callback: TXCallback?) {
        TRTCLog.out("cancel + \(identifier)")
        imManager.cancel(identifier, data: nil, succ: {
            TRTCLog.out("cancel invitation success.")
            callback?(0, "cancel invitation success.")
        }) { (code, message) in
            TRTCLog.out("cancel invitation error\(code), message:\(message ?? "")")
            callback?(code, message ?? "cancel invitation failed.")
        }
    }
}

// MARK: - 私有方法
extension TXRoomService {
    
    private func initIMListener() {
        imManager.setGroupListener(self)
        imManager.addSignalingListener(listener: self)
        imManager.add(self)
    }
    
    private func unInitIMListener() {
        imManager.setGroupListener(nil)
        imManager.removeSignalingListener(listener: self)
        imManager.remove(self)
    }
    
    private func onCreateSuccess(callback: TXCallback?) {
        // 创建房间成功
        initIMListener()
        imManager.initGroupAttributes(roomId, attributes: IMJsonHandle.getInitRoomMap(roomInfo: roomInfo, seatInfoList: seatInfoList), succ: { [weak self] in
            guard let `self` = self else { return }
            self.isEnterRoom = true
            callback?(0, "init room info and seat success")
        }) { (code, message) in
            callback?(code, message ?? "init group attributes failed")
        }
    }
    
    private func onJoinRoomSuccess(roomId: String, callback: TXCallback?) {
        imManager.getGroupAttributes(roomId, keys: nil, succ: { [weak self] (attrDic) in
            guard let `self` = self else { return }
            self.initIMListener()
            if let attrMap = attrDic as? [String: String] {
                 // 开始解析room info
                if let result = IMJsonHandle.getRoomInfoFromAttr(map: attrMap) {
                    self.roomInfo = result
                } else {
                    TRTCLog.out("group room info is empty, enter room failed.")
                    callback?(-1, "group room info is empty, enter room failed.")
                    return
                }
                TRTCLog.out("enter room success \(roomId)")
                // 解析Seat Info
                self.roomId = roomId
                self.seatInfoList = IMJsonHandle.getSeatListFromAttr(map: attrMap, seatSize: self.roomInfo.seatSize)
                self.isEnterRoom = true
                self.ownerUserId = self.roomInfo.ownerId
                // 回调给上层
                self.delegate?.onRoomInfoChange(roomInfo: self.roomInfo)
                self.delegate?.onSeatInfoListChange(seatInfoList: self.seatInfoList)
                callback?(0, "enter room success.")
            }
        }) { (code, message) in
            callback?(code, "get group attr error, enter room fail. code: \(code), msg: \(message ?? "")")
        }
    }
    
    private func cleanStatus() {
        isEnterRoom = false
        roomId = ""
        ownerUserId = ""
    }
    
    private func cleanGroupAttr() {
        imManager.deleteGroupAttributes(roomId, keys: nil, succ: nil, fail: nil)
    }
    
    private func modeifyGroupAttrs(map: [String: String], callback: TXCallback?) {
        imManager.setGroupAttributes(roomId, attributes: map, succ: {
            callback?(0, "modify grouop attrs success")
        }) { (code, message) in
            callback?(code, message ?? "modify group attrs failed.")
        }
    }
    
    private func setGroupInfo(roomId: String, roomName: String, coverUrl: String, userName: String) {
        let info = V2TIMGroupInfo.init()
        info.groupID = roomId
        info.groupName = roomName
        info.faceURL = coverUrl
        info.introduction = userName
        self.imManager.setGroupInfo(info, succ: {
            TRTCLog.out("success: set group info success.")
        }) { (code, message) in
            TRTCLog.out("fail: set group info fail.")
        }
    }
}

// MARK: - 私有回调方法处理
extension TXRoomService {
    private func onSeatTake(index: Int, user: String) {
        TRTCLog.out("onSeatTake \(index), userInfo: \(user)")
        let userIdList = [user]
        getUserInfo(userList: userIdList) { [weak self] (code, message, userInfos) in
            guard let `self` = self else { return }
            if code == 0 {
                self.delegate?.onSeatTake(index: index, userInfo: userInfos[0])
            } else {
                TRTCLog.out("onSeat Take get user info error!")
                let userInfo = TXUserInfo.init()
                userInfo.userId = user
                self.delegate?.onSeatTake(index: index, userInfo: userInfo)
            }
        }
    }
    
    private func onSeatClose(index: Int, isClose: Bool) {
        TRTCLog.out("onSeatClose \(index)")
        self.delegate?.onSeatClose(index: index, isClose: isClose)
    }
    
    private func onSeatLeave(index: Int, user: String) {
        TRTCLog.out("onSeatLeave \(index), user: \(user)")
        let userIdList = [user]
        getUserInfo(userList: userIdList) { (code, message, userInfos) in
            if code == 0 && userInfos.count > 0 {
                self.delegate?.onSeatLeave(index: index, userInfo: userInfos[0])
            } else {
                TRTCLog.out("onSeatLeave get user info error!")
                let userInfo = TXUserInfo.init()
                userInfo.userId = user
                self.delegate?.onSeatLeave(index: index, userInfo: userInfo)
            }
        }
    }
    
    private func onSeatMute(index: Int, mute: Bool) {
        TRTCLog.out("onSeatMute \(index), mute: \(mute)")
        self.delegate?.onSeatMute(index: index, mute: mute)
    }
}

// MARK: - SDK连接回调，暂未实现
extension TXRoomService: V2TIMSDKListener {
    
}

// MARK: - SimpleMsgListener
extension TXRoomService: V2TIMSimpleMsgListener {
    
    public func onRecvC2CTextMessage(_ msgID: String!, sender info: V2TIMUserInfo!, text: String!) {
        
    }
    
    public func onRecvC2CCustomMessage(_ msgID: String!, sender info: V2TIMUserInfo!, customData data: Data!) {
        
    }
    
    public func onRecvGroupTextMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, text: String!) {
        TRTCLog.out("im get text msg group: \(groupID ?? ""), userId:\(info.userID ?? ""), text: \(text ?? "")")
        guard groupID == roomId else {
            return
        }
        let userInfo = TXUserInfo.init()
        userInfo.userId = info.userID
        userInfo.avatarURL = info.faceURL ?? ""
        userInfo.userName = info.nickName ?? ""
        self.delegate?.onRoomRecvRoomTextMsg(roomID: roomId, message: text, userInfo: userInfo)
    }
    
    public func onRecvGroupCustomMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, customData data: Data!) {
        guard groupID == roomId else {
            return
        }
        guard let customData = data else {
            return
        }
        do {
            let jsonObject = try JSON.init(data: customData)
            if let version = jsonObject.dictionaryValue[IMJsonHandle.Define.KEY_ATTR_VERSION]?.string {
                if version != IMJsonHandle.Define.VALUE_ATTR_VERSION {
                    TRTCLog.out("protocol version is not match, ignore msg.")
                    return
                }
            }
            if let action = jsonObject.dictionaryValue[IMJsonHandle.Define.KEY_CMD_ACTION]?.intValue {
                switch action {
                case IMJsonHandle.Define.CODE_UNKNOWN:
                    break
                case IMJsonHandle.Define.CODE_ROOM_CUSTOM_MSG:
                    let cusPair = IMJsonHandle.poarseCusMsg(jsonObj: jsonObject)
                    let userInfo = TXUserInfo.init()
                    userInfo.userId = info.userID
                    userInfo.avatarURL = info.faceURL ?? ""
                    userInfo.userName = info.nickName ?? ""
                    self.delegate?.onRoomRecvRoomCustomMsg(roomID: roomId, cmd: cusPair.cmd, message: cusPair.message, userInfo: userInfo)
                case IMJsonHandle.Define.CODE_ROOM_DESTROY:
                    exitRoom(callback: nil)
                    self.delegate?.onRoomDestroy(roomID: roomId)
                    cleanStatus()
                default:
                    break
                }
            }
        } catch let error {
            TRTCLog.out("custom message json data error:\(error)")
        }
    }
    
    
}

extension TXRoomService: V2TIMGroupListener {
    public func onMemberEnter(_ groupID: String!, memberList: [V2TIMGroupMemberInfo]!) {
        guard groupID == roomId else {
            return
        }
        if let list = memberList {
            list.forEach { (v2TIMGroupMemberInfo) in
                let userInfo = TXUserInfo.init()
                userInfo.userId = v2TIMGroupMemberInfo.userID
                userInfo.avatarURL = v2TIMGroupMemberInfo.faceURL ?? ""
                userInfo.userName = v2TIMGroupMemberInfo.nickName ?? ""
                self.delegate?.onRoomAudienceEnter(userInfo: userInfo)
            }
        }
    }
    
    public func onMemberLeave(_ groupID: String!, member: V2TIMGroupMemberInfo!) {
        guard groupID == roomId else {
            return
        }
        if let v2TIMGroupMemberInfo = member {
            let userInfo = TXUserInfo.init()
            userInfo.userId = v2TIMGroupMemberInfo.userID
            userInfo.avatarURL = v2TIMGroupMemberInfo.faceURL ?? ""
            userInfo.userName = v2TIMGroupMemberInfo.nickName ?? ""
            self.delegate?.onRoomAudienceLeave(userInfo: userInfo)
        }
    }
    
    public func onGroupDismissed(_ groupID: String!, opUser: V2TIMGroupMemberInfo!) {
        guard groupID == roomId else {
            return
        }
        // FIXME: - 先清除后回调
        cleanStatus()
        self.delegate?.onRoomDestroy(roomID: groupID)
    }
    
    public func onGroupAttributeChanged(_ groupID: String!, attributes: NSMutableDictionary!) {
        TRTCLog.out("on group attr changed: \(attributes ?? [:])")
        guard groupID == roomId else {
            return
        }
        if roomInfo.seatSize == 0 {
            TRTCLog.out("group attr changed, but room info is empty.")
            return
        }
        guard let attr = attributes as? [String: String] else {
            TRTCLog.out("attributes error.")
            return
        }
        let seatInfoList = IMJsonHandle.getSeatListFromAttr(map: attr, seatSize: roomInfo.seatSize)
        let oldInfolist = self.seatInfoList
        self.seatInfoList = seatInfoList
        self.delegate?.onSeatInfoListChange(seatInfoList: seatInfoList)
        for index in 0..<self.roomInfo.seatSize {
            let oldInfo = oldInfolist[index]
            let newInfo = self.seatInfoList[index]
            if oldInfo.status != newInfo.status {
                switch newInfo.status {
                case TXSeatInfo.STATUS_UNUSED:
                    if oldInfo.status == TXSeatInfo.STATUS_CLOSE {
                        onSeatClose(index: index, isClose: false)
                    } else {
                        onSeatLeave(index: index, user: oldInfo.user)
                    }
                case TXSeatInfo.STATUS_USED:
                    onSeatTake(index: index, user: newInfo.user)
                case TXSeatInfo.STATUS_CLOSE:
                    onSeatClose(index: index, isClose: true)
                default:
                    break
                }
            }
            if oldInfo.mute != newInfo.mute {
                onSeatMute(index: index, mute: newInfo.mute)
            }
        }
    }
}

extension TXRoomService: V2TIMSignalingListener {
    public func onReceiveNewInvitation(_ inviteID: String!, inviter: String!, groupID: String!, inviteeList: [String]!, data: String!) {
        TRTCLog.out("recv new invitation:\(String(describing: inviteID)), from: \(String(describing: inviter))")
        guard let txInviteData = IMJsonHandle.parseInvitationMsg(json: data) else {
            TRTCLog.out("parse data error")
            return
        }
        guard txInviteData.roomId == roomId else {
            TRTCLog.out("roomId is not right")
            return
        }
        self.delegate?.onReceiveNewInvitation(identifier: inviteID, inviter: inviter, cmd: txInviteData.command, content: txInviteData.message)
    }
    
    public func onInviteeAccepted(_ inviteID: String!, invitee: String!, data: String!) {
        TRTCLog.out("recv accept invitation: \(inviteID ?? "") from: invitee:\(invitee ?? "")")
        self.delegate?.onInviteeAccepted(identifier: inviteID, invitee: invitee)
    }
    
    public func onInviteeRejected(_ inviteID: String!, invitee: String!, data: String!) {
        TRTCLog.out("recv accept invitation: \(inviteID ?? "") from: invitee:\(invitee ?? "")")
        self.delegate?.onInviteeRejected(identifier: inviteID, invitee: invitee)
    }
    
    public func onInvitationCancelled(_ inviteID: String!, inviter: String!, data: String!) {
        TRTCLog.out("recv accept invitation: \(inviteID ?? "") from: invitee:\(inviter ?? "")")
        self.delegate?.onInviteeCancelled(identifier: inviteID, invitee: inviter)
    }
}
