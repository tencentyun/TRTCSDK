//
//  TRTCVoiceRoomAudioEffectManager.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCVoiceRoomAudioEffectManager.h"

@interface TRTCVoiceRoomAudioEffectManager()

@property (strong, nonatomic) TRTCCloud *trtc;
@property (strong, nonatomic) NSArray<TRTCAudioEffectParam *> *effects;

@end

@implementation TRTCVoiceRoomAudioEffectManager

- (instancetype)initWithTrtc:(TRTCCloud *)trtc {
    if (self = [super init]) {
        self.trtc = trtc;
        self.effects = [self setupEffects];
        self.globalVolume = 100;
        self.loopCount = 1;
    }
    return self;
}

- (NSArray<TRTCAudioEffectParam *> *)setupEffects {
    return @[
        [self buildEffectWithId:0 path:[[NSBundle mainBundle] pathForResource:@"vchat_cheers" ofType:@"m4a"]],
        [self buildEffectWithId:1 path:[[NSBundle mainBundle] pathForResource:@"giftSent" ofType:@"aac"]],
        [self buildEffectWithId:2 path:[[NSBundle mainBundle] pathForResource:@"on_mic" ofType:@"aac"]],
    ];
}
        
- (TRTCAudioEffectParam *)buildEffectWithId:(int)effectId path:(NSString *)path {
    TRTCAudioEffectParam *effect = [[TRTCAudioEffectParam alloc] initWith:effectId path:path];
    effect.publish = YES;
    effect.volume = 100;
    return effect;
}

- (void)setLoopCount:(NSInteger)loopCount {
    _loopCount = loopCount;
    for (TRTCAudioEffectParam *effect in self.effects) {
        effect.loopCount = (int)loopCount;
    }
}

- (void)updateEffect:(NSInteger)effectId volume:(NSInteger)volume {
    self.effects[effectId].volume = (int) volume;
    [self.trtc setAudioEffectVolume:(int)effectId volume:(int)volume];
}

- (void)toggleEffectPublish:(NSInteger)effectId {
    self.effects[effectId].publish = !self.effects[effectId].publish;
}

- (void)setGlobalVolume:(NSInteger)globalVolume {
    _globalVolume = globalVolume;
    for (TRTCAudioEffectParam *effect in self.effects) {
        effect.volume = (int) globalVolume;
    }
    [self.trtc setAllAudioEffectsVolume:(int)globalVolume];
}

- (void)playEffect:(NSInteger)effectId {
    [self.trtc playAudioEffect:self.effects[effectId]];
}

- (void)stopEffect:(NSInteger)effectId {
    [self.trtc stopAudioEffect:(int)effectId];
}

- (void)stopAllEffects {
    [self.trtc stopAllAudioEffects];
}

@end
