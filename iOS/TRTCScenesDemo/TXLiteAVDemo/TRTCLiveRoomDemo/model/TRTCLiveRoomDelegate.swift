//
//  TRTCLiveRoomDelegate.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/8.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

@objc public protocol TRTCLiveRoomDelegate: class {
    /// 出错回调
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onError code: Int, message: String?)
    
    /// 警告回调
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onWarning code: Int, message: String?)
    
    /// 日志回调
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onDebugLog log: String)

    /// 房间销毁回调
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRoomDestroy roomID: String)

    /// 直播房间信息变更回调
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRoomInfoChange info: TRTCLiveRoomInfo)

    /// 主播进房回调
    /// - Note: 主播包括房间大主播、连麦观众和跨房PK主播
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAnchorEnter userID: String)
    
    /// 主播离开回调
    /// - Note: 主播包括房间大主播、连麦观众和跨房PK主播
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAnchorExit userID: String)

    /// 观众进房回调
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAudienceEnter user: TRTCLiveUserInfo)

    /// 观众离开回调
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAudienceExit user: TRTCLiveUserInfo)

    /// 主播收到观众的连麦申请
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRequestJoinAnchor user: TRTCLiveUserInfo, reason: String?, timeout: Double)

    /// 观众收到主播发来的下麦通知
    @objc optional func trtcLiveRoomOnKickoutJoinAnchor(_ trtcLiveRoom: TRTCLiveRoomImpl)
    
    /// 主播收到其他主播的跨房PK申请
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRequestRoomPK user: TRTCLiveUserInfo, timeout: Double)

    /// 主播收到PK中对方主播结束PK的通知
    @objc optional func trtcLiveRoomOnQuitRoomPK(_ trtcLiveRoom: TRTCLiveRoomImpl)

    /// 房间成员收到群发的文本消息
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRecvRoomTextMsg message: String, fromUser user: TRTCLiveUserInfo)
    
    /// 房间成员收到群发的自定义消息
    @objc optional func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRecvRoomCustomMsg command: String, message: String, fromUser user: TRTCLiveUserInfo)
}
