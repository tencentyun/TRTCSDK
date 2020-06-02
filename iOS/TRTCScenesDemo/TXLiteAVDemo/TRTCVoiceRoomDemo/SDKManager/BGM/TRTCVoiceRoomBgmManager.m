//
//  TRTCVoiceRoomBgmManager.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCVoiceRoomBgmManager.h"

@interface TRTCVoiceRoomBgmManager()

@property (strong, nonatomic) TRTCCloud *trtc;

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isOnPause;
@property (nonatomic) float progress;
@property (nonatomic) NSInteger bgmVolume;
@property (nonatomic) NSInteger micVolume;
@property (nonatomic) TRTCReverbType reverb;
@property (nonatomic) TRTCVoiceChangerType voiceChanger;

@end

@implementation TRTCVoiceRoomBgmManager

- (instancetype)initWithTrtc:(TRTCCloud *)trtc {
    if (self = [super init]) {
        _trtc = trtc;
        _bgmVolume = 100;
        _micVolume = 100;
    }
    return self;
}

- (void)playBgm:(NSString *)path onProgress:(void (^)(float))progressNotify onComplete:(void(^)(void))complete{
    self.isPlaying = YES;
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
        complete();
    }];
    [self.trtc setBGMVolume:_bgmVolume];
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
    [self.trtc setBGMVolume:volume];
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
