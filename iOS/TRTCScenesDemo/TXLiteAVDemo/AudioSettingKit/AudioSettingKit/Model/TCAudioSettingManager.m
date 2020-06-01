//
//  TCAudioSettingManager.m
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/28.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TCAudioSettingManager.h"
#import "TRTCCloud.h"
#import "TXAudioEffectManager.h"

@interface TCAudioSettingManager (){
    uint32_t _bgmID; // 当前播放的bgmID
}

@property (nonatomic, strong)TXAudioEffectManager *manager;

@end

@implementation TCAudioSettingManager

- (void)setAudioEffectManager:(TXAudioEffectManager *)manager {
    self.manager = manager;
}

/// 设置变声效果
/// @param value 变声效果
- (void)setVoiceChangerTypeWithValue:(NSInteger)value {
    [self.manager setVoiceChangerType:value];
}

/// 设置混响效果
/// @param value 设置混响效果
- (void)setReverbTypeWithValue:(NSInteger)value {
    [self.manager setVoiceReverbType:value];
}

- (void)setBGMVolume:(NSInteger)volume {
    if (_bgmID != 0) {
        [self.manager setMusicPlayoutVolume:_bgmID volume:volume];
        [self.manager setMusicPublishVolume:_bgmID volume:volume];
    }
}

- (void)setVoiceVolume:(NSInteger)volume {
    [self.manager setVoiceVolume:volume];
}

- (void)setBGMPitch:(CGFloat)value {
    if (_bgmID != 0) {
        [self.manager setMusicPitch:_bgmID pitch:value];
    }
}

- (void)playMusicWithPath:(NSString *)path bgmID:(NSInteger)bgmID {
    if (_bgmID == bgmID) {
        [self resumePlay];
        return;
    } else {
        [self.manager stopPlayMusic:_bgmID];
        _bgmID = bgmID;
    }
    TXAudioMusicParam *params = [[TXAudioMusicParam alloc] init];
    params.ID   = _bgmID;
    params.path = path;
    [self.manager startPlayMusic:params onStart:^(NSInteger errCode) {
        // 开始
        if (self.delegate && [self.delegate respondsToSelector:@selector(onStartPlayMusic)]) {
            [self.delegate onStartPlayMusic];
        }
    } onProgress:^(NSInteger progressMs, NSInteger durationMs) {
        // 进度
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayingWithCurrent:total:)]) {
            [self.delegate onPlayingWithCurrent:progressMs / 1000 total: durationMs / 1000];
        }
    } onComplete:^(NSInteger errCode) {
       // 结束
        if (self.delegate && [self.delegate respondsToSelector:@selector(onStartPlayMusic)]) {
            [self.delegate onStopPlayerMusic];
        }
    }];
}

- (void)stopPlay {
    if (_bgmID != 0) {
        [self.manager stopPlayMusic:_bgmID];
        _bgmID = 0;
    }
    
}

- (void)pausePlay {
    if (_bgmID != 0) {
        [self.manager pausePlayMusic:_bgmID];
    }
}

- (void)resumePlay {
    if (_bgmID != 0) {
        [self.manager resumePlayMusic:_bgmID];
    }
}

- (void)clearStates {
    if (_bgmID != 0) {
        [self setBGMPitch:0];
        [self stopPlay];
        _bgmID = 0;
    }
    [self setVoiceVolume:100];
    [self setBGMVolume:100];
    self.manager = nil;
}

@end
