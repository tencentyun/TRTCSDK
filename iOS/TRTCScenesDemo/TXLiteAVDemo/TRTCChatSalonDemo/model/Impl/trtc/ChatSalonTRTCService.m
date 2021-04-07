//
//  ChatSalonTRTCService.m
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/7/1.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "ChatSalonTRTCService.h"
#import "TRTCCloud.h"

@interface ChatSalonTRTCService () <TRTCCloudDelegate>

@property (nonatomic, assign) BOOL isInRoom;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) TRTCParams *mTRTCParms;
@property (nonatomic, copy) TXCallback enterRoomCallback;
@property (nonatomic, copy) TXCallback exitRoomCallback;
@property (nonatomic, copy) TXCallback switchRoleCallback;

@property (nonatomic, strong, readonly)TRTCCloud *mTRTCCloud;

@end

@implementation ChatSalonTRTCService

- (TRTCCloud *)mTRTCCloud {
    return [TRTCCloud sharedInstance];
}

+ (instancetype)sharedInstance{
    static ChatSalonTRTCService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ChatSalonTRTCService alloc] init];
    });
    return instance;
}

- (void)enterRoomWithSdkAppId:(UInt32)sdkAppId
                       roomId:(NSString *)roomId
                       userID:(NSString *)userID
                     userSign:(NSString *)userSign
                         role:(NSInteger)role
                     callback:(TXCallback)callback {
    BOOL isParamError = NO;
    if (roomId == nil || [roomId isEqualToString:@""]) {
        isParamError = YES;
    }
    if (userID == nil || [userID isEqualToString:@""]) {
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
        TRTCLog(@"error: enter trtc room fail. params invalid. room id:%@, userID:%@, userSig is empty:%d", roomId, userID, (userSign == nil || [userSign isEqualToString:@""]));
        callback(-1, @"enter trtc room fail.");
        return;
    }
    self.userID = userID;
    self.roomId = roomId;
    self.enterRoomCallback = callback;
    TRTCLog(@"enter room. app id:%u, room id: %@, userID: %@", (unsigned int)sdkAppId, roomId, userID);
    TRTCParams * parms = [[TRTCParams alloc] init];
    parms.sdkAppId = sdkAppId;
    parms.userId = userID;
    parms.userSig = userSign;
    parms.role = role == 20 ? TRTCRoleAnchor : TRTCRoleAudience;
    parms.roomId = roomIdIntValue;
    self.mTRTCParms = parms;
    [self internalEnterRoom];
}

- (void)exitRoom:(TXCallback)callback {
    TRTCLog(@"exit trtc room.");
    self.userID = nil;
    self.mTRTCParms = nil;
    self.enterRoomCallback = nil;
    self.exitRoomCallback = callback;
    [self.mTRTCCloud exitRoom];
}

- (void)muteLocalAudio:(BOOL)isMute {
    [self.mTRTCCloud muteLocalAudio:isMute];
}

- (void)muteRemoteAudioWithUserId:(NSString *)userID isMute:(BOOL)isMute {
    [self.mTRTCCloud muteRemoteAudio:userID mute:isMute];
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

- (void)switchToAnchor:(TXCallback)callback {
    self.switchRoleCallback = callback;
    [self.mTRTCCloud switchRole:TRTCRoleAnchor];
    [self.mTRTCCloud startLocalAudio:TRTCAudioQualityDefault];
}

- (void)switchToAudience:(TXCallback)callback {
    self.switchRoleCallback = callback;
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
        [self enableAudioEvalutation:YES];
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

- (void)onRemoteUserEnterRoom:(NSString *)userID {
    TRTCLog(@"on user enter, userid: %@", userID);
    if ([self canDelegateResponseMethod:@selector(onTRTCAnchorEnter:)]) {
        [self.delegate onTRTCAnchorEnter:userID];
    }
}

- (void)onRemoteUserLeaveRoom:(NSString *)userID reason:(NSInteger)reason {
    if ([self canDelegateResponseMethod:@selector(onTRTCAnchorExit:)]) {
        [self.delegate onTRTCAnchorExit:userID];
    }
}

- (void)onSwitchRole:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    if (self.switchRoleCallback) {
        self.switchRoleCallback(errCode, errMsg);
    }
}

- (void)onUserAudioAvailable:(NSString *)userID available:(BOOL)available {
    if ([self canDelegateResponseMethod:@selector(onTRTCAudioAvailable:available:)]) {
        [self.delegate onTRTCAudioAvailable:userID available:available];
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
