export const EVENT = {
  LOCAL_JOIN: 'LOCAL_JOIN', // 本地进房成功
  LOCAL_LEAVE: 'LOCAL_LEAVE', // 本地退房
  REMOTE_USER_JOIN: 'REMOTE_USER_JOIN', // 远端用户进房
  REMOTE_USER_LEAVE: 'REMOTE_USER_LEAVE', // 远端用户退房
  REMOTE_VIDEO_ADD: 'REMOTE_VIDEO_ADD', // 远端视频流添加事件，当远端用户取消发布音频流后会收到该通知
  REMOTE_VIDEO_REMOVE: 'REMOTE_VIDEO_REMOVE', // 远端视频流移出事件，当远端用户取消发布音频流后会收到该通知
  REMOTE_AUDIO_ADD: 'REMOTE_AUDIO_ADD', // 远端音频流添加事件，当远端用户取消发布音频流后会收到该通知
  REMOTE_AUDIO_REMOVE: 'REMOTE_AUDIO_REMOVE', // 远端音频流移除事件，当远端用户取消发布音频流后会收到该通知
  REMOTE_STATE_UPDATE: 'REMOTE_STATE_UPDATE', // 远端用户播放状态变更
  LOCAL_NET_STATE_UPDATE: 'LOCAL_NET_STATE_UPDATE', // 本地推流网络状态变更
  REMOTE_NET_STATE_UPDATE: 'REMOTE_NET_STATE_UPDATE', // 远端用户网络状态变更
  LOCAL_AUDIO_VOLUME_UPDATE: 'LOCAL_AUDIO_VOLUME_UPDATE', // 本地音量变更
  REMOTE_AUDIO_VOLUME_UPDATE: 'REMOTE_AUDIO_VOLUME_UPDATE', // 远端用户音量变更
  VIDEO_FULLSCREEN_UPDATE: 'VIDEO_FULLSCREEN_UPDATE', // 调用 player requestFullScreen 或者 exitFullScreen 后触发
  BGM_PLAY_START: 'BGM_PLAY_START', // 调用 LivePusherContext.playBGM(Object object)
  BGM_PLAY_FAIL: 'BGM_PLAY_FAIL', //
  BGM_PLAY_PROGRESS: 'BGM_PLAY_PROGRESS', // bgm 播放时间戳变更
  BGM_PLAY_COMPLETE: 'BGM_PLAY_COMPLETE', // bgm 播放结束 或者 调用 LivePusherContext.stopBGM() ?
  ERROR: 'ERROR', // pusher 出现错误
  IM_READY: 'IM_READY', // IM SDK 可用
  IM_MESSAGE_RECEIVED: 'IM_MESSAGE_RECEIVED', // 收到IM 消息
  IM_NOT_READY: 'IM_NOT_READY', // IM SDK 不可用
  IM_KICKED_OUT: 'IM_KICKED_OUT', // IM SDK 下线
  IM_ERROR: 'IM_ERROR', // IM SDK 下线
}

export const DEFAULT_PUSHER_CONFIG = {
  url: '',
  mode: 'RTC', // RTC：实时通话（trtc sdk） live：直播模式（liteav sdk）
  autopush: false, // 自动推送
  enableCamera: false, // 是否开启摄像头
  enableMic: false, // 是否开启麦克风
  enableAgc: false, // 是否开启音频自动增益
  enableAns: false, // 是否开启音频噪声抑制
  enableEarMonitor: false, // 是否开启耳返（目前只在iOS平台有效）
  enableAutoFocus: true, // 是否自动对焦
  enableZoom: false, // 是否支持调整焦距
  minBitrate: 600, // 最小码率
  maxBitrate: 900, // 最大码率
  videoWidth: 360, // 视频宽（若设置了视频宽高就会忽略aspect）
  videoHeight: 640, // 视频高（若设置了视频宽高就会忽略aspect）
  beautyLevel: 0, // 美颜，取值范围 0-9 ，0 表示关闭
  whitenessLevel: 0, // 美白，取值范围 0-9 ，0 表示关闭
  videoOrientation: 'vertical', // vertical horizontal
  videoAspect: '9:16', // 宽高比，可选值有 3:4,9:16
  frontCamera: 'front', // 前置或后置摄像头，可选值：front，back
  enableRemoteMirror: false, // 设置推流画面是否镜像，产生的效果会表现在 live-player
  localMirror: 'auto', // auto:前置摄像头镜像，后置摄像头不镜像（系统相机的表现）enable:前置摄像头和后置摄像头都镜像 disable: 前置摄像头和后置摄像头都不镜像
  enableBackgroundMute: false, // 进入后台时是否静音
  audioQuality: 'high', // 高音质(48KHz)或低音质(16KHz)，可选值：high，low
  audioVolumeType: 'voicecall', // 声音类型 可选值： media: 媒体音量，voicecall: 通话音量
  audioReverbType: 0, // 音频混响类型 0: 关闭 1: KTV 2: 小房间 3:大会堂 4:低沉 5:洪亮 6:金属声 7:磁性
  waitingImage: '', // 当微信切到后台时的垫片图片 trtc暂不支持
  waitingImageHash: '',
}

export const DEFAULT_PLAYER_CONFIG = {
  src: '',
  mode: 'RTC',
  autoplay: true, // 7.0.9 必须设置为true，否则 Android 有概率调用play()失败
  muteAudio: true, // 默认不拉取音频，需要手动订阅
  muteVideo: true, // 默认不拉取视频，需要手动订阅
  orientation: 'vertical', // 画面方向 vertical horizontal
  objectFit: 'fillCrop', // 填充模式，可选值有 contain，fillCrop
  enableBackgroundMute: false, // 进入后台时是否静音（已废弃，默认退台静音）
  minCache: 1, // 最小缓冲区，单位s（RTC 模式推荐 0.2s）
  maxCache: 2, // 最大缓冲区，单位s（RTC 模式推荐 0.8s）
  soundMode: 'speaker', // 声音输出方式 ear speaker
  enableRecvMessage: 'false', // 是否接收SEI消息
  autoPauseIfNavigate: true, // 当跳转到其它小程序页面时，是否自动暂停本页面的实时音视频播放
  autoPauseIfOpenNative: true, // 当跳转到其它微信原生页面时，是否自动暂停本页面的实时音视频播放
}
