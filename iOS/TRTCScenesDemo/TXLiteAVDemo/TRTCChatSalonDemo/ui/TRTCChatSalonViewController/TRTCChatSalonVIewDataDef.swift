//
//  TRTCChatSalonModelDef.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/15.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

enum ChatSalonViewType {
    case anchor
    case audience
}

/// Voice Room 定义常量的类
class ChatSalonConstants {
    public static let TYPE_VOICE_ROOM = "chatSalon"
    // 直播端右下角listview显示的type
    public static let CMD_REQUEST_TAKE_SEAT = "1"
    public static let CMD_PICK_UP_SEAT = "2"
}

/// 记录房间座位信息的Model
struct ChatSalonSeatInfoModel {
    var seatIndex: Int = -1
    var isClosed: Bool = false
    var isUsed: Bool = false
    var isOwner: Bool = false
    var seatInfo: ChatSalonSeatInfo?
    var seatUser: ChatSalonUserInfo?
    var action: ((ChatSalonSeatInfoModel) -> Void)? // 入参为当前Model对象
    var isTalking = false
}

/// 记录房间消息列表的Model
struct CSMsgEntity {
    public static let TYPE_NORMAL     = 0;
    public static let TYPE_WAIT_AGREE = 1;
    public static let TYPE_AGREED     = 2;
    
    let userID: String
    let userName: String
    let content: String
    let invitedId: String
    var type: Int
}

/// 记录房间上麦申请的Model
struct CSMemberRequestEntity {
    public static let TYPE_WAIT_AGREE = 1;
    public static let TYPE_AGREED     = 2;
    
    let userID: String
    var userInfo: ChatSalonUserInfo
    let content: String
    var invitedId: String
    var type: Int
    var action: (Int) -> Void // 点击同意上麦按钮的动作
}

struct CSAudienceInfoModel {
    
    static let TYPE_IDEL = 0
    static let TYPE_IN_SEAT = 1
    static let TYPE_WAIT_AGREE = 2
    
    var type: Int = 0 // 观众类型
    var userInfo: ChatSalonUserInfo
    var action: (Int) -> Void // 点击邀请按钮的动作
}

struct CSSeatInvitation {
    let seatIndex: Int
    let inviteUserId: String
}
