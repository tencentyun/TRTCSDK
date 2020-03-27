//
//  TRTCLiveRoomIMAction+Handler.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/8.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit


extension TRTCLiveRoomImpl: TIMMessageListener {
    public func onNewMessage(_ msgs: [Any]!) {
        guard let messages = msgs as? [TIMMessage] else { return }
        messages.forEach { message in
            handleNewMessage(message)
        }
    }
    
    private func handleNewMessage(_ message: TIMMessage) {
        if let groupSystemElem = message.getElem(0) as? TIMGroupSystemElem {
            self.handleGroupSystemMessage(groupSystemElem)
        } else if let profileElem = message.getElem(0) as? TIMProfileSystemElem {
            self.handleProfileMessage(profileElem)
        } else if let customElem = message.getElem(0) as? TIMCustomElem,
            let data = customElem.data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let action = TRTCLiveRoomIMActionType(rawValue: (json["action"] as? Int) ?? 0),
            let version = (json["version"] as? String)
        {
            if version != trtcLiveRoomProtocolVersion { //考虑兼容性问题
                
            }
            message.getSenderProfile { [weak self] (senderProfile) in
                if let sender = senderProfile {
                    self?.handleActionMessage(action, message: message, json: json, sender: sender)
                } else {
                    let sender = TIMUserProfile()
                    sender.identifier = message.sender()
                    self?.handleActionMessage(action, message: message, json: json, sender: sender)
                }
            }
        }
    }
    
    private func handleGroupSystemMessage(_ element: TIMGroupSystemElem) {
        if element.type == .DELETE_GROUP_TYPE {
            handleRoomDismissed(isOwnerDeleted: true)
        } else if element.type == .CANCEL_ADMIN_TYPE {
            handleRoomDismissed(isOwnerDeleted: false)
        }
    }
    
    private func handleProfileMessage(_ element: TIMProfileSystemElem) {
        // TODO: 目前IM的逻辑是群成员修改个人资料后，群主收不到更新的消息
//        guard let userId = element.fromUser else {
//            return
//        }
//        TRTCLiveRoomIMAction.getMembers(userIdList: [userId], success: { users in
//            if let user = users.first {
//                self.memberManager.updateProfile(user.userId, name: user.userName, avatar: user.avatarURL)
//            }
//        }, error: nil)
    }
    
    private func handleActionMessage(_ action: TRTCLiveRoomIMActionType, message: TIMMessage, json: [String: Any], sender: TIMUserProfile) {
        print("[TEST] - New message: \(action.rawValue), data: \(json)")
        
        // 判断消息是否超时，发送到接收间隔超过10秒被认为超时
        guard let sendTime = message.timestamp(), sendTime.timeIntervalSinceNow > -10 else {
            return
        }
        
        guard let userID = sender.identifier else {
            return
        }
        let liveUser = TRTCLiveUserInfo(profile: sender)
        
        if memberManager.anchors[liveUser.userId] == nil { //非主播 更新观众列表
            memberManager.addAudience(liveUser)
        }
        
        switch action {
        case .requestJoinAnchor:
            handleJoinAnchorRequest(from: liveUser, reason: json["reason"] as? String)
            
        case .respondJoinAnchor:
            if let agreed = json["accept"] as? Bool,
                let callback = requestJoinAnchorCallback
            {
                if agreed {
                    switchRoleOnLinkMic(isLinkMic: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + trtcLiveCheckStatusTimeOut) { [id = joinAnchorInfo.uuid] in //检查 连麦 主播是否进房
                        if self.memberManager.anchors[userID] == nil && id == self.joinAnchorInfo.uuid {
                            self.kickoutJoinAnchor(userID: userID, callback: nil)
                            self.clearJoinState()
                        } else {
                            self.clearJoinState(shouldRemove: false)
                        }
                    }
                } else {
                    clearJoinState()
                }
                let reason = json["reason"] as? String?
                callback(agreed, reason ?? "")
                requestJoinAnchorCallback = nil
            }
            
        case .kickoutJoinAnchor:
            delegate?.trtcLiveRoomOnKickoutJoinAnchor?(self)
            switchRoleOnLinkMic(isLinkMic: false)
            
        case .notifyJoinAnchorStream:
            if let streamId = json["stream_id"] as? String {
                startLinkMic(userId: userID, streamId: streamId)
            }

        case .requestRoomPK:
            if let roomId = json["from_room_id"] as? String,
                let streamId = json["from_stream_id"] as? String
            {
                handleRoomPKRequest(from: liveUser, roomId: roomId, streamId: streamId)
            }
            
        case .respondRoomPK:
            if let agreed = json["accept"] as? Bool,
                let reason = json["reason"] as? String,
                let streamId = json["stream_id"] as? String,
                let callback = requestRoomPKCallback
            {
                if agreed {
                    startRoomPK(with: liveUser, streamId: streamId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + trtcLiveCheckStatusTimeOut) { [id = pkAnchorInfo.uuid] in //检查 PK 主播是否进房
                        if self.type != .roomPK && id == self.pkAnchorInfo.uuid {
                            self.quitRoomPK(callback: nil)
                            self.clearPKState()
                        }
                    }
                } else {
                    clearPKState()
                }
                callback(agreed, reason)
                requestRoomPKCallback = nil
            }
            
        case .quitRoomPK:
            type = .single
            if let pkAnchor = memberManager.pkAnchor {
                memberManager.removeAnchor(pkAnchor.userId)
            }
            if pkAnchorInfo.userId != nil && pkAnchorInfo.roomId != nil {
                delegate?.trtcLiveRoomOnQuitRoomPK?(self)
            }
            clearPKState()
            
        case .roomTextMsg:
            if let textElem = message.getElem(1) as? TIMTextElem, let text = textElem.text {
                delegate?.trtcLiveRoom?(self, onRecvRoomTextMsg: text, fromUser: liveUser)
            }
            
        case .roomCustomMsg:
            if let command = json["command"] as? String,
                let message = json["message"] as? String
            {
                delegate?.trtcLiveRoom?(self, onRecvRoomCustomMsg: command, message: message, fromUser: liveUser)
            }
            
        case .updateGroupInfo:
            memberManager.updateAnchorsWithGroupInfo(json)
            if let roomType = json["type"] as? Int,
                let theType = TRTCLiveRoomLiveType(rawValue: roomType) {
                type = theType
            }
            
        case .unknown:
            assert(false)
        }
    }
}

extension TRTCLiveRoomImpl: TIMGroupEventListener {
    public func onGroupTipsEvent(_ elem: TIMGroupTipsElem!) {
        if elem.type == .INVITE {
            TRTCLiveRoomIMAction.getMembers(userIdList: [elem.opUser], success: { users in
                if let user = users.first {
                    self.memberManager.addAudience(user)
                }
            }) { (code, message) in
                print("[TEST] - Get new member info failed: \(code), \(message ?? "")")
            }
        } else if elem.type == .QUIT_GRP {
            memberManager.removeMember(elem.opUser)
        } else if elem.type == .INFO_CHANGE { //type change
            if let info = elem.groupChangeList.first,
                let customInfo = info.value.toJson(),
                let roomType = customInfo["type"] as? Int,
                let theType = TRTCLiveRoomLiveType(rawValue: roomType)
            {
                type = theType
            }
        }
    }
}
