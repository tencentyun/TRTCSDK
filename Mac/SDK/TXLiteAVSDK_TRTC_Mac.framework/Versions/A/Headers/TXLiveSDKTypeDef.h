#ifndef __TX_LIVE_SDK_TYPE_DEF_H__
#define __TX_LIVE_SDK_TYPE_DEF_H__

#include "TXLiveSDKEventDef.h"
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
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

/// 屏幕旋转方法
typedef NS_ENUM(NSInteger, TX_Enum_Type_HomeOrientation) {
    /// home在右边
    HOME_ORIENTATION_RIGHT  = 0,        
    /// home在下面
    HOME_ORIENTATION_DOWN,              
    /// home在左边
    HOME_ORIENTATION_LEFT,              
    /// home在上面
    HOME_ORIENTATION_UP,                
};

/// 渲染方式
typedef NS_ENUM(NSInteger, TX_Enum_Type_RenderMode) {
    /// 图像铺满屏幕
    RENDER_MODE_FILL_SCREEN  = 0,    
    /// 图像长边填满屏幕
    RENDER_MODE_FILL_EDGE            
};

/// 美颜程度, 取值1-9, 这里定义了关闭和最大值
typedef NS_ENUM(NSInteger, TX_Enum_Type_BeautyFilterDepth) {
    /// 关闭美颜
    BEAUTY_FILTER_DEPTH_CLOSE   = 0,    
    /// 最大美颜强度
    BEAUTY_FILTER_DEPTH_MAX     = 9,    
};

/// 美颜处理方式
typedef NS_ENUM(NSInteger, TX_Enum_Type_BeautyStyle) {
    /// 光滑
    BEAUTY_STYLE_SMOOTH     = 0,    
    /// 自然
    BEAUTY_STYLE_NATURE     = 1,    
    /// pitu美颜, 需要企业版SDK
    BEAUTY_STYLE_PITU       = 2,    
};

/** 视频分辨率
  SDK的视频采集模块只支持前3种分辨率，即：360*640 540*960 720*1280
  如果客户自己负责视频采集，向SDK填充YUV数据，可以使用全部6种分辨率
 */
typedef NS_ENUM(NSInteger, TX_Enum_Type_VideoResolution) {
    VIDEO_RESOLUTION_TYPE_360_640 = 0,
    VIDEO_RESOLUTION_TYPE_540_960 = 1,
    VIDEO_RESOLUTION_TYPE_720_1280 = 2,
    VIDEO_RESOLUTION_TYPE_640_360 = 3,
    VIDEO_RESOLUTION_TYPE_960_540 = 4,
    VIDEO_RESOLUTION_TYPE_1280_720 = 5,
    /// @name 连麦专用，采用固定码率。
    VIDEO_RESOLUTION_TYPE_320_480 = 6,   
    VIDEO_RESOLUTION_TYPE_180_320 = 7,
    VIDEO_RESOLUTION_TYPE_270_480 = 8,
    VIDEO_RESOLUTION_TYPE_320_180 = 9,
    VIDEO_RESOLUTION_TYPE_480_270 = 10,
    
    VIDEO_RESOLUTION_TYPE_240_320  = 11,
    VIDEO_RESOLUTION_TYPE_360_480  = 12,
    VIDEO_RESOLUTION_TYPE_480_640  = 13,
    VIDEO_RESOLUTION_TYPE_320_240  = 14,
    VIDEO_RESOLUTION_TYPE_480_360  = 15,
    VIDEO_RESOLUTION_TYPE_640_480  = 16,
    
    VIDEO_RESOLUTION_TYPE_480_480  = 17,
    VIDEO_RESOLUTION_TYPE_270_270  = 18,
    VIDEO_RESOLUTION_TYPE_160_160  = 19,
};

/**
*  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\  推流的画面质量选项  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
* 
*  - 1.9.1 版本开始引入推流画质接口 setVideoQuality 用于傻瓜化的选择推流画质效果。
*  - TXLivePush::setVideoQuality 内部通过 TXLivePushConfig 实现几种不同场景和风格的推流质量
*  - 目前支持的几种画质选项如下：
*
*  （1）标清 - 采用 360 * 640 级别分辨率，码率会在 400kbps - 800kbps 之间自适应，如果主播的网络条件不理想，
*              直播的画质会偏模糊，但总体卡顿率不会太高。
*              Android平台下这一档我们会选择采用软编码，软编码虽然更加耗电，但在运动画面的表现要由于硬编码。
*
*  （2）高清 - 采用 540 * 960 级别分辨率，码率会锁定在 1200kbps，如果主播的网络条件不理想，直播画质不会有变化，
*              但这段时间内会出现频繁的卡顿和跳帧。 两个平台下，这一档我们都会采用硬编码。
*
*  （3）超清 - 采用 720 * 1280 级别分辨率，码率会锁定在 1500kbps，对主播的上行带宽要求比较高，适合观看端是大屏的业务场景。
*   
*  （4）大主播 - 顾名思义，连麦中大主播使用，因为是观众的主画面，追求清晰一些的效果，所以分辨率会优先选择 540 * 960。
*
*  （5）小主播 - 顾名思义，连麦中小主播使用，因为是小画面，画面追求流畅，分辨率采用 320 * 480， 码率 350kbps 固定。
*              
* 【特别说明】
*  1. 如果是秀场直播，iOS 和 Android 都推荐使用[高清]，虽说“马上看壮士，月下观美人”是有这么一说，但是看完某椒就知道清晰有多么重要了。
*  2. 使用 setVideoQuality 之后，依然可以使用 TXLivePushConfig 设置画质，以最后一次的设置为准。
*  3. 如果您是手机端观看，那么一般不推荐使用【超清】选项，我们做过多组的画质主观评测，尤其是iOS平台，在小屏幕上观看几乎看不出差别。
*
*/
typedef NS_ENUM(NSInteger, TX_Enum_Type_VideoQuality) {
    ///标清：建议追求流畅性的客户使用该选项
    VIDEO_QUALITY_STANDARD_DEFINITION       = 1,      
    ///高清：建议对清晰度有要求的客户使用该选项
    VIDEO_QUALITY_HIGH_DEFINITION           = 2,      
    ///超清：如果不是大屏观看，不推荐使用
    VIDEO_QUALITY_SUPER_DEFINITION          = 3,      
    ///连麦大主播
    VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER    = 4,      
    ///连麦小主播
    VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER     = 5,      
    ///实时音视频
    VIDEO_QUALITY_REALTIME_VIDEOCHAT        = 6,      
};

///流控策略
typedef NS_ENUM(NSInteger, TX_Enum_Type_AutoAdjustStrategy) {
    /// 无流控
    AUTO_ADJUST_NONE                            = -1, 
    /// 适用于普通直播推流的流控策略，该策略敏感度比较低，会缓慢适应带宽变化，有利于在带宽波动时保持画面的清晰度。
    
    AUTO_ADJUST_LIVEPUSH_STRATEGY               = 0,
    /// 适用于普通直播推流的流控策略，与 LIVEPUSH_STRATEGY 的差别是改模式下 SDK 会根据当前码率自动调整出适合的分辨率
    AUTO_ADJUST_LIVEPUSH_RESOLUTION_STRATEGY    = 1,
    
    /// 适用于实时音视频通话的流控策略，也就是 VIDEO_QUALITY_REALTIME_VIDEOCHAT 所使用流控策略, 该策略敏感度比较高，网络稍有风吹草动就会进行自适应调整
    AUTO_ADJUST_REALTIME_VIDEOCHAT_STRATEGY     = 5,


    /// @name 下面是个是老版本中的常量定义，由于名字起得过于奇葩，在宰杀了一个“代码猴子”以后，我们进行如上调整
    
    /// 已经废弃不用
    AUTO_ADJUST_BITRATE_STRATEGY_1              = 0,      
    /// 已经废弃不用
    AUTO_ADJUST_BITRATE_RESOLUTION_STRATEGY_1   = 1,      
    /// 已经废弃不用
    AUTO_ADJUST_BITRATE_STRATEGY_2              = 2,      
    /// 已经废弃不用
    AUTO_ADJUST_BITRATE_RESOLUTION_STRATEGY_2   = 3,      
    ///实时：只调码率
    AUTO_ADJUST_REALTIME_BITRATE_STRATEGY       = 4,      
    ///实时：同时调码率和分辨率
    AUTO_ADJUST_REALTIME_BITRATE_RESOLUTION_STRATEGY = 5,      
};

/// 声音采样率
typedef NS_ENUM(NSInteger, TX_Enum_Type_AudioSampleRate) {
    /// 8k采样率
    AUDIO_SAMPLE_RATE_8000 = 0,
    /// 16k采样率
    AUDIO_SAMPLE_RATE_16000,
    /// 32k采样率
    AUDIO_SAMPLE_RATE_32000,
    /// 44.1k采样率
    AUDIO_SAMPLE_RATE_44100,
    /// 48k采样率
    AUDIO_SAMPLE_RATE_48000,
};

typedef NS_ENUM(NSInteger, TXVideoType) {
    /// Android 视频采集格式   PixelFormat.YCbCr_420_SP 17
    VIDEO_TYPE_420SP       = 1,    
    /// iOS 视频采集格式       kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    VIDEO_TYPE_420YpCbCr   = 2,    
    /// yuv420p格式           客户自己负责视频采集，直接向SDK填充YUV数据
    VIDEO_TYPE_420P        = 3,    
    /// BGRA8888 
    VIDEO_TYPE_BGRA8888    = 4,    
    /// RGBA8888
    VIDEO_TYPE_RGBA8888    = 5,    
    /// NV12 
    VIDEO_TYPE_NV12        = 6,    
};

///混响类型
typedef NS_ENUM(NSInteger, TXReverbType) {
    /// 关闭混响
    REVERB_TYPE_0         = 0,    
    /// KTV
    REVERB_TYPE_1         = 1,    
    /// 小房间
    REVERB_TYPE_2         = 2,    
    /// 大会堂
    REVERB_TYPE_3         = 3,    
    /// 低沉
    REVERB_TYPE_4         = 4,    
    /// 洪亮
    REVERB_TYPE_5         = 5,    
    /// 金属声
    REVERB_TYPE_6         = 6,    
    /// 磁性
    REVERB_TYPE_7         = 7,    
};

/// 变声选项
typedef NS_ENUM(NSInteger, TXVoiceChangerType) {
    /// 关闭变声
    VOICECHANGER_TYPE_0   = 0,    
    /// 熊孩子
    VOICECHANGER_TYPE_1   = 1,    
    /// 萝莉
    VOICECHANGER_TYPE_2   = 2,    
    /// 大叔
    VOICECHANGER_TYPE_3   = 3,    
    /// 重金属
    VOICECHANGER_TYPE_4   = 4,    
    /// 感冒
    VOICECHANGER_TYPE_5   = 5,    
    /// 外国人
    VOICECHANGER_TYPE_6   = 6,    
    /// 困兽
    VOICECHANGER_TYPE_7   = 7,    
    /// 死肥仔
    VOICECHANGER_TYPE_8   = 8,    
    /// 强电流
    VOICECHANGER_TYPE_9   = 9,    
    /// 重机械
    VOICECHANGER_TYPE_10  = 10,   
    /// 空灵
    VOICECHANGER_TYPE_11  = 11,   
};

///音频播放类型
typedef NS_ENUM(NSInteger, TXAudioRouteType) {
    /// 扬声器
    AUDIO_ROUTE_SPEAKER    = 0,   
    /// 听筒
    AUDIO_ROUTE_RECEIVER   = 1,   
};

///传输通道
typedef NS_ENUM(NSInteger, TX_Enum_Type_RTMPChannel) {
    /// 自动
    RTMP_CHANNEL_TYPE_AUTO          = 0,    
    /// 标准的RTMP协议，网络层采用TCP协议
    RTMP_CHANNEL_TYPE_STANDARD      = 1,    
    /// 标准的RTMP协议，网络层采用私有通道传输（在UDP上封装的一套可靠快速的传输通道），能够更好地抵抗网络抖动
    RTMP_CHANNEL_TYPE_PRIVATE       = 2,    
};

#if TARGET_OS_OSX
/// 采集源
typedef NS_ENUM(NSInteger, TXCaptureVideoInputSource) {
    TXCaptureVideoInputSourceCamera,
    TXCaptureVideoInputSourceScreen,
    TXCaptureVideoInputSourceWindow
};
#endif

/// @name 状态键名定义
/// cpu使用率
#define NET_STATUS_CPU_USAGE         @"CPU_USAGE"        
/// 设备总CPU占用
#define NET_STATUS_CPU_USAGE_D       @"CPU_USAGE_DEVICE" 
/// 当前视频编码器输出的比特率，也就是编码器每秒生产了多少视频数据，单位 kbps
#define NET_STATUS_VIDEO_BITRATE     @"VIDEO_BITRATE"    
/// 当前音频编码器输出的比特率，也就是编码器每秒生产了多少音频数据，单位 kbps
#define NET_STATUS_AUDIO_BITRATE     @"AUDIO_BITRATE"    
/// 当前视频帧率，也就是视频编码器每条生产了多少帧画面
#define NET_STATUS_VIDEO_FPS         @"VIDEO_FPS"        
/// 当前视频GOP,也就是每两个关键帧(I帧)间隔时长，单位s
#define NET_STATUS_VIDEO_GOP         @"VIDEO_GOP"        
/// 当前的发送速度
#define NET_STATUS_NET_SPEED         @"NET_SPEED"        
/// 网络抖动情况，抖动越大，网络越不稳定
#define NET_STATUS_NET_JITTER        @"NET_JITTER"       
/// 缓冲区大小，缓冲区越大，说明当前上行带宽不足以消费掉已经生产的视频数据
#define NET_STATUS_CACHE_SIZE        @"CACHE_SIZE"       
/// 视频缓冲帧数 （包括jitterbuffer和解码器两部分缓冲）
#define NET_STATUS_VIDEO_CACHE_SIZE  @"VIDEO_CACHE_SIZE" 
/// 视频解码器缓冲帧数
#define NET_STATUS_V_DEC_CACHE_SIZE  @"V_DEC_CACHE_SIZE" 
///视频当前渲染帧的timestamp和音频当前播放帧的timestamp的差值，标示当时音画同步的状态
#define NET_STATUS_AV_PLAY_INTERVAL  @"AV_PLAY_INTERVAL"  
///jitterbuffer最新收到的视频帧和音频帧的timestamp的差值，标示当时jitterbuffer收包同步的状态
#define NET_STATUS_AV_RECV_INTERVAL  @"AV_RECV_INTERVAL"  
///jitterbuffer当前的播放速度
#define NET_STATUS_AUDIO_PLAY_SPEED  @"AUDIO_PLAY_SPEED"  
///当前流的音频信息，包括采样率信息和声道数信息
#define NET_STATUS_AUDIO_INFO        @"AUDIO_INFO"        
#define NET_STATUS_DROP_SIZE         @"DROP_SIZE"
#define NET_STATUS_VIDEO_WIDTH       @"VIDEO_WIDTH"
#define NET_STATUS_VIDEO_HEIGHT      @"VIDEO_HEIGHT"
#define NET_STATUS_SERVER_IP         @"SERVER_IP"
///编解码缓冲大小
#define NET_STATUS_CODEC_CACHE       @"CODEC_CACHE"      
///编解码队列DROPCNT
#define NET_STATUS_CODEC_DROP_CNT    @"CODEC_DROP_CNT"   
#define NET_STATUS_SET_VIDEO_BITRATE @"SET_VIDEO_BITRATE"

#define EVT_MSG                      @"EVT_MSG"
#define EVT_TIME                     @"EVT_TIME"
#define EVT_PARAM1					 @"EVT_PARAM1"
#define EVT_PARAM2					 @"EVT_PARAM2"
#define EVT_PLAY_PROGRESS            @"EVT_PLAY_PROGRESS"
#define EVT_PLAY_DURATION            @"EVT_PLAY_DURATION"
#define EVT_PLAYABLE_DURATION        @"PLAYABLE_DURATION"   
#define EVT_REPORT_TOKEN             @"EVT_REPORT_TOKEN"
#define EVT_GET_MSG                  @"EVT_GET_MSG"
///视频封面
#define EVT_PLAY_COVER_URL           @"EVT_PLAY_COVER_URL"   
///视频播放地址
#define EVT_PLAY_URL                 @"EVT_PLAY_URL"         
///视频名称
#define EVT_PLAY_NAME                @"EVT_PLAY_NAME"        
///视频简介
#define EVT_PLAY_DESCRIPTION         @"EVT_PLAY_DESCRIPTION" 

#define STREAM_ID                    @"STREAM_ID"

#endif 
