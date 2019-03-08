//
//  TXLivePlayer.h
//  LiteAV
//
//  Created by alderzhang on 2017/5/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXLiveSDKTypeDef.h"
#import "TXLivePlayListener.h"
#import "TXLivePlayConfig.h"
#import "TXVideoCustomProcessDelegate.h"
#import "TXLiveRecordTypeDef.h"
#import "TXLiveRecordListener.h"
#import "TXAudioRawDataDelegate.h"

typedef NS_ENUM(NSInteger, TX_Enum_PlayType) {
    /// RTMP直播
    PLAY_TYPE_LIVE_RTMP = 0,
    /// FLV直播
    PLAY_TYPE_LIVE_FLV,
#if TARGET_OS_IPHONE
    /// FLV点播
    PLAY_TYPE_VOD_FLV,
    /// HLS点播
    PLAY_TYPE_VOD_HLS,
    /// MP4点播
    PLAY_TYPE_VOD_MP4,
#endif
    /// RTMP直播加速播放
    PLAY_TYPE_LIVE_RTMP_ACC,
#if TARGET_OS_IPHONE
    /// 本地视频文件
    PLAY_TYPE_LOCAL_VIDEO,
#endif
};

/// 直播播放器
@interface TXLivePlayer : NSObject
/// 播放器回调
@property(nonatomic, weak) id <TXLivePlayListener> delegate;
/// 视频处理回调
@property(nonatomic, weak) id <TXVideoCustomProcessDelegate> videoProcessDelegate;
/// 音频处理回调
@property(nonatomic, weak) id <TXAudioRawDataDelegate> audioRawDataDelegate;
/// 是否硬件加速
@property(nonatomic, assign) BOOL enableHWAcceleration;
/// 直播配置参数
@property(nonatomic, copy) TXLivePlayConfig *config;
#if TARGET_OS_IPHONE
/// 短视频录制回调
@property (nonatomic, weak)   id<TXLiveRecordListener>   recordDelegate;
/// startPlay后是否立即播放，默认YES。点播有效
@property BOOL isAutoPlay;
#endif
/**
 * 创建Video渲染Widget,该控件承载着视频内容的展示。
 * @param frame Widget在父view中的rc
 * @param view  父view
 * @param idx   Widget在父view上的层级位置
 * @discussion 变更历史：1.5.2版本将参数frame废弃，设置此参数无效，控件大小与参数view的大小保持一致，如需修改控件的大小及位置，请调整父view的大小及位置. 参考文档：https://www.qcloud.com/doc/api/258/4736#step-3.3A-.E7.BB.91.E5.AE.9A.E6.B8.B2.E6.9F.93.E7.95.8C.E9.9D.A2
 */
- (void)setupVideoWidget:(CGRect)frame containView:(TXView *)view insertIndex:(unsigned int)idx;

/* 修改VideoWidget frame
 * 变更历史：1.5.2版本将此方法废弃，调用此方法无效，如需修改控件的大小及位置，请调整父view的大小及位置
 * 参考文档：https://www.qcloud.com/doc/api/258/4736#step-3.3A-.E7.BB.91.E5.AE.9A.E6.B8.B2.E6.9F.93.E7.95.8C.E9.9D.A2
 */
//- (void)resetVideoWidgetFrame:(CGRect)frame;

/**
 * 移除Video渲染Widget
 */
- (void)removeVideoWidget;


/**
 * 启动从指定URL播放RTMP音视频流
 * @param url 完整的URL(如果播放的是本地视频文件，这里传本地视频文件的完整路径)
 * @param playType 播放类型
 * @return 0 = OK
 */
- (int)startPlay:(NSString *)url type:(TX_Enum_PlayType)playType;

/**
 * 停止播放音视频流
 * @return 0 = OK
 */
- (int)stopPlay;

/**
 * 是否正在播放
 * @return YES 拉流中，NO 没有拉流
 */
- (bool)isPlaying;

/**
 * 暂停播放
 * @discussion 适用于点播，直播（此接口会暂停数据拉流，不会销毁播放器，暂停后，播放器会显示最后一帧数据图像）
 */
- (void)pause;

/**
 * 继续播放，适用于点播，直播
 */
- (void)resume;

/**
 * 直播时移准备，拉取该直播流的起始播放时间。
 @ @param domain 时移域名
 * @param bizId 流bizId
 * @return 0 = OK，-1 = 无播放地址,-2 = appId未配置
 * @discussion 使用时移功能需在播放开始后调用此方法，否者时移失败。时移的使用请参考文档 https://cloud.tencent.com/document/product/266/9237
 * @warning 非腾讯云直播地址不能时移
 */
- (int)prepareLiveSeek:(NSString*)domain bizId:(NSInteger)bizId;

/**
 * 停止时移播放，返回直播
 * @return 0 = OK
 */
- (int)resumeLive;

#if TARGET_OS_IPHONE
/**
 * 播放跳转到音视频流某个时间
 * @param time 流时间，单位为秒
 * @return 0 = OK
 */
- (int)seek:(float)time;
#endif

/**
 * 设置画面的方向
 * @param rotation 方向
 * @see TX_Enum_Type_HomeOrientation
 */
- (void)setRenderRotation:(TX_Enum_Type_HomeOrientation)rotation;

/**
 * 设置画面的裁剪模式
 * @param renderMode 裁剪
 * @see TX_Enum_Type_RenderMode
 */
- (void)setRenderMode:(TX_Enum_Type_RenderMode)renderMode;

/**
 * 设置静音
 */
- (void)setMute:(BOOL)bEnable;

#if TARGET_OS_IPHONE
/*视频录制*/
/**
 * 开始录制短视频
 * @param recordType 参见TXRecordType定义
 * @return  0 成功；-1 正在录制短视频；-2 videoRecorder初始化失败；
 */
-(int) startRecord:(TXRecordType)recordType;

/*
 * 结束录制短视频
 * @return 0 成功；-1 不存在录制任务； -2 videoRecorder未初始化；
 */
-(int) stopRecord;

/*
 * 截屏
 * @param snapshotCompletionBlock 通过回调返回当前图像
 */
- (void)snapshot:(void (^)(TXImage *))snapshotCompletionBlock;


/**
 * 设置播放速率
 * @param rate 正常速度为1.0；小于为慢速；大于为快速。最大建议不超过2.0
 */
- (void)setRate:(float)rate;
#endif
/**
 * 设置状态浮层view在渲染view上的边距
 * @param margin 边距
 */
- (void)setLogViewMargin:(TXEdgeInsets)margin;

/**
 * 是否显示播放状态统计及事件消息浮层view
 * @param isShow 是否显示
 */
- (void)showVideoDebugLog:(BOOL)isShow;

#if TARGET_OS_IPHONE
/**
 * 设置声音播放模式(切换扬声器，听筒)
 * @param audioRoute 声音播放模式
 */
+ (void)setAudioRoute:(TXAudioRouteType)audioRoute;
#endif

/**
 * flv直播无缝切换
 *
 * 参  数：
 *      playUrl 播放地址
 * @return 0 = OK
 * @warning playUrl必须是当前播放直播流的不同清晰度，切换到无关流地址可能会失败
 */
- (int)switchStream:(NSString *)playUrl;
@end
