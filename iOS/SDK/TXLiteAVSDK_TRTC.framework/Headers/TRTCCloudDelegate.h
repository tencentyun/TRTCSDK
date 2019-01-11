/*
 * Module:   TRTCCloudDelegate @ TXLiteAVSDK
 * 
 * Function: 腾讯云视频通话功能的事件回调接口
 *
 */

#import <Foundation/Foundation.h>
#import "TRTCCloudDef.h"
#import "TXLiteAVCode.h"

NS_ASSUME_NONNULL_BEGIN

@class TRTCCloud;
@class TRTCStatistics;


/**
 * TRTCCloudDelegate 是 TRTCCloud 的主要回调接口
 */
@protocol TRTCCloudDelegate <NSObject>
@optional

/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）通用事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 通用事件回调
/// @{
/**
 * 1.1 错误回调: SDK不可恢复的错误，一定要监听，并分情况给用户适当的界面提示
 * @param errCode 错误码
 * @param errMsg  错误信息
 * @param extInfo 扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
 */
- (void)onError:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg extInfo:(nullable NSDictionary*)extInfo;

/**
 * 1.2 警告回调
 * @param warningCode 警告码
 * @param warningMsg 警告信息
 * @param extInfo 扩展信息字段，个别警告码可能会带额外的信息帮助定位问题
 */
- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(nullable NSString *)warningMsg extInfo:(nullable NSDictionary*)extInfo;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）房间事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 房间事件回调
/// @{
/**
 * 2.1 加入房间
 * @param elapsed 加入房间耗时
 */
- (void)onEnterRoom:(NSInteger)elapsed;

/**
 * 2.2 离开房间
 * 离开房间成功的回调
 * @param reason 离开房间原因
 */
- (void)onExitRoom:(NSInteger)reason;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）成员事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 成员事件回调
/// @{

/**
 * 3.1 成员进入房间事件
 * @param userId 用户标识
 */
- (void)onUserEnter:(NSString *)userId;

/**
 * 3.2 成员离开房间事件
 * @param userId 用户标识
 * @param reason 离开原因代码
 */
- (void)onUserExit:(NSString *)userId reason:(NSInteger)reason; 

/**
 * 3.3 成员屏蔽自己的画面
 * @param userId 用户标识
 * @param available 画面是否开启
 */
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available;

/**
 * 3.4 成员屏蔽自己的声音
 * @param userId 用户标识
 * @param available 声音是否开启
 */
- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available;

/**
 * 3.5 成员语音音量回调
 * 通过调用 TRTCCloud enableAudioVolumeEvaluation:smooth: 来开关这个回调
 * @param userVolumes  每位发言者的语音音量，取值范围 0~100
 * @param totalVolume  总的语音音量, 取值范围 0~100
 */
- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）统计和质量回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 统计和质量回调
/// @{

/**
 * 4.1 网络质量: 该回调每 2 秒触发一次，统计当前网络的上行和下行质量
 * 注：userid == nil 代表自己当前的视频质量
 * @param localQuality 上行网络质量
 * @param remoteQuality 下行网络质量
 */
 
- (void)onNetworkQuality: (TRTCQualityInfo*)localQuality remoteQuality:(NSArray<TRTCQualityInfo*>*)remoteQuality;


/**
 * 4.2 技术指标统计回调: 
 *     如果您是熟悉音视频领域相关术语，可以通过这个回调获取SDK的所有技术指标，
 *     如果您是首次开发音视频相关项目，可以只关注 onNetworkQuality 回调
 * @param statistics 统计数据，包括本地和远程的
 * @note 每2秒回调一次
 */
 
- (void)onStatistics: (TRTCStatistics *)statistics;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）音视频事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 音视频事件回调
/// @{

/**
 * 5.1 首帧视频画面到达，界面此时可以结束loading，并开始显示视频画面
 * @param userId 用户Id
 * @param width  画面宽度
 * @param height 画面高度
 */ 
- (void)onFirstVideoFrame:(NSString*)userId width:(int)width height:(int)height;


/**
 * 5.2 首帧音频数据到达
 */
- (void)onFirstAudioFrame:(NSString*)userId;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）服务器事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 服务器事件回调
/// @{

/**
 * 6.1 SDK 跟服务器的连接断开
 */
- (void)onConnectionLost;

/**
 * 6.2 SDK 尝试重新连接到服务器
 */
- (void)onTryToReconnect;

/**
 * 6.3 SDK 跟服务器的连接恢复
 */
- (void)onConnectionRecovery;

/**
 * 6.4 SDK 跟服务器的连接断开 （暂无）
 */
//- (void)onConnectionBandByServer;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）硬件设备事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 硬件设备事件回调
/// @{

/**
 * 7.1 摄像头准备就绪
 */
- (void)onCameraDidReady;

/**
 * 7.2 麦克风准备就绪
 */
- (void)onMicDidReady;

#if TARGET_OS_IPHONE
/**
 * 7.3 音频路由发生变化(仅iOS)，音频路由即声音由哪里输出（扬声器、听筒）
 * @param route     当前音频路由
 * @param fromRoute 变更前的音频路由
 */
- (void)onAudioRouteChanged:(TRTCAudioRoute)route fromRoute:(TRTCAudioRoute)fromRoute;
#endif


#if !TARGET_OS_IPHONE && TARGET_OS_MAC
/**
 * 7.4 本地设备通断回调
 * @param deviceId 设备id
 * @param deviceType 设备类型 @see TRTCMediaDeviceType
 * @param state   0: 设备断开   1: 设备连接
 */
- (void)onDevice:(NSString *)deviceId type:(TRTCMediaDeviceType)deviceType stateChanged:(NSInteger)state;

#endif

/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      （八）自定义消息的接收回调
// 
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 自定义消息的接收回调
/// @{

/**
 * 当房间中的某个用户使用 sendCustomCmdMsg 发送自定义消息时，房间中的其它用户可以通过 onRecvCustomCmdMsg 接口接收消息
 *
 * @param userId 用户标识
 * @param cmdID 命令ID
 * @param seq   消息序号
 * @param message 消息数据
 */
- (void)onRecvCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID seq:(UInt32)seq message:(NSData *)message;

/**
 * TRTC所使用的传输通道为UDP通道，所以即使设置了 reliable，也做不到100%不丢失，只是丢消息概率极低，能满足常规可靠性要求。
 * 在过去的一段时间内（通常为5s），自定义消息在传输途中丢失的消息数量的统计，SDK 都会通过此回调通知出来
 *   
 * @note  只有在发送端设置了可靠传输(reliable)，接收方才能收到消息的丢失回调
 * @param userId 用户标识
 * @param cmdID 命令ID
 * @param errCode 错误码
 * @param missed 丢失的消息数量
 */
- (void)onMissCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID errCode:(NSInteger)errCode missed:(NSInteger)missed;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （九）旁路转推和混流回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 旁路转推和混流回调
/// @{
- (void)onStartPublishCDNStream:(int)err errMsg:(NSString *)errMsg;
- (void)onStopPublishCDNStream:(int)err errMsg:(NSString *)errMsg;
- (void)onStartCloudMixTranscoding:(int)err errMsg:(NSString *)errMsg;
- (void)onStopCloudMixTranscoding:(int)err errMsg:(NSString *)errMsg;
/// @}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十）自定义视频渲染回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 自定义视频渲染回调对象
 */
#pragma mark - TRTCVideoRenderDelegate
@protocol TRTCVideoRenderDelegate <NSObject>
/**
 * 自定义视频渲染回调
 * @param frame  待渲染的视频帧信息
 * @param userId 视频源的 userid，如果是本地视频回调，该参数可以不用理会
 * @param streamType 视频源类型，比如是摄像头画面还是屏幕分享画面等等
 */
@optional
- (void) onRenderVideoFrame:(TRTCVideoFrame * _Nonnull)frame userId:(NSString* __nullable)userId streamType:(TRTCVideoStreamType)streamType;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十一）Log 信息回调
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 日志事件回调对象
 *
 * 建议在一个比较早初始化的类中设置回调委托对象，如AppDelegate
 */
@protocol TRTCLogDelegate <NSObject>
/**
 * 有日志打印时的回调
 * @param log 日志内容
 * @param level 日志等级 参见TRTCLogLevel
 * @param module 值暂无具体意义，目前为固定值TXLiteAVSDK
 */
@optional
-(void) onLog:(nullable NSString*)log LogLevel:(TRTCLogLevel)level WhichModule:(nullable NSString*)module;

@end

NS_ASSUME_NONNULL_END
