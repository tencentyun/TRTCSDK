/*
* Module:   TRTCVideoConfig
*
* Function: 保存视频的设置项，并提供每个分辨率下对应的码率支持
*
*    1. 在init中，会检查UserDefauls是否有历史记录，如存在则用历史记录初始化对象
*
*    2. 在dealloc中，将对象当前的值保存进UserDefaults中
*
*    3. 分辨率对应的码率配置在TRTCBitrateRange对象中，包括最小、最大和推荐码率，以及码率调整的步长
*/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TRTCCloud.h"
#import "TRTCCloudDef.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TRTCVideoSourceCamera = 0,
    TRTCVideoSourceCustom,
    TRTCVideoSourceScreen,
} TRTCVideoSource;

@class TRTCBitrateRange;

/// 视频参数
@interface TRTCVideoConfig : NSObject

- (instancetype)initWithScene:(TRTCAppScene)scene NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)loadFromLocal;

- (void)saveToLocal;

@property (nonatomic) TRTCVideoSource source;

/// 开启视频采集
@property (nonatomic) BOOL isEnabled;

/// 视频静画
@property (nonatomic) BOOL isMuted;

/// 暂停屏幕采集
@property (nonatomic) BOOL isScreenCapturePaused;

/// 主视频编码
@property (strong, nonatomic) TRTCVideoEncParam* videoEncConfig;

/// 小画面视频编码
@property (strong, nonatomic) TRTCVideoEncParam* smallVideoEncConfig;

/// 流控设置
@property (strong, nonatomic) TRTCNetworkQosParam* qosConfig;

/// 使用前置摄像头，默认值为YES
@property (nonatomic) BOOL isFrontCamera;

/// 开启闪光灯，默认值为NO
@property (nonatomic) BOOL isTorchOn;

/// 开启自动对焦，默认值为YES
@property (nonatomic) BOOL isAutoFocusOn;

/// 远程视频镜像，默认值为NO
@property (nonatomic) BOOL isRemoteMirrorEnabled;

/// 本地视频镜像，默认值为TRTCLocalVideoMirrorType_Auto
@property (nonatomic) TRTCLocalVideoMirrorType localMirrorType;

/// 本地视频填充模式，默认为TRTCVideoFillMode_Fill
@property (nonatomic) TRTCVideoFillMode fillMode;

/// 开启双路编码，默认值为NO
@property (nonatomic) BOOL isSmallVideoEnabled;

/// 画质偏好低清，默认值为YES
@property (nonatomic) BOOL prefersLowQuality;

/// 开启重力感应模式，默认为NO
@property (nonatomic) BOOL isGSensorEnabled;

/// 自定义视频播放的视频资源
@property (strong, nonatomic) AVAsset *videoAsset;


/// 支持的分辨率
+ (NSArray<NSNumber *> *)resolutions;
+ (NSArray<NSString *> *)resolutionNames;
@property (nonatomic, readonly) NSInteger resolutionIndex;

/// 支持的帧数
+ (NSArray<NSString *> *)fpsList;
@property (nonatomic, readonly) NSInteger fpsIndex;

/// 分辨率对应的码率区间
/// @param resolution 分辨率
+ (TRTCBitrateRange *)bitrateRangeOf:(TRTCVideoResolution)resolution scene:(TRTCAppScene)scene;

/// 本地预览镜像
+ (NSArray<NSString *> *)localMirrorTypeNames;

@property (nonatomic, readonly) NSInteger qosPreferenceIndex;

@end



/// 分辨率下对应的码率支持
@interface TRTCBitrateRange : NSObject

/// 最小支持的码率
@property (nonatomic) NSInteger minBitrate;

/// 最大支持的码率
@property (nonatomic) NSInteger maxBitrate;

/// 默认码率
@property (nonatomic) NSInteger defaultBitrate;

/// 调整码率的步长
@property (nonatomic) NSInteger step;

- (instancetype)initWithMin:(NSInteger)min max:(NSInteger)max defaultBitrate:(NSInteger)defaultBitrate step:(NSInteger)step;

@end


NS_ASSUME_NONNULL_END
