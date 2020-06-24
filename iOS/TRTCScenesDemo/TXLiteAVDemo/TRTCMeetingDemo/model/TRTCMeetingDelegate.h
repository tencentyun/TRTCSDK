//
//  TRTCMeetingDelegate.h
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/21/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import "TRTCMeetingDef.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TRTCMeetingDelegate <NSObject>

@optional

- (void)onError:(NSInteger)code message:(NSString* _Nullable)message;

- (void)onRoomDestroy:(NSString *)roomId;

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality
           remoteQuality:(NSArray<TRTCQualityInfo*> *)remoteQuality;

- (void)onUserVolumeUpdate:(NSString *)userId volume:(NSInteger)volume;

- (void)onUserEnterRoom:(NSString *)userId;

- (void)onUserLeaveRoom:(NSString *)userId;

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available;

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available;

- (void)onRecvRoomTextMsg:(NSString* _Nullable)message userInfo:(TRTCMeetingUserInfo *)userInfo;

- (void)onRecvRoomCustomMsg:(NSString* _Nullable)cmd message:(NSString* _Nullable)message userInfo:(TRTCMeetingUserInfo *)userInfo;

// 录屏相关
- (void)onScreenCaptureStarted;

// reason 原因，0：用户主动暂停；1：屏幕窗口不可见暂停
- (void)onScreenCapturePaused:(int)reason;

// reason 恢复原因，0：用户主动恢复；1：屏幕窗口恢复可见从而恢复分享
- (void)onScreenCaptureResumed:(int)reason;

// reason 停止原因，0：用户主动停止；1：屏幕窗口关闭导致停止
- (void)onScreenCaptureStoped:(int)reason;

@end

NS_ASSUME_NONNULL_END
