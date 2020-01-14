/*
* Module:   TRTCCloudManager
*
* Function: TRTC SDK的视频、音频以及消息功能
*
*    1. 视频功能包括摄像头的设置，视频编码的设置和视频流的设置
*
*    2. 音频功能包括采集端的设置（采集开关、增益、降噪、耳返、采样率），以及播放端的设置（音频通道、音量类型、音量提示）
*
*    3. 消息发送有两种：自定义消息和SEI消息，具体适用场景和限制可参照TRTCCloud.h中sendCustomCmdMsg和sendSEIMsg的接口注释
*/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TRTCVideoConfig.h"
#import "TRTCAudioConfig.h"
#import "TRTCStreamConfig.h"
#import "TRTCRemoteUserManager.h"

#import "TRTCCloud.h"
#import "TRTCCloudDef.h"

NS_ASSUME_NONNULL_BEGIN

@class TRTCCloudManager;

@protocol TRTCCloudManagerDelegate <NSObject>

@optional
- (void)roomSettingsManager:(TRTCCloudManager *)manager didSetVolumeEvaluation:(BOOL)isEnabled;

@end


@interface TRTCCloudManager : NSObject

@property (weak, nonatomic) id<TRTCCloudManagerDelegate> delegate;
@property (nonatomic) TRTCAppScene scene;
@property (strong, nonatomic) TRTCParams *params;
@property (strong, nonatomic, readonly) TRTCCloud *trtc;

@property (strong, nonatomic, readonly) TRTCVideoConfig *videoConfig;
@property (strong, nonatomic, readonly) TRTCAudioConfig *audioConfig;
@property (strong, nonatomic, readonly) TRTCStreamConfig *streamConfig;
@property (strong, nonatomic) TRTCRemoteUserManager *remoteUserManager;
@property (strong, nonatomic, nullable) UIImageView *videoView;

- (instancetype)initWithTrtc:(TRTCCloud *)trtc
                      params:(TRTCParams *)params
                       scene:(TRTCAppScene)scene
                       appId:(NSInteger)appId
                       bizId:(NSInteger)bizId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// 用当前的配置项设置Trtc Engine
- (void)setupTrtc;

#pragma mark - Room

/// 加入房间
- (void)enterRoom;

/// 退出房间
- (void)exitRoom;

/// 切换身份
/// @param role 用户在房间的身份：主播或观众
- (void)switchRole:(TRTCRoleType)role;

#pragma mark - Video Settings

/// 设置视频采集
/// @param isEnabled 开启视频采集
- (void)setVideoEnabled:(BOOL)isEnabled;

/// 设置视频推送
/// @param isMuted 推送关闭
- (void)setVideoMuted:(BOOL)isMuted;

/// 设置分辨率
/// @param resolution 分辨率
- (void)setResolution:(TRTCVideoResolution)resolution;

/// 设置帧率
/// @param fps 帧率
- (void)setVideoFps:(int)fps;

/// 设置码率
/// @param bitrate 码率
- (void)setVideoBitrate:(int)bitrate;

/// 设置画质偏好
/// @param preference 画质偏好
- (void)setQosPreference:(TRTCVideoQosPreference)preference;

/// 设置画面方向
/// @param mode 画面方向
- (void)setResolutionMode:(TRTCVideoResolutionMode)mode;

/// 设置填充模式
/// @param mode 填充模式
- (void)setVideoFillMode:(TRTCVideoFillMode)mode;

/// 设置本地镜像
/// @param type 本地镜像模式
- (void)setLocalMirrorType:(TRTCLocalVideoMirrorType)type;

/// 设置远程镜像
/// @param isEnabled 开启远程镜像
- (void)setRemoteMirrorEnabled:(BOOL)isEnabled;

/// 设置视频水印
/// @param image 水印图片，必须使用透明底的png格式图片
/// @param rect 水印位置，x, y, width, height取值范围都是0 - 1
/// @note 如果当前分辨率为540 x 960, 设置rect为(0.1, 0.1, 0.2, 0)，
///       那水印图片的出现位置在(540 * 0.1, 960 * 0.1) = (54, 96),
///       宽度为540 * 0.2 = 108, 高度自动计算
- (void)setWaterMark:(UIImage * _Nullable)image inRect:(CGRect)rect;

/// 切换前后摄像头
- (void)switchCamera;

/// 切换闪光灯
- (void)switchTorch;

/// 设置自动对焦
/// @param isEnabled 开启自动对焦
- (void)setAutoFocusEnabled:(BOOL)isEnabled;

/// 设置重力感应
/// @param isEnable 开启重力感应
- (void)setGSensorEnabled:(BOOL)isEnable;

/// 设置流控方案
/// @param mode 流控方案
- (void)setQosControlMode:(TRTCQosControlMode)mode;

/// 设置双路编码
/// @param isEnabled 开启双路编码
- (void)setSmallVideoEnabled:(BOOL)isEnabled;

/// 设置是否默认观看低清
/// @param prefersLowQuality 默认观看低清
- (void)setPrefersLowQuality:(BOOL)prefersLowQuality;

#pragma mark - Audio Settings

/// 设置音频采集
/// @param isEnabled 开启音频采集
- (void)setAudioEnabled:(BOOL)isEnabled;

/// 采集音量
@property (nonatomic) NSInteger captureVolume;

/// 播放音量
@property (nonatomic) NSInteger playoutVolume;


/// 设置音频通道
/// @param route 音频通道
- (void)setAudioRoute:(TRTCAudioRoute)route;

/// 设置音量类型
/// @param type 音量类型
- (void)setVolumeType:(TRTCSystemVolumeType)type;

/// 设置耳返
/// @param isEnabled 开启耳返
- (void)setEarMonitoringEnabled:(BOOL)isEnabled;

/// 设置自动增益
/// @param isEnabled 开启自动增益
- (void)setAgcEnabled:(BOOL)isEnabled;

/// 设置噪声消除
/// @param isEnabled 开启噪声消除
- (void)setAnsEnabled:(BOOL)isEnabled;

/// 设置采样率，支持的值为8000, 16000, 32000, 44100, 48000
/// @param sampleRate 采样率
/// @note 在音频启动前设置
- (void)setSampleRate:(NSInteger)sampleRate;

/// 设置音量提示
/// @param isEnabled 开启音量提示
/// @note 在音频启动前设置
- (void)setVolumeEvaluationEnabled:(BOOL)isEnabled;

#pragma mark - Stream

/// 设置云端混流
/// @param isMixingInCloud 开启云端混流
- (void)setMixingInCloud:(BOOL)isMixingInCloud;

/// 设置云端混流参数
- (void)updateCloudMixtureParams;

#pragma mark - Message

/// 发送自定义消息
/// @param message 消息内容，最大支持1kb
/// @result 发送是否成功
- (BOOL)sendCustomMessage:(NSString *)message;

/// 发送SEI消息
/// @param message 消息内容，最大支持1kb，推荐只传几个字节
/// @param repeatCount 发送数据次数
/// @result 消息是否检验成功，检验成功的消息将等待发送
- (BOOL)sendSEIMessage:(NSString *)message repeatCount:(NSInteger)repeatCount;

#pragma mark - Cross Room

/// 当前是否在跨房连接中
@property (nonatomic, readonly) BOOL isCrossingRoom;

/// 开始跨房通话
/// @param roomId 对方的房间ID
/// @param userId 对方的用户ID
- (void)startCrossRoom:(NSString *)roomId userId:(NSString *)userId;

/// 结束跨房通话
- (void)stopCrossRomm;

#pragma mark - Live Player

/// 旁路直播开启后，获取旁路直播的播放地址
- (NSString *)getCdnUrlOfUser:(NSString *)userId;

#pragma mark - Custom Video Capture and Render

/// 设置视频文件
/// @param videoAsset 视频文件资源
/// @note 这个接口需要要在enterRoom之前调用
- (void)setCustomVideo:(AVAsset *)videoAsset;

/// 开启远程用户视频的自定义渲染
/// @param userId 远程用户ID
/// @param view 视频页面
- (void)playCustomVideoOfUser:(NSString *)userId inView:(UIImageView *)view;

@end

NS_ASSUME_NONNULL_END
