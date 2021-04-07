//
//  TRTCChatSalonDelegate.h
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/7/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#ifndef TRTCChatSalonDelegate_h
#define TRTCChatSalonDelegate_h

#import "TRTCChatSalonDef.h"

NS_ASSUME_NONNULL_BEGIN

@class TRTCVolumeInfo;

@protocol TRTCChatSalonDelegate <NSObject>

/// 组件出错信息，请务必监听并处理
/// @param code 错误码
/// @param message 错误信息
- (void)onError:(int)code
                message:(NSString*)message
NS_SWIFT_NAME(onError(code:message:));

/// 组件告警信息
/// @param code 警告码
/// @param message 警告信息
- (void)onWarning:(int)code
                  message:(NSString *)message
NS_SWIFT_NAME(onWarning(code:message:));

/// 组件log信息
/// @param message 信息
- (void)onDebugLog:(NSString *)message
NS_SWIFT_NAME(onDebugLog(message:));

/// 房间被销毁，当主播调用destroyRoom后，观众会收到该回调
/// @param message 销毁信息
- (void)onRoomDestroy:(NSString *)message
NS_SWIFT_NAME(onRoomDestroy(message:));

/// 房间信息改变的通知
/// @param roomInfo 房间信息
- (void)onRoomInfoChange:(ChatSalonInfo *)roomInfo
NS_SWIFT_NAME(onRoomInfoChange(roomInfo:));

/// 有成员上麦(主动上麦/主播抱人上麦)
/// @param user 用户信息
- (void)onAnchorEnterSeat:(ChatSalonUserInfo *)user
NS_SWIFT_NAME(onAnchorEnterSeat(user:));

/// 有成员下麦(主动下麦/主播踢人下麦)
/// @param user 用户信息
- (void)onAnchorLeaveSeat:(ChatSalonUserInfo *)user
NS_SWIFT_NAME(onAnchorLeaveSeat(user:));

/// 主播禁麦
/// @param isMute 静音状态
- (void)onSeatMute:(NSString *)userID
            isMute:(BOOL)isMute
NS_SWIFT_NAME(onSeatMute(userID:isMute:));

/// 观众进入房间
/// @param userInfo 观众信息
- (void)onAudienceEnter:(ChatSalonUserInfo *)userInfo
NS_SWIFT_NAME(onAudienceEnter(userInfo:));

/// 观众离开房间
/// @param userInfo 观众信息
- (void)onAudienceExit:(ChatSalonUserInfo *)userInfo
NS_SWIFT_NAME(onAudienceExit(userInfo:));

/// 上麦成员的音量变化
/// @param userVolumes 各个用户音量信息
/// @param totalVolume 整体音量信息
- (void)onUserVolumeUpdate:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume
NS_SWIFT_NAME(onUserVolumeUpdate(userVolumes:totalVolume:));

/// 收到文本消息
/// @param message 消息内容
/// @param userInfo 消息发送方信息
- (void)onRecvRoomTextMsg:(NSString *)message
                 userInfo:(ChatSalonUserInfo *)userInfo
NS_SWIFT_NAME(onRecvRoomTextMsg(message:userInfo:));

/// 收到自定义消息
/// @param cmd 信令
/// @param message 消息内容
/// @param userInfo 发送方信息
- (void)onRecvRoomCustomMsg:(NSString *)cmd
                    message:(NSString *)message
                   userInfo:(ChatSalonUserInfo *)userInfo
NS_SWIFT_NAME(onRecvRoomCustomMsg(cmd:message:userInfo:));

/// 收到新的邀请请求
/// @param identifier 目标用户ID
/// @param inviter 邀请者ID
/// @param cmd 信令
/// @param content 内容
- (void)onReceiveNewInvitation:(NSString *)identifier
                       inviter:(NSString *)inviter
                           cmd:(NSString *)cmd
                       content:(NSString *)content
NS_SWIFT_NAME(onReceiveNewInvitation(identifier:inviter:cmd:content:));

/// 被邀请者接受邀请
/// @param identifier 目标用户ID
/// @param invitee 邀请者ID
- (void)onInviteeAccepted:(NSString *)identifier
                  invitee:(NSString *)invitee
NS_SWIFT_NAME(onInviteeAccepted(identifier:invitee:));

/// 被邀请者拒绝邀请
/// @param identifier 目标用户ID
/// @param invitee 邀请者ID
- (void)onInviteeRejected:(NSString *)identifier
                  invitee:(NSString *)invitee
NS_SWIFT_NAME(onInviteeRejected(identifier:invitee:));

/// 邀请人取消邀请
/// @param identifier 目标用户ID
/// @param invitee 邀请者ID
- (void)onInvitationCancelled:(NSString *)identifier
                      invitee:(NSString *)invitee NS_SWIFT_NAME(onInvitationCancelled(identifier:invitee:));

/// 邀请超时
/// @param identifier 邀请 ID
- (void)onInvitationTimeout:(NSString *)identifier NS_SWIFT_NAME(onInvitationTimeout(identifier:));

@end

NS_ASSUME_NONNULL_END


#endif /* TRTCChatSalonDelegate_h */


