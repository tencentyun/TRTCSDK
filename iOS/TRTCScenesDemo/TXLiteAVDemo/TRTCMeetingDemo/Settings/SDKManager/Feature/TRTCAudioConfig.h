/*
* Module:   TRTCAudioConfig
*
* Function: 保存音频的设置项
*
*    1. 在init中，会检查UserDefauls是否有历史记录，如存在则用历史记录初始化对象
*
*    2. 在dealloc中，将对象当前的值保存进UserDefaults中
*
*/

#import <Foundation/Foundation.h>
#import "TRTCCloud.h"
#import "TRTCCloudDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCAudioConfig : NSObject

/// 采样率，支持的值为8000, 16000, 32000, 44100, 48000
@property (nonatomic) NSInteger sampleRate;

/// 音频是否开启，默认为YES
@property (nonatomic) BOOL isEnabled;

/// 音频是否自定义采集，默认为NO，如果希望测试自定义音频采集，可以将默认值改为YES
@property (nonatomic) BOOL isCustomCapture;

/// 音频路由，类型为TRTCAudioRoute，默认为TRTCAudioModeSpeakerphone
@property (nonatomic) TRTCAudioRoute route;

/// 音量类型，类型为TRTCSystemVolumeType，默认为TRTCSystemVolumeTypeAuto
@property (nonatomic) TRTCSystemVolumeType volumeType;

/// 自动增益，默认为NO
@property (nonatomic) BOOL isAgcEnabled;

/// 噪声消除，默认为NO
@property (nonatomic) BOOL isAnsEnabled;

/// 耳返，默认为NO
@property (nonatomic) BOOL isEarMonitoringEnabled;

/// 音量提示，默认为NO
@property (nonatomic) BOOL isVolumeEvaluationEnabled;

@end

NS_ASSUME_NONNULL_END
