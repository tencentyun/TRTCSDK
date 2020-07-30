//
//  VoiceRoomTRTCService.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/1.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXBaseDef.h"

NS_ASSUME_NONNULL_BEGIN

#define kTRTCRoleAnchorValue 20
#define kTRTCRoleAudienceValue 21

@class TRTCQualityInfo;
@class TRTCVolumeInfo;
@class TRTCAudioRecordingParams;

@protocol VoiceRoomTRTCServiceDelegate <NSObject>

- (void)onTRTCAnchorEnter:(NSString *)userId;
- (void)onTRTCAnchorExit:(NSString *)userId;
- (void)onTRTCAudioAvailable:(NSString *)userId available:(BOOL)available;
- (void)onError:(NSInteger)code message:(NSString *)message;
- (void)onNetWorkQuality:(TRTCQualityInfo *)trtcQuality arrayList:(NSArray<TRTCQualityInfo *> *)arrayList;
- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume;

@end

@interface VoiceRoomTRTCService : NSObject

@property (nonatomic, weak) id<VoiceRoomTRTCServiceDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)enterRoomWithSdkAppId:(UInt32)sdkAppId roomId:(NSString *)roomId userId:(NSString *)userId userSign:(NSString *)userSign role:(NSInteger)role callback:(TXCallback _Nullable)callback;

- (void)exitRoom:(TXCallback _Nullable)callback;

- (void)muteLocalAudio:(BOOL)isMute;

- (void)muteRemoteAudioWithUserId:(NSString *)userId isMute:(BOOL)isMute;

- (void)muteAllRemoteAudio:(BOOL)isMute;

- (void)setAudioQuality:(NSInteger)quality;

- (void)startMicrophone;

- (void)stopMicrophone;

- (void)switchToAnchor;

- (void)switchToAudience;

- (void)setSpeaker:(BOOL)userSpeaker;

- (void)setAudioCaptureVolume:(NSInteger)volume;

- (void)setAudioPlayoutVolume:(NSInteger)volume;

- (void)startFileDumping:(TRTCAudioRecordingParams *)params;

- (void)stopFileDumping;

- (void)enableAudioEvalutation:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
