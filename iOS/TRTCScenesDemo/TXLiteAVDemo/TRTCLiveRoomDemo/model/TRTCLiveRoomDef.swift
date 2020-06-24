//
//  TRTCLiveRoomModels.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/10.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

@objc public enum TRTCLiveRoomLiveStatus: Int {
    case none = 0
    case single = 1         //单人房间
    case linkMic = 2        //连麦
    case roomPK = 3         //PK
}

@objc public class TRTCCreateRoomParam: NSObject {
    /// 【字段含义】房间名称
    @objc var roomName: String = ""
    /// 【字段含义】房间封面图
    @objc var coverUrl: String = ""
    
    convenience init(roomName: String, coverUrl: String) {
        self.init()
        self.roomName = roomName
        self.coverUrl = coverUrl
    }
    
    public override var debugDescription: String {
        return "roomName: \(roomName), coverUrl: \(coverUrl)"
    }
}

@objc public class TRTCLiveRoomConfig: NSObject {
    
    /// 【字段含义】观众端使用CDN播放
    /// 【特殊说明】true: 默认进房使用CDN播放 false: 使用低延时播放
    @objc var useCDNFirst: Bool = false
    /// 【字段含义】CDN播放的域名地址
    @objc var cdnPlayDomain: String? = nil
    
    convenience init(useCDNFirst: Bool, cdnPlayDomain: String?) {
        self.init()
        self.useCDNFirst = useCDNFirst
        self.cdnPlayDomain = cdnPlayDomain
    }
}

@objc public class TRTCLiveRoomInfo: NSObject {
    /// 【字段含义】房间唯一标识
    @objc var roomId: String = ""
    /// 【字段含义】房间名称
    @objc var roomName: String = ""
    /// 【字段含义】房间封面图
    @objc var coverUrl: String = ""
    /// 【字段含义】房主id
    @objc var ownerId: String = ""
    /// 【字段含义】房主昵称
    @objc var ownerName: String = ""
    /// 【字段含义】cdn模式下的播放流地址
    @objc var streamUrl: String?
    /// 【字段含义】房间人数
    @objc var memberCount: Int = 0
    /// 【字段含义】房间状态 /单人/连麦/PK
    @objc var roomStatus: TRTCLiveRoomLiveStatus = .none
    
    convenience init(roomId: String, roomName: String, coverUrl: String, ownerId: String, ownerName: String, streamUrl: String?, memberCount: Int, roomStatus: TRTCLiveRoomLiveStatus) {
        self.init()
        self.roomId = roomId
        self.roomName = roomName
        self.coverUrl = coverUrl
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.streamUrl = streamUrl
        self.memberCount = memberCount
        self.roomStatus = roomStatus
    }
    
    public override var debugDescription: String {
        return "roomId: \(roomId), roomName: \(roomName), streamUrl: \(streamUrl ?? ""), memberCount: \(memberCount)"
    }
}

public class TRTCLiveUserInfo: NSObject {
    /// 【字段含义】用户唯一标识
    @objc var userId: String = ""
    /// 【字段含义】用户昵称
    @objc var userName: String = ""
    /// 【字段含义】用户头像
    @objc var avatarURL: String?
    /// 【字段含义】cdn模式下的播放流id
    @objc var streamId: String?
    /// 【字段含义】是否是主播
    @objc var isOwner = false

    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "name": userName,
            "streamId": streamId
        ].compactMapValues { $0 }
    }
    
    convenience init(profile: V2TIMGroupMemberFullInfo) {
        self.init()
        userId = profile.userID
        userName = profile.nickName ?? ""
        avatarURL = profile.faceURL
        isOwner = (profile.role == .GROUP_MEMBER_ROLE_SUPER)
    }
}
