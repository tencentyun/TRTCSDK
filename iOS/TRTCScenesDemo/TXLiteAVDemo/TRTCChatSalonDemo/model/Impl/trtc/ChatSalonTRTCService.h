//
//  ChatSalonTRTCService.h
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/7/1.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatSalonBaseDef.h"

NS_ASSUME_NONNULL_BEGIN

#define kTRTCRoleAnchorValue 20
#define kTRTCRoleAudienceValue 21

@class TRTCQualityInfo;
@class TRTCVolumeInfo;
@class TRTCAudioRecordingParams;

@protocol ChatSalonTRTCServiceDelegate <NSObject>

- (void)onTRTCAnchorEnter:(NSString *)userID;
- (void)onTRTCAnchorExit:(NSString *)userID;
- (void)onTRTCAudioAvailable:(NSString *)userID available:(BOOL)available;
- (void)onError:(NSInteger)code message:(NSString *)message;
- (void)onNetWorkQuality:(TRTCQualityInfo *)trtcQuality arrayList:(NSArray<TRTCQualityInfo *> *)arrayList;
- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume;

@end

@interface ChatSalonTRTCService : NSObject

@property (nonatomic, weak) id<ChatSalonTRTCServiceDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)enterRoomWithSdkAppId:(UInt32)sdkAppId roomId:(NSString *)roomId userID:(NSString *)userID userSign:(NSString *)userSign role:(NSInteger)role callback:(TXCallback _Nullable)callback;

- (void)exitRoom:(TXCallback _Nullable)callback;

- (void)muteLocalAudio:(BOOL)isMute;

- (void)muteRemoteAudioWithUserId:(NSString *)userID isMute:(BOOL)isMute;

- (void)muteAllRemoteAudio:(BOOL)isMute;

- (void)setAudioQuality:(NSInteger)quality;

- (void)startMicrophone;

- (void)stopMicrophone;

- (void)switchToAnchor:(TXCallback _Nullable)callback;

- (void)switchToAudience:(TXCallback _Nullable)callback;

- (void)setSpeaker:(BOOL)userSpeaker;

- (void)setAudioCaptureVolume:(NSInteger)volume;

- (void)setAudioPlayoutVolume:(NSInteger)volume;

- (void)startFileDumping:(TRTCAudioRecordingParams *)params;

- (void)stopFileDumping;

- (void)enableAudioEvalutation:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
