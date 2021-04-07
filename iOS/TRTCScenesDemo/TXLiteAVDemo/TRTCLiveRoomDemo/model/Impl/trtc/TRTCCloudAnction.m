//
//  TRTCCloudAnction.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/12.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCCloudAnction.h"
#import "TXLivePlayer.h"
#import "TXLiveRoomCommonDef.h"
#import <MJExtension.h>
#import "AppLocalized.h"

static int trtcLivePlayTimeOut = 5;

@interface PlayInfo : NSObject

@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, copy) NSString *streamId;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, strong) TXLivePlayer *cdnPlayer;

- (instancetype)initWithVideoView:(UIView *)videoView streamId:(NSString *)streamId roomId:(NSString *)roomId;

@end

@implementation PlayInfo

- (instancetype)initWithVideoView:(UIView *)videoView streamId:(NSString *)streamId roomId:(NSString *)roomId {
    self = [super init];
    if (self) {
        self.videoView = videoView;
        self.streamId = streamId;
        self.roomId = roomId;
    }
    return self;
}

- (TXLivePlayer *)cdnPlayer {
    if (!_cdnPlayer) {
        _cdnPlayer = [[TXLivePlayer alloc] init];
    }
    return _cdnPlayer;
}

@end

@class TRTCCloudAnction;
@interface TRTCCloudCdnDelegate : NSObject<TXLivePlayListener>

@property (nonatomic, copy) NSString *streamId;
@property (nonatomic, weak)  TRTCCloudAnction *action;

- (instancetype)initWithStreamId:(NSString *)streamId;

@end

@implementation TRTCCloudCdnDelegate

- (instancetype)initWithStreamId:(NSString *)streamId {
    self = [super init];
    if (self) {
        self.streamId = streamId;
    }
    return self;
}

- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {
    if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME) {
        if (self.action) {
            [self.action playCallBackWithUserId:self.streamId code:0 message:@""];
            self.action = nil;
        }
    } else if (EvtID < 0) {
        if (self.action) {
            [self.action playCallBackWithUserId:self.streamId code:-1 message:@""];
            self.action = nil;
        }
    }
}

- (void)onNetStatus:(NSDictionary *)param {
    
}

@end


@interface TRTCCloudAnction ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, Callback> *playCallbackMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PlayInfo *> *userPlayInfo;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *urlDomain;
@property (nonatomic, assign) int sdkAppId;
@property (nonatomic, copy) NSString *userSig;

@property (nonatomic, assign) BOOL isEnterRoom; // 是否进房标记，避免重复进房

@end

@implementation TRTCCloudAnction

-(NSMutableDictionary<NSString *,Callback> *)playCallbackMap {
    if (!_playCallbackMap) {
        _playCallbackMap = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _playCallbackMap;
}

- (NSMutableDictionary<NSString *,PlayInfo *> *)userPlayInfo {
    if (!_userPlayInfo) {
        _userPlayInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _userPlayInfo;
}

- (TXBeautyManager *)beautyManager {
    return [[TRTCCloud sharedInstance] getBeautyManager];
}

#pragma mark - Public method
- (void)setupWithUserId:(NSString *)userId urlDomain:(NSString *)urlDomain sdkAppId:(int)sdkAppid userSig:(NSString *)userSig {
    self.userId = userId;
    self.urlDomain = urlDomain;
    self.sdkAppId = sdkAppid;
    self.userSig = userSig;
}

- (void)reset {
    self.userId = nil;
    self.urlDomain = nil;
    self.sdkAppId = 0;
    self.userSig = nil;
}

- (void)enterRoomWithRoomID:(NSString *)roomID userId:(NSString *)userId role:(TRTCRoleType)role {
    if (!self.userId || self.sdkAppId == 0 || self.isEnterRoom) {
        return;
    }
    self.isEnterRoom = YES;
    self.curroomUUID = [[[NSUUID alloc] init] UUIDString];
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = self.sdkAppId;
    params.userSig = self.userSig;
    params.userId = self.userId;
    params.roomId = [roomID intValue];
    params.role = role;
    [[TRTCCloud sharedInstance] enterRoom:params appScene:TRTCAppSceneLIVE];
}

- (void)switchRole:(TRTCRoleType)role {
    [[TRTCCloud sharedInstance] switchRole:role];
}

- (void)exitRoom {
    [self.playCallbackMap removeAllObjects];
    [[TRTCCloud sharedInstance] exitRoom];
    self.isEnterRoom = NO;
    self.curroomUUID = nil;
}

- (void)setupVideoParam:(BOOL)isOwner {
    TRTCVideoEncParam *videoParam = [[TRTCVideoEncParam alloc] init];
    if (isOwner) {
        // 大主播
        videoParam.videoResolution = TRTCVideoResolution_1280_720;
        videoParam.videoBitrate = 1800;
        videoParam.videoFps = 15;
        videoParam.enableAdjustRes = YES;
    } else {
        // 小主播
        videoParam.videoResolution = TRTCVideoResolution_480_270;
        videoParam.videoBitrate = 400;
        videoParam.videoFps = 15;
    }
    [[TRTCCloud sharedInstance] setVideoEncoderParam:videoParam];
}

- (void)startLocalPreview:(BOOL)frontCamera view:(UIView *)view {
    [[TRTCCloud sharedInstance] startLocalPreview:frontCamera view:view];
}

- (void)stopLocalPreview {
    [[TRTCCloud sharedInstance] stopLocalPreview];
}

- (void)startPublish:(NSString *)streamId {
    if (!self.userId || !self.roomId) {
        return;
    }
    [self enterRoomWithRoomID:self.roomId userId:self.userId role:TRTCRoleAnchor];
    [[TRTCCloud sharedInstance] startLocalAudio];
    if (streamId && streamId.length > 0) {
        [[TRTCCloud sharedInstance] startPublishing:streamId type:TRTCVideoStreamTypeBig];
    }
}

- (void)stopPublish {
    [[TRTCCloud sharedInstance] stopLocalAudio];
    [[TRTCCloud sharedInstance] stopPublishCDNStream];
}

- (void)startPlay:(NSString *)userId streamID:(NSString *)streamID view:(UIView *)view usesCDN:(BOOL)usesCDN roomId:(NSString *)roomId callback:(Callback)callback {
    PlayInfo *info = self.userPlayInfo[userId];
    if (info) {
        if (callback) {
            callback(-1, TRTCLocalize(@"Demo.TRTC.LiveRoom.donotreplaypls"));
        }
        return;
    }
    PlayInfo* playInfo = [[PlayInfo alloc] initWithVideoView:view streamId:streamID roomId:roomId];
    self.userPlayInfo[userId] = playInfo;
    if (usesCDN) {
        if (streamID && callback) {
            self.playCallbackMap[streamID] = callback;
        }
        [self startCDNPlay:playInfo.cdnPlayer streamId:streamID view:view];
    } else {
       if (userId && callback) {
            self.playCallbackMap[userId] = callback;
        }
        [[TRTCCloud sharedInstance] startRemoteView:userId view:view];
        NSString* blockUUID = [self.curroomUUID mutableCopy];
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trtcLivePlayTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            if (!self) {
                return;
            }
            if ([self.curroomUUID isEqualToString:blockUUID]) {
                [self playCallBackWithUserId:userId code:-1 message:TRTCLocalize(@"Demo.TRTC.LiveRoom.timeouttonotplay")];
            }
        });
    }
}

- (void)startTRTCPlay:(NSString *)userId {
    PlayInfo* info = self.userPlayInfo[userId];
    UIView* view = info.videoView;
    if (view) {
        [[TRTCCloud sharedInstance] startRemoteView:userId view:view];
    }
}

- (void)stopPlay:(NSString *)userId usesCDN:(BOOL)usesCDN {
    PlayInfo* playInfo = self.userPlayInfo[userId];
    if (usesCDN) {
        if (playInfo.streamId) {
            [self playCallBackWithUserId:playInfo.streamId code:-1 message:TRTCLocalize(@"Demo.TRTC.LiveRoom.stopplaying")];
        }
        [self stopCdnPlay:playInfo.cdnPlayer];
    } else {
        [self playCallBackWithUserId:userId code:-1 message:TRTCLocalize(@"Demo.TRTC.LiveRoom.stopplaying")];
        [[TRTCCloud sharedInstance] stopRemoteView:userId];
    }
    [self.userPlayInfo removeObjectForKey:userId];
}

- (void)stopAllPlay:(BOOL)usesCDN {
    if (usesCDN) {
        [[self.userPlayInfo allValues] enumerateObjectsUsingBlock:^(PlayInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self stopCdnPlay:obj.cdnPlayer];
        }];
    } else {
       [[TRTCCloud sharedInstance] stopAllRemoteView];
    }
    [self.userPlayInfo removeAllObjects];
}

- (void)onFirstVideoFrame:(NSString *)userId {
    [self playCallBackWithUserId:userId code:0 message:@""];
}

- (void)playCallBackWithUserId:(NSString *)userId code:(NSInteger)code message:(NSString *)message {
    Callback callback = self.playCallbackMap[userId];
    if (callback) {
        [self.playCallbackMap removeObjectForKey:userId];
        callback((int)code, message);
    }
}

- (void)togglePlay:(BOOL)usesCDN {
    if (usesCDN) {
        [self exitRoom];
        [self.userPlayInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, PlayInfo * _Nonnull obj, BOOL * _Nonnull stop) {
            [self startCDNPlay:obj.cdnPlayer streamId:obj.streamId view:obj.videoView];
        }];
    } else {
        [self.userPlayInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, PlayInfo * _Nonnull obj, BOOL * _Nonnull stop) {
            [self stopCdnPlay:obj.cdnPlayer];
        }];
        [self switchRole:TRTCRoleAudience];
    }
}

- (BOOL)isUserPlaying:(NSString *)userId {
    return self.userPlayInfo[userId] != nil;
}

- (void)startRoomPK:(NSString *)roomId userId:(NSString *)userId {
    NSDictionary *dic = @{@"strRoomId": roomId, @"userId": userId};
    [[TRTCCloud sharedInstance] connectOtherRoom:[dic mj_JSONString]];
}

- (void)updateMixingParams:(BOOL)shouldMix {
    if (!self.userId) {
        return;
    }
    if (!shouldMix || self.userPlayInfo.count == 0) {
        [[TRTCCloud sharedInstance] setMixTranscodingConfig:nil];
        return;
    }
    TRTCTranscodingConfig *config = [[TRTCTranscodingConfig alloc] init];
    config.appId = self.sdkAppId;
    config.videoWidth = 544;
    config.videoHeight = 960;
    config.videoGOP = 1;
    config.videoFramerate = 15;
    config.videoBitrate = 1000;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 1;
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:2];
    __block int index = 0;
    TRTCMixUser *me = [[TRTCMixUser alloc] init];
    me.userId = self.userId;
    me.zOrder = index;
    [users addObject:me];
    [self.userPlayInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, PlayInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        index += 1;
        TRTCMixUser *user = [[TRTCMixUser alloc] init];
        user.userId = key;
        user.zOrder = index;
        user.rect = [self rectWithIndex:index width:160 height:288 padding:10];
        user.roomID = obj.roomId;
        [users addObject:user];
    }];
    config.mixUsers = users;
    [[TRTCCloud sharedInstance] setMixTranscodingConfig:config];
}

- (CGRect)rectWithIndex:(int)index width:(CGFloat)width height:(CGFloat)height padding:(CGFloat)padding {
    CGFloat subWidth = (width - padding * 2) / 3;
    CGFloat subHeight = (height - padding * 2) / 3;
    CGFloat x = (9 - index) % 3 * (subWidth + padding);
    CGFloat y = (9 - index) % 3 * (subHeight + padding);
    return CGRectMake(x, y, subWidth, subHeight);
}

- (NSString *)cdnUrlForUser:(NSString *)userId roomId:(NSString *)roomId {
    if (self.sdkAppId == 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%d_%@_%@_main.flv", self.sdkAppId, self.roomId, self.userId];
}

#pragma mark - private method
- (void)startCDNPlay:(TXLivePlayer *)cdnPlayer streamId:(NSString *)streamId view:(UIView *)view {
    if (!self.urlDomain || !streamId) {
        return;
    }
    NSString *streamUrl = nil;
    if ([self.urlDomain hasSuffix:@"/"]) {
        streamUrl = [NSString stringWithFormat:@"%@%@", self.urlDomain, streamId];
    } else {
        streamUrl = [NSString stringWithFormat:@"%@/%@.flv", self.urlDomain, streamId];
    }
    [cdnPlayer setupVideoWidget:view.bounds containView:view insertIndex:0];
    TRTCCloudCdnDelegate *trtcCDNDelegate = [[TRTCCloudCdnDelegate alloc] initWithStreamId:streamId];
    trtcCDNDelegate.action = self;
    cdnPlayer.delegate = trtcCDNDelegate;
    int result = [cdnPlayer startPlay:streamUrl type:PLAY_TYPE_LIVE_FLV];
    if (result != 0) {
        [self playCallBackWithUserId:streamId code:result message:TRTCLocalize(@"Demo.TRTC.LiveRoom.playingfailed")];
    }
}

- (void)stopCdnPlay:(TXLivePlayer *)cdnPlayer {
    cdnPlayer.delegate = nil;
    [cdnPlayer stopPlay];
    [cdnPlayer removeVideoWidget];
}

- (void)setFilter:(UIImage *)image {
    [[[TRTCCloud sharedInstance] getBeautyManager] setFilter:image];
}

- (void)setFilterConcentration:(float)concentration {
    [[[TRTCCloud sharedInstance] getBeautyManager] setFilterStrength:concentration];
}

- (void)setGreenScreenFile:(NSURL *)fileUrl {
    NSString *filePath = [fileUrl path];
    [[[TRTCCloud sharedInstance] getBeautyManager] setGreenScreenFile: filePath];
}


@end
