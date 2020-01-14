/*
* Module:   TRTCVoiceRoomBgmManager
*
* Function: TRTC SDK的BGM和声音处理功能调用
*
*    1. BGM包括播放、暂停、继续和停止。注意每次调用playBgm时，BGM都会重头开始播放。
*
*    2. 声音的处理包括混响和变声，支持的类型分别定义在TRTCReverbType和TRTCVoiceChangerType中。
*
*/

#import <Foundation/Foundation.h>
#import "TRTCCloud.h"
#import "TRTCCloudDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCVoiceRoomBgmManager : NSObject

@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isOnPause;
@property (nonatomic, readonly) float progress;

@property (nonatomic, readonly) NSInteger bgmVolume;
@property (nonatomic, readonly) NSInteger micVolume;
@property (nonatomic, readonly) TRTCReverbType reverb;
@property (nonatomic, readonly) TRTCVoiceChangerType voiceChanger;

- (instancetype)initWithTrtc:(TRTCCloud *)trtc NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// 开始播放BGM
/// @param path Bgm文件位置，可以是本地文件地址，也可以是网络地址
/// @param progressNotify 播放进度回调，取值范围为0.0 - 1.0
/// @param complete 播放结束
- (void)playBgm:(NSString *)path onProgress:(void (^)(float))progressNotify onComplete:(void(^)(void))complete;

/// 停止播放
- (void)stopBgm;

/// 继续播放
- (void)resumeBgm;

/// 暂停播放
- (void)pauseBgm;

/// 设置混音时Bgm音量大小
/// @param volume Bgm音量，取值范围为0 - 100
- (void)setBgmVolume:(NSInteger)volume;

/// 设置混音时麦克风音量大小
/// @param volume 麦克风音量，取值范围为0 - 100
- (void)setMicVolume:(NSInteger)volume;

/// 设置混响类型
/// @param reverb 混响类型，详见 TRTCReverbType
- (void)setReverb:(TRTCReverbType)reverb;

/// 设置变声类型
/// @param voiceChanger 变声类型，详见 TRTCVoiceChangerType
- (void)setVoiceChanger:(TRTCVoiceChangerType)voiceChanger;

@end

NS_ASSUME_NONNULL_END
