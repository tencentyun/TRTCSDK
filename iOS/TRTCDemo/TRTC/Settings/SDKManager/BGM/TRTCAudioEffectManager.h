/*
* Module:   TRTCAudioEffectManager
*
* Function: TRTC SDK的音效功能管理
*
*    1. Demo中内置了三个音效文件: vchat_cheers.m4a, giftSent.aac和on_mic.aac，可根据app实际需要更改
*
*    2. 每个音效都需要一个ID（effectId），调用API时，通过传入ID来控制对应音效。
*
*/

#import <Foundation/Foundation.h>
#import "TRTCCloud.h"
#import "TRTCCloudDef.h"

NS_ASSUME_NONNULL_BEGIN

@class TRTCAudioEffectConfig;

@interface TRTCAudioEffectManager : NSObject

/// 音效列表
@property (strong, nonatomic, readonly) NSArray<TRTCAudioEffectConfig *> *effects;

/// 全局音量
@property (nonatomic) NSInteger globalVolume;

/// 循环次数
@property (nonatomic) NSInteger loopCount;


- (instancetype)initWithTrtc:(TRTCCloud *)trtc NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// 设置音效循环次数，次数会设置到每个音效对应的TRTCAudioEffectParam中
/// @param loopCount 循环次数，0表示播放1次，1表示播放2次，依次类推
- (void)setLoopCount:(NSInteger)loopCount;

/// 设置音效音量
/// @param effectId 音效ID
/// @param volume 音量，取值范围为0 - 100
- (void)updateEffect:(NSInteger)effectId volume:(NSInteger)volume;

/// 切换音效上传，如果不开启上传，则音效仅在本地播放
/// @param effectId 音效ID
- (void)toggleEffectPublish:(NSInteger)effectId;

/// 设置全局音效音量
/// @param globalVolume 全局音效音量
- (void)setGlobalVolume:(NSInteger)globalVolume;

/// 播放音效
/// @param effectId 音效ID
- (void)playEffect:(NSInteger)effectId;

/// 停止音效
/// @param effectId 音效ID
- (void)stopEffect:(NSInteger)effectId;

/// 暂停音效
/// @param effectId 音效ID
- (void)pauseEffect:(NSInteger)effectId;

/// 继续音效
/// @param effectId 音效ID
- (void)resumeEffect:(NSInteger)effectId;

/// 停止全部音效
- (void)stopAllEffects;

@end

#pragma mark - TRTCAudioEffectConfig

typedef NS_ENUM(NSUInteger, TRTCPlayState) {
    TRTCPlayStateIdle,
    TRTCPlayStatePlaying,
    TRTCPlayStateOnPause,
};

@interface TRTCAudioEffectConfig : NSObject

@property (nonatomic) TRTCPlayState playState;
@property (nonatomic) float progress;
@property (strong, nonatomic) TRTCAudioEffectParam *params;

@end

NS_ASSUME_NONNULL_END
