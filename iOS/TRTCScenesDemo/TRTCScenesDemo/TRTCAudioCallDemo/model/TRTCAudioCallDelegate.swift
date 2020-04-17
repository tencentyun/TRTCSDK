//
//  TRTCAudioCallDelegate.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 2020/2/11.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

// MARK: - TRTCAudioCallDelegate

@objc protocol TRTCAudioCallDelegate {
    // common callback
    
    /// sdk内部发生了错误 | sdk error
    /// - Parameters:
    ///   - code: 错误码
    ///   - msg: 错误消息
    @objc optional func onError(code: Int32, msg: String?)
    
    /// 被邀请通话回调 | invitee callback
    /// - Parameter userIds: 邀请列表 (invited list)
    @objc optional func onInvited(sponsor: String, userIds: [String], isFromGroup: Bool)
    
    /// 群聊更新邀请列表回调 | update current inviteeList in group calling
    /// - Parameter userIds: 邀请列表 | inviteeList
    @objc optional func onGroupCallInviteeListUpdate(userIds: [String])
    
    /// 进入通话回调 | user enter room callback
    /// - Parameter uid: userid
    @objc optional func onUserEnter(uid: String)
    
    /// 离开通话回调 | user leave room callback
    /// - Parameter uid: userid
    @objc optional func onUserLeave(uid: String)
    
    /// 用户是否开启音频上行回调 | is user audio available callback
    /// - Parameters:
    ///   - uid: 用户ID | userID
    ///   - available: 是否有效 | available
    @objc optional func onUserAudioAvailable(uid: String, available: Bool)
    
    /// 用户音量回调
    /// - Parameter uid: 用户ID | userID
    @objc optional func onUserVoiceVolume(uid: String, volume: UInt32)
    
    /// 拒绝通话回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
    /// reject callback only worked for Sponsor, others should use onUserEnter)
    /// - Parameter uid: userid
    @objc optional func onReject(uid: String)
    
    /// 无回应回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
    /// no response callback only worked for Sponsor, others should use onUserEnter)
    /// - Parameter uid: userid
    @objc optional func onNoResp(uid: String)
    
    /// 通话占线回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
    /// linebusy callback only worked for Sponsor, others should use onUserEnter
    /// - Parameter uid: userid
    @objc optional func onLineBusy(uid: String)
    
    // invitee callback
    
    /// 当前通话被取消回调 | current call had been canceled callback
    @objc optional func onCallingCancel()
    
    /// 通话超时的回调 | timeout callback
    @objc optional func onCallingTimeOut()
    
    /// 通话结束 | end callback
    @objc optional func onCallEnd()
}
