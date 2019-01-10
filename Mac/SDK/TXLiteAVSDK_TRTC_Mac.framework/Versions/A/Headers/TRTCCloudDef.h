/*
 * Module:   TRTC 关键类型定义
 * 
 * Function: 分辨率、质量等级等枚举和常量值的定义
 *
 */

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
typedef UIView TXView;
typedef UIImage TXImage;
typedef UIEdgeInsets TXEdgeInsets;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView TXView;
typedef NSImage TXImage;
typedef NSEdgeInsets TXEdgeInsets;
#endif

/////////////////////////////////////////////////////////////////////////////////
//
//                    【视频分辨率 TRTCVideoResolution】
//                   
//   此处仅有横屏分辨率，如果要使用 360x640 这样的竖屏分辨率，需要指定 ResolutionMode 为 Portrait
//
/////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, TRTCVideoResolution) {
    /// 宽高比1:1
    TRTCVideoResolution_120_120 = 1,     ///< 建议码率 80kbps
    TRTCVideoResolution_160_160 = 3,     ///< 建议码率 100kbps
    TRTCVideoResolution_270_270 = 5,     ///< 建议码率 200kbps
    TRTCVideoResolution_480_480 = 7,     ///< 建议码率 350kbps
    
    /// 宽高比4:3
    TRTCVideoResolution_160_120 = 50,    ///< 建议码率 100kbps
    TRTCVideoResolution_240_180 = 52,    ///< 建议码率 150kbps
    TRTCVideoResolution_280_210 = 54,    ///< 建议码率 200kbps
    TRTCVideoResolution_320_240 = 56,    ///< 建议码率 250kbps
    TRTCVideoResolution_400_300 = 58,    ///< 建议码率 300kbps
    TRTCVideoResolution_480_360 = 60,    ///< 建议码率 400kbps
    TRTCVideoResolution_640_480 = 62,    ///< 建议码率 600kbps
    TRTCVideoResolution_960_720 = 64,    ///< 建议码率 1000kbps
    
    /// 宽高比16:9
    TRTCVideoResolution_160_90  = 100,   ///< 建议码率 150kbps
    TRTCVideoResolution_256_144 = 102,   ///< 建议码率 200kbps
    TRTCVideoResolution_320_180 = 104,   ///< 建议码率 250kbps
    TRTCVideoResolution_480_270 = 106,   ///< 建议码率 350kbps
    TRTCVideoResolution_640_360 = 108,   ///< 建议码率 550kbps
    TRTCVideoResolution_960_540 = 110,   ///< 建议码率 850kbps
    TRTCVideoResolution_1280_720 = 112,  ///< 建议码率 1200kbps
};


typedef NS_ENUM(NSInteger, TRTCVideoResolutionMode) {
	TRTCVideoResolutionModeLandscape = 0,  ///< 横屏分辨率
    TRTCVideoResolutionModePortrait  = 1,  ///< 竖屏分辨率
};


typedef NS_ENUM(NSInteger, TRTCVideoCodecMode) {
	TRTCVideoCodecModeSmooth     = 0,  ///< 启用流畅编码模式，该模式下视频的弱网抗性和卡顿率明显好于兼容模式
    TRTCVideoCodecModeCompatible = 1,  ///< 强制启用兼容编码模式，支持绝大多数硬件编码器，性能优异，但卡顿率高于流畅编码模式
};



typedef NS_ENUM(NSInteger, TRTCVideoStreamType) {
    TRTCVideoStreamTypeBig = 0,     ///< 大画面视频流
    TRTCVideoStreamTypeSmall = 1,   ///< 小画面视频流
    TRTCVideoStreamTypeSub = 2,     ///< 辅流（屏幕分享）

};

/**
 * Qos流控模式，本地控制还是云端控制
 */
typedef NS_ENUM(NSInteger, TRTCQosControlMode)
{
    TRTCQosControlModeClient,        ///< 客户端控制（用于SDK开发内部调试，客户请勿使用）
    TRTCQosControlModeServer,        ///< 云端控制 （默认）
};

/**
 * 弱网下是“保清晰”还是“保流畅”
 * 弱网下保流畅 - 在遭遇弱网环境时，画面会变得模糊，且会有较多马赛克，但可以保持流畅不卡顿
 * 弱网下保清晰 - 在遭遇弱网环境时，画面会尽可能保持清晰，但可能会更容易出现卡顿
 */
typedef NS_ENUM(NSInteger, TRTCVideoQosPreference)
{
    TRTCVideoQosPreferenceSmooth = 1,      ///< 弱网下保流畅
    TRTCVideoQosPreferenceClear = 2,       ///< 弱网下保清晰
};

/// 日志等级
typedef NS_ENUM(NSInteger, TRTCLogLevel) {
    TRTCLogLevelNone = 0,      ///< 不输出任何sdk log
    TRTCLogLevelVerbose = 1,   ///< 输出所有级别的log
    TRTCLogLevelDebug = 2,     ///< 输出 DEBUG，INFO，WARNING，ERROR 和 FATAL 级别的log
    TRTCLogLevelInfo = 3,      ///< 输出 INFO，WARNNING，ERROR 和 FATAL 级别的log
    TRTCLogLevelWarn = 4,      ///< 只输出WARNNING，ERROR 和 FATAL 级别的log
    TRTCLogLevelError = 5,     ///< 只输出ERROR 和 FATAL 级别的log
    TRTCLogLevelFatal = 6,     ///< 只输出 FATAL 级别的log
};


typedef NS_ENUM(NSInteger, TRTCQuality) {
    TRTCQuality_Unknown = 0,
    TRTCQuality_Excellent,
    TRTCQuality_Good,
    TRTCQuality_Poor,
    TRTCQuality_Bad,
    TRTCQuality_Vbad,
    TRTCQuality_Down
};

/**
 * 视频画面填充模式
 */
typedef NS_ENUM(NSInteger, TRTCVideoFillMode) {
    TRTCVideoFillMode_Fill   = 0,  ///< 图像铺满屏幕，超出显示视窗的视频部分将被截掉
    TRTCVideoFillMode_Fit    = 1,  ///< 图像长边填满屏幕，短边区域会被填充黑色
};

/**
 * 视频画面旋转方向
 */
typedef NS_ENUM(NSInteger, TRTCVideoRotation) {
    TRTCVideoRotation_0    = 0,
    TRTCVideoRotation_90   = 1,
    TRTCVideoRotation_180  = 2,
    TRTCVideoRotation_270  = 3,
};

/**
 * 重力感应开关，此配置仅适用于 iOS 和 iPad 等移动设备，并且需要配合您当前 UI 的布局模式一起使用
 * 
 * Disable - 如果您不希望视频画面跟随重力感应方向而调整
 * UIAutoLayout - 如果您当前的 UI 开启了跟随设备方向的自动旋转布局，SDK不会自动调整 LocalVideoView 的旋转方向，而是交给 iOS 系统进行处理
 * UIFixLayout - 如果您当前的 UI 关闭了跟随设备方向的自动旋转布局，SDK会自动调整 LocalVideoView 的旋转方向
 */
typedef NS_ENUM(NSInteger, TRTCGSensorMode) {
    TRTCGSensorMode_Disable         = 0,  ///< 关闭重力感应
    TRTCGSensorMode_UIAutoLayout    = 1,  ///< 开启重力感应（适用于UI开启了屏幕旋转自动布局的场景）
	TRTCGSensorMode_UIFixLayout     = 2   ///< 开启重力感应（适用于UI关闭了屏幕旋转自动布局的场景）
};

/**
 * 美颜风格
 */
typedef NS_ENUM(NSInteger, TRTCBeautyStyle) {
    TRTCBeautyStyleSmooth = 0, ///< 光滑
    TRTCBeautyStyleNature = 1, ///< 自然
};

/**
 * 音频采样率
 */
typedef NS_ENUM(NSInteger, TRTCAudioSampleRate) {
    TRTCAudioSampleRate16000 = 16000,
    TRTCAudioSampleRate32000 = 32000,
    TRTCAudioSampleRate44100 = 44100,
    TRTCAudioSampleRate48000 = 48000,
};


/**
 * 声音播放模式
 */
typedef NS_ENUM(NSInteger, TRTCAudioRoute) {
    TRTCAudioModeSpeakerphone  =   0,   ///< 扬声器
    TRTCAudioModeEarpiece      =   1,   ///< 听筒
};

typedef NS_ENUM(NSInteger, TRTCReverbType) {
    TRTCReverbType_0         = 0,    ///< 关闭混响
    TRTCReverbType_1         = 1,    ///< KTV
    TRTCReverbType_2         = 2,    ///< 小房间
    TRTCReverbType_3         = 3,    ///< 大会堂
    TRTCReverbType_4         = 4,    ///< 低沉
    TRTCReverbType_5         = 5,    ///< 洪亮
    TRTCReverbType_6         = 6,    ///< 金属声
    TRTCReverbType_7         = 7,    ///< 磁性
};

typedef NS_ENUM(NSInteger, TRTCVoiceChangerType) {
    TRTCVoiceChangerType_0   = 0,    //关闭变声
    TRTCVoiceChangerType_1   = 1,    //熊孩子
    TRTCVoiceChangerType_2   = 2,    //萝莉
    TRTCVoiceChangerType_3   = 3,    //大叔
    TRTCVoiceChangerType_4   = 4,    //重金属
    TRTCVoiceChangerType_5   = 5,    //感冒
    TRTCVoiceChangerType_6   = 6,    //外国人
    TRTCVoiceChangerType_7   = 7,    //困兽
    TRTCVoiceChangerType_8   = 8,    //死肥仔
    TRTCVoiceChangerType_9   = 9,    //强电流
    TRTCVoiceChangerType_10  = 10,   //重机械
    TRTCVoiceChangerType_11  = 11,   //空灵
};

/**
 * 视频像素格式
 */
typedef NS_ENUM(NSInteger, TRTCVideoPixelFormat) {
    TRTCVideoPixelFormat_Unknown    = 0,
    TRTCVideoPixelFormat_I420       = 1,    // YUV I420
    TRTCVideoPixelFormat_Texture_2D = 2,    // OpenGL 2D 纹理
};

/**
 * 视频数据结构类型
 */
typedef NS_ENUM(NSInteger, TRTCVideoBufferType) {
    TRTCVideoBufferType_Unknown         = 0,
	// iOS原始的PixelBuffer格式，直接使用效果较高，但是内部的YUV数据有孔隙，需要写代码跳过孔隙部分
    TRTCVideoBufferType_PixelBuffer     = 1,
    // 经过SDK修正后的PixelBuffer数据，经过了一次内存整理，没有孔隙，更容易使用，兼容性更好   
    TRTCVideoBufferType_NSData          = 2,    //NSData
    // 直接操作纹理ID，性能最好，画质损失最少
    TRTCVideoBufferType_Texture         = 3,    // 对应纹理ID
};

/////////////////////////////////////////////////////////////////////////////////
//
//                      【进房参数 TRTCParams】
//                   
//   作为 TRTC SDK 的进房参数，只有该参数填写正确，才能顺利进入roomid所指定的音视频房间
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -

/** 进房参数 TRTCParams
 *
 * 作为 TRTC SDK 的进房参数，只有该参数填写正确，才能顺利进入roomid所指定的音视频房间
 */
@interface TRTCParams : NSObject

/// 应用标识 [必填] 腾讯视频云基于 sdkAppId 完成计费统计
@property (nonatomic, assign) UInt32   sdkAppId;

/// 用户标识 [必填] 当前用户的 userid，相当于用户名
@property (nonatomic, strong, nonnull) NSString* userId;

/// 用户签名 [必填] 当前 userId 对应的验证签名，相当于登录密码
@property (nonatomic, strong, nonnull) NSString* userSig;

/// 房间号码 [必填] 指定房间号，在同一个房间里的用户（userId）可以彼此看到对方并进行视频通话
@property (nonatomic, assign) UInt32 roomId;

/// 房间签名 [非必选] 如果您希望某个房间（roomId）只让特定的某些用户（userId）才能进入，就需要使用 privateMapKey 进行权限保护
@property (nonatomic, strong, nullable) NSString* privateMapKey;

/// 业务数据 [非必选] 某些非常用的高级特性才需要用到此字段
@property (nonatomic, strong, nullable) NSString* bussInfo;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                      【编码参数 TRTCVideoEncParam】
//                   
//   视频编码器相关参数，该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface TRTCVideoEncParam : NSObject

/// 视频分辨率
///
/// @note 您在 TRTCVideoResolution 只能找到横屏模式的分辨率，比如： 640x360 这样的分辨率
///       如果想要使用竖屏分辨率，请指定 resMode 为 Portrait，比如：640x360 + Portrait = 360x640
@property (nonatomic, assign) TRTCVideoResolution videoResolution;

/// 分辨率模式（横屏分辨率 - 竖屏分辨率）
///
/// @note 如果 videoResolution 指定分辨率 640x360，resMode 指定模式为 Portrait，则最终编码出的分辨率为 360x640
@property (nonatomic, assign) TRTCVideoResolutionMode resMode;

/// 编码器的编码模式（流畅 - 兼容）
///
/// Smooth 模式（默认）：能够获得理论上最低的卡顿率，但性能略逊于 Compatible 模式
/// Compatible 模式：使用最标准的视频编码模式，卡顿率高于 Smooth 模式，但性能优异，推荐在低端设备上开启
@property (nonatomic, assign) TRTCVideoCodecMode codecMode;

/// 视频采集帧率，推荐设置为 15fps 或 20fps，10fps以下会有明显的卡顿感，20fps以上则没有必要
///
/// @note 很多 Android 手机的前置摄像头并不支持 15fps 以上的采集帧率
///       部分过于突出美颜功能的 Android 手机前置摄像头的采集帧率可能低于 10fps
@property (nonatomic, assign) int videoFps;

/// 视频上行码率
/// 
/// @note 推荐设置请参考 TRTCVideoResolution 定义处的注释说明
@property (nonatomic, assign) int videoBitrate;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                    【网络流控相关参数 TRTCNetworkQosParam】
//                   
//   网络流控相关参数，该设置决定了SDK在各种网络环境下的调控方向（比如弱网下是“保清晰”还是“保流畅”）
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface TRTCNetworkQosParam : NSObject

/// 弱网下是“保清晰”还是“保流畅”
///
/// 弱网下保流畅 - 在遭遇弱网环境时，画面会变得模糊，且会有较多马赛克，但可以保持流畅不卡顿
/// 弱网下保清晰 - 在遭遇弱网环境时，画面会尽可能保持清晰，但可能会更容易出现卡顿
@property (nonatomic, assign) TRTCVideoQosPreference preference;

/// 视频分辨率（云端控制 - 客户端控制）
///
/// Client 模式：客户端控制模式，用于SDK开发内部调试，客户请勿使用
/// Server 模式（默认）：云端控制模式，若没有特殊原因，请直接使用该模式
@property (nonatomic, assign) TRTCQosControlMode controlMode;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      【音量大小 TRTCVolumeInfo】
//                   
//  表示语音音量的评估大小，通过这个数值，您可以在 UI 界面上用图标表征 userId 是否有在说话 
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface TRTCVolumeInfo : NSObject <NSCopying>
/// 说话者的userId, nil为自己
@property (strong, nonatomic, nullable) NSString *userId;
/// 说话者的音量, 取值范围 0~100
@property (assign, nonatomic) NSUInteger volume;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      【音量大小 TRTCQualityInfo】
//                   
//  表示视频质量的好坏，通过这个数值，您可以在 UI 界面上用图标表征 userId 的通话线路质量
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface TRTCQualityInfo : NSObject
/// 用户ID
@property (nonatomic, copy, nullable)  NSString* userId;
/// 视频质量
@property (nonatomic, assign)   TRTCQuality quality;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//              【设备类型 TRTCMediaDeviceType】（仅适用于 MAC OS）
//                   
/////////////////////////////////////////////////////////////////////////////////

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -
/// 设备类型
typedef NS_ENUM(NSInteger, TRTCMediaDeviceType) {
    TRTCMediaDeviceTypeUnknown      =   -1,
	
    TRTCMediaDeviceTypeAudioInput   =    0,
    TRTCMediaDeviceTypeAudioOutput  =    1,
    TRTCMediaDeviceTypeVideoCamera  =    2,
	
    //屏幕采集源
    TRTCMediaDeviceTypeVideoWindow  =    3,
    TRTCMediaDeviceTypeVideoScreen  =    4,
};
#pragma mark -
@interface TRTCMediaDeviceInfo : NSObject
/// 设备类型
@property (assign, nonatomic) TRTCMediaDeviceType type;
/// 设备ID
@property (copy, nonatomic, nullable) NSString * deviceId;
/// 设备名称
@property (copy, nonatomic, nullable) NSString * deviceName;
@end
#endif


/////////////////////////////////////////////////////////////////////////////////
//
//                      【网络测速结果 TRTCSpeedTestResult】
//                   
//  您可以在用户进入房间前通过 TRTCCloud 的 startSpeedTest 接口进行测速 （注意：请不要在通话中调用）
//  测速结果会每 2~3 秒钟返回一次，每次返回一个 ip 地址的测试结果，其中：
//  
//  >> quality 是内部通过评估算法测算出的网络质量，loss 越低，rtt 越小，得分也就越高
//  >> upLostRate 是指上行丢包率，例如 0.3 代表每向服务器发送10个数据包，可能有3个会在中途丢失
//  >> downLostRate 是指下行丢包率，例如 0.2 代表从服务器每收取10个数据包，可能有2个会在中途丢失
//  >> rtt 是指当前设备到腾讯云服务器的一次网络往返时间，正常数值在 10ms ~ 100ms 之间
//  
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface TRTCSpeedTestResult : NSObject

/// 服务器ip地址
@property (strong, nonatomic, nonnull) NSString *ip;

/// 网络质量
///
/// 内部通过评估算法测算出的网络质量，loss 越低，rtt 越小，得分也就越高
@property (nonatomic) TRTCQuality quality;

/// 上行丢包率，范围是[0,1.0]
///
/// 例如 0.3 代表每向服务器发送10个数据包，可能有3个会在中途丢失
@property (nonatomic) float upLostRate;

/// 下行丢包率，范围是[0,1.0]
///
/// 例如 0.2 代表从服务器每收取10个数据包，可能有2个会在中途丢失
@property (nonatomic) float downLostRate;


/// 延迟（毫秒）：代表 SDK 跟服务器一来一回之间所消耗的时间，这个值越小越好
///
/// 是指当前设备到腾讯云服务器的一次网络往返时间，正常数值在 10ms ~ 100ms 之间
@property (nonatomic) uint32_t rtt;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//              【视频帧数据 TRTCVideoFrame】
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface TRTCVideoFrame : NSObject
/// 视频像素格式
@property (nonatomic, assign) TRTCVideoPixelFormat pixelFormat;
/// 视频数据结构类型
@property (nonatomic, assign) TRTCVideoBufferType bufferType;
/// 视频纹理ID
@property (nonatomic, assign) int textureId;
/// bufferType为TRTCVideoBufferType_PixelBuffer时的视频数据
@property (nonatomic, assign, nullable) CVPixelBufferRef pixelBuffer;
/// bufferType为TRTCVideoBufferType_NSData时的视频数据
@property (nonatomic, retain, nullable) NSData* data;
/// 视频帧的时间戳，单位毫秒
@property (nonatomic, assign) uint64_t timestamp;
/// 视频宽度
@property (nonatomic, assign) uint32_t width;
/// 视频高度
@property (nonatomic, assign) uint32_t height;
/// 视频像素的顺时针旋转角度
@property (nonatomic) TRTCVideoRotation rotation;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//              【音频帧数据 TRTCAudioFrame】
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface TRTCAudioFrame : NSObject
/// 音频数据
@property (nonatomic, retain, nonnull) NSData * data;
/// 采样率
@property (nonatomic, assign) TRTCAudioSampleRate sampleRate;
/// 声道数
@property (nonatomic, assign) int channels;
/// 时间戳，单位ms
@property (nonatomic, assign) uint64_t timestamp;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//              【旁路推流参数 TRTCPublishCDNParam】
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface TRTCPublishCDNParam : NSObject
/// 腾讯云 AppID，在直播控制台-直播码接入可查询到
@property (nonatomic) int appId;

/// 腾讯云直播bizid，在直播控制台-直播码接入可查询到
@property (nonatomic) int bizId;

/// 旁路转推的URL
@property (nonatomic, strong, nonnull) NSString * url;

/// 是否允许转码混流
/// 1. enableTranscoding = YES : 需要调用startCloudMixTranscoding对多路画面进行混合，发布到CDN上的是混合之后的一路音视频流
/// 2. enableTranscoding = NO  : 不经过云端转码，只是把当前用户的音视频画面转推到 url 参数所指定的 rtmp 推流地址上。
@property (nonatomic) BOOL enableTranscoding;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//              【转码混流配置 TRTCTranscodingConfig】
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -

typedef NS_ENUM(NSInteger, TRTCTranscodingConfigMode) {
    TRTCTranscodingConfigMode_Unknown = 0,
    
    // 手动配置混流混流参数，需要指定 TRTCTranscodingConfig 的全部参数
    TRTCTranscodingConfigMode_Manual = 1,

};

// 用于指定每一路视频画面的具体摆放位置
@interface TRTCMixUser : NSObject
/// 参与混流的userId
@property(nonatomic, copy) NSString * userId;
/// 图层位置坐标以及大小，左上角为坐标原点(0,0) （绝对像素值）
@property(nonatomic, assign) CGRect rect;
/// 图层层次 （1-16） 不可重复
@property(nonatomic, assign) int zOrder;
@end


@interface TRTCTranscodingConfig : NSObject
@property(nonatomic, assign) TRTCTranscodingConfigMode mode; ///< 转码config模式 @see TRTCTranscodingConfigMode

@property(nonatomic, assign) int videoWidth;       ///< 视频分辨率：宽
@property(nonatomic, assign) int videoHeight;      ///< 视频分辨率：高
@property(nonatomic, assign) int videoBitrate;     ///< 视频码率
@property(nonatomic, assign) int videoFramerate;   ///< 视频帧率
@property(nonatomic, assign) int videoGOP;         ///< 视频GOP，单位秒

@property(nonatomic, assign) int audioSampleRate;  ///< 音频采样率 48000
@property(nonatomic, assign) int audioBitrate;     ///< 音频码率   64K
@property(nonatomic, assign) int audioChannels;    ///< 声道数     2

@property(nonatomic, copy) NSString * mixExtraInfo; ///< SEI信息
@property(nonatomic, copy) NSArray<TRTCMixUser *> * mixUsers; ///< 混流配置
@end


