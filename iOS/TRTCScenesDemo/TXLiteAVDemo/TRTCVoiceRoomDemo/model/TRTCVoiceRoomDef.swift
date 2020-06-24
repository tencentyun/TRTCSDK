//
//  TRTCVoiceRoomParamProtocl.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/4.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation

public class VoiceRoomParam: NSObject {
    var roomName: String = "" // 房间名称
    var coverUrl: String = "" // 房间封面图
    var needRequest: Bool = false
    var seatCount: Int = 8
    var seatInfoList: [VoiceRoomSeatInfo] = []
    
    func toStirng() -> String {
        return "VoiceRoomParam { roomName=\"\(roomName)\", coverUrl=\"\(coverUrl)\" }"
    }
}

public class VoiceRoomSeatInfo: NSObject {
    /// 【字段含义】座位状态 0(unused)/1(used)/2(close)
    var status: Int = 0
    /// 【字段含义】座位是否禁言
    var mute: Bool = false
    /// 【字段含义】座位状态为1时，存储user info
    var userId: String = ""
    
    init(status: Int = 0, mute: Bool = false, userId: String = "") {
        self.status = status
        self.mute = mute
        self.userId = userId
        super.init()
    }
}

public class VoiceRoomUserInfo: NSObject {
    /// 【字段含义】用户唯一标识
    public var userId: String
    /// 【字段含义】用户昵称
    public var userName: String
    /// 【字段含义】用户头像
    public var userAvatar: String

    init(userId: String, userName: String, userAvatar: String) {
        self.userId = userId
        self.userName = userName
        self.userAvatar = userAvatar
        super.init()
    }
}


public final class VoiceRoomInfo: NSObject {
    public let roomID: Int
    public var roomName: String
    public var coverUrl: String
    public var ownerId: String
    public var ownerName: String
    public var memberCount: Int
    public var needRequest: Bool = false
    
    init(roomID: Int, roomName: String = "", coverUrl: String = "", ownerId: String, ownerName: String = "", memberCount: Int) {
        self.roomID = roomID
        self.roomName = roomName
        self.coverUrl = coverUrl
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.memberCount = memberCount
        super.init()
    }
}

