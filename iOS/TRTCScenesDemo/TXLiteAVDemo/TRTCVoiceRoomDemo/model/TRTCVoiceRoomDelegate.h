//
//  TRTCVoiceRoomDelegate.h
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/7/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#ifndef TRTCVoiceRoomDelegate_h
#define TRTCVoiceRoomDelegate_h

#import "TRTCVoiceRoomDef.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TRTCVoiceRoomDelegate <NSObject>

/// 错误回调
/// @param code 错误码
/// @param message 错误信息
- (void)onError:(int)code
                message:(NSString*)message
NS_SWIFT_NAME(onError(code:message:));

/// 警告回调
/// @param code 警告码
/// @param message 警告信息
- (void)onWarning:(int)code
                  message:(NSString *)message
NS_SWIFT_NAME(onWarning(code:message:));

/// Debug日志
/// @param message 信息
- (void)onDebugLog:(NSString *)message
NS_SWIFT_NAME(onDebugLog(message:));

/// 房间销毁回调
/// @param message 销毁信息
- (void)onRoomDestroy:(NSString *)message
NS_SWIFT_NAME(onRoomDestroy(message:));

/// 房间信息变更回调
/// @param roomInfo 房间信息
- (void)onRoomInfoChange:(VoiceRoomInfo *)roomInfo
NS_SWIFT_NAME(onRoomInfoChange(roomInfo:));

/// 房间作为变更回调
/// @param seatInfolist 座位列表信息
- (void)onSeatInfoChange:(NSArray<VoiceRoomSeatInfo *> *)seatInfolist
NS_SWIFT_NAME(onSeatListChange(seatInfoList:));

/// 主播上麦回调
/// @param index 麦位号
/// @param user 用户信息
- (void)onAnchorEnterSeat:(NSInteger)index
                              user:(VoiceRoomUserInfo *)user
NS_SWIFT_NAME(onAnchorEnterSeat(index:user:));

/// 主播下麦回调
/// @param index 麦位号
/// @param user 用户信息
- (void)onAnchorLeaveSeat:(NSInteger)index
                     user:(VoiceRoomUserInfo *)user
NS_SWIFT_NAME(onAnchorLeaveSeat(index:user:));

/// 座位静音状态回调
/// @param index 座位号
/// @param isMute 静音状态
- (void)onSeatMute:(NSInteger)index
            isMute:(BOOL)isMute
NS_SWIFT_NAME(onSeatMute(index:isMute:));

/// 座位关闭回调
/// @param index 座位号
/// @param isClose 是否关闭
- (void)onSeatClose:(NSInteger)index
            isClose:(BOOL)isClose
NS_SWIFT_NAME(onSeatClose(index:isClose:));

/// 观众进房回调
/// @param userInfo 观众信息
- (void)onAudienceEnter:(VoiceRoomUserInfo *)userInfo
NS_SWIFT_NAME(onAudienceEnter(userInfo:));

/// 观众退房回调
/// @param userInfo 观众信息
- (void)onAudienceExit:(VoiceRoomUserInfo *)userInfo
NS_SWIFT_NAME(onAudienceExit(userInfo:));

/// 用户音量变动回调
/// @param userId 用户ID
/// @param volume 音量信息
- (void)onUserVolumeUpdate:(NSString *)userId
                              volume:(NSInteger)volume
NS_SWIFT_NAME(onUserVolumeUpdate(userId:volume:));

/// 文本消息接收回调
/// @param message 消息内容
/// @param userInfo 消息发送方信息
- (void)onRecvRoomTextMsg:(NSString *)message
                 userInfo:(VoiceRoomUserInfo *)userInfo
NS_SWIFT_NAME(onRecvRoomTextMsg(message:userInfo:));

/// 自定义消息（信令消息）接收回调
/// @param cmd 信令
/// @param message 消息内容
/// @param userInfo 发送方信息
- (void)onRecvRoomCustomMsg:(NSString *)cmd
                    message:(NSString *)message
                   userInfo:(VoiceRoomUserInfo *)userInfo
NS_SWIFT_NAME(onRecvRoomCustomMsg(cmd:message:userInfo:));

/// 邀请信息接收回调
/// @param identifier 目标用户ID
/// @param inviter 邀请者ID
/// @param cmd 信令
/// @param content 内容
- (void)onReceiveNewInvitation:(NSString *)identifier
                       inviter:(NSString *)inviter
                           cmd:(NSString *)cmd
                       content:(NSString *)content
NS_SWIFT_NAME(onReceiveNewInvitation(identifier:inviter:cmd:content:));

/// 邀请被接受回调
/// @param identifier 目标用户ID
/// @param invitee 邀请者ID
- (void)onInviteeAccepted:(NSString *)identifier
                  invitee:(NSString *)invitee
NS_SWIFT_NAME(onInviteeAccepted(identifier:invitee:));

/// 邀请被拒绝回调
/// @param identifier 目标用户ID
/// @param invitee 邀请者ID
- (void)onInviteeRejected:(NSString *)identifier
                  invitee:(NSString *)invitee
NS_SWIFT_NAME(onInviteeRejected(identifier:invitee:));

/// 邀请被取消回调
/// @param identifier 目标用户ID
/// @param invitee 邀请者ID
- (void)onInvitationCancelled:(NSString *)identifier
                      invitee:(NSString *)invitee NS_SWIFT_NAME(onInvitationCancelled(identifier:invitee:));

@end

NS_ASSUME_NONNULL_END


#endif /* TRTCVoiceRoomDelegate_h */


