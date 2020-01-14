/*
* Module:    TRTCAudioCallCloudManager
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
#import "TRTCAudioCallAudioConfig.h"
#import "TRTCCloud.h"
#import "TRTCCloudDef.h"

NS_ASSUME_NONNULL_BEGIN

@class  TRTCAudioCallCloudManager;

@protocol  TRTCAudioCallCloudManagerDelegate <NSObject>

@optional
- (void)roomSettingsManager:(TRTCAudioCallCloudManager *)manager didSetVolumeEvaluation:(BOOL)isEnabled;

@end


@interface  TRTCAudioCallCloudManager : NSObject

@property (weak, nonatomic) id<TRTCAudioCallCloudManagerDelegate> delegate;
@property (nonatomic) TRTCAppScene scene;
@property (strong, nonatomic) TRTCParams *params;
@property (strong, nonatomic, readonly) TRTCAudioCallAudioConfig *audioConfig;

- (instancetype)initWithTrtc:(TRTCCloud *)trtc params:(TRTCParams *)params scene:(TRTCAppScene)scene NS_DESIGNATED_INITIALIZER;

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



#pragma mark - Audio Settings

/// 设置音频采集
/// @param isEnabled 开启音频采集
- (void)setAudioEnabled:(BOOL)isEnabled;

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


/// 静音
/// @param isEnabled  开启静音
-(void)setSilent:(BOOL)isEnabled;

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
- (NSString *)getCdnUrl;

//禁本地麦
-(void)setMuteLocalAudio:(BOOL)isMuteLocalAudio;

@end

NS_ASSUME_NONNULL_END
