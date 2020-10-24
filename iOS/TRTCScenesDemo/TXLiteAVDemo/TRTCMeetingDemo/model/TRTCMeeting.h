//
//  TRTCMeeting.h
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/20/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TRTCMeetingDelegate.h"
#import "TRTCMeetingDef.h"

typedef void(^TRTCMeetingCallback)(NSInteger code, NSString *_Nullable message);
typedef void(^TRTCMeetingUserListCallback)(NSInteger code, NSString *_Nullable message, NSArray<TRTCMeetingUserInfo *> *_Nullable userInfoList);

NS_ASSUME_NONNULL_BEGIN

@interface TRTCMeeting : NSObject

// 请使用 +sharedIntance 方法
+ (instancetype)new  __attribute__((unavailable("Use +sharedInstance instead")));
- (instancetype)init __attribute__((unavailable("Use +sharedInstance instead")));

/**
 * 创建 TRTCMeeting 单例
 */
+ (instancetype)sharedInstance;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                 基础接口
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 基础接口

@property (nonatomic, weak) id<TRTCMeetingDelegate> delegate;

// 设置回调 TRTCMeetingDelegate 的 Queue，默认为 MainQueue
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

/**
 * 登录
 *
 * @param sdkAppId 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
 * @param userId 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
 * @param userSig 腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算UserSig](https://cloud.tencent.com/document/product/647/17275)。
 * @param callback 登录回调，成功时 code 为0
 */
- (void)login:(UInt32)sdkAppId userId:(NSString *)userId userSig:(NSString *)userSig callback:(TRTCMeetingCallback)callback;

/**
 * 退出登录
 */
- (void)logout:(TRTCMeetingCallback)callback;

/**
 * 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
 *
 * @param userName 用户昵称
 * @param avatarURL 用户头像
 * @param callback 设置用户信息的结果回调，成功时 code 为0
 */
- (void)setSelfProfile:(NSString *)userName avatarURL:(NSString *)avatarURL callback:(TRTCMeetingCallback)callback;

/**
 * 创建会议（房主调用）
 *
 * @param roomId 房间标识，需要由您分配并进行统一管理。
 * @param callback 创建房间的结果回调，成功时 code 为0.
 */
- (void)createMeeting:(UInt32)roomId callback:(TRTCMeetingCallback)callback;

/**
 * 销毁会议（房主调用）
 *
 * 房主在创建会议房间后，可以调用这个函数来销毁房间。
 * @param roomId 房间标识，需要由您分配并进行统一管理。
 * @param callback 创建房间的结果回调，成功时 code 为0.
 */
- (void)destroyMeeting:(UInt32)roomId callback:(TRTCMeetingCallback)callback;

/**
 * 进入会议（其他参会者调用）
 *
 * @param roomId 房间标识，需要由您分配并进行统一管理。
 * @param callback 结果回调，成功时 code 为0.
 */
- (void)enterMeeting:(UInt32)roomId callback:(TRTCMeetingCallback)callback;

/**
 * 离开会议（其他参会者调用）
 *
 * @param callback 结果回调，成功时 code 为0.
 */
- (void)leaveMeeting:(TRTCMeetingCallback)callback;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                 远端用户接口
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 远端用户接口

/**
 * 获取房间内所有的人员列表，enterMeeting() 成功后调用才有效。
 *
 * @param callback 用户详细信息回调
 */
- (void)getUserInfoList:(TRTCMeetingUserListCallback)callback;

/**
 * 获取房间内指定人员的详细信息，enterMeeting() 成功后调用才有效。
 *
 * @param callback 用户详细信息回调
 */
- (void)getUserInfo:(NSString *)userId callback:(TRTCMeetingUserListCallback)callback;

/**
 * 播放远端视频画面
 *
 * @param userId 需要观看的用户id
 * @param view 承载视频画面的 view 控件
 * @param callback 操作回调
 * @note 在 onUserVideoAvailable 为 true 回调时，调用这个接口
 */
- (void)startRemoteView:(NSString *)userId view:(UIView *)view callback:(TRTCMeetingCallback)callback;

/**
 * 停止播放远端视频画面
 *
 * @param userId 对方的用户信息
 * @param callback 操作回调
 * @note 在 onUserVideoAvailable 为 false 回调时，调用这个接口
 */
- (void)stopRemoteView:(NSString *)userId callback:(TRTCMeetingCallback)callback;

/**
 * 根据用户id和设置远端图像的渲染模式
 *
 * @param userId 用户id
 * @param fillMode 填充模式
 */
- (void)setRemoteViewFillMode:(NSString *)userId fillMode:(TRTCVideoFillMode)fillMode;

/**
 * 设置远端图像的顺时针旋转角度
 *
 * @param userId 用户id
 * @param rotation 旋转角度
 */
- (void)setRemoteViewRotation:(NSString *)userId rotation:(NSInteger)rotation;

/**
 * 静音某一个用户的声音
 *
 * @param userId 用户id
 * @param mute true：静音  false：解除静音
 */
- (void)muteRemoteAudio:(NSString *)userId mute:(BOOL)mute;

/**
 * 屏蔽某个远程用户的视频
 *
 * @param userId 用户id
 * @param mute true：屏蔽  false：解除屏蔽
 */
- (void)muteRemoteVideoStream:(NSString *)userId mute:(BOOL)mute;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                 本地视频操作接口
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 本地视频操作接口

/**
 * 开启本地视频的预览画面
 *
 * @param isFront true：前置摄像头；false：后置摄像头。
 * @param view 承载视频画面的控件
 */
- (void)startCameraPreview:(BOOL)isFront view:(UIView *)view;

/**
 * 停止本地视频采集及预览
 */
- (void)stopCameraPreview;

/**
 * 切换前后摄像头
 *
 * @param isFront true：前置摄像头；false：后置摄像头。
 */
- (void)switchCamera:(BOOL)isFront;

/**
 * 设置分辨率
 *
 * @param resolution 视频分辨率
 */
- (void)setVideoResolution:(TRTCVideoResolution)resolution;

/**
 * 设置帧率
 *
 * @param fps 帧率数
 */
- (void)setVideoFps:(int)fps;

/**
 * 设置码率
 *
 * @param bitrate 码率，单位：kbps
 */
- (void)setVideoBitrate:(int)bitrate;

/**
 * 设置本地画面镜像预览模式
 *
 * @param type 本地视频预览镜像类型
 */
- (void)setLocalViewMirror:(TRTCLocalVideoMirrorType)type;


/**
 * 设置网络qos参数
 *
 * @param qosParam 网络流控相关参数
 */
- (void)setNetworkQosParam:(TRTCNetworkQosParam *)qosParam;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                 本地音频操作接口
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 本地音频操作接口

/**
 * 开启麦克风采集
 */
- (void)startMicrophone;

/**
 * 停止麦克风采集
 */
- (void)stopMicrophone;

/**
 * 设置音质
 *
 * @param quality 音质
 */
- (void)setAudioQuality:(TRTCAudioQuality)quality;

/**
 * 开启本地静音
 *
 * @param mute 是否静音
 */
- (void)muteLocalAudio:(BOOL)mute;

/**
 * 设置开启扬声器
 *
 * @param useSpeaker true：扬声器 false：听筒
 */
- (void)setSpeaker:(BOOL)useSpeaker;

/**
 * 设置麦克风采集音量
 *
 * @param volume 采集音量 0-100
 */
- (void)setAudioCaptureVolume:(NSInteger)volume;

/**
 * 设置播放音量
 *
 * @param volume 播放音量 0-100
 */
- (void)setAudioPlayoutVolume:(NSInteger)volume;

/**
 * 开始录音
 *
 * 该方法调用后， SDK 会将通话过程中的所有音频（包括本地音频，远端音频，BGM 等）录制到一个文件里。
 * 无论是否进房，调用该接口都生效。
 * 如果调用 exitMeeting 时还在录音，录音会自动停止。
 * @param params 录音参数
 */
- (void)startFileDumping:(TRTCAudioRecordingParams *)params;

/**
 * 停止录音
 *
 * 如果调用 exitMeeting 时还在录音，录音会自动停止。
 */
- (void)stopFileDumping;

/**
 * 启用音量大小提示
 *
 * 开启后会在 onUserVolumeUpdate 中获取到 SDK 对音量大小值的评估。
 * @param enable true：打开  false：关闭
 */
- (void)enableAudioEvaluation:(BOOL)enable;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                 美颜
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 美颜

/**
 * 获取美颜管理对象
 *
 * 通过美颜管理，您可以使用以下功能：
 * - 设置”美颜风格”、”美白”、“红润”、“大眼”、“瘦脸”、“V脸”、“下巴”、“短脸”、“瘦鼻”、“亮眼”、“白牙”、“祛眼袋”、“祛皱纹”、“祛法令纹”等美容效果。
 * - 调整“发际线”、“眼间距”、“眼角”、“嘴形”、“鼻翼”、“鼻子位置”、“嘴唇厚度”、“脸型”
 * - 设置人脸挂件（素材）等动态效果
 * - 添加美妆
 * - 进行手势识别
 */
- (TXBeautyManager *)getBeautyManager;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                 录屏接口
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 录屏

- (void)startScreenCapture:(TRTCVideoEncParam *)params API_AVAILABLE(ios(11.0));

- (int)stopScreenCapture API_AVAILABLE(ios(11.0));

- (int)pauseScreenCapture API_AVAILABLE(ios(11.0));

- (int)resumeScreenCapture API_AVAILABLE(ios(11.0));


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                 分享接口
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 分享

/**
 * 获取cdn分享链接
 * @return 返回CDN分享链接
 */

- (NSString *)getLiveBroadcastingURL;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                 发送消息接口
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 消息

/**
 * 在房间中广播文本消息，一般用于文本聊天
 * @param message 文本消息
 * @param callback 发送结果回调
 */
- (void)sendRoomTextMsg:(NSString *)message callback:(TRTCMeetingCallback)callback;

/**
 * 在房间中广播自定义（信令）消息，一般用于广播点赞和礼物消息
 *
 * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
 * @param message 文本消息
 * @param callback 发送结果回调
 */
- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TRTCMeetingCallback)callback;

@end

NS_ASSUME_NONNULL_END
