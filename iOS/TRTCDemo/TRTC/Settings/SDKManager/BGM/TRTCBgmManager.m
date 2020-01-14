/*
* Module:   TRTCBgmManager
*
* Function: TRTC SDK的BGM和声音处理功能调用
*
*    1. BGM包括播放、暂停、继续和停止。注意每次调用playBgm时，BGM都会重头开始播放。
*
*    2. 声音的处理包括混响和变声，支持的类型分别定义在TRTCReverbType和TRTCVoiceChangerType中。
*
*/

#import "TRTCBgmManager.h"

@interface TRTCBgmManager()

@property (strong, nonatomic) TRTCCloud *trtc;

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isOnPause;
@property (nonatomic) float progress;
@property (nonatomic) NSInteger bgmVolume;
@property (nonatomic) NSInteger bgmPlayoutVolume;
@property (nonatomic) NSInteger bgmPublishVolume;
@property (nonatomic) NSInteger micVolume;
@property (nonatomic) TRTCReverbType reverb;
@property (nonatomic) TRTCVoiceChangerType voiceChanger;

@end


@implementation TRTCBgmManager

- (instancetype)initWithTrtc:(TRTCCloud *)trtc {
    if (self = [super init]) {
        _trtc = trtc;
        _bgmVolume = 100;
        _bgmPlayoutVolume = 100;
        _bgmPublishVolume = 100;
        _micVolume = 100;
    }
    return self;
}

- (void)playBgm:(NSString *)path onProgress:(void (^)(float))progressNotify onCompleted:(void (^)(void))completeNotify {
    self.isPlaying = YES;
    
    [self.trtc setBGMVolume:_bgmVolume];
    [self.trtc setBGMPlayoutVolume:_bgmPlayoutVolume];
    [self.trtc setBGMPublishVolume:_bgmPublishVolume];
    
    __weak __typeof(self) wSelf = self;
    [self.trtc playBGM:path withBeginNotify:^(NSInteger errCode) {
        if (errCode != 0) {
            wSelf.isPlaying = NO;
        }
    } withProgressNotify:^(NSInteger progressMS, NSInteger durationMS) {
        wSelf.progress = (float)progressMS / durationMS;
        progressNotify(wSelf.progress);
    } andCompleteNotify:^(NSInteger errCode) {
        wSelf.isPlaying = NO;
        completeNotify();
    }];
}

- (void)stopBgm {
    self.isPlaying = NO;
    [self.trtc stopBGM];
}

- (void)resumeBgm {
    self.isOnPause = NO;
    [self.trtc resumeBGM];
}

- (void)pauseBgm {
    self.isOnPause = YES;
    [self.trtc pauseBGM];
}

- (void)setBgmVolume:(NSInteger)volume {
    _bgmVolume = volume;
    _bgmPlayoutVolume = volume;
    _bgmPublishVolume = volume;
    [self.trtc setBGMVolume:volume];
}

- (void)setBgmPlayoutVolume:(NSInteger)volume {
    _bgmPlayoutVolume = volume;
    [self.trtc setBGMPlayoutVolume:volume];
}

- (void)setBgmPublishVolume:(NSInteger)volume {
    _bgmPublishVolume = volume;
    [self.trtc setBGMPublishVolume:volume];
}

- (void)setMicVolume:(NSInteger)volume {
    _micVolume = volume;
    [self.trtc setMicVolumeOnMixing:volume];
}

- (void)setReverb:(TRTCReverbType)reverb {
    _reverb = reverb;
    [self.trtc setReverbType:reverb];
}

- (void)setVoiceChanger:(TRTCVoiceChangerType)voiceChanger {
    _voiceChanger = voiceChanger;
    [self.trtc setVoiceChangerType:voiceChanger];
}

@end
