/*
* Module:   TRTCVoiceRoomCloudManager
*
* Function: TRTC SDK的视频、音频以及消息功能
*
*    1. 视频功能包括摄像头的设置，视频编码的设置和视频流的设置
*
*    2. 音频功能包括采集端的设置（采集开关、增益、降噪、耳返、采样率），以及播放端的设置（音频通道、音量类型、音量提示）
*
*    3. 消息发送有两种：自定义消息和SEI消息，具体适用场景和限制可参照TRTCCloud.h中sendCustomCmdMsg和sendSEIMsg的描述
*/

#import "TRTCVoiceRoomCloudManager.h"
#import "TRTCCloudDef.h"
#import "TRTCVoiceRoomTestUserSig.h"
#import "TRTCVoiceRoomCustomAudioFileReader.h"

@interface TRTCVoiceRoomCloudManager()<TRTCVoiceRoomCustomAudioFileReaderDelegate>

@property (strong, nonatomic) TRTCCloud *trtc;
@property (nonatomic) BOOL isCrossingRoom;

@property (nonatomic, assign) TRTCAudioQuality audioQuality;

@end

@implementation TRTCVoiceRoomCloudManager

- (instancetype)initWithTrtc:(TRTCCloud *)trtc params:(TRTCParams *)params scene:(TRTCAppScene)scene {
    if (self = [super init]) {
        _trtc = trtc;
        _params = params;
        _scene = scene;
        _audioConfig = [[TRTCVoiceRoomAudioConfig alloc] init];
        if (16000 == _audioConfig.sampleRate) {
            _audioQuality = TRTCAudioQualitySpeech;
        } else {
            _audioQuality = TRTCAudioQualityDefault;
        }
    }
    return self;
}

- (void)setupTrtc {
    [self setupTrtcAudio];
}


- (void)setupTrtcAudio {
    [self.trtc setAudioRoute:self.audioConfig.route];
    [self.trtc enableAudioEarMonitoring:self.audioConfig.isEarMonitoringEnabled];
    [self setExperimentConfig:@"enableAudioAGC" params:@{ @"enable": @(self.audioConfig.isAgcEnabled) }];
    [self setExperimentConfig:@"enableAudioANS" params:@{ @"enable": @(self.audioConfig.isAnsEnabled) }];
    [self.trtc setAudioQuality:self.audioQuality];
    [self.trtc enableAudioVolumeEvaluation:self.audioConfig.isVolumeEvaluationEnabled ? 300 : 0];
}

- (void)enterRoom {
    [self setupTrtc];
    
    [self.trtc enterRoom:self.params appScene:self.scene];
    
    [self startLocalAudio:self.audioConfig.isCustomCapture];
}

- (void)exitRoom {
    [self stopLocalAudio:self.audioConfig.isCustomCapture];
    
    [self.trtc exitRoom];
}

- (void)switchRole:(TRTCRoleType)role {
    self.params.role = role;
    [self.trtc switchRole:role];
    
    if (role == TRTCRoleAnchor) {
        [self startLocalAudio:self.audioConfig.isCustomCapture];
    } else {
        [self stopLocalAudio:self.audioConfig.isCustomCapture];
    }
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

- (void)setAudioQuality:(NSInteger)quality {
    TRTCAudioQuality target = TRTCAudioQualityMusic;
    switch (quality) {
        case 1:
            target = TRTCAudioQualitySpeech;
            break;
        case 2:
            target = TRTCAudioQualityDefault;
            break;
        case 3:
            target = TRTCAudioQualityMusic;
            break;
        default:
            break;
    }
    _audioQuality = target;
    [self.trtc setAudioQuality:target];
}

- (void)setVolumeEvaluationEnabled:(BOOL)isEnabled {
    self.audioConfig.isVolumeEvaluationEnabled = isEnabled;
    [self.trtc enableAudioVolumeEvaluation:isEnabled ? 300 : 0];
}

-(void)setSilent:(BOOL)isEnabled{
    self.audioConfig.isSilent = isEnabled;
    [self.trtc muteAllRemoteAudio:isEnabled];
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
}

- (void)stopCrossRomm {
    self.isCrossingRoom = NO;
    
    [self.trtc disconnectOtherRoom];
}



#pragma mark - Private

- (void)startLocalAudio:(BOOL)isCustomCapture {
    if (!self.audioConfig.isEnabled || self.isLiveAudience) {
        return;
    }
    if (isCustomCapture) {
        [TRTCVoiceRoomCustomAudioFileReader sharedInstance].delegate = self;
        [[TRTCVoiceRoomCustomAudioFileReader sharedInstance] start:48000 channels:1 framLenInSample:960];
        [self.trtc enableCustomAudioCapture:YES];
    } else {
        [self.trtc startLocalAudio];
    }
}

- (void)stopLocalAudio:(BOOL)isCustomCapture {
    if (isCustomCapture) {
        [self.trtc enableCustomAudioCapture:NO];
        [[TRTCVoiceRoomCustomAudioFileReader sharedInstance] stop];
        [TRTCVoiceRoomCustomAudioFileReader sharedInstance].delegate = nil;
    } else {
        [self.trtc stopLocalAudio];
    }
}




- (BOOL)isLiveAudience {
    return self.scene == TRTCAppSceneLIVE && self.params.role == TRTCRoleAudience;
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



#pragma mark - Live Player

- (NSString *)getCdnUrl{
    NSString *playUrl = [NSString stringWithFormat:@"http://%d.liveplay.myqcloud.com/live/mix_%d_%u.flv",_BIZID,_SDKAppID,(unsigned int)self.params.roomId];
    
//    NSString *playUrl = @"http://5815.liveplay.myqcloud.com/live/5815_89aad37e06ff11e892905cb9018cf0d4_900.flv";        //测试用
    
    return playUrl;
}


//禁本地麦
-(void)setMuteLocalAudio:(BOOL)isMuteLocalAudio{
    self.audioConfig.isMuteLocalAudio = isMuteLocalAudio;
    [_trtc muteLocalAudio:isMuteLocalAudio];
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
