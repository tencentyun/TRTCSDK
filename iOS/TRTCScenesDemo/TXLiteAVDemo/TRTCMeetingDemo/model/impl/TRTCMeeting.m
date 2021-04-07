//
//  TRTCMeeting.m
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/20/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import <TIMFriendshipManager.h>

#import "TRTCMeeting.h"
#import "TXRoomService.h"
#import "TRTCMeetingDef.h"
#import "AppLocalized.h"

@interface TRTCMeeting() <TRTCCloudDelegate, TXRoomServiceDelegate>
{
    dispatch_queue_t     _queue;
    BOOL                _frontCamera;
    TRTCVideoResolution _videoResolution;
    int                 _videoFPS;
    int                 _videoBitrate;
    BOOL                _getLiveUrl;
    
    TRTCMeetingCallback _enterRoomCallback;
    NSMutableDictionary<NSString*, TRTCMeetingUserInfo*> *_userInfoList;
    
    // TODO 为了不增加辅流的接口，这里将辅流伪成一个独立的userId（只有pc/mac端进房后开启录屏，其他端才会收到辅流通知）
    // 辅流ID = userId + _sub
    // 记录辅流ID到真实userId的映射，如果 _substreamMap 中存在 userId， 则表示当前 userId 实际上是辅流伪造的
    NSMutableDictionary<NSString*, NSString*> *_substreamMap;
}

@property (nonatomic, assign) UInt32   sdkAppId;
@property (nonatomic, assign) UInt32   roomId;
@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, copy)   NSString *userSig;
@property (nonatomic, copy)   NSString *streamId;

@end


static TRTCMeeting *sharedInstance = nil;

@implementation TRTCMeeting

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[TRTCMeeting alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("TRTCMeetingQueue", DISPATCH_QUEUE_SERIAL);
        _delegateQueue = dispatch_get_main_queue();
        _userInfoList = [[NSMutableDictionary alloc] init];
        _substreamMap = [[NSMutableDictionary alloc] init];
        
        _frontCamera = YES;
        _videoResolution = TRTCVideoResolution_960_540;
        _videoFPS = 15;
        _videoBitrate = 1000;
        
        [[TXRoomService sharedInstance] setDelegate:self];
    }
    return self;
}

- (void)setDelegateQueue:(dispatch_queue_t)delegateQueue {
    // 设置TRTC的delegate queue，避免额外抛一次队列
    [[TRTCCloud sharedInstance] setDelegateQueue:delegateQueue];
}

typedef void (^block)(TRTCMeeting *self);
- (void)asyncRun:(block)block {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (self) {
            block(self);
        }
    });
}

- (void)syncRun:(block)block {
    __weak __typeof(self) weakSelf = self;
    dispatch_sync(_queue, ^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (self) {
            block(self);
        }
    });
}

- (void)asyncRunOnDelegateQueue:(void(^)(void))block {
    if (self.delegateQueue) {
        __weak __typeof(self) weakSelf = self;
        dispatch_async(self.delegateQueue, ^{
            __strong __typeof(weakSelf) self = weakSelf;
            if (self) {
                block();
            }
        });
    }
}

- (void)clear {
    [_userInfoList removeAllObjects];
    [_substreamMap removeAllObjects];
}

- (void)login:(UInt32)sdkAppId userId:(NSString *)userId userSig:(NSString *)userSig callback:(TRTCMeetingCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        self.sdkAppId = sdkAppId;
        self.userId = userId;
        self.userSig = userSig;
        
        __weak __typeof(self) weakSelf = self;
        [[TXRoomService sharedInstance] login:sdkAppId userId:userId userSign:userSig callback:^(NSInteger code, NSString *message) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self && callback) {
                [self asyncRunOnDelegateQueue:^{
                    callback(code, message);
                }];
            }
        }];
    }];
}

- (void)logout:(TRTCMeetingCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        __weak __typeof(self) weakSelf = self;
        [[TXRoomService sharedInstance] logout:^(NSInteger code, NSString *message) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self && callback) {
                [self asyncRunOnDelegateQueue:^{
                    callback(code, message);
                }];
            }
        }];
    }];
}

- (void)setSelfProfile:(NSString *)userName avatarURL:(NSString *)avatarURL callback:(TRTCMeetingCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        __weak __typeof(self) weakSelf = self;
        [[TXRoomService sharedInstance] setSelfProfile:userName avatarURL:avatarURL callback:^(NSInteger code, NSString *message) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self && callback) {
                [self asyncRunOnDelegateQueue:^{
                    callback(code, message);
                }];
            }
        }];
    }];
}

- (void)createMeeting:(UInt32)roomId callback:(TRTCMeetingCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        [self clear];
        self.roomId = roomId;
        
        __weak __typeof(self) weakSelf = self;
        NSString *strRoomId = [NSString stringWithFormat:@"%u", roomId];
        [[TXRoomService sharedInstance] createRoom:strRoomId roomInfo:strRoomId coverUrl:@"" callback:^(NSInteger code, NSString *message) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self == nil) {
                return;
            }
            
            // 进入TRTC房间
            if (code == 0) {
                // 保存回调，要在TRTC进房后才能回调
                self->_enterRoomCallback = callback;
                [self enterRTCRoomInternal];
                
            } else {
                if (callback) {
                    [self asyncRunOnDelegateQueue:^{
                        callback(code, message);
                    }];
                }
            }
        }];
    }];
}

- (void)destroyMeeting:(UInt32)roomId callback:(TRTCMeetingCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        [[TRTCCloud sharedInstance] exitRoom];
        
        __weak __typeof(self) weakSelf = self;
        [[TXRoomService sharedInstance] destroyRoom:^(NSInteger code, NSString *message) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self && callback) {
                [self asyncRunOnDelegateQueue:^{
                    callback(code, message);
                }];
            }
        }];
        
    }];
}

- (void)enterMeeting:(UInt32)roomId callback:(TRTCMeetingCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        [self clear];
        self.roomId = roomId;
        
        [[TXRoomService sharedInstance] enterRoom:[NSString stringWithFormat:@"%u", roomId] callback:^(NSInteger code, NSString *message) {
            // 先不管这个
        }];
        
        // 保存回调，要在TRTC进房后才能回调
        self->_enterRoomCallback = callback;
        [self enterRTCRoomInternal];
    }];
}

- (void)enterRTCRoomInternal {
    [[TRTCCloud sharedInstance] setDelegate:self];
    
    [self setVideoEncoderParamInternal];
    
    self.streamId = [NSString stringWithFormat:@"%u_%u_%@_main", self.sdkAppId, self.roomId, self.userId];
    
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = self.sdkAppId;
    params.userId = self.userId;
    params.roomId = self.roomId;
    params.userSig = self.userSig;
    params.role = TRTCRoleAnchor; // 主播角色
    params.streamId = self.streamId;
    
    [[TRTCCloud sharedInstance] enterRoom:params appScene:TRTCAppSceneVideoCall];
}

- (void)leaveMeeting:(TRTCMeetingCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        [[TRTCCloud sharedInstance] exitRoom];
        
        __weak __typeof(self) weakSelf = self;
        if ([[TXRoomService sharedInstance] isOwner]) {  // 房主：销毁房间
            [[TXRoomService sharedInstance] destroyRoom:^(NSInteger code, NSString *message) {
                __strong __typeof(weakSelf) self = weakSelf;
                if (self && callback) {
                    [self asyncRunOnDelegateQueue:^{
                        callback(code, message);
                    }];
                }
            }];
            
        } else {  // 普通成员：退房
            [[TXRoomService sharedInstance] exitRoom:^(NSInteger code, NSString *message) {
                __strong __typeof(weakSelf) self = weakSelf;
                if (self && callback) {
                    [self asyncRunOnDelegateQueue:^{
                        callback(code, message);
                    }];
                }
            }];
        }
    }];
}

- (void)getUserInfoList:(TRTCMeetingUserListCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        NSMutableArray *userIdArray = [[NSMutableArray alloc] init];
        for (NSString *userId in self->_userInfoList) {
            [userIdArray addObject:userId];
        }
        [self getUserInfoListInternal:userIdArray callback:callback];
    }];
}

- (void)getUserInfo:(NSString *)userId callback:(TRTCMeetingUserListCallback)callback {
    [self asyncRun:^(TRTCMeeting *self) {
        // 判断是否是辅流
        NSString *realUserId = [self->_substreamMap valueForKey:userId];
        if (realUserId) {
            // 辅流直接从现有的取数据
            TRTCMeetingUserInfo *userInfo = [[TRTCMeetingUserInfo alloc] init];
            userInfo.userId = userId;
            
            TRTCMeetingUserInfo *mainUserInfo = [self->_userInfoList valueForKey:userId];
            if (mainUserInfo) {
                userInfo.userName = [NSString stringWithFormat:@"%@（%@）", mainUserInfo.userName, TRTCLocalize(@"Demo.TRTC.Meeting.secondarystream")];
                userInfo.avatarURL = mainUserInfo.avatarURL;
            }
            
            NSMutableArray *cbArray = [[NSMutableArray alloc] initWithObjects:userInfo, nil];
            [self asyncRunOnDelegateQueue:^{
                if (callback) {
                    callback(0, @"success", cbArray);
                }
            }];
            return;
        }
        
        // 不是辅流就走这里
        NSArray *userIdArray = [[NSArray alloc] initWithObjects:userId, nil];
        [self getUserInfoListInternal:userIdArray callback:callback];
    }];
}

- (void)startRemoteView:(NSString *)userId view:(UIView *)view callback:(TRTCMeetingCallback)callback {
    [self syncRun:^(TRTCMeeting *self) {
        // 先判断是否是辅流
        NSString *realUserId = [self->_substreamMap valueForKey:userId];
        if (realUserId) {
            [[TRTCCloud sharedInstance] startRemoteSubStreamView:realUserId view:view];
            // 辅流的话需要设置自适应渲染，以及旋转90度（因为电脑端的屏幕分享画面太大了）
            [[TRTCCloud sharedInstance] setRemoteSubStreamViewFillMode:realUserId mode:TRTCVideoFillMode_Fit];
            [[TRTCCloud sharedInstance] setRemoteSubStreamViewRotation:realUserId rotation:TRTCVideoRotation_90];
        } else {
            [[TRTCCloud sharedInstance] startRemoteView:userId view:view];
        }
        
        [self asyncRunOnDelegateQueue:^{
            if (callback) {
                callback(0, @"success");
            }
        }];
    }];
}

- (void)stopRemoteView:(NSString *)userId callback:(TRTCMeetingCallback)callback {
    [self syncRun:^(TRTCMeeting *self) {
        // 先判断是否是辅流
        NSString *realUserId = [self->_substreamMap valueForKey:userId];
        if (realUserId) {
            [[TRTCCloud sharedInstance] stopRemoteSubStreamView:realUserId];
        } else {
            [[TRTCCloud sharedInstance] stopRemoteView:userId];
        }
        
        [self asyncRunOnDelegateQueue:^{
            if (callback) {
                callback(0, @"success");
            }
        }];
    }];
}

- (void)setRemoteViewFillMode:(NSString *)userId fillMode:(TRTCVideoFillMode)fillMode {
    [self asyncRun:^(TRTCMeeting *self) {
        // 先判断是否是辅流
        NSString *realUserId = [self->_substreamMap valueForKey:userId];
        if (realUserId) {
            [[TRTCCloud sharedInstance] setRemoteSubStreamViewFillMode:realUserId mode:fillMode];
        } else {
            [[TRTCCloud sharedInstance] setRemoteViewFillMode:userId mode:fillMode];
        }
    }];
}

- (void)setRemoteViewRotation:(NSString *)userId rotation:(NSInteger)rotation {
    [self asyncRun:^(TRTCMeeting *self) {
        // 先判断是否是辅流
        NSString *realUserId = [self->_substreamMap valueForKey:userId];
        if (realUserId) {
            [[TRTCCloud sharedInstance] setRemoteSubStreamViewRotation:realUserId rotation:rotation];
        } else {
            [[TRTCCloud sharedInstance] setRemoteViewRotation:userId rotation:rotation];
        }
    }];
}

- (void)muteRemoteAudio:(NSString *)userId mute:(BOOL)mute {
    [self asyncRun:^(TRTCMeeting *self) {
        // 先判断是否是辅流，辅流没有静音
        NSString *realUserId = [self->_substreamMap valueForKey:userId];
        if (realUserId) {
            return;
        }
        [[TRTCCloud sharedInstance] muteRemoteAudio:userId mute:mute];
    }];
}

- (void)muteRemoteVideoStream:(NSString *)userId mute:(BOOL)mute {
    [self asyncRun:^(TRTCMeeting *self) {
        // 先判断是否是辅流，辅流没有静画
        NSString *realUserId = [self->_substreamMap valueForKey:userId];
        if (realUserId) {
            return;
        }
        [[TRTCCloud sharedInstance] muteRemoteVideoStream:userId mute:mute];
    }];
}

- (void)startCameraPreview:(BOOL)isFront view:(UIView *)view {
    _frontCamera = isFront;
    [[TRTCCloud sharedInstance] startLocalPreview:isFront view:view];
}

- (void)stopCameraPreview {
    [[TRTCCloud sharedInstance] stopLocalPreview];
}

- (void)switchCamera:(BOOL)isFront {
    if (_frontCamera != isFront) {
        _frontCamera = isFront;
        [[TRTCCloud sharedInstance] switchCamera];
    }
}

- (void)setVideoResolution:(TRTCVideoResolution)resolution {
    _videoResolution = resolution;
    [self setVideoEncoderParamInternal];
}

- (void)setVideoFps:(int)fps {
    _videoFPS = fps;
    [self setVideoEncoderParamInternal];
}

- (void)setVideoBitrate:(int)bitrate {
    _videoBitrate = bitrate;
    [self setVideoEncoderParamInternal];
}

- (void)setLocalViewMirror:(TRTCLocalVideoMirrorType)type {
    [[TRTCCloud sharedInstance] setLocalViewMirror:type];
}

- (void)setNetworkQosParam:(TRTCNetworkQosParam *)qosParam {
    [[TRTCCloud sharedInstance] setNetworkQosParam:qosParam];
}

- (void)startMicrophone {
    [[TRTCCloud sharedInstance] startLocalAudio];
}

- (void)stopMicrophone {
    [[TRTCCloud sharedInstance] stopLocalAudio];
}

- (void)setAudioQuality:(TRTCAudioQuality)quality {
    [[TRTCCloud sharedInstance] setAudioQuality:quality];
}

- (void)muteLocalAudio:(BOOL)mute {
    [[TRTCCloud sharedInstance] muteLocalAudio:mute];
}

- (void)setSpeaker:(BOOL)useSpeaker {
    if (useSpeaker) {
        [[TRTCCloud sharedInstance] setAudioRoute:TRTCAudioModeSpeakerphone];
    } else {
        [[TRTCCloud sharedInstance] setAudioRoute:TRTCAudioModeEarpiece];
    }
}

- (void)setAudioCaptureVolume:(NSInteger)volume {
    [[TRTCCloud sharedInstance] setAudioCaptureVolume:volume];
}

- (void)setAudioPlayoutVolume:(NSInteger)volume {
    [[TRTCCloud sharedInstance] setAudioPlayoutVolume:volume];
}

- (void)startFileDumping:(TRTCAudioRecordingParams *)params {
    [[TRTCCloud sharedInstance] startAudioRecording:params];
}

- (void)stopFileDumping {
    [[TRTCCloud sharedInstance] stopAudioRecording];
}

- (void)enableAudioEvaluation:(BOOL)enable {
    [[TRTCCloud sharedInstance] enableAudioVolumeEvaluation:enable ? 300 : 0];
}

- (TXBeautyManager *)getBeautyManager {
    return [[TRTCCloud sharedInstance] getBeautyManager];
}

- (void)startScreenCapture:(TRTCVideoEncParam *)params {
    [[TRTCCloud sharedInstance] startScreenCaptureByReplaykit:params appGroup:@"TRTCMeeting"];
}

- (int)stopScreenCapture {
    return [[TRTCCloud sharedInstance] stopScreenCapture];
}

- (int)pauseScreenCapture {
    return [[TRTCCloud sharedInstance] pauseScreenCapture];
}

- (int)resumeScreenCapture {
    return [[TRTCCloud sharedInstance] resumeScreenCapture];
}

- (NSString *)getLiveBroadcastingURL {
    __block NSString *url = @"";
    [self syncRun:^(TRTCMeeting *self) {
        self->_getLiveUrl = YES;
        [self updateMixConfig];
        
        NSString *conDomain = @"http://3891.liveplay.myqcloud.com/live";
        url = [NSString stringWithFormat:@"%@%@%@.flv", conDomain, ([conDomain hasSuffix:@"/"] ? @"":@"/"), self.streamId];
    }];
    return url;
}

- (void)sendRoomTextMsg:(NSString *)message callback:(TRTCMeetingCallback)callback {
    __weak __typeof(self) weakSelf = self;
    [[TXRoomService sharedInstance] sendRoomTextMsg:message callback:^(NSInteger code, NSString *message) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self && callback) {
            [self asyncRunOnDelegateQueue:^{
                callback(code, message);
            }];
        }
    }];
}

- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TRTCMeetingCallback)callback {
    __weak __typeof(self) weakSelf = self;
    [[TXRoomService sharedInstance] sendRoomCustomMsg:cmd message:message callback:^(NSInteger code, NSString *message) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self && callback) {
            [self asyncRunOnDelegateQueue:^{
                callback(code, message);
            }];
        }
    }];
}

- (void)setVideoEncoderParamInternal {
    TRTCVideoEncParam *param = [[TRTCVideoEncParam alloc] init];
    param.videoResolution = _videoResolution;
    param.videoBitrate = _videoBitrate;
    param.videoFps = _videoFPS;
    param.resMode = TRTCVideoResolutionModePortrait;
    param.enableAdjustRes = YES;
    [[TRTCCloud sharedInstance] setVideoEncoderParam:param];
}

#pragma mark - utils

- (void)updateMixConfig {
    if ([_userInfoList count] == 0) {
        // 不需要混流
        [[TRTCCloud sharedInstance] setMixTranscodingConfig:nil];
        return;
    }
    
    NSMutableArray<TRTCMeetingUserInfo *> *mixUserList = [[NSMutableArray alloc] init];
    for (NSString *userId in _userInfoList) {
        if ([userId isEqualToString:self.userId]) {
            continue;
        }
        
        TRTCMeetingUserInfo *userInfo = [[TRTCMeetingUserInfo alloc] init];
        userInfo.userId = userId;
        [mixUserList addObject:userInfo];
    }
    
    if ([mixUserList count] == 0) {
        [[TRTCCloud sharedInstance] setMixTranscodingConfig:nil];
    } else {
        int videoWidth = 544;
        int videoHeight = 960;
        int subWidth  = 160;
        int subHeight = 288;
        int offsetX = 5;
        int offsetY = 50;
        int bitrate = 1000;
        
        TRTCTranscodingConfig *config = [[TRTCTranscodingConfig alloc] init];
        config.videoWidth = videoWidth;
        config.videoHeight = videoHeight;
        config.videoGOP = 1;
        config.videoFramerate = 15;
        config.videoBitrate = bitrate;
        config.audioSampleRate = 48000;
        config.audioBitrate = 64;
        config.audioChannels = 1;
        
        TRTCMixUser *mixUser = [[TRTCMixUser alloc] init];
        mixUser.userId = self.userId;
        mixUser.roomID = [NSString stringWithFormat:@"%u", self.roomId];
        mixUser.zOrder = 1;
        mixUser.rect = CGRectMake(0, 0, videoWidth, videoHeight);
        
        NSMutableArray *mixUsers = [[NSMutableArray alloc] init];
        [mixUsers addObject:mixUser];  // 自己
        
        int index = 0;
        for (TRTCMeetingUserInfo *userInfo in mixUserList) {
            TRTCMixUser *mixUser = [[TRTCMixUser alloc] init];
            mixUser.userId = userInfo.userId;
            mixUser.roomID = [NSString stringWithFormat:@"%u", self.roomId];
            mixUser.streamType = TRTCVideoStreamTypeBig;
            mixUser.zOrder = 2 + index;
            
            if (index < 3) {
                mixUser.rect = CGRectMake(videoWidth - offsetX - subWidth, videoHeight - offsetY - index * subHeight - subHeight, subWidth, subHeight);
            } else if (index < 6) {
                mixUser.rect = CGRectMake(offsetX, videoHeight - offsetY - (index - 3) * subHeight - subHeight, subWidth, subHeight);
            } else {
                // ...
            }
            
            [mixUsers addObject:mixUser];
            index ++;
        }
        config.mixUsers = mixUsers;
        
        [[TRTCCloud sharedInstance] setMixTranscodingConfig:config];
    }
}

- (void)getUserInfoListInternal:(NSArray *)userIdArray callback:(TRTCMeetingUserListCallback)callback {
    __weak __typeof(self) weakSelf = self;
    [[TXRoomService sharedInstance] getUserInfo:userIdArray callback:^(NSInteger code, NSString *message, NSArray<TXUserInfo *> *userList) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self == nil) {
            return;
        }
        
        [self asyncRun:^(TRTCMeeting *self) {
            NSMutableArray *cbArray = [[NSMutableArray alloc] init];
            for (TXUserInfo *info in userList) {
                TRTCMeetingUserInfo *userInfo = [self->_userInfoList valueForKey:info.userId];
                if (userInfo) {
                    userInfo.userId = info.userId;
                    userInfo.userName = info.userName;
                    userInfo.avatarURL = info.avatarURL;
                    
                    [cbArray addObject:userInfo];
                }
            }
            
            [self asyncRunOnDelegateQueue:^{
                if (callback) {
                    callback(code, message, cbArray);
                }
            }];
            
        }];
        
    }];
}

#pragma mark - TRTCCloudDelegate

- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onError:message:)]) {
        [self.delegate onError:errCode message:errMsg];
    }
}

- (void)onEnterRoom:(NSInteger)result {
    // result > 0 时为进房耗时（ms），result < 0 时为进房错误码。
    if (_enterRoomCallback) {
        if (result < 0) {
            _enterRoomCallback(result, @"enter room failed");
        } else {
            _enterRoomCallback(0, @"enter room succeed");
        }
        _enterRoomCallback = NULL;
    }
}

- (void)onExitRoom:(NSInteger)reason {
    NSLog(@"onExitRoom: reason[%ld]", reason);
}

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    [self asyncRun:^(TRTCMeeting *self) {
        TRTCMeetingUserInfo *userInfo = [[TRTCMeetingUserInfo alloc] init];
        userInfo.userId = userId;
        [self->_userInfoList setValue:userInfo forKey:userId];
        
        if (self->_getLiveUrl) {
            [self updateMixConfig];
        }
        
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(onUserEnterRoom:)]) {
            [self asyncRunOnDelegateQueue:^{
                [self->_delegate onUserEnterRoom:userId];
            }];
        }
    }];
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    [self asyncRun:^(TRTCMeeting *self) {
        [self->_userInfoList removeObjectForKey:userId];
        if (self->_getLiveUrl) {
            [self updateMixConfig];
        }
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(onUserLeaveRoom:)]) {
            [self asyncRunOnDelegateQueue:^{
                [self->_delegate onUserLeaveRoom:userId];
            }];
        }
    }];
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    [self asyncRun:^(TRTCMeeting *self) {
        TRTCMeetingUserInfo *userInfo = [self->_userInfoList valueForKey:userId];
        if (userInfo) {
            userInfo.isVideoAvailable = available;
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(onUserVideoAvailable:available:)]) {
                [self asyncRunOnDelegateQueue:^{
                    [self->_delegate onUserVideoAvailable:userId available:available];
                }];
            }
        }
    }];
}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available {
    [self asyncRun:^(TRTCMeeting *self) {
       // 辅路
       // TODO 简单起见，伪造一个userId
        NSString *subStreamUserId = [NSString stringWithFormat:@"%@_sub", userId];
        
        if (available) {
            // 有一条新的辅流进来
            [self->_substreamMap setValue:userId forKey:subStreamUserId];
            
            [self asyncRunOnDelegateQueue:^{
                // 注意：这里要跑两个回调，注意先后顺序
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(onUserEnterRoom:)]) {
                    [self->_delegate onUserEnterRoom:subStreamUserId];
                }
                
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(onUserVideoAvailable:available:)]) {
                    [self->_delegate onUserVideoAvailable:subStreamUserId available:YES];
                }
            }];
            
        } else {
            // 有一条新的辅流离开了
            [self->_substreamMap removeObjectForKey:subStreamUserId];
            
            [self asyncRunOnDelegateQueue:^{
                // 注意：这里要跑两个回调，注意先后顺序
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(onUserVideoAvailable:available:)]) {
                    [self->_delegate onUserVideoAvailable:subStreamUserId available:NO];
                }
                
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(onUserLeaveRoom:)]) {
                    [self->_delegate onUserLeaveRoom:subStreamUserId];
                }
            }];
        }
    }];
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    [self asyncRun:^(TRTCMeeting *self) {
        TRTCMeetingUserInfo *userInfo = [self->_userInfoList valueForKey:userId];
        if (userInfo) {
            userInfo.isAudioAvailable = available;
            
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(onUserAudioAvailable:available:)]) {
                [self asyncRunOnDelegateQueue:^{
                    [self->_delegate onUserAudioAvailable:userId available:available];
                }];
            }
        }
    }];
}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    [self asyncRunOnDelegateQueue:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onNetworkQuality:remoteQuality:)]) {
            [self.delegate onNetworkQuality:localQuality remoteQuality:remoteQuality];
        }
    }];
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    [self asyncRunOnDelegateQueue:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onUserVolumeUpdate:volume:)]) {
            for (TRTCVolumeInfo *info in userVolumes) {
                NSString *userId = (info.userId == nil ? self.userId : info.userId);
                [self.delegate onUserVolumeUpdate:userId volume:info.volume];
            }
        }
    }];
}

#pragma mark - TXRoomServiceDelegate

- (void)onRoomDestroy:(NSString *_Nullable)roomId {
    if ([roomId intValue] != self.roomId) {
        return;
    }
    
    [self leaveMeeting:^(NSInteger code, NSString * _Nullable message) {
        NSLog(@"onRoomDestroy. leaveMeeting: code[%ld], message[%@]", (long)code, message);
    }];
    
    [self asyncRunOnDelegateQueue:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomDestroy:)]) {
            [self.delegate onRoomDestroy:roomId];
        }
    }];
}

- (void)onRoomRecvRoomTextMsg:(NSString *_Nullable)roomId message:(NSString *_Nullable)message userInfo:(TXUserInfo *_Nullable)userInfo {
    [self asyncRunOnDelegateQueue:^{
        TRTCMeetingUserInfo *info = [[TRTCMeetingUserInfo alloc] init];
        info.userId = userInfo.userId;
        info.userName = userInfo.userName;
        info.avatarURL = userInfo.avatarURL;
        
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(onRecvRoomTextMsg:userInfo:)]) {
            [self->_delegate onRecvRoomTextMsg:message userInfo:info];
        }
    }];
}

- (void)onRoomRecvRoomCustomMsg:(NSString *_Nullable)roomId cmd:(NSString *_Nullable)cmd message:(NSString *_Nullable)message userInfo:(TXUserInfo *_Nonnull)userInfo {
    [self asyncRunOnDelegateQueue:^{
        TRTCMeetingUserInfo *info = [[TRTCMeetingUserInfo alloc] init];
        info.userId = userInfo.userId;
        info.userName = userInfo.userName;
        info.avatarURL = userInfo.avatarURL;
        
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(onRecvRoomTextMsg:userInfo:)]) {
            [self->_delegate onRecvRoomCustomMsg:cmd message:message userInfo:info];
        }
    }];
}

- (void)onScreenCaptureStarted {
    [self asyncRunOnDelegateQueue:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onScreenCaptureStarted)]) {
            [self.delegate onScreenCaptureStarted];
        }
    }];
}

- (void)onScreenCapturePaused:(int)reason {
    [self asyncRunOnDelegateQueue:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onScreenCapturePaused:)]) {
            [self.delegate onScreenCapturePaused: reason];
        }
    }];
}

- (void)onScreenCaptureResumed:(int)reason {
    [self asyncRunOnDelegateQueue:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onScreenCaptureResumed:)]) {
            [self.delegate onScreenCaptureResumed: reason];
        }
    }];
}

- (void)onScreenCaptureStoped:(int)reason {
    [self asyncRunOnDelegateQueue:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onScreenCaptureStoped:)]) {
            [self.delegate onScreenCaptureStoped: reason];
        }
    }];
}

@end
