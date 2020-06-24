//
//  TRTCAudioCall.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/6/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import Foundation

@objc public class TRTCAudioCall: NSObject,
                                  ITRTCAudioCallInterface,
                                  V2TIMAdvancedMsgListener {
    @objc public static let shared = TRTCAudioCall()
    
    private override init() {
        super.init()
    }
    
    @objc public func setup() {
        isOnCalling = false
    }
    
    @objc public func destroy() {
        delegate = nil
        V2TIMManager.sharedInstance()?.remove(self)
    }
    
    /// 是否正在通话
    var isOnCalling: Bool = false { // is on calling
        didSet {
            if isOnCalling && oldValue != isOnCalling { //开始通话
                
            } else if !isOnCalling && oldValue != isOnCalling { //退出通话
                curCallID = ""
                curRoomID = 0
                curType = .unknown
                curInvitingList = []
                curRespList = []
                curRoomList = []
                curSponsorForMe = ""
                checkTimeOutIDsMap = [:]
                checkTimeID = 0
                curLastModel = AudioCallModel()
                isRespSponsor = false
                isInRoom = false
            }
            debugPrint("📳 isOnCalling : \(isOnCalling)")
        }
    }
    
    /// 当前通话的唯一ID |
    /// only unique id for current call
    var curCallID: String {
        set {
            curLastModel.callid = newValue
        }
        get {
            return curLastModel.callid
        }
    }
    
    /// 当前通话房间号 |
    /// roomid for current call
    var curRoomID: UInt32 {
        set {
            curLastModel.roomid = newValue
        }
        get {
            return curLastModel.roomid
        }
    }
    
    @objc public var curType: AudioCallType {
        set {
            curLastModel.calltype = newValue
        }
        get {
            return curLastModel.calltype
        }
    }
    
    var curGroupID: String? {
        set {
            curLastModel.groupid = newValue
        }
        get {
            return curLastModel.groupid
        }
    }
    
    var checkTimeOutIDsMap: [String: UInt32] = [:]
    
    var checkTimeID: UInt32 = 0
    
    /// 当前通话我正在邀请的用户列表 |
    /// user list who had been invited by me and have no response
    var curInvitingList: [String] = []
    
    /// 当前通话被我邀请且回复我的用户列表 |
    /// user list who invited by me, and made response to me
    var curRespList: [String] = []
    
    /// 当前通话被我邀请且接受通话的用户列表 |
    /// user list who invited by me, and accepted to make a call
    var curRoomList: [String] = []
    
    /// 当前通话邀请我的人 |
    /// user who had invited me for current call
    var curSponsorForMe: String = ""
    
    /// 当前通话最后信令 |
    /// latest signalling
    var curLastModel: AudioCallModel = AudioCallModel()
    
    /// 是否回复当前邀请我的人 |
    /// weather i had make a response to the user who invited me
    var isRespSponsor: Bool = false
    
    /// 当前用户是否在通话房间中 |
    /// weather current user is in the room
    var isInRoom: Bool = false
    
    weak var delegate: TRTCAudioCallDelegate?
    
    let timeOut: Double = 30
    
    // MARK: - login
    
    @objc public func login(sdkAppID: UInt32,
                            user: String,
                            userSig: String,
                            success: @escaping (() -> Void),
                            failed: @escaping ((_ code: Int, _ message: String) -> Void)) {
        V2TIMManager.sharedInstance()?.initSDK(Int32(sdkAppID), config: nil, listener: nil)
        V2TIMManager.sharedInstance()?.add(self)

        if V2TIMManager.sharedInstance()?.getLoginUser() == user {
            success()
            //设置 APNS
            self.setupAPNs()
            return
        }

        assert(user.count > 0 || userSig.count > 0)
        
        let loginParam = TIMLoginParam.init()
        loginParam.identifier = user
        loginParam.userSig = userSig
        V2TIMManager.sharedInstance()?.login(user, userSig: userSig, succ: { [weak self] in
            success()
            //设置 APNS
            guard let `self` = self else { return }
            self.setupAPNs()
        }, fail: { [weak self] (code, errorDes) in
            self?.delegate?.onError?(code: code, msg: errorDes)
            failed(Int(code), errorDes ?? "nil")
        })
    }
    
    private func setupAPNs() {
        if let deviceToken = AppUtils.shared.appDelegate.deviceToken {
            let param = V2TIMAPNSConfig.init()
            param.businessID = Int32(timSdkBusiId)
            param.token = deviceToken
            V2TIMManager.sharedInstance()?.setAPNS(param, succ: {
                debugPrint("-----> 上传 token 成功 ")
            }, fail: { (code, error) in
                debugPrint("-----> 上传 token 失败 ")
            })
        }
    }
    
    @objc public func logout(success: @escaping (() -> Void),
                             failed: @escaping ((_ code: Int, _ message: String) -> Void)) {
        V2TIMManager.sharedInstance()?.logout({
            success()
        }, fail: { [weak self] (code, errorDes) in
            self?.delegate?.onError?(code: code, msg: errorDes)
            failed(Int(code), errorDes ?? "nil")
        })
    }
    
    // MARK: - call
    
    /// c2c通话邀请
    /// - Parameters:
    ///   - userID: 用户ID | userID
    ///   - type: 通话类型 （音频/视频）| voice or video call
    @objc public func call(userID: String) {
        invite(userIds: [userID], type: .audio)
    }
    
    /// 群聊通话邀请
    /// - Parameters:
    ///   - userIDs: 用户ID列表 | userIDs
    ///   - groupID: 群组ID | groupID
    @objc public func groupCall(userIDs: [String], groupID: String) {
        invite(userIds: userIDs, type: .audio, groupID: groupID)
    }
    
    /// 邀请用户进入当前通话，当前无通话则发起通话 |
    /// invite users to join call
    /// - Parameter userIds: 用户列表 |
    /// user list to invite
    internal func invite(userIds: [String], type: AudioCallType = .audio, groupID: String? = nil) {
        if !isOnCalling { //首次邀请
            curCallID = AudioCallUtils.shared.generateCallID()
            curRoomID = AudioCallUtils.shared.generateRoomID()
            curGroupID = groupID
            curType = type
            isOnCalling = true
            curLastModel.action = .dialing
            // trtc enter room
            enterRoom()
        }
        
        /// 不在当前邀请列表，新增加的邀请
        let filterUserIds = userIds.filter { !curInvitingList.contains($0) }
        curInvitingList.append(contentsOf: filterUserIds)
        curLastModel.invitedList = curInvitingList
        
        // 更新已经回复的列表，移除正在邀请的人
        curRespList = curRespList.filter { !curInvitingList.contains($0) }
        
        if let group = curGroupID, group.count > 0 { //群
            if filterUserIds.count > 0 {
                sendModel(user: group, action: .dialing)
            }
        } else { // 1v1
            for uid in filterUserIds {
                debugPrint("invite: \(uid)")
                sendModel(user: uid, action: .dialing)
            }
        }
        
        /// 发起方检查超时与否
        for uid in filterUserIds {
            checkTimeOut(uid: uid, time: timeOut)
        }
        
    }
    
    /// 接受当前通话 |
    ///  accept current call
    @objc public func accept() {
        isRespSponsor = true
        // trtc enter room
        enterRoom()
    }
    
    /// 拒绝当前通话 |
    ///  reject cunrrent call
    @objc public func reject() {
        isRespSponsor = true
        sendModel(user: curGroupID ?? curSponsorForMe, action: .reject)
        isOnCalling = false
    }
    
    /// 挂断多人通话如果有人未应答就发送取消 |
    /// In a multi-person call a cancel message will be sent if there have user who not respond
    @objc public func hangup() {
        if !isOnCalling {
            return
        }
        if !isInRoom {
            reject()
            return
        }
        
        if let group = curGroupID { // 群
            if curRoomList.count == 0 {
                if curInvitingList.count > 0 {
                    /// 没有应答的人取消
                    sendModel(user: group, action: .sponsorCancel)
                }
                //挂断
                sendModel(user: group, action: .hangup)
            }
        } else { // 1v1
            for user in curInvitingList {
                /// 没有应答的人取消
                sendModel(user: user, action: .sponsorCancel)
            }
            
            if let user = curRoomList.first , curRoomList.count == 1 { // 1v1 hangup
                //挂断
                sendModel(user: user, action: .hangup)
            }
        }
        quitRoom()
        isOnCalling = false
    }
    
    // MARK: - device
    
    @objc public func startRemoteView(userId: String, view: UIView) {
        TRTCCloud.sharedInstance()?.startRemoteView(userId, view: view)
    }
    
    @objc public var isMicMute: Bool = false {
        didSet {
            TRTCCloud.sharedInstance()?.muteLocalAudio(isMicMute)
        }
    }
    
    @objc public var isHandsFreeOn: Bool = true {
        didSet {
            TRTCCloud.sharedInstance()?.setAudioRoute(isHandsFreeOn ? .modeSpeakerphone : .modeEarpiece)
        }
    }
    
    @objc public func setMicMute(isMute: Bool) {
        isMicMute = isMute
    }
    
    @objc public func setHandsFree(isHandsFree: Bool) {
        isHandsFreeOn = isHandsFree
    }
}
