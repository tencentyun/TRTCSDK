/*
 * Module:   TRTCCloud @ TXLiteAVSDK
 * 
 * Function: 腾讯云视频通话功能的主要接口类
 *
 * Version: 6.2.7005
 */

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "TRTCCloudDelegate.h"
#import "TRTCCloudDef.h"

@interface TRTCCloud : NSObject

// 请使用 +sharedIntance 方法
+ (instancetype)new  __attribute__((unavailable("Use +sharedInstance instead")));
- (instancetype)init __attribute__((unavailable("Use +sharedInstance instead")));

/// @name 创建与销毁
/// @{

/// 创建TRTCCloud单例
+ (instancetype)sharedInstance;

/// 销毁TRTCCloud单例
+ (void)destroySharedIntance;

/// @}

/// 设置回调接口 TRTCCloudDelegate，用户获得来自 TRTCCloud 的各种状态通知
@property (nonatomic, weak) id<TRTCCloudDelegate> delegate;

/// 设置驱动回调的队列，默认会采用 Main Queue。
/// 也就是说，如果您不指定 delegateQueue，那么直接在 TRTCCloudDelegate 的回调函数中操作 UI 界面将是安全的
@property (nonatomic, strong) dispatch_queue_t delegateQueue;



/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）房间相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 房间相关接口函数
/// @name 房间相关接口函数
/// @{
/**
 * 1.1 进入房间
 * @param param 进房参数，请参考 TRTCParams
 * @param scene 应用场景，目前支持视频通话（VideoCall）和在线直播（Live）两种场景
 * @note 不管进房是否成功，都必须与exitRoom配对使用，在调用 exitRoom 前再次调用 enterRoom 函数会导致不可预期的错误问题
 */
- (void)enterRoom:(TRTCParams *)param appScene:(TRTCAppScene)scene;

/**
 * 1.2 离开房间
 */
- (void)exitRoom;

/**
 * 1.3 请求跨房连麦
 * @param param json字符串连麦参数，包含以下字段:
 * roomId: int  //连麦房间号
 * userId: String                    //被连麦帐号
 * sign: String                      //跨房连麦签名，加密内容为TC_ConnRoomSig，由第三方后台加密生成，是否使用由spear配置决定
 **/
- (void)connectOtherRoom:(NSString *)param;

/**
 * 取消跨房连麦
 **/
- (void)disconnectOtherRoom;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）视频相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 视频相关接口函数
/// @name 视频相关接口函数
/// @{
#if TARGET_OS_IPHONE
/**
 * 2.1 开启本地视频的预览画面 (iOS版本)
 * @param frontCamera YES:前置摄像头 NO:后置摄像头
 * @param view 承载预览画面的控件所在的父控件
 */
- (void)startLocalPreview:(BOOL)frontCamera view:(TXView *)view;
#elif TARGET_OS_MAC
/**
 * 2.1 开启本地视频的预览画面 (Mac版本)
 * @note 在调用该方法前，请先调用 setCurrentCameraDevice 选择使用 Mac 自带的摄像头还是外接摄像头
 * @param view 指定渲染控件所在的父控件，SDK会在 view 内部创建一个等大的子控件用来渲染本地摄像头的视频画面
 */
- (void)startLocalPreview:(TXView *)view;
#endif

/**
 * 2.2 停止本地视频采集及预览
 */
- (void)stopLocalPreview;

/**
 * 2.3 启动渲染远端视频画面
 * @param userId 对方的用户标识
 * @param view 指定渲染控件所在的父控件，SDK会在 view 内部创建一个等大的子控件用来渲染远端画面
 * @note 在 onUserVideoAvailable 回调时，调用这个接口
 */
- (void)startRemoteView:(NSString *)userId view:(TXView *)view;

/**
 * 2.4 停止渲染远端视频画面
 * @param userId 对方的用户标识
 */
- (void)stopRemoteView:(NSString *)userId;

/**
 * 2.5 停止渲染远端视频画面，如果有屏幕分享，则屏幕分享的画面也会一并被关闭
 */
- (void)stopAllRemoteView;

/**
 * 2.6 是否屏蔽本地视频
 * 
 * 当屏蔽本地视频后，房间里的其它成员将会收到 onUserVideoAvailable 回调通知
 * @param mute YES:屏蔽 NO:开启
 */
- (void)muteLocalVideo:(BOOL)mute;

/**
 * 2.7 设置视频编码器相关参数，该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
 * @param param         视频编码参数，详情请参考 TRTCCloudDef.h 中的 TRTCVideoEncParam 定义
 */ 
- (void)setVideoEncoderParam:(TRTCVideoEncParam*)param;

/**
 * 2.8 设置网络流控相关参数，该设置决定了SDK在各种网络环境下的调控策略（比如弱网下是“保清晰”还是“保流畅”）
 * @param param         网络流控参数，详情请参考 TRTCCloudDef.h 中的 TRTCNetworkQosParam 定义
 */ 
- (void)setNetworkQosParam:(TRTCNetworkQosParam*)param;

/**
 * 2.9 设置本地图像的渲染模式
 *
 * @param mode 填充（画面可能会被拉伸裁剪）还是适应（画面可能会有黑边）
 */
- (void)setLocalViewFillMode:(TRTCVideoFillMode)mode;

/**
 * 2.10 设置远端图像的渲染模式
 *
 * @param userId 用户的id
 * @param mode 填充（画面可能会被拉伸裁剪）还是适应（画面可能会有黑边）
 */
- (void)setRemoteViewFillMode:(NSString*)userId mode:(TRTCVideoFillMode)mode;

/**
 * 2.11 设置本地图像的顺时针旋转角度
 * @param rotation 支持 90、180、270 旋转角度
 */
- (void)setLocalViewRotation:(TRTCVideoRotation)rotation;

/**
 * 2.12 设置远端图像的顺时针旋转角度
 * @param userId 用户Id
 * @param rotation 支持 90、180、270 旋转角度
 */
- (void)setRemoteViewRotation:(NSString*)userId rotation:(TRTCVideoRotation)rotation;

/**
 * 2.13 设置视频编码输出的（也就是远端用户观看到的，以及服务器录制下来的）画面方向
 * @param rotation 支持 0 和 180 两个旋转角度
 */
- (void)setVideoEncoderRotation:(TRTCVideoRotation)rotation;

/**
 * 2.14 设置重力感应的适应模式
 * @param mode 重力感应模式，详情请参考 TRTCGSensorMode 的定义
 */
- (void)setGSensorMode:(TRTCGSensorMode) mode;

/**
 * 2.15 开启大小画面双路编码模式
 *
 * 如果当前用户是房间中的主要角色（比如主播、老师、主持人...），并且使用 PC 或者 Mac 环境，可以开启该模式
 * 开启该模式后，当前用户会同时输出【高清】和【低清】两路视频流（但只有一路音频流）
 * 对于开启该模式的当前用户，会占用更多的网络带宽，并且会更加消耗 CPU 计算资源
 * 对于同一房间的远程观众而言，
 * 如果有些人的下行网络很好，可以选择观看【高清】画面
 * 如果有些人的下行网络不好，可以选择观看【低清】画面
 * @param enable 是否开启小画面编码
 * @param smallVideoEncParam 小流的视频参数
 * @return 0:成功  -1:大画面已经是最低画质
 */
- (int)enableEncSmallVideoStream:(BOOL)enable withQuality:(TRTCVideoEncParam*)smallVideoEncParam;

/**
 * 2.16 选定观看指定 uid 的大画面还是小画面
 *
 * 此功能需要该 uid 通过 enableEncSmallVideoStream 提前开启双路编码模式
 * 如果该 uid 没有开启双路编码模式，则此操作无效
 * @param userId 用户的uid
 * @param type 视频流类型，即选择看大画面还是小画面
 */
- (void)setRemoteVideoStreamType:(NSString*)userId type:(TRTCVideoStreamType)type;

/**
 * 2.17 设定观看方优先选择的视频质量
 *
 * 低端设备推荐优先选择低清晰度的小画面
 * 如果对方没有开启双路视频模式，则此操作无效
 * @param type 默认观看大画面还是小画面
 */
- (void)setPriorRemoteVideoStreamType:(TRTCVideoStreamType)type;

#if !TARGET_OS_IPHONE && TARGET_OS_MAC
/**
 * 2.18 设置摄像头本地预览是否开镜像
 *
 * @param mirror 是否开启预览镜像
 */
- (void)setLocalVideoMirror:(BOOL)mirror;
#endif

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）音频相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 音频相关接口函数
/// @name 音频相关接口函数
/// @{
	
/**
 * 3.1 开启本地音频流，该函数会启动麦克风采集，并将音频数据广播给房间里的其他用户
 *
 * @note TRTC SDK 并不会默认打开本地的麦克风采集。
 * @note 该函数会检查麦克风使用权限，如果没有麦克风权限，SDK 会向用户申请开启
 */
- (void)startLocalAudio;

/**
 * 3.2 关闭本地音频流
 */
- (void)stopLocalAudio;

/**
 * 3.3 是否屏蔽本地音频
 *
 * 当屏蔽本地音频后，房间里的其它成员会收到 onUserAudioAvailable 回调通知
 * @param mute YES:屏蔽 NO:开启
 */
- (void)muteLocalAudio:(BOOL)mute;

/**
 * 3.4 设置音频路由
 * @param route 音频路由即声音由哪里输出（扬声器、听筒）
 */
- (void)setAudioRoute:(TRTCAudioRoute)route;

/**
 * 3.5 设置指定用户是否静音
 * @param userId 对方的用户标识
 * @param mute YES:静音 NO:非静音
 */
- (void)muteRemoteAudio:(NSString *)userId mute:(BOOL)mute;

/**
 * 3.6 设置所有远端用户是否静音
 * @param mute YES:静音 NO:非静音
 */
- (void)muteAllRemoteAudio:(BOOL)mute;

/**
 * 3.7 启用音量大小提示
 *
 * 开启后会在 onUserVoiceVolume 中获取到 SDK 对音量大小值的评估
 * @param interval     报告间隔单位为ms, 最小间隔20ms, 如果小于等于0则会关闭回调，建议设置为大于200ms
 * @param smoothLevel  灵敏度，[0,10], 数字越大，波动越灵敏
 */
- (void)enableAudioVolumeEvaluation:(NSUInteger)interval smooth:(NSInteger)smoothLevel;
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）摄像头相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 摄像头相关接口函数
/// @name 摄像头相关接口函数
/// @{
#if TARGET_OS_IPHONE

/**
 * 4.1 切换摄像头
 */
- (void)switchCamera;

/**
 * 4.2 查询当前摄像头是否支持缩放
 */
- (BOOL)isCameraZoomSupported;

/**
 * 4.3 设置摄像头缩放因子（焦距）
 * @param distance 取值范围 1~5 ，当为1的时候为最远视角（正常镜头），当为5的时候为最近视角（放大镜头），这里最大值推荐为5，超过5后视频数据会变得模糊不清
 */
- (void)setZoom:(CGFloat)distance;

/**
 * 4.4 查询是否支持手电筒模式
 */
- (BOOL)isCameraTorchSupported;

/**
 * 4.5 开关闪光灯
 * @param enable YES:开启  NO:关闭
 */
- (BOOL)enbaleTorch:(BOOL)enable;

/**
 * 4.6 查询是否支持设置焦点
 */
- (BOOL)isCameraFocusPositionInPreviewSupported;

/**
 * 4.7 设置摄像头焦点
 * @param touchPoint 对焦位置
 */
- (void)setFocusPosition:(CGPoint)touchPoint;

/**
 * 4.8 查询是否支持自动识别人脸位置
 */
- (BOOL)isCameraAutoFocusFaceModeSupported;

/**
 * 4.9 自动识别人脸位置
 * @param enable YES:打开  NO:关闭
 */
- (void)enableAutoFaceFoucs:(BOOL)enable;

#elif TARGET_OS_MAC

/**
 * 4.10 获取摄像头设备列表
 * @return 摄像头设备列表，第一项为当前系统默认设备
 */
- (NSArray<TRTCMediaDeviceInfo*>*)getCameraDevicesList;

/**
 * 4.11 获取当前要使用的摄像头
 */
- (TRTCMediaDeviceInfo*)getCurrentCameraDevice;

/**
 * 4.12 设置要使用的摄像头
 * @param deviceId 从getCameraDevicesList中得到的设备id
 * @return 0:成功 -1:失败
 */
- (int)setCurrentCameraDevice:(NSString*)deviceId;


#endif
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）音频设备相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 音频设备相关接口函数
/// @name 音频设备相关接口函数
/// @{
#if !TARGET_OS_IPHONE  && TARGET_OS_MAC
/**
 * 5.1 获取麦克风设备列表
 * @return 麦克风设备列表,第一项为当前系统默认设备
 */
- (NSArray<TRTCMediaDeviceInfo*>*)getMicDevicesList;

/**
 * 5.2 获取当前的麦克风设备
 * @return 当前麦克风设备信息
 */
- (TRTCMediaDeviceInfo*)getCurrentMicDevice;

/**
 * 5.3 设置要使用的麦克风
 * @param deviceId 从getMicDevicesList中得到的设备id
 * @return 0:成功 <0:失败
 */
- (int)setCurrentMicDevice:(NSString*)deviceId;

/**
 * 5.4 获取当前麦克风设备音量
 * @return 麦克风音量
 */
- (float)getCurrentMicDeviceVolume;

/**
 * 5.5 设置麦克风设备的音量
 * @param volume 麦克风音量值, 范围0~100
 */
- (void)setCurrentMicDeviceVolume:(NSInteger)volume;

/** 
 * 5.6 获取扬声器设备列表
 * @return 麦克风设备列表,第一项为当前系统默认设备
 */
- (NSArray<TRTCMediaDeviceInfo*>*)getSpeakerDevicesList;

/**
 * 5.7 获取当前的扬声器设备
 * @return 当前扬声器设备信息
 */
- (TRTCMediaDeviceInfo*)getCurrentSpeakerDevice;

/**
 * 5.8 设置要使用的扬声器
 * @param deviceId 从getSpeakerDevicesList中得到的设备id
 * @return 0:成功 <0:失败
 */
- (int)setCurrentSpeakerDevice:(NSString*)deviceId;

/**
 * 5.9 当前扬声器设备音量
 * @return 扬声器音量
 */
- (float)getCurrentSpeakerDeviceVolume;

/**
 * 5.10 设置当前扬声器音量
 * @param volume 设置的扬声器音量, 范围0~100
 * @return 0:成功  <0:调用失败
 */
- (int)setCurrentSpeakerDeviceVolume:(NSInteger)volume;

#endif
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）美颜滤镜相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 美颜滤镜相关接口函数
/// @name 美颜滤镜相关接口函数
/// @{
/**
 * 6.1 设置美颜、美白、红润效果级别
 * @param beautyStyle 美颜风格
 * @param beautyLevel 美颜级别，取值范围 0 ~ 9； 0 表示关闭， 1 ~ 9值越大，效果越明显
 * @param whitenessLevel 美白级别，取值范围 0 ~ 9； 0 表示关闭， 1 ~ 9值越大，效果越明显
 * @param ruddinessLevel 红润级别，取值范围 0 ~ 9； 0 表示关闭， 1 ~ 9值越大，效果越明显
 */
- (void)setBeautyStyle:(TRTCBeautyStyle)beautyStyle beautyLevel:(NSInteger)beautyLevel
        whitenessLevel:(NSInteger)whitenessLevel ruddinessLevel:(NSInteger)ruddinessLevel;

/**
 * 6.2 设置指定素材滤镜特效
 * @param image 指定素材，即颜色查找表图片。注意：一定要用png格式！！！
 */
- (void)setFilter:(TXImage *)image;

/**
 * 6.3 设置滤镜浓度
 * @param concentration 从0到1，越大滤镜效果越明显，默认值为0.5
 */
- (void)setFilterConcentration:(float)concentration;

/**
 * 6.4 添加水印
 * @param image 水印图片
 * @param streamType (TRTCVideoStreamTypeBig、TRTCVideoStreamTypeSub)
 * @param rect 水印相对于编码分辨率的归一化坐标，x,y,width,height 取值范围 0~1；height不用设置，sdk内部会根据水印宽高比自动计算height
 */
- (void)setWatermark:(TXImage*)image streamType:(TRTCVideoStreamType)streamType rect:(CGRect)rect;
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）辅流相关接口函数(屏幕共享)(MAC)
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 屏幕共享接口函数(MAC)
/// @name 辅流相关接口函数(MAC)
/// @{
/**
 * 7.1 开始渲染远端用户辅流画面
 *     对应于 startRemoteView() 用于观看远端的主路画面，该接口只能用于观看辅路（屏幕分享、远程播片）画面
 *
 * @param userId 对方的用户标识
 * @param view 渲染控件所在的父控件
 * @note 在 onUserSubStreamAvailable 回调时，调用这个接口
 */
- (void)startRemoteSubStreamView:(NSString *)userId view:(TXView *)view;

/**
 * 7.2 停止渲染远端用户屏幕分享画面
 * @param userId 对方的用户标识
 */
- (void)stopRemoteSubStreamView:(NSString *)userId;

/**
 * 7.3 设置辅流画面的渲染模式
 *     对应于setRemoteViewFillMode() 于设置远端的主路画面，该接口用于设置远端的辅路（屏幕分享、远程播片）画面
 *
 * @param userId 用户的id
 * @param mode 填充（画面可能会被拉伸裁剪）还是适应（画面可能会有黑边）
 */
- (void)setRemoteSubStreamViewFillMode:(NSString *)userId mode:(TRTCVideoFillMode)mode;

#if !TARGET_OS_IPHONE && TARGET_OS_MAC

/**
 *  7.4 【屏幕共享】枚举可用的屏幕分享窗口
 * @param thumbnailSize - 指定要获取的窗口缩略图大小，缩略图可用于绘制在窗口选择界面上
 * @param iconSize  - 指定要获取的窗口图标大小
 * @return 窗口列表保护屏幕窗口
 */
- (NSArray<TRTCScreenCaptureSourceInfo*>*)getScreenCaptureSourcesWithThumbnailSize:(CGSize)thumbnailSize iconSize:(CGSize)iconSize;

/**
 *  7.5 【屏幕共享】设置屏幕共享参数，该方法在屏幕共享过程中也可以调用
 *  @param screenSource     指定分享源
 *  @param rect             指定捕获的区域(传CGRectZero则默认分享全屏);
 *  @param capturesCursor   是否捕获鼠标光标
 *  @param highlight        是否高亮正在分享的窗口
 * 
 */
- (void)selectScreenCaptureTarget:(TRTCScreenCaptureSourceInfo *)screenSource
                             rect:(CGRect)rect 
		           capturesCursor:(BOOL)capturesCursor
                        highlight:(BOOL)highlight;

/**
 *  7.6 【屏幕共享】启动屏幕分享
 *  @param view 渲染控件所在的父控件
 */
- (void)startScreenCapture:(NSView *)view;

/**
 *  7.7 【屏幕共享】停止屏幕采集
 *
 *  @return 0：成功 <0:失败
 */
- (int)stopScreenCapture;

/**
 *  7.8 【屏幕共享】暂停屏幕分享
 *
 *  @return 0：成功 <0:失败
 */
- (int)pauseScreenCapture;

/**
 *  7.9 【屏幕共享】恢复屏幕分享
 *
 *  @return 0：成功 <0:失败
 */
- (int)resumeScreenCapture;

/**
 *  7.10 设置辅路视频编码器参数，对应于 setVideoEncoderParam() 设置主路画面的编码质量
 *       该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
 *
 *  @param param   辅流编码参数，详情请参考 TRTCCloudDef.h 中的 TRTCVideoEncParam 定义
 */
- (void)setSubStreamEncoderParam:(TRTCVideoEncParam *)param;

/**
 *  7.11 设置辅流的混音音量大小，这个数值越高，辅流音量占比就约高，麦克风音量占比就越小
 *
 *  @param volume 设置的音量大小，范围[0,100]
 */
- (void)setSubStreamMixVolume:(NSInteger)volume;

#endif
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （八）自定义采集和渲染
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 自定义采集和渲染
/// @name 自定义采集和渲染
/// @{

/**
 * 8.1 启用视频自定义采集模式，即放弃SDK原来的视频采集流程，改用sendCustomVideoData向SDK塞入自己采集的视频画面
 * @param enable 是否启用
 */
- (void)enableCustomVideoCapture:(BOOL)enable;

/**
 * 8.2 发送自定义的SampleBuffer
 * @note SDK内部不做帧率控制,请务必保证调用该函数的频率和TXLivePushConfig中设置的帧率一致,否则编码器输出的码率会不受控制
 * @param frame 视频数据   仅支持PixelBuffer I420数据
 */
- (void)sendCustomVideoData:(TRTCVideoFrame *)frame;

/**
 * 8.3 设置本地视频的自定义渲染回调
 * @note 设置此方法后，SDK内部会把采集到的数据回调出来，SDK跳过自己原来的渲染流程，您需要自己完成画面的渲染
 * @param delegate    自定义渲染回调
 * @param pixelFormat 指定回调的像素格式, 目前仅支持 TRTCVideoPixelFormat_I420
 * @param bufferType  SDK为了提高回调性能，提供了两种PixelBuffer格式，一种是iOS原始的(TRTCVideoBufferType_PixelBuffer)，一种是经过内存整理的(TRTCVideoBufferType_NSData)
 * @return 0:成功 <0 错误
 */
- (int)setLocalVideoRenderDelegate:(id<TRTCVideoRenderDelegate>)delegate pixelFormat:(TRTCVideoPixelFormat)pixelFormat bufferType:(TRTCVideoBufferType)bufferType;

/**
 * 8.4 设置远端视频的自定义渲染回调
 * @note 设置此方法后，SDK内部会把远端的数据解码后回调出来，SDK跳过自己原来的渲染流程，您需要自己完成画面的渲染
 * @note setRemoteVideoRenderDelegate 之前需要调用 startRemoteView 来开启对应 userid 的视频画面，才有数据回调出来。
 *
 * @param userId    自定义渲染回调
 * @param delegate    自定义渲染的回调
 * @param pixelFormat 指定回调的像素格式，目前仅支持 TRTCVideoPixelFormat_I420
 * @param bufferType  SDK为了提高回调性能，提供了两种PixelBuffer格式，一种是iOS原始的(TRTCVideoBufferType_PixelBuffer)，一种是经过内存整理的(TRTCVideoBufferType_NSData)
 * @return 0:成功 <0 错误
 */
- (int)setRemoteVideoRenderDelegate:(NSString*)userId delegate:(id<TRTCVideoRenderDelegate>)delegate pixelFormat:(TRTCVideoPixelFormat)pixelFormat bufferType:(TRTCVideoBufferType)bufferType;

/**
 * 8.6 调用实验性API接口
 *
 * @note 该接口用于调用一些实验性功能
 * @param jsonStr 接口及参数描述的json字符串
 */
- (void)callExperimentalAPI:(NSString*)jsonStr;

/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      （九）自定义消息发送
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 自定义消息发送
/// @name 自定义消息发送
/// @{

/**
 * 9.1 发送自定义消息给房间内所有用户
 *
 * @param cmdID    消息ID，取值范围为 1 ~ 10
 * @param data     待发送的消息，最大支持 1KB（1000字节）的数据大小
 * @param reliable 是否可靠发送，可靠发送的代价是会引入一定的延时，因为接收端要暂存一段时间的数据来等待重传
 * @param ordered  是否要求有序，即是否要求接收端接收的数据顺序和发送端发送的顺序一致，这会带来一定的接收延时，因为在接收端需要暂存并排序这些消息
 * @return YES:消息已经发出 NO:消息发送失败
 *
 * @note 限制1：发送消息到房间内所有用户，每秒最多能发送 30 条消息
 *       限制2：每个包最大为 1 KB，超过则很有可能会被中间路由器或者服务器丢弃
 *       限制3：每个客户端每秒最多能发送总计 8 KB 数据
 *
 *       请将 reliable 和 ordered 同时设置为 YES 或 NO, 暂不支持交叉设置。
 *       有序性（ordered）是指相同 cmdID 的消息流一定跟发送方的发送顺序相同，
 *       强烈建议不同类型的消息使用不同的 cmdID，这样可以在要求有序的情况下减小消息时延
 */
- (BOOL)sendCustomCmdMsg:(NSInteger)cmdID data:(NSData *)data reliable:(BOOL)reliable ordered:(BOOL)ordered;

/**
 * 9.2 发送自定义消息给房间内所有用户
 *
 * @param data          待发送的数据，最大支持 1kb（1000字节）的数据大小
 * @param repeatCount   发送数据次数
 * @return YES:消息已通过限制，等待后续视频帧发送 NO:消息被限制发送
 *
 * @note 限制1：数据在接口调用完后不会被即时发送出去，而是从下一帧视频帧开始带在视频帧中发送
 *       限制2：发送消息到房间内所有用户，每秒最多能发送 30 条消息 (**与sendCustomCmdMsg共享限制**)
 *       限制2：每个包最大为1KB，若发送大量数据，会导致视频码率增大，可能导致视频画质下降甚至卡顿 (**与sendCustomCmdMsg共享限制**)
 *       限制4：每个客户端每秒最多能发送总计 8 KB 数据 (**与sendCustomCmdMsg共享限制**)
 *       限制5：若指定多次发送（repeatCount>1）,则数据会被带在后续的连续repeatCount个视频帧中发送出去，同样会导致视频码率增大
 *       限制6: 如果repeatCount>1,多次发送，接收消息onRecvSEIMsg回调也可能会收到多次相同的消息，需要去重
 */
- (BOOL)sendSEIMsg:(NSData *)data  repeatCount:(int)repeatCount;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十）背景混音相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 背景混音相关接口函数
/// @name 背景混音相关接口函数
/// @{
/**
 * 10.1 播放背景音乐
 * @param path 音乐文件路径
 * @param beginNotify 音乐播放开始的回调通知
 * @param progressNotify 音乐播放的进度通知，单位毫秒
 * @param completeNotify 音乐播放结束的回调通知
 */
- (void) playBGM:(NSString *)path
   withBeginNotify:(void (^)(NSInteger errCode))beginNotify
withProgressNotify:(void (^)(NSInteger progressMS, NSInteger durationMS))progressNotify
 andCompleteNotify:(void (^)(NSInteger errCode))completeNotify;

/**
 * 10.2 停止播放背景音乐
 */
- (void)stopBGM;

/**
 * 10.3 暂停播放背景音乐
 */
- (void)pauseBGM;

/**
 * 10.4 继续播放背景音乐
 */
- (void)resumeBGM;


/**
 * 10.5 获取音乐文件总时长，单位毫秒
 * @param path 音乐文件路径，如果path为空，那么返回当前正在播放的music时长
 * @return 成功返回时长， 失败返回-1
 */
- (NSInteger)getBGMDuration:(NSString *)path;

/**
 * 10.6 设置BGM播放进度
 * @param pos 单位毫秒
 * @return 0:成功  -1:失败
 */
- (int)setBGMPosition:(NSInteger)pos;


/** 
 * 10.7 设置麦克风的音量大小，播放背景音乐混音时使用，用来控制麦克风音量大小
 * @param volume 音量大小，100为正常音量，值为0~200
 */
- (void)setMicVolumeOnMixing:(NSInteger)volume;

/**
 * 10.8 设置背景音乐的音量大小，播放背景音乐混音时使用，用来控制背景音音量大小
 * @param volume 音量大小，100为正常音量，建议值为0~200，如果需要调大背景音量可以设置更大的值
 */
- (void)setBGMVolume:(NSInteger)volume;

/**
 * 10.9 设置混响效果 (目前仅iOS)
 * @param reverbType ：混响类型 ，详见 TXReverbType
 */
- (void)setReverbType:(TRTCReverbType)reverbType;

/**
 * 10.10 设置变声类型 (目前仅iOS)
 * @param voiceChangerType 变声类型, 详见 TXVoiceChangerType
 */
- (void)setVoiceChangerType:(TRTCVoiceChangerType)voiceChangerType;
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十一）设备和网络测试
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 设备和网络测试
/// @name 设备和网络测试
/// @{

/**
 * 11.1 开始进行网络测速(视频通话期间请勿测试，以免影响通话质量)
 *
 * 测速结果将会用于优化 SDK 接下来的服务器选择策略，因此推荐您在用户首次通话前先进行一次测速，这将有助于我们选择最佳的服务器
 * 同时，如果测试结果非常不理想，您可以通过醒目的 UI 提示用户选择更好的网络
 * 
 * 注意：测速本身会消耗一定的流量，所以也会产生少量额外的流量费用
 *
 * @param sdkAppId 应用标识
 * @param userId 用户标识
 * @param userSig 用户签名
 * @param completion 测试回调，会分多次回调
 */
- (void)startSpeedTest:(uint32_t)sdkAppId userId:(NSString *)userId userSig:(NSString *)userSig completion:(void(^)(TRTCSpeedTestResult* result, NSInteger completedCount, NSInteger totalCount))completion;

/**
 * 11.2 停止服务器测速
 */
- (void)stopSpeedTest;


#if TARGET_OS_OSX
/**
 * 11.3 开始进行摄像头测试
 * @note 在测试过程中可以使用 setCurrentCameraDevice 接口切换摄像头
 * @param view 预览控件所在的父控件
 */
- (void)startCameraDeviceTestInView:(NSView *)view;

/**
 * 11.4 结束视频测试预览
 */
- (void)stopCameraDeviceTest;


/**
 * 11.5 开始进行麦克风测试
 * 该方法测试麦克风是否能正常工作, volume的取值范围为 0~100
 */
- (void)startMicDeviceTest:(NSInteger)interval testEcho:(void (^)(NSInteger volume))testEcho;

/**
 * 11.6 停止麦克风测试
 */
- (void)stopMicDeviceTest;

/**
 * 11.7 开始扬声器测试
 * 该方法播放指定的音频文件测试播放设备是否能正常工作。如果能听到声音，说明播放设备能正常工作。
 */
- (void)startSpeakerDeviceTest:(NSString*)audioFilePath onVolumeChanged:(void (^)(NSInteger volume, BOOL isLastFrame))volumeBlock;

/**
 * 11.8 停止扬声器测试
 */
- (void)stopSpeakerDeviceTest;

#endif

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十二）混流转码并发布到CDN
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 旁路推流
/// @name 混流转码并发布到CDN
/// @{
	
/**
 * 12.1 启动CDN发布：通过腾讯云将当前房间的音视频流发布到直播CDN上
 *
 * 由于 TRTC 的线路费用是按照时长收费的，并且房间容量有限（< 1000人）
 * 当您有大规模并发观看的需求时，将房间里的音视频流发布到低成本高并发的直播CDN上是一种较为理想的选择。
 * 目前支持两种发布方案：
 *
 * 【1】需要您先调用 setMixTranscodingConfig 对多路画面进行混合，发布到CDN上的是混合之后的音视频流
 *
 * 【2】发布当前房间里的各路音视频画面，每一路画面都有一个独立的地址，相互之间无影响
 *
 * @param param 请参考 TRTCCloudDef.h 中关于 TRTCPublishCDNParam 的介绍
 */
- (void) startPublishCDNStream:(TRTCPublishCDNParam*)param;

/**
 * 12.2 停止CDN发布
 */
- (void) stopPublishCDNStream;

/**
 * @brief 12.3 启动(更新)云端的混流转码：通过腾讯云的转码服务，将房间里的多路画面叠加到一路画面上
 * @desc
 * <pre>
 * 【画面1】=> 解码 => =>
 *                         \
 * 【画面2】=> 解码 =>  画面混合 => 编码 => 【混合后的画面】
 *                         /
 * 【画面3】=> 解码 => =>
 * </pre>
 * @param config 请参考 TRTCCloudDef.h 中关于 TRTCTranscodingConfig 的介绍
 *               传入nil取消云端混流转码
 */
- (void)setMixTranscodingConfig:(TRTCTranscodingConfig*)config;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十三）LOG相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
/// @name LOG相关接口函数
/// @{
	
#pragma mark - LOG相关接口函数
/**
 * 13.1 获取SDK版本信息
 */
+ (NSString *)getSDKVersion;

/**
 * 13.2 设置log输出级别
 * @param level 参见 TRTCLogLevel
 */
+ (void)setLogLevel:(TRTCLogLevel)level;

/**
 * 13.3 启用或禁用控制台日志打印
 * @param enabled 指定是否启用
 */
+ (void)setConsoleEnabled:(BOOL)enabled;

/**
 * 13.4 启用或禁用Log的本地压缩。
 *
 * 开启压缩后，log存储体积明显减小，但需要腾讯云提供的 python 脚本解压后才能阅读
 *      禁用压缩后，log采用明文存储，可以直接用记事本打开阅读，但占用空间较大。
 *  @param enabled 指定是否启用
 */
+ (void)setLogCompressEnabled:(BOOL)enabled;

/**
 * 13.5 修改日志保存路径
 *
 * @note 默认保存在 sandbox Documents/log 下，如需修改, 必须在所有方法前调用
 * @param path 存储日志路径
 */
+ (void)setLogDirPath:(NSString *)path;

/**
 * 13.6 设置日志回调
 */
+ (void)setLogDelegate:(id<TRTCLogDelegate>)logDelegate;

/**
 * 13.7 显示仪表盘
 *
 * 仪表盘是状态统计和事件消息浮层view，方便调试
 * @param showType 0:不显示 1:显示精简版 2:显示全量版
 */
- (void)showDebugView:(NSInteger)showType;

/**
 * 13.8 设置仪表盘的边距
 *
 * 必须在 showDebugView 调用前设置才会生效
 * @param userId 用户Id
 * @param margin 仪表盘内边距，注意这里是基于parentView的百分比，margin的取值范围是0--1
 */
- (void)setDebugViewMargin:(NSString *)userId margin:(TXEdgeInsets)margin;
/// @}

@end
