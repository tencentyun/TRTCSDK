//
//  TRTCVideoCall+internal.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/10/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import Foundation

extension TRTCVideoCall {
    
    /// handle new call model
    /// - Parameters:
    ///   - user: message's sender
    ///   - model: call model which have been sent
    ///   - leftTime: the time left for user to make response
    func handleCallModel(user: String,
                         model: VideoCallModel, leftTime: Double = 0) {
        defer {
            if curCallID == model.callid {
                curLastModel = model.copy()
            }
        }
        
        if (model.groupid?.count ?? 0) <= 0 {
            model.groupid = nil
        }
        
        func syncInvitingList() {
            if let _ = curGroupID {
                var filterUserIds = model.invitedList.filter { !curInvitingList.contains($0) }
                filterUserIds = filterUserIds.filter { $0 != VideoCallUtils.shared.curUserId() }
                curInvitingList.append(contentsOf: filterUserIds)
                //同步列表后发起超时
                for uid in filterUserIds {
                    checkTimeOut(uid: uid, time: leftTime)
                }
            }
        }
        
        switch model.action {
        case .dialing:
            if (model.groupid != nil &&
                !model.invitedList.contains(VideoCallUtils.shared.curUserId())) { //群聊但是邀请不包含自己不处理
                if curCallID == model.callid { //在房间中更新列表
                    syncInvitingList()
                    if curInvitingList.count > 0 {
                        if let dele = delegate { //同步列表
                            dele.onGroupCallInviteeListUpdate?(userIds: curInvitingList)
                        }
                    }
                }
                return
            }
            if isOnCalling { // tell busy
                if model.callid != curCallID {
                    sendModel(user: model.groupid ?? user,
                    action: .linebusy, model: model)
                }
            } else {
                isOnCalling = true
                curCallID = model.callid
                curRoomID = model.roomid
                if let groupid = model.groupid, groupid.count > 0 {
                    curGroupID = model.groupid
                }
                curType = model.calltype
                curSponsorForMe = user
                syncInvitingList()
                if let dele = delegate {
                    dele.onInvited?(sponsor: user, userIds: model.invitedList, isFromGroup: curGroupID == nil ? false : true)
                }
                //被邀请方检查超时
                checkTimeID = VideoCallUtils.shared.generateRoomID()
                DispatchQueue.main.asyncAfter(deadline: .now() + leftTime) { [cid = curCallID, weak self, checkID = checkTimeID] in
                    guard let self = self else {return}
                    if  cid == self.curCallID && checkID == self.checkTimeID
                        && !self.isRespSponsor {
                         self.isOnCalling = false
                        if let dele = self.delegate {
                            dele.onCallingTimeOut?()
                        }
                    }
                }
            }
        case .sponsorCancel:
            if curCallID == model.callid, let dele = delegate {
                isOnCalling = false
                dele.onCallingCancel?()
            }
        case .reject:
            if curCallID == model.callid, let dele = delegate {
                curInvitingList = curInvitingList.filter {
                    $0 != user
                }
                dele.onReject?(uid: user)
                checkAutoHangUp()
            }
        case .sponsorTimeout:
            if curCallID == model.callid, let dele = delegate {
                isOnCalling = false
                dele.onCallingTimeOut?()
                checkAutoHangUp()
            }
        case .hangup: 
            break
        case .linebusy:
            if curCallID == model.callid, let dele = delegate {
                curInvitingList = curInvitingList.filter {
                    $0 != user
                }
                dele.onLineBusy?(uid: user)
                checkAutoHangUp()
            }
        case .error:
            if curCallID == model.callid, let dele = delegate {
                curInvitingList = curInvitingList.filter {
                    $0 != user
                }
                dele.onError?(code: -1, msg: "系统错误")
                checkAutoHangUp()
            }
        default:
            debugPrint("📳 👻 WTF ????")
        }
    }
    
    /// 发送数据
    /// - Parameters:
    ///   - user: message send target
    ///   - action: signalling
    ///   - model: while the model is nil send models to current call ,
    ///    otherwise send models the call which is not related to current call, Only .linebusy at the moment.
    func sendModel(user: String, action: VideoCallAction,
                   model: VideoCallModel? = nil) {
        if user.count <= 0 {
            return
        }
        
        var realModel = generateModel(action: action)
        var isGroup = (curGroupID == user)
        
        if let paramModel = model {
            realModel = paramModel.copy()
            realModel.action = action
            if paramModel.groupid != nil {
                isGroup = true
            }
        }
         
        defer {
            if  realModel.action != .reject &&
                realModel.action != .hangup &&
                realModel.action != .sponsorCancel &&
                model == nil {
                curLastModel = realModel.copy()
            }
        }
        
        guard let data = VideoCallUtils.shared.callModel2Data(model: realModel) else {
            return
        }
        
        let msg = V2TIMManager.sharedInstance()?.createCustomMessage(data)
        let pushInfo = V2TIMOfflinePushInfo()
        if realModel.action == .dialing {
            pushInfo.desc = "您收到了一个语音通话请求"
            pushInfo.iOSSound = "00.caf"
        }
        if isGroup {
            V2TIMManager.sharedInstance()?.send(msg, receiver: nil, groupID: realModel.groupid ?? "", priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: pushInfo, progress: nil, succ: nil, fail: { [weak self] (code, error) in
                self?.delegate?.onError?(code: code, msg: error)
                debugPrint("send message error \(code) \(error ?? "")")
            })
        } else {
            V2TIMManager.sharedInstance()?.send(msg, receiver: user, groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: pushInfo, progress: nil, succ: nil, fail: { [weak self] (code, error) in
                self?.delegate?.onError?(code: code, msg: error)
                debugPrint("send message error \(code) \(error ?? "")")
            })
        }
        debugPrint("📳 send msg to \(user): call_id:\(realModel.callid), room_id:\(realModel.roomid), action:\(realModel.action.debug)")
    }
    
    func generateModel(action: VideoCallAction) -> VideoCallModel {
        let model: VideoCallModel = curLastModel.copy()
        model.action = action
        return model
    }
    
    func checkTimeOut(uid: String, time: Double) {
        let checkID = VideoCallUtils.shared.generateRoomID()
        checkTimeOutIDsMap[uid] = checkID
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [cid = curCallID, weak self, userID = uid, theCheckID = checkID] in
            guard let self = self else {return}
            if self.curCallID == cid && theCheckID == self.checkTimeOutIDsMap[uid] {
                let timeOut = !self.curRespList.contains(userID) &&
                    self.curInvitingList.contains(userID)
                if timeOut { //send timeout
                    if self.curGroupID == nil {
                        self.sendModel(user: userID, action: .sponsorTimeout)
                    }
                    if let del = self.delegate {
                        del.onNoResp?(uid: userID)
                    }
                    self.curInvitingList = self.curInvitingList.filter {
                        $0 != userID
                    }
                }
                self.curRespList = self.curRespList.filter {
                    $0 != userID
                }
                if timeOut {
                    self.checkAutoHangUp()
                }
            }
        }
    }
    
    func checkAutoHangUp() {
        //自动挂断
        if isInRoom && curRoomList.count == 0
            && curInvitingList.count == 0 {
            if let del = delegate {
                del.onCallEnd?()
            }
            hangup()
        }
    }
}
