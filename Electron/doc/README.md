## ITRTCCloud @ TXLiteAVSDK

腾讯云视频通话功能的主要接口类。


### 创建TRTC对象
```java
const TrtcEngine = require('trtc-electron-sdk');
this.rtcEngine = new TrtcEngine();
```


### 设置回调
```java
subscribeEvents = (rtcEngine) => {
    rtcEngine.on('onError', (errcode, errmsg) => {
    console.info('trtc_demo: onError :' + errcode + " msg" + errmsg);
    }); 
    rtcEngine.on('onEnterRoom', (elapsed) => {
    console.info('trtc_demo: onEnterRoom elapsed:' + elapsed);
    });
    rtcEngine.on('onExitRoom', (reason) => {
    console.info('onExitRoom: userenter reason:' + reason);
    });
};

subscribeEvents(this.rtcEngine);
```

### 房间相关接口函数

| API | 描述 |
|-----|-----|
| [enterRoom] | 进入房间。 |
| [exitRoom] | 离开房间。 |
| [switchRole] | 切换角色，仅适用于直播场景（TRTCAppSceneLIVE）。 |
| [connectOtherRoom] | 请求跨房通话（主播 PK）。 |
| [disconnectOtherRoom]| 关闭跨房连麦。 |


### 视频相关接口函数

| API | 描述 |
|-----|-----|
| [startLocalPreview]| 开启本地视频的预览画面。 |
| [stopLocalPreview]| 停止本地视频采集及预览。 |
| [muteLocalVideo]| 是否屏蔽自己的视频画面。 |
| [startRemoteView] | 开始显示远端视频画面。 |
| [stopRemoteView]| 停止显示远端视频画面。 |
| [stopAllRemoteView]| 停止显示所有远端视频画面。 |
| [muteRemoteVideoStream]| 暂停接收指定的远端视频流。 |
| [muteAllRemoteVideoStreams] | 停止接收所有远端视频流。 |
| [setVideoEncoderParam] | 设置视频编码器相关参数。 |
| [setNetworkQosParam] | 设置网络流控相关参数。 |
| [setLocalViewFillMode]| 设置本地图像的渲染模式。 |
| [setRemoteViewFillMode]| 设置远端图像的渲染模式。 |
| [setLocalViewRotation](| 设置本地图像的顺时针旋转角度。 |
| [setRemoteViewRotation]| 设置远端图像的顺时针旋转角度。 |
| [setVideoEncoderRotation]| 设置视频编码输出的（也就是远端用户观看到的，以及服务器录制下来的）画面方向。 |
| [setLocalViewMirror] | 设置本地摄像头预览画面的镜像模式。 |
| [setVideoEncoderMirror]| 设置编码器输出的画面镜像模式。 |
| [enableSmallVideoStream]| 开启大小画面双路编码模式。 |
| [setRemoteVideoStreamType] | 选定观看指定 userId 的大画面还是小画面。 |
| [setPriorRemoteVideoStreamType] | 设定观看方优先选择的视频质量。 |


### 音频相关接口函数

| API | 描述 |
|-----|-----|
| [startLocalAudio] 开启本地音频的采集和上行。 |
| [stopLocalAudio]| 关闭本地音频的采集和上行。 |
| [muteLocalAudio] | 静音本地的音频。 |
| [muteRemoteAudio] | 静音掉某一个用户的声音。 |
| [muteAllRemoteAudio] | 静音掉所有用户的声音。 |
| [enableAudioVolumeEvaluation]| 启用或关闭音量大小提示。 |
| [startAudioRecording] | 开始录音。 |
| [stopAudioRecording] | 停止录音。 |


### 摄像头相关接口函数

| API | 描述 |
|-----|-----|
| [getCameraDevicesList]| 获取摄像头设备列表。 |
| [setCurrentCameraDevice]| 设置要使用的摄像头。 |
| [getCurrentCameraDevice]| 获取当前使用的摄像头。 |


### 音频设备相关接口函数

| API | 描述 |
|-----|-----|
| [getMicDevicesList] | 获取麦克风设备列表。 |
| [getCurrentMicDevice] | 获取当前选择的麦克风。 |
| [setCurrentMicDevice] | 设置要使用的麦克风。 |
| [getCurrentMicDeviceVolume] | 获取当前麦克风设备音量。 |
| [setCurrentMicDeviceVolume]| 设置麦克风设备的音量。 |
| [getSpeakerDevicesList]| 获取扬声器设备列表。 |
| [getCurrentSpeakerDevice]| 获取当前的扬声器设备。 |
| [setCurrentSpeakerDevice] | 设置要使用的扬声器。 |
| [getCurrentSpeakerVolume] | 当前扬声器设备音量。 |
| [setCurrentSpeakerVolume] | 设置当前扬声器音量。 |


### 美颜相关接口函数

| API | 描述 |
|-----|-----|
| [setBeautyStyle] | 设置美颜、美白、红润效果级别。 |
| [setWaterMark]| 设置水印。 |


### 辅流相关接口函数

| API | 描述 |
|-----|-----|
| [startRemoteSubStreamView]| 开始渲染远端用户辅流画面。 |
| [stopRemoteSubStreamView] | 停止显示远端用户的屏幕分享画面。 |
| [setRemoteSubStreamViewFillMode] | 设置辅流画面的渲染模式。 |
| [getScreenCaptureSources] | 枚举可共享的窗口列表，。 |
| [selectScreenCaptureTarget] | 设置屏幕共享参数，该方法在屏幕共享过程中也可以调用。 |
| [startScreenCapture] | 启动屏幕分享。 |
| [pauseScreenCapture] | 暂停屏幕分享。 |
| [resumeScreenCapture] | 恢复屏幕分享。 |
| [stopScreenCapture] | 停止屏幕采集。 |
| [setSubStreamEncoderParam] | 设置屏幕分享的编码器参数。 |
| [setSubStreamMixVolume] | 设置辅流的混音音量大小。 |


### 自定义消息发送

| API | 描述 |
|-----|-----|
| [sendCustomCmdMsg] | 发送自定义消息给房间内所有用户。 |
| [sendSEIMsg] | 将小数据量的自定义数据嵌入视频帧中。 |


### 背景混音相关接口函数

| API | 描述 |
|-----|-----|
| [playBGM] | 启动播放背景音乐。 |
| [stopBGM] | 停止播放背景音乐。 |
| [pauseBGM]| 暂停播放背景音乐。 |
| [resumeBGM] | 继续播放背景音乐。 |
| [getBGMDuration] | 获取音乐文件总时长，单位毫秒。 |
| [setBGMPosition] | 设置 BGM 播放进度。 |
| [setMicVolumeOnMixing] | 设置麦克风的音量大小，播放背景音乐混音时使用，用来控制麦克风音量大小。 |
| [setBGMVolume] | 设置背景音乐的音量大小，播放背景音乐混音时使用，用来控制背景音音量大小。 |
| [startSystemAudioLoopback] | 打开系统声音采集。 |
| [stopSystemAudioLoopback] | 关闭系统声音采集。 |
| [setSystemAudioLoopbackVolume] | 设置系统声音采集的音量。 |


### 设备和网络测试

| API | 描述 |
|-----|-----|
| [startSpeedTest]| 开始进行网络测速（视频通话期间请勿测试，以免影响通话质量）。 |
| [stopSpeedTest] | 停止服务器测速。 |
| [startCameraDeviceTest] | 开始进行摄像头测试。 |
| [stopCameraDeviceTest] | 停止摄像头测试。 |
| [startMicDeviceTest] | 开启麦克风测试。 |
| [stopMicDeviceTest] | 停止麦克风测试。 |
| [startSpeakerDeviceTest] | 开启扬声器测试。 |
| [stopSpeakerDeviceTest] | 停止扬声器测试。 |


### 混流转码以及 CDN 旁路推流

| API | 描述 |
|-----|-----|
| [setMixTranscodingConfig] | 启动(更新)云端的混流转码：通过腾讯云的转码服务，将房间里的多路画面叠加到一路画面上。 |
| [startPublishCDNStream] | 旁路转推到指定的推流地址。 |
| [stopPublishCDNStream]| 停止旁路推流。 |


### LOG 相关接口函数

| API | 描述 |
|-----|-----|
| [getSDKVersion]| 获取 SDK 版本信息。 |
| [setLogLevel]| 设置 Log 输出级别。 |
| [setConsoleEnabled]| 启用或禁用控制台日志打印。 |
| [setLogDirPath]| 设置日志保存路径。 |
| [callExperimentalAPI] | 调用实验性 API 接口。 |


## TRTCCloudCallback @ TXLiteAVSDK

腾讯云视频通话功能的回调接口类。

### 通用事件回调

| API | 描述 |
|-----|-----|
| [onError] | 错误回调：SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示。 |
| [onWarning] | 警告回调：用于告知您一些非严重性问题，例如出现了卡顿或者可恢复的解码失败。 |


### 房间事件回调

| API | 描述 |
|-----|-----|
| [onEnterRoom]| 已加入房间的回调。 |
| [onExitRoom] | 离开房间的事件回调。 |
| [onSwitchRole]| 切换角色的事件回调。 |
| [onConnectOtherRoom]| 请求跨房通话（主播 PK）的结果回调。 |
| [onDisconnectOtherRoom]| 结束跨房通话（主播 PK）的结果回调。 |


### 成员事件回调

| API | 描述 |
|-----|-----|
| [onUserEnter]| 有用户（主播）加入当前房间。 |
| [onUserExit]| 有用户（主播）离开当前房间。 |
| [onUserVideoAvailable] | 用户是否开启摄像头视频。 |
| [onUserSubStreamAvailable]| 用户是否开启屏幕分享。 |
| [onUserAudioAvailable]| 用户是否开启音频上行。 |
| [onFirstVideoFrame] | 开始渲染本地或远程用户的首帧画面。 |
| [onFirstAudioFrame] | 开始播放远程用户的首帧音频（本地声音暂不通知）。 |
| [onSendFirstLocalVideoFrame] | 首帧本地视频数据已经被送出。 |
| [onSendFirstLocalAudioFrame]| 首帧本地音频数据已经被送出。 |


### 统计和质量回调

| API | 描述 |
|-----|-----|
| [onNetworkQuality]| 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量。 |
| [onStatistics]| 技术指标统计回调。 |


### 服务器事件回调

| API | 描述 |
|-----|-----|
| [onConnectionLost] | SDK 跟服务器的连接断开。 |
| [onTryToReconnect] | SDK 尝试重新连接到服务器。 |
| [onConnectionRecovery]| SDK 跟服务器的连接恢复。 |
| [onSpeedTest] | 服务器测速的回调，SDK 对多个服务器 IP 做测速，每个 IP 的测速结果通过这个回调通知。 |


### 硬件设备事件回调

| API | 描述 |
|-----|-----|
| [onCameraDidReady]| 摄像头准备就绪。 |
| [onMicDidReady] | 麦克风准备就绪。 |
| [onUserVoiceVolume]| 用于提示音量大小的回调,包括每个 userId 的音量和远端总音量。 |
| [onDeviceChange] | 本地设备通断回调。 |
| [onTestMicVolume] | 麦克风测试音量回调。 |
| [onTestSpeakerVolume] | 扬声器测试音量回调。 |


### 自定义消息的接收回调

| API | 描述 |
|-----|-----|
| [onRecvCustomCmdMsg]| 收到自定义消息回调。 |
| [onMissCustomCmdMsg]| 自定义消息丢失回调。 |
| [onRecvSEIMsg]| 收到 SEI 消息的回调。 |


### CDN 旁路转推回调

| API | 描述 |
|-----|-----|
| [onStartPublishCDNStream] | 启动旁路推流到 CDN 完成的回调。 |
| [onStopPublishCDNStream]| 停止旁路推流到 CDN 完成的回调。 |
| [onSetMixTranscodingConfig]| 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口。 |


### 屏幕分享回调

| API | 描述 |
|-----|-----|
| [onScreenCaptureCovered]| 当屏幕分享窗口被遮挡无法正常捕获时，SDK 会通过此回调通知，可在此回调里通知用户移开遮挡窗口。 |
| [onScreenCaptureStarted] | 当屏幕分享开始时，SDK 会通过此回调通知。 |
| [onScreenCapturePaused]| 当屏幕分享暂停时，SDK 会通过此回调通知。 |
| [onScreenCaptureResumed]| 当屏幕分享恢复时，SDK 会通过此回调通知。 |
| [onScreenCaptureStoped]| 当屏幕分享停止时，SDK 会通过此回调通知。 |


### 背景混音事件回调

| API | 描述 |
|-----|-----|
| [onPlayBGMBegin] | 开始播放背景音乐。 |
| [onPlayBGMProgress]| 播放背景音乐的进度。 |
| [onPlayBGMComplete] | 播放背景音乐结束。 |


## 关键类型定义

| 类名 | 描述 |
|-----|-----|
| [TRTCParams]| 进房相关参数。 |
| [TRTCVideoEncParam] | 视频编码参数。 |
| [TRTCNetworkQosParam] | 网络流控相关参数。 |
| [TRTCQualityInfo]| 视频质量。 |
| [TRTCVolumeInfo] | 音量大小。 |
| [TRTCSpeedTestResult]| 网络测速结果。 |
| [TRTCMixUser]| 云端混流中每一路子画面的位置信息。 |
| [TRTCTranscodingConfig]| 云端混流（转码）配置。 |
| [TRTCPublishCDNParam]| CDN 旁路推流参数。 |
| [TRTCAudioRecordingParams]| 录音参数。 |
| [TRTCLocalStatistics]| 自己本地的音视频统计信息。 |
| [TRTCRemoteStatistics] | 远端成员的音视频统计信息。 |
| [TRTCStatistics]| 统计数据。 |

### 枚举值

| 枚举 | 描述 |
|-----|-----|
| [TRTCVideoResolution]| 视频分辨率。 |
| [TRTCVideoResolutionMode]| 视频分辨率模式。 |
| [TRTCVideoStreamType] | 视频流类型。 |
| [TRTCQuality]| 画质级别。 |
| [TRTCVideoFillMode]| 视频画面填充模式。 |
| [TRTCBeautyStyle] | 美颜（磨皮）算法。 |
| [TRTCAppScene]| 应用场景。 |
| [TRTCRoleType]| 角色，仅适用于直播场景（TRTCAppSceneLIVE）。 |
| [TRTCQosControlMode]| 流控模式。 |
| [TRTCVideoQosPreference]| 画质偏好。 |
| [TRTCDeviceState]| 设备操作。 |
| [TRTCDeviceType]| 设备类型。 |
| [TRTCWaterMarkSrcType]| 水印图片的源类型。 |
| [TRTCTranscodingConfigMode]| 混流参数配置模式。 |


