//
//  TRTCAudioCallInterface.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 2020/2/11.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

// MARK: - ITRTCAudioCallInterface

/*
 * TRTC 语音通话接口
 * 本功能使用腾讯云实时音视频 / 腾讯云即时通信IM 组合实现
 * 使用方式如下
 * 1. 初始化
 * TRTCAudioCall.shared.setup()
 * 2. 监听回调
 * TRTCAudioCall.shared.delegate = self
 * 3. 登录到IM系统中
 * TRTCAudioCall.shared.login(sdkAppid, A, password, success, failed)
 * 4. 给B拨打电话
 * TRTCAudioCall.shared.call(B)
 * 5. 接听/拒绝电话
 * 此时B如果也登录了IM系统，会收到onInvited(A, null, false)回调
 * B 可以调用 TRTCAudioCall.shared.accept 接受 / TRTCAudioCall.shared.reject 拒绝
 * 6. 结束通话
 * 需要结束通话时，A、B 任意一方可以调用 TRTCAudioCall.shared.hangup() 挂断电话
 * 7. 销毁实例
 * TRTCAudioCall.shared.destroy()
 */

@objc protocol ITRTCAudioCallInterface {
    
    /// 回调代理
    weak var delegate: TRTCAudioCallDelegate? {get set}
    
    // MARK: - life-cycle
    
    /// 初始化函数，请在使用所有功能之前先调用该函数进行必要的初始化
    @objc func setup()
    
    /// 销毁函数，如果不需要再运行该实例，请调用该接口
    @objc func destroy()
    
    // MARK: - login
    
    /// 登录IM接口，所有功能需要先进行登录后才能使用
    /// - Parameters:
    ///   - sdkAppID: TRTC SDK AppID
    ///   - user: 用户名
    ///   - userSig: 用户签名
    ///   - success: 成功回调
    ///   - failed: 失败回调
    @objc func login(sdkAppID: UInt32,
                     user: String,
                     userSig: String,
                     success: @escaping (() -> Void),
                     failed: @escaping ((_ code: Int, _ message: String) -> Void))

    /// 登出接口，登出后无法再进行拨打操作
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failed: 失败回调
    @objc func logout(success: @escaping (() -> Void),
    failed: @escaping ((_ code: Int, _ message: String) -> Void))
    
    // MARK: - call
    
    /// c2c通话邀请
    /// - Parameters:
    ///   - userID: 用户ID | userID
    @objc func call(userID: String)
    
    /// 群聊通话邀请
    /// - Parameters:
    ///   - userIDs: 用户ID列表 | userIDs
    ///   - groupID: 群组ID | groupID
    /// - Note:
    ///    IM群组邀请通话，被邀请方会收到 onInvited 回调
    ///    如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到 onGroupCallInviteeListUpdate 回调
    @objc func groupCall(userIDs: [String], groupID: String)
    
    /// 接受当前通话 |
    ///  accept current call
    /// - Note:
    ///    当您作为被邀请方收到 onInvited 的回调时，可以调用该函数接听来电
    @objc func accept()
    
    /// 拒绝当前通话 |
    ///  reject cunrrent call
    /// - Note:
    ///    当您作为被邀请方收到 onInvited 的回调时，可以调用该函数拒绝来电
    @objc func reject()
    
    /// 挂断当前通话如果多人通话中有人未应答就发送取消 |
    /// In a multi-person call a cancel message will be sent if there have user who not respond
    /// - Note:
    ///    当您处于通话中，可以调用该函数结束通话
    @objc func hangup()
    
    // MARK: - Device
    
    /// isMute true:麦克风关闭 false:麦克风打开 |
    /// isMute true:micphone will be closed  false:micphone will be open
    @objc func setMicMute(isMute: Bool)
    
    /// isHandsFree true:开启免提 false:关闭免提 |
    /// isHandsFree true:Hands Free false:Headset
    @objc func setHandsFree(isHandsFree: Bool)

}
