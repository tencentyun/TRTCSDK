//
//  TRTCLiveRoomMemberManager.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/10.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

protocol TRTCLiveRoomMemberManagerDelegate: class {
    func memberManager(_ manager: TRTCLiveRoomMemberManager, onUserEnter user: TRTCLiveUserInfo, isAnchor: Bool)
    
    func memberManager(_ manager: TRTCLiveRoomMemberManager, onUserLeave user: TRTCLiveUserInfo, isAnchor: Bool)
    
    func memberManager(_ manager: TRTCLiveRoomMemberManager, onChangeStreamId streamID: String?, userId: String)
    
    func memberManager(_ manager: TRTCLiveRoomMemberManager, onChangeAnchorList anchorList: [[String: Any]])
}

class TRTCLiveRoomMemberManager: NSObject {
    weak var delegate: TRTCLiveRoomMemberManagerDelegate?
    // 房主
    var ownerId: String?
    
    // 主持人列表
    var anchors = [String: TRTCLiveUserInfo]()
    
    // 观众列表
    var audience: [TRTCLiveUserInfo] {
        return allMembers.filter { anchors[$0.userId] == nil }
    }
    
    // 跨房PK的主播
    var pkAnchor: TRTCLiveUserInfo?
    
    private var allMembers = [TRTCLiveUserInfo]()
}

extension TRTCLiveRoomMemberManager: TRTCLiveRoomMemberProtocol {
    func setOwner(_ user: TRTCLiveUserInfo) {
        allMembers.append(user)
        anchors[user.userId] = user
        ownerId = user.userId
        delegate?.memberManager(self, onUserEnter: user, isAnchor: true)
        delegate?.memberManager(self, onChangeAnchorList: anchorDataList)
    }
    
    func addAnchor(_ user: TRTCLiveUserInfo) {
        anchors[user.userId] = user
        delegate?.memberManager(self, onUserEnter: user, isAnchor: true)
        
//        if user.streamId != nil {
            delegate?.memberManager(self, onChangeAnchorList: anchorDataList)
//        }
    }
    
    func removeAnchor(_ userId: String) {
        if pkAnchor?.userId == userId {
            pkAnchor = nil
        }
        if let anchor = anchors[userId] {
            anchors[userId] = nil
            delegate?.memberManager(self, onUserLeave: anchor, isAnchor: true)
            // 主播离开变为观众时，不需要通知观众进入，否则会有重复通知。
//            if let audience = allMembers.first(where: { $0.userId == userId }) {
//                delegate?.memberManager(self, onUserEnter: audience, isAnchor: false)
//            }
            delegate?.memberManager(self, onChangeAnchorList: anchorDataList)
        }
    }
    
    func addAudience(_ user: TRTCLiveUserInfo) {
        if allMembers.contains(where: { $0.userId == user.userId }) {
            return
        }
        allMembers.append(user)
        delegate?.memberManager(self, onUserEnter: user, isAnchor: false)
    }
    
    func removeMember(_ userId: String) {
        guard let index = allMembers.firstIndex(where: { $0.userId == userId }) else {
            return
        }
        let user = allMembers[index]
        allMembers.remove(at: index)
        
        if anchors[userId] != nil {
            removeAnchor(userId)
        } else {
            delegate?.memberManager(self, onUserLeave: user, isAnchor: false)
        }
    }
    
    func preparePKAnchor(_ user: TRTCLiveUserInfo) {
        pkAnchor = user
    }
    
    func confirmPKAnchor(_ userId: String) {
        guard let user = pkAnchor else { return }
        anchors[user.userId] = user
        delegate?.memberManager(self, onUserEnter: user, isAnchor: true)
        delegate?.memberManager(self, onChangeAnchorList: anchorDataList)
    }
    
    func removePKAnchor() {
        pkAnchor = nil
    }
    
    func switchMember(_ userId: String, toAnchor: Bool, streamId: String?) {
        guard let user = allMembers.first(where: { $0.userId == userId }) else { return }
        
        if toAnchor {
            user.streamId = streamId
            if anchors[user.userId] != nil {
                anchors[user.userId] = user
            } else {
                anchors[user.userId] = user
//                delegate?.memberManager(self, onUserLeave: user, isAnchor: false)
//                delegate?.memberManager(self, onUserEnter: user, isAnchor: true)
            }
        } else {
            user.streamId = nil
            anchors[userId] = nil
//            delegate?.memberManager(self, onUserLeave: user, isAnchor: true)
//            delegate?.memberManager(self, onUserEnter: user, isAnchor: false)
        }
        delegate?.memberManager(self, onChangeAnchorList: anchorDataList)
    }
    
    func updateStream(_ userId: String, streamId: String?) {
        if let anchor = anchors[userId], anchor.streamId != streamId {
            anchor.streamId = streamId
            delegate?.memberManager(self, onChangeStreamId: streamId, userId: anchor.userId)
            delegate?.memberManager(self, onChangeAnchorList: anchorDataList)
        }
    }
    
    func updateProfile(_ userId: String, name: String, avatar: String?) {
        if let user = anchors[userId] {
            user.userName = name
            user.avatarURL = avatar
            delegate?.memberManager(self, onChangeAnchorList: anchorDataList)
        } else if let audience = allMembers.first(where: { $0.userId == userId }) {
            audience.userName = name
            audience.avatarURL = avatar
        }
        // TODO: 是不是给一个群成员资料变更的通知
    }

    func updateAnchorsWithGroupInfo(_ groupInfo: [String: Any]) {
        guard let anchorList = groupInfo["list"] as? [[String: Any]] else {
            assert(false)
            return
        }
        
        handleNewOrUpdatedAnchor(anchorList)
//        TODO: IM Group只支持128字节，所以只能保存主播状态，不会有主播移除的事件
//        handleRemovedAnchor(anchorList)
    }
    
    func setMembers(_ members: [TRTCLiveUserInfo], groupInfo: [String: Any]) {
        guard let anchorList = groupInfo["list"] as? [[String: Any]] else {
            return
        }
        
        self.allMembers = members
        
        anchorList.forEach { (anchorData) in
            guard let userId = anchorData["userId"] as? String,
                let name = anchorData["name"] as? String else
            {
                return
            }
            let streamId = anchorData["streamId"] as? String
            if let user = members.first(where: { $0.userId == userId }) {
                user.streamId = streamId
                anchors[userId] = user
                delegate?.memberManager(self, onUserEnter: user, isAnchor: true)
            } else {
                let avatar = anchorData["avatar"] as? String
                syncPKAnchor(userId, name: name, avatar: avatar, streamId: streamId)
            }
        }
        
        if let owner = members.first(where: { $0.isOwner }) {
            ownerId = owner.userId
        }
    }
    
    func clearMembers() {
        anchors.removeAll()
        allMembers.removeAll()
        pkAnchor = nil
    }
}

// MARK: - Private
private extension TRTCLiveRoomMemberManager {
    func handleNewOrUpdatedAnchor(_ anchorList: [[String: Any]]) {
        anchorList.forEach { (anchorData) in
            guard let userId = anchorData["userId"] as? String else { return }
            guard let name = anchorData["name"] as? String else { return }
            let avatar = anchorData["avatar"] as? String
            let streamId = anchorData["streamId"] as? String
            
            if let anchor = anchors[userId] {
                syncProfile(anchor, name: name, avatar: avatar)
                updateAnchor(anchor, streamId: streamId)
            } else if let audience = allMembers.first(where: { $0.userId == userId }) {
                syncProfile(audience, name: name, avatar: avatar)
                changeToAnchor(audience, streamId: streamId)
            } else {
                syncPKAnchor(userId, name: name, avatar: avatar, streamId: streamId)
            }
        }
    }
    
    func handleRemovedAnchor(_ anchorList: [[String: Any]]) {
        let newAnchorIds = anchorList.compactMap { $0["userId"] as? String }
        anchors.filter { (userId, _) -> Bool in
            return !newAnchorIds.contains(userId)
        }.forEach { (_, anchor) in
            if allMembers.contains(anchor) {
                changeToAudience(anchor)
            } else {
                removePKAnchor(anchor)
            }
        }
    }
    
    func updateAnchor(_ anchor: TRTCLiveUserInfo, streamId: String?) {
        if anchor.streamId == streamId {
            return
        }
        anchor.streamId = streamId
        delegate?.memberManager(self, onChangeStreamId: streamId, userId: anchor.userId)
    }
    
    func changeToAnchor(_ user: TRTCLiveUserInfo, streamId: String?) {
        user.streamId = streamId
        anchors[user.userId] = user
        
        self.delegate?.memberManager(self, onUserLeave: user, isAnchor: false)
        self.delegate?.memberManager(self, onUserEnter: user, isAnchor: true)
    }
    
    func changeToAudience(_ user: TRTCLiveUserInfo) {
        user.streamId = nil
        anchors.removeValue(forKey: user.userId)
        
        delegate?.memberManager(self, onUserLeave: user, isAnchor: true)
        delegate?.memberManager(self, onUserEnter: user, isAnchor: false)
    }
    
    func syncProfile(_ user: TRTCLiveUserInfo, name: String, avatar: String?) {
        user.userName = name
        user.avatarURL = avatar
    }
    
    func syncPKAnchor(_ userId: String, name: String, avatar: String?, streamId: String?) {
        let user = TRTCLiveUserInfo()
        user.userId = userId
        user.userName = name
        user.avatarURL = avatar
        user.streamId = streamId
        
        self.anchors[user.userId] = user
        self.delegate?.memberManager(self, onUserEnter: user, isAnchor: true)
    }
    
    func removePKAnchor(_ user: TRTCLiveUserInfo) {
        anchors.removeValue(forKey: user.userId)
        delegate?.memberManager(self, onUserLeave: user, isAnchor: true)
    }
    
    var anchorDataList: [[String: Any]] {
        if let userId = ownerId, let user = anchors[userId] {
            return [user.toDictionary()]
        }
        return []
    }
}
