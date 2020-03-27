//
//  TRTCLiveRoomMemberAnchorActionProtocol.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/13.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

// 房间成员主动更新的接口
protocol TRTCLiveRoomMemberProtocol: class {
    /// 更新主持人信息，主持人创建房间后设置
    /// - Parameter user: 主持人
    func setOwner(_ user: TRTCLiveUserInfo)
    
    /// 添加主持人
    func addAnchor(_ user: TRTCLiveUserInfo)
    
    /// 移除主持人，包括跨房PK的主持人，或连麦的观众
    /// - Parameter userId: 主持人用户ID
    func removeAnchor(_ userId: String)

    /// 添加观众
    /// - Parameter user: 用户对象
    func addAudience(_ user: TRTCLiveUserInfo)
    
    /// 移除成员（主持人或观众）
    /// - Parameter userId: 用户ID
    func removeMember(_ userId: String)

    /// 预添加跨房PK的主持人，不会回调用户主持人进房的通知
    /// - Parameter user: 主持人
    func preparePKAnchor(_ user: TRTCLiveUserInfo)
    
    /// TRTC收到了连麦的视频流之后，确认连麦主持人，此时回调主持人进房通知，并更新房间信息
    /// - Parameter userId: 连麦主持人ID
    func confirmPKAnchor(_ userId: String)
    
    /// 切换房间成员的上麦状态
    /// - Parameters:
    ///   - userId: 成员用户ID
    ///   - isAnchor: 是否上麦
    func switchMember(_ userId: String, toAnchor: Bool, streamId: String?)
    
    /// 更新房间主持人的视频流ID
    /// - Parameters:
    ///   - streamId: 流ID
    ///   - userId: 主持人ID
    func updateStream(_ userId: String, streamId: String?)
    
    /// 更新房间成员信息
    func updateProfile(_ userId: String, name: String, avatar: String?)
    
    /// 观众端收到更新的groupInfo，解析并更新主持人列表
    /// - Parameter groupInfo: IM房间信息，记录了主持人列表
    func updateAnchorsWithGroupInfo(_ groupInfo: [String: Any])
    
    /// 主播或观众刚加入房间后，同步全部成员
    /// - Parameters:
    ///   - members: 全部成员（包括主持人和观众）
    ///   - groupInfo: IM房间信息，记录了主持人列表
    func setMembers(_ members: [TRTCLiveUserInfo], groupInfo: [String: Any])
    
    /// 清空房间的全部成员
    func clearMembers()
}
