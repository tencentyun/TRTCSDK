//
//  TRTCLiveRoomIMAction+Handler.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/8.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit


extension TRTCLiveRoomImpl: V2TIMAdvancedMsgListener {
    public func onRecvNewMessage(_ msg: V2TIMMessage!) {
        if msg.elemType == .ELEM_TYPE_CUSTOM {
            if  let elem = msg.customElem,
                let data = elem.data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let action = TRTCLiveRoomIMActionType(rawValue: (json["action"] as? Int) ?? 0),
                let version = (json["version"] as? String)
            {
                if version != trtcLiveRoomProtocolVersion { //考虑兼容性问题
                    
                }
                handleActionMessage(action, elem:elem, message: msg, json: json)
            }
        } else if msg.elemType == .ELEM_TYPE_TEXT {
            if let elem = msg.textElem {
                handleActionMessage(.roomTextMsg, elem:elem, message: msg, json: ["":""])
            }
        }
    }
    
//  private func handleProfileMessage(_ element: TIMProfileSystemElem) {
        // TODO: 目前IM的逻辑是群成员修改个人资料后，群主收不到更新的消息
//        guard let userId = element.fromUser else {
//            return
//        }
//        TRTCLiveRoomIMAction.getMembers(userIdList: [userId], success: { users in
//            if let user = users.first {
//                self.memberManager.updateProfile(user.userId, name: user.userName, avatar: user.avatarURL)
//            }
//        }, error: nil)
//   }
    
    private func handleActionMessage(_ action: TRTCLiveRoomIMActionType, elem:V2TIMElem, message: V2TIMMessage, json: [String: Any]) {
        print("[TEST] - New message: \(action.rawValue), data: \(json)")
        
        // 判断消息是否超时，发送到接收间隔超过10秒被认为超时
        guard let sendTime = message.timestamp, sendTime.timeIntervalSinceNow > -10 else {
            return
        }
        
        guard let userID = message.sender else {
            return
        }

        let liveUser = TRTCLiveUserInfo()
        liveUser.userId = userID;
        liveUser.userName = message.nickName;
        liveUser.avatarURL = message.faceURL;
        
        if memberManager.anchors[liveUser.userId] == nil { //非主播 更新观众列表
            if action != .respondRoomPK {
                // 如果是响应PK的观众进房，则不属于观众列表
                memberManager.addAudience(liveUser)
            }
            
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
                        if self.status != .roomPK && id == self.pkAnchorInfo.uuid {
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
            status = .single
            if let pkAnchor = memberManager.pkAnchor {
                memberManager.removeAnchor(pkAnchor.userId)
            }
            if pkAnchorInfo.userId != nil && pkAnchorInfo.roomId != nil {
                delegate?.trtcLiveRoomOnQuitRoomPK?(self)
            }
            clearPKState()
            
        case .roomTextMsg:
            if let textElem = elem as? V2TIMTextElem, let text = textElem.text {
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
            if let roomStatus = json["type"] as? Int,
                let theStatus = TRTCLiveRoomLiveStatus(rawValue: roomStatus) {
                status = theStatus
            }
            
        case .unknown:
            assert(false)
        }
    }
}

extension TRTCLiveRoomImpl: V2TIMGroupListener {
    public func onMemberInvited(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
        for memberInfo in memberList {
            let user = TRTCLiveUserInfo()
            user.userId = memberInfo.userID
            user.userName = memberInfo.nickName
            user.avatarURL = memberInfo.faceURL
            self.memberManager.addAudience(user)
        }
    }
    
    public func onMemberLeave(_ groupID: String!, member: V2TIMGroupMemberInfo!) {
        memberManager.removeMember(member.userID)
    }
    
    public func onMemberEnter(_ groupID: String!, memberList: [V2TIMGroupMemberInfo]!) {
        for memberInfo in memberList {
            let user = TRTCLiveUserInfo()
            user.userId = memberInfo.userID
            user.userName = memberInfo.nickName
            user.avatarURL = memberInfo.faceURL
            self.memberManager.addAudience(user)
        }
    }
    
    public func onGroupInfoChanged(_ groupID: String!, changeInfoList: [V2TIMGroupChangeInfo]!) {
        if let info = changeInfoList.first,
            let customInfo = info.value.toJson(),
            let roomStatus = customInfo["type"] as? Int,
            let theStatus = TRTCLiveRoomLiveStatus(rawValue: roomStatus)
        {
            status = theStatus
        }
    }
    
    public func onGroupDismissed(_ groupID: String!, opUser: V2TIMGroupMemberInfo!) {
        handleRoomDismissed(isOwnerDeleted: true)
    }
    
    public func onRevokeAdministrator(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
        handleRoomDismissed(isOwnerDeleted: true)
    }
}
