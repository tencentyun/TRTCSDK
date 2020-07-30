//
//  VoiceRoomTRTCService.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/1.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "VoiceRoomTRTCService.h"
#import "TRTCCloud.h"

@interface VoiceRoomTRTCService () <TRTCCloudDelegate>

@property (nonatomic, assign) BOOL isInRoom;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) TRTCParams *mTRTCParms;
@property (nonatomic, copy) TXCallback enterRoomCallback;
@property (nonatomic, copy) TXCallback exitRoomCallback;

@property (nonatomic, strong, readonly)TRTCCloud *mTRTCCloud;

@end

@implementation VoiceRoomTRTCService

- (TRTCCloud *)mTRTCCloud {
    return [TRTCCloud sharedInstance];
}

+ (instancetype)sharedInstance{
    static VoiceRoomTRTCService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VoiceRoomTRTCService alloc] init];
    });
    return instance;
}

- (void)enterRoomWithSdkAppId:(UInt32)sdkAppId
                       roomId:(NSString *)roomId
                       userId:(NSString *)userId
                     userSign:(NSString *)userSign
                         role:(NSInteger)role
                     callback:(TXCallback)callback {
    BOOL isParamError = NO;
    if (roomId == nil || [roomId isEqualToString:@""]) {
        isParamError = YES;
    }
    if (userId == nil || [userId isEqualToString:@""]) {
        isParamError = YES;
    }
    if (userSign == nil || [userSign isEqualToString:@""]) {
        isParamError = YES;
    }
    int roomIdIntValue = [roomId intValue];
    if (roomIdIntValue == 0) {
        isParamError = YES;
    }
    if (isParamError) {
        TRTCLog(@"error: enter trtc room fail. params invalid. room id:%@, userId:%@, userSig is empty:%d", roomId, userId, (userSign == nil || [userSign isEqualToString:@""]));
        callback(-1, @"enter trtc room fail.");
        return;
    }
    self.userId = userId;
    self.roomId = roomId;
    self.enterRoomCallback = callback;
    TRTCLog(@"enter room. app id:%u, room id: %@, userID: %@", (unsigned int)sdkAppId, roomId, userId);
    TRTCParams * parms = [[TRTCParams alloc] init];
    parms.sdkAppId = sdkAppId;
    parms.userId = userId;
    parms.userSig = userSign;
    parms.role = role == 20 ? TRTCRoleAnchor : TRTCRoleAudience;
    parms.roomId = roomIdIntValue;
    self.mTRTCParms = parms;
    [self internalEnterRoom];
}

- (void)exitRoom:(TXCallback)callback {
    TRTCLog(@"exit trtc room.");
    self.userId = nil;
    self.mTRTCParms = nil;
    self.enterRoomCallback = nil;
    self.exitRoomCallback = callback;
    [self.mTRTCCloud exitRoom];
}

- (void)muteLocalAudio:(BOOL)isMute {
    [self.mTRTCCloud muteLocalAudio:isMute];
}

- (void)muteRemoteAudioWithUserId:(NSString *)userId isMute:(BOOL)isMute {
    [self.mTRTCCloud muteRemoteAudio:userId mute:isMute];
}

- (void)muteAllRemoteAudio:(BOOL)isMute {
    [self.mTRTCCloud muteAllRemoteAudio:isMute];
}

- (void)setAudioQuality:(NSInteger)quality {
    TRTCAudioQuality targetQuality = TRTCAudioQualityDefault;
    switch (quality) {
        case 1:
            targetQuality = TRTCAudioQualitySpeech;
            break;
        case 3:
            targetQuality = TRTCAudioQualityMusic;
        default:
            break;
    }
    [self.mTRTCCloud setAudioQuality:targetQuality];
}

- (void)startMicrophone {
    [self.mTRTCCloud startLocalAudio];
}

- (void)stopMicrophone {
    [self.mTRTCCloud stopLocalAudio];
}

- (void)switchToAnchor {
    [self.mTRTCCloud switchRole:TRTCRoleAnchor];
    [self.mTRTCCloud startLocalAudio];
}

- (void)switchToAudience {
    [self.mTRTCCloud stopLocalAudio];
    [self.mTRTCCloud switchRole:TRTCRoleAudience];
}

- (void)setSpeaker:(BOOL)userSpeaker {
    [self.mTRTCCloud setAudioRoute:userSpeaker ? TRTCAudioModeSpeakerphone : TRTCAudioModeEarpiece];
}

- (void)setAudioCaptureVolume:(NSInteger)volume {
    [self.mTRTCCloud setAudioCaptureVolume:volume];
}

- (void)setAudioPlayoutVolume:(NSInteger)volume {
    [self.mTRTCCloud setAudioPlayoutVolume:volume];
}

- (void)startFileDumping:(TRTCAudioRecordingParams *)params {
    [self.mTRTCCloud startAudioRecording:params];
}

- (void)stopFileDumping {
    [self.mTRTCCloud stopAudioRecording];
}

- (void)enableAudioEvalutation:(BOOL)enable {
    [self.mTRTCCloud enableAudioVolumeEvaluation:enable ? 300 : 0];
}

#pragma mark - private method
- (void)internalEnterRoom{
    if (self.mTRTCParms) {
        self.mTRTCCloud.delegate = self;
        [self.mTRTCCloud enterRoom:self.mTRTCParms appScene:TRTCAppSceneVoiceChatRoom];
    }
}

- (BOOL)canDelegateResponseMethod:(SEL)method {
    return self.delegate && [self.delegate respondsToSelector:method];
}

#pragma mark - TRTCCloudDelegate
- (void)onEnterRoom:(NSInteger)result{
    TRTCLog(@"on enter trtc room. result:%ld", (long)result);
    if (result > 0) {
        self.isInRoom = YES;
        if (self.enterRoomCallback) {
            self.enterRoomCallback(0, @"enter trtc room success.");
        }
    } else {
        self.isInRoom = NO;
        if (self.enterRoomCallback) {
            self.enterRoomCallback((int)result, @"enter trtc room fail.");
        }
    }
    self.enterRoomCallback = nil;
}

- (void)onExitRoom:(NSInteger)reason {
    TRTCLog(@"on exit trtc room. reslut: %ld", (long)reason);
    self.isInRoom = NO;
    if (self.exitRoomCallback) {
        self.exitRoomCallback(0, @"exite room success");
    }
    self.exitRoomCallback = nil;
}

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    TRTCLog(@"on user enter, userid: %@", userId);
    if ([self canDelegateResponseMethod:@selector(onTRTCAnchorEnter:)]) {
        [self.delegate onTRTCAnchorEnter:userId];
    }
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    if ([self canDelegateResponseMethod:@selector(onTRTCAnchorExit:)]) {
        [self.delegate onTRTCAnchorExit:userId];
    }
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    if ([self canDelegateResponseMethod:@selector(onTRTCAudioAvailable:available:)]) {
        [self.delegate onTRTCAudioAvailable:userId available:available];
    }
}

- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo{
    if ([self canDelegateResponseMethod:@selector(onError:message:)]) {
        [self.delegate onError:errCode message:errMsg];
    }
}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    if ([self canDelegateResponseMethod:@selector(onNetworkQuality:remoteQuality:)]) {
        [self.delegate onNetWorkQuality:localQuality arrayList:remoteQuality];
    }
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    if ([self canDelegateResponseMethod:@selector(onUserVoiceVolume:totalVolume:)]) {
        [self.delegate onUserVoiceVolume:userVolumes totalVolume:totalVolume];
    }
}

- (void)onSetMixTranscodingConfig:(int)err errMsg:(NSString *)errMsg{
    TRTCLog(@"on set mix transcoding, code:%d, msg: %@", err, errMsg);
}

@end
