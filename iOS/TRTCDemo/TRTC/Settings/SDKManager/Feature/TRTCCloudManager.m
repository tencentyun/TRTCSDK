/*
* Module:   TRTCCloudManager
*
* Function: TRTC SDK的视频、音频以及消息功能
*
*    1. 视频功能包括摄像头的设置，视频编码的设置和视频流的设置
*
*    2. 音频功能包括采集端的设置（采集开关、增益、降噪、耳返、采样率），以及播放端的设置（音频通道、音量类型、音量提示）
*
*    3. 消息发送有两种：自定义消息和SEI消息，具体适用场景和限制可参照TRTCCloud.h中sendCustomCmdMsg和sendSEIMsg的描述
*/

#import "TRTCCloudManager.h"
#import "TRTCCloudDef.h"
#import "NSString+Common.h"
#import "CustomAudioFileReader.h"
#import "TestSendCustomVideoData.h"
#import "TestRenderVideoFrame.h"

#define TX_BIZID 3891
#define TX_APPID 1252463788

@interface TRTCCloudManager()<CustomAudioFileReaderDelegate>

@property (strong, nonatomic) TRTCCloud *trtc;
@property (nonatomic) BOOL isCrossingRoom;

// 视频文件播放
@property (strong, nonatomic) TestSendCustomVideoData *videoCaptureTester;
@property (strong, nonatomic) TestRenderVideoFrame *renderTester;

@end

@implementation TRTCCloudManager

- (instancetype)initWithTrtc:(TRTCCloud *)trtc params:(TRTCParams *)params scene:(TRTCAppScene)scene {
    if (self = [super init]) {
        _trtc = trtc;
        _params = params;
        _scene = scene;
        _videoConfig = [[TRTCVideoConfig alloc] initWithScene:scene];
        _audioConfig = [[TRTCAudioConfig alloc] init];
        _renderTester = [[TestRenderVideoFrame alloc] init];
        [self setupTorchObservation];
    }
    return self;
}

- (void)setupTrtc {
    [self setupTrtcVideo];
    [self setupTrtcAudio];
}

- (void)setupTrtcVideo {
    [self.trtc setVideoEncoderParam:self.videoConfig.videoEncConfig];
    [self.trtc enableEncSmallVideoStream:self.videoConfig.isSmallVideoEnabled
                             withQuality:self.videoConfig.smallVideoEncConfig];
    [self.trtc setNetworkQosParam:self.videoConfig.qosConfig];
    [self.trtc setLocalViewFillMode:self.videoConfig.fillMode];
    [self.trtc setLocalViewMirror:self.videoConfig.localMirrorType];
    [self.trtc setVideoEncoderMirror:self.videoConfig.isRemoteMirrorEnabled];
    [self.trtc setGSensorMode:self.videoConfig.isGSensorEnabled ?
        TRTCGSensorMode_UIAutoLayout :
        TRTCGSensorMode_Disable];
    [self.trtc setPriorRemoteVideoStreamType:self.videoConfig.prefersLowQuality ?
        TRTCVideoStreamTypeSmall :
        TRTCVideoStreamTypeBig];
}

- (void)setupTrtcAudio {
    [self.trtc setAudioRoute:self.audioConfig.route];
    [self.trtc setSystemVolumeType:self.audioConfig.volumeType];
    [self.trtc enableAudioEarMonitoring:self.audioConfig.isEarMonitoringEnabled];
    [self setExperimentConfig:@"enableAudioAGC" params:@{ @"enable": @(self.audioConfig.isAgcEnabled) }];
    [self setExperimentConfig:@"enableAudioANS" params:@{ @"enable": @(self.audioConfig.isAnsEnabled) }];
    [self setExperimentConfig:@"setAudioSampleRate" params:@{ @"sampleRate": @(self.audioConfig.sampleRate) }];
    [self.trtc enableAudioVolumeEvaluation:self.audioConfig.isVolumeEvaluationEnabled ? 300 : 0];
}

- (void)enterRoom {
    [self setupTrtc];
    
    [self startLocalAudio:self.audioConfig.isCustomCapture];
    [self startLocalVideo];
    
    [self.trtc enterRoom:self.params appScene:self.scene];
}

- (void)exitRoom {
    [self stopLocalAudio:self.audioConfig.isCustomCapture];
    [self stopLocalVideo];
    
    [self.trtc exitRoom];
}

- (void)switchRole:(TRTCRoleType)role {
    self.params.role = role;
    [self.trtc switchRole:role];
    
    if (role == TRTCRoleAnchor) {
        [self startLocalAudio:self.audioConfig.isCustomCapture];
        [self startLocalVideo];
    } else {
        [self stopLocalAudio:self.audioConfig.isCustomCapture];
        [self stopLocalVideo];
    }
}

#pragma mark - Video Settings

- (void)setResolution:(TRTCVideoResolution)resolution {
    self.videoConfig.videoEncConfig.videoResolution = resolution;
    [self.trtc setVideoEncoderParam:self.videoConfig.videoEncConfig];
}

- (void)setVideoFps:(int)fps {
    self.videoConfig.videoEncConfig.videoFps = fps;
    [self.trtc setVideoEncoderParam:self.videoConfig.videoEncConfig];
    
    self.videoConfig.smallVideoEncConfig.videoFps = fps;
    [self.trtc enableEncSmallVideoStream:self.videoConfig.isSmallVideoEnabled
                             withQuality:self.videoConfig.smallVideoEncConfig];
}

- (void)setVideoBitrate:(int)bitrate {
    self.videoConfig.videoEncConfig.videoBitrate = bitrate;
    [self.trtc setVideoEncoderParam:self.videoConfig.videoEncConfig];
}

- (void)setQosPreference:(TRTCVideoQosPreference)preference {
    self.videoConfig.qosConfig.preference = preference;
    [self.trtc setNetworkQosParam:self.videoConfig.qosConfig];
}

- (void)setResolutionMode:(TRTCVideoResolutionMode)mode {
    self.videoConfig.videoEncConfig.resMode = mode;
    [self.trtc setVideoEncoderParam:self.videoConfig.videoEncConfig];
    
    self.videoConfig.smallVideoEncConfig.resMode = mode;
    [self.trtc enableEncSmallVideoStream:self.videoConfig.isSmallVideoEnabled
                             withQuality:self.videoConfig.smallVideoEncConfig];
}

- (void)setVideoFillMode:(TRTCVideoFillMode)mode {
    self.videoConfig.fillMode = mode;
    [self.trtc setLocalViewFillMode:mode];
}

- (void)setVideoEnabled:(BOOL)isEnabled {
    self.videoConfig.isEnabled = isEnabled;

    if (isEnabled) {
        [self startLocalVideo];
    } else {
        [self stopLocalVideo];
    }
}

- (void)setLocalMirrorType:(TRTCLocalVideoMirrorType)type {
    self.videoConfig.localMirrorType = type;
    [self.trtc setLocalViewMirror:type];
}

- (void)setRemoteMirrorEnabled:(BOOL)isEnabled {
    self.videoConfig.isRemoteMirrorEnabled = isEnabled;
    [self.trtc setVideoEncoderMirror:isEnabled];
}

- (void)setWaterMark:(UIImage *)image inRect:(CGRect)rect {
    [self.trtc setWatermark:image streamType:TRTCVideoStreamTypeBig rect:rect];
    [self.trtc setWatermark:image streamType:TRTCVideoStreamTypeSub rect:rect];
}

- (void)setGSensorEnabled:(BOOL)isEnable {
    self.videoConfig.isGSensorEnabled = isEnable;
    [self.trtc setGSensorMode:isEnable ? TRTCGSensorMode_UIAutoLayout : TRTCGSensorMode_Disable];
}

- (void)setMixingInCloud:(BOOL)isMixingInCloud {
    self.videoConfig.isMixingInCloud = isMixingInCloud;
    if (self.videoConfig.isMixingInCloud) {
        [self updateCloudMixtureParams];
    } else {
        [self.trtc setMixTranscodingConfig:nil];
    }
}

- (void)setQosControlMode:(TRTCQosControlMode)mode {
    self.videoConfig.qosConfig.controlMode = mode;
    [self.trtc setNetworkQosParam:self.videoConfig.qosConfig];
}

- (void)setSmallVideoEnabled:(BOOL)isEnabled {
    self.videoConfig.isSmallVideoEnabled = isEnabled;
    [self.trtc enableEncSmallVideoStream:isEnabled
                             withQuality:self.videoConfig.smallVideoEncConfig];
}

- (void)setPrefersLowQuality:(BOOL)prefersLowQuality {
    self.videoConfig.prefersLowQuality = prefersLowQuality;
    TRTCVideoStreamType type = prefersLowQuality ?
        TRTCVideoStreamTypeSmall :
        TRTCVideoStreamTypeBig;
    [self.trtc setPriorRemoteVideoStreamType:type];
}

- (void)switchCamera {
    self.videoConfig.isFrontCamera = !self.videoConfig.isFrontCamera;
    self.videoConfig.isTorchOn = NO;
    [self.trtc switchCamera];
}

- (void)switchTorch {
    self.videoConfig.isTorchOn = !self.videoConfig.isTorchOn;
    [self.trtc enbaleTorch:self.videoConfig.isTorchOn];
}

- (void)setAutoFocusEnabled:(BOOL)isEnabled {
    self.videoConfig.isAutoFocusOn = isEnabled;
    [self.trtc enableAutoFaceFoucs:isEnabled];
}

- (void)setCustomVideo:(AVAsset *)videoAsset {
    self.videoConfig.videoAsset = videoAsset;
}

#pragma mark - Audio Settings

- (void)setAudioEnabled:(BOOL)isEnabled {
    self.audioConfig.isEnabled = isEnabled;
    if (isEnabled) {
        [self startLocalAudio:self.audioConfig.isCustomCapture];
    } else {
        [self stopLocalAudio:self.audioConfig.isCustomCapture];
    }
}

- (void)setAudioRoute:(TRTCAudioRoute)route {
    self.audioConfig.route = route;
    [self.trtc setAudioRoute:route];
}

- (void)setVolumeType:(TRTCSystemVolumeType)type {
    self.audioConfig.volumeType = type;
    [self.trtc setSystemVolumeType:type];
}

- (void)setEarMonitoringEnabled:(BOOL)isEnabled {
    self.audioConfig.isEarMonitoringEnabled = isEnabled;
    [self.trtc enableAudioEarMonitoring:isEnabled];
}

- (void)setAgcEnabled:(BOOL)isEnabled {
    self.audioConfig.isAgcEnabled = isEnabled;
    [self setExperimentConfig:@"enableAudioAGC" params:@{ @"enable": @(isEnabled) }];
}

- (void)setAnsEnabled:(BOOL)isEnabled {
    self.audioConfig.isAnsEnabled = isEnabled;
    [self setExperimentConfig:@"enableAudioANS" params:@{ @"enable": @(isEnabled) }];
}

- (void)setSampleRate:(NSInteger)sampleRate {
    self.audioConfig.sampleRate = sampleRate;
    [self setExperimentConfig:@"setAudioSampleRate" params:@{ @"sampleRate": @(sampleRate) }];
}

- (void)setVolumeEvaluationEnabled:(BOOL)isEnabled {
    self.audioConfig.isVolumeEvaluationEnabled = isEnabled;
    [self.trtc enableAudioVolumeEvaluation:isEnabled ? 300 : 0];
}

#pragma mark - Message

- (BOOL)sendCustomMessage:(NSString *)message {
    NSData * _Nullable data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        return [self.trtc sendCustomCmdMsg:0 data:data reliable:YES ordered:NO];
    }
    return NO;
}

- (BOOL)sendSEIMessage:(NSString *)message repeatCount:(NSInteger)repeatCount {
    NSData * _Nullable data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        return [self.trtc sendSEIMsg:data repeatCount:repeatCount == 0 ? 1 : (int)repeatCount];
    }
    return NO;
}

#pragma mark - Cross Rooom

- (void)startCrossRoom:(NSString *)roomId userId:(NSString *)userId {
    self.isCrossingRoom = YES;
    
    NSDictionary* pkParams = @{
        @"strRoomId" : roomId,
        @"userId" : userId,
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pkParams options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self.trtc connectOtherRoom:jsonString];
    [self.remoteUserManager addUser:userId roomId:roomId];
}

- (void)stopCrossRomm {
    self.isCrossingRoom = NO;
    
    [self.trtc disconnectOtherRoom];
}

#pragma mark - Others

- (void)playCustomVideoOfUser:(NSString *)userId inView:(UIImageView *)view {
    [self.trtc startRemoteView:userId view:nil];
    [self.renderTester addUser:userId videoView:view];
    [self.trtc setRemoteVideoRenderDelegate:userId
                                   delegate:self.renderTester
                                pixelFormat:TRTCVideoPixelFormat_NV12
                                 bufferType:TRTCVideoBufferType_PixelBuffer];
}

#pragma mark - Private

- (void)startLocalAudio:(BOOL)isCustomCapture {
    if (!self.audioConfig.isEnabled || self.isLiveAudience) {
        return;
    }
    if (isCustomCapture) {
        [CustomAudioFileReader sharedInstance].delegate = self;
        [[CustomAudioFileReader sharedInstance] start:48000 channels:1 framLenInSample:960];
        [self.trtc enableCustomAudioCapture:YES];
    } else {
        [self.trtc startLocalAudio];
    }
}

- (void)stopLocalAudio:(BOOL)isCustomCapture {
    if (isCustomCapture) {
        [self.trtc enableCustomAudioCapture:NO];
        [[CustomAudioFileReader sharedInstance] stop];
        [CustomAudioFileReader sharedInstance].delegate = nil;
    } else {
        [self.trtc stopLocalAudio];
    }
}

- (void)startLocalVideo {
    if (!self.videoConfig.isEnabled || self.isLiveAudience) {
        return;
    }
    if (self.videoConfig.videoAsset) {
        // 使用视频文件
        [self setupVideoCapture];
        [self.trtc enableCustomVideoCapture:YES];
        [self.trtc setLocalVideoRenderDelegate:self.renderTester
                                   pixelFormat:TRTCVideoPixelFormat_NV12
                                    bufferType:TRTCVideoBufferType_PixelBuffer];
        [self.renderTester addUser:nil videoView:self.videoView];
        [self.videoCaptureTester start];
    } else {
        // 使用摄像头采集视频
        [self.trtc startLocalPreview:self.videoConfig.isFrontCamera
                                view:self.videoView];
    }
}

- (void)stopLocalVideo {
    if (self.videoCaptureTester) {
        [self.videoCaptureTester stop];
        self.videoCaptureTester = nil;
    } else {
        [self.trtc stopLocalPreview];
    }
}

- (BOOL)isLiveAudience {
    return self.scene == TRTCAppSceneLIVE && self.params.role == TRTCRoleAudience;
}

- (void)setupVideoCapture {
    self.videoCaptureTester = [[TestSendCustomVideoData alloc]
                               initWithTRTCCloud:self.trtc
                               mediaAsset:self.videoConfig.videoAsset];
    [self setVideoFps:self.videoCaptureTester.mediaReader.fps];
}

- (void)setExperimentConfig:(NSString *)key params:(NSDictionary *)params {
    NSDictionary *json = @{
        @"api": key,
        @"params": params
    };
    [self.trtc callExperimentalAPI:[self jsonStringFrom:json]];
}

- (NSString *)jsonStringFrom:(NSDictionary *)dict {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)updateCloudMixtureParams {
    if (!self.videoConfig.isMixingInCloud) {
        return;
    }
    int videoWidth  = 720;
    int videoHeight = 1280;
    
    // 小画面宽高
    int subWidth  = 180;
    int subHeight = 320;
    
    int offsetX = 5;
    int offsetY = 50;
    
    int bitrate = 200;
    
    switch (self.videoConfig.videoEncConfig.videoResolution) {
            
        case TRTCVideoResolution_160_160:
        {
            videoWidth  = 160;
            videoHeight = 160;
            subWidth    = 27;
            subHeight   = 48;
            offsetY     = 20;
            bitrate     = 200;
            break;
        }
        case TRTCVideoResolution_320_180:
        {
            videoWidth  = 192;
            videoHeight = 336;
            subWidth    = 54;
            subHeight   = 96;
            offsetY     = 30;
            bitrate     = 400;
            break;
        }
        case TRTCVideoResolution_320_240:
        {
            videoWidth  = 240;
            videoHeight = 320;
            subWidth    = 54;
            subHeight   = 96;
            bitrate     = 400;
            break;
        }
        case TRTCVideoResolution_480_480:
        {
            videoWidth  = 480;
            videoHeight = 480;
            subWidth    = 72;
            subHeight   = 128;
            bitrate     = 600;
            break;
        }
        case TRTCVideoResolution_640_360:
        {
            videoWidth  = 368;
            videoHeight = 640;
            subWidth    = 90;
            subHeight   = 160;
            bitrate     = 800;
            break;
        }
        case TRTCVideoResolution_640_480:
        {
            videoWidth  = 480;
            videoHeight = 640;
            subWidth    = 90;
            subHeight   = 160;
            bitrate     = 800;
            break;
        }
        case TRTCVideoResolution_960_540:
        {
            videoWidth  = 544;
            videoHeight = 960;
            subWidth    = 171;
            subHeight   = 304;
            bitrate     = 1000;
            break;
        }
        case TRTCVideoResolution_1280_720:
        {
            videoWidth  = 720;
            videoHeight = 1280;
            subWidth    = 180;
            subHeight   = 320;
            bitrate     = 1500;
            break;
        }
        default:
            assert(false);
            break;
    }
    
    TRTCTranscodingConfig* config = [TRTCTranscodingConfig new];
    config.appId = TX_APPID;
    config.bizId = TX_BIZID;
    config.videoWidth = videoWidth;
    config.videoHeight = videoHeight;
    config.videoGOP = 1;
    config.videoFramerate = 15;
    config.videoBitrate = bitrate;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 1;
    
    // 设置混流后主播的画面位置
    TRTCMixUser* broadCaster = [TRTCMixUser new];
    broadCaster.userId = self.params.userId; // 以主播uid为broadcaster为例
    broadCaster.zOrder = 0;
    broadCaster.rect = CGRectMake(0, 0, videoWidth, videoHeight);
    broadCaster.roomID = nil;
    
    NSMutableArray* mixUsers = [NSMutableArray new];
    [mixUsers addObject:broadCaster];
    
    // 设置混流后各个小画面的位置
    __block int index = 0;
    [self.remoteUserManager.remoteUsers enumerateKeysAndObjectsUsingBlock:^(NSString *userId, TRTCRemoteUserConfig *settings, BOOL *stop) {
        TRTCMixUser* audience = [TRTCMixUser new];
        audience.userId = userId;
        audience.zOrder = 1 + index;
        audience.roomID = settings.roomId;
        //辅流判断：辅流的Id为原userId + "-sub"
        if ([userId hasSuffix:@"-sub"]) {
            NSArray* spritStrs = [userId componentsSeparatedByString:@"-"];
            if (spritStrs.count < 2) {
                return;
            }
            NSString* realUserId = spritStrs[0];
            audience.userId = realUserId;
            audience.streamType = TRTCVideoStreamTypeSub;
        }
        if (index < 3) {
            // 前三个小画面靠右从下往上铺
            audience.rect = CGRectMake(videoWidth - offsetX - subWidth, videoHeight - offsetY - index * subHeight - subHeight, subWidth, subHeight);
        } else if (index < 6) {
            // 后三个小画面靠左从下往上铺
            audience.rect = CGRectMake(offsetX, videoHeight - offsetY - (index - 3) * subHeight - subHeight, subWidth, subHeight);
        } else {
            // 最多只叠加六个小画面
        }
        
        [mixUsers addObject:audience];
        ++index;
    }];
    config.mixUsers = mixUsers;
    [_trtc setMixTranscodingConfig:config];
}

#pragma mark - Live Player

- (NSString *)getCdnUrlOfUser:(NSString *)userId {
    NSString* md5streamId = [[NSString stringWithFormat:@"%@_%@_main", @(self.params.roomId), userId] md5];
    return [NSString stringWithFormat:@"http://3891.liveplay.myqcloud.com/live/3891_%@.flv", md5streamId];
}

#pragma mark - Torch Observe

- (void)setupTorchObservation {
    __weak __typeof(self) wSelf = self;
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIApplicationDidEnterBackgroundNotification
     object:self
     queue:NSOperationQueue.mainQueue
     usingBlock:^(NSNotification * _Nonnull note) {
        wSelf.videoConfig.isTorchOn = NO;
    }];
}

#pragma mark - custom audio send

- (void)onAudioCapturePcm:(NSData *)pcmData sampleRate:(int)sampleRate channels:(int)channels ts:(uint32_t)timestampMs {
    TRTCAudioFrame * frame = [[TRTCAudioFrame alloc] init];
    frame.data = pcmData;
    frame.sampleRate = sampleRate;
    frame.channels = channels;
    frame.timestamp = timestampMs;
    
    [self.trtc sendCustomAudioData:frame];
}

@end
