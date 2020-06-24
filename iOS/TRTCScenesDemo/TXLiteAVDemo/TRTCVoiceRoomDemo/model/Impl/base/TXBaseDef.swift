//
//  TXBaseDef.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/9.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation
import HandyJSON

public typealias TXCallback = (Int32, String) -> Void // code msg
public typealias TXUserListCallback = (Int32, String, [TXUserInfo]) -> Void
public typealias TXRoomInfoListCallback = (Int32, String, [TXRoomInfo]) ->Void

public class TXRoomInfo: HandyJSON {
    var roomId: String = ""
    var memberCount: UInt32 = 0
    
    var ownerId: String = ""
    var ownerName: String = ""
    var roomName: String = ""
    var cover: String = ""
    var seatSize: Int = -1 // 如果是 -1 说明房间信息未正常赋值
    var needRequest: Int = 0
    
    required public init() {
        
    }
    
    public func mapping(mapper: HelpingMapper) {
        mapper >>> self.roomId
        mapper >>> self.memberCount
    }
}

public class TXUserInfo: HandyJSON {
    var userId: String = ""
    var userName: String = ""
    var avatarURL: String = ""
    
    required public init() {
        
    }
}

public class TXSeatInfo: HandyJSON {
    static let STATUS_UNUSED: Int = 0
    static let STATUS_USED: Int = 1
    static let STATUS_CLOSE: Int = 2
    /// 【字段含义】座位状态 0(unused)/1(used)/2(close)
    var status: Int = 0
    /// 【字段含义】座位是否禁言
    var mute: Bool = false
    /// 【字段含义】座位状态为1，存储user
    var user: String = ""
    
    required public init() {
        
    }
    
//    public func mapping(mapper: HelpingMapper) {
//        mapper <<<
//        self.mute <-- TransformOf<Bool, Int>(fromJSON: { (rawValue) -> Bool in
//            return rawValue == 1
//        }, toJSON: { (mute) -> Int in
//            return (mute ?? false) ? 1 : 0
//        })
//    }
}

public class TXInviteData: HandyJSON {
    var roomId: String = ""
    var command: String = ""
    var message: String = ""
    
    required public init() {
        
    }
}
