package com.tencent.liteav.meeting.model;

import android.content.Context;
import android.os.Handler;

import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.meeting.model.impl.TRTCMeetingImpl;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloudDef;

public abstract class TRTCMeeting {
    public static final String CDN_DOMAIN = "http://3891.liveplay.myqcloud.com/live";

    /**
     * 获取 TRTCMeeting 单例对象
     *
     * @param context Android 上下文，内部会转为 ApplicationContext 用于系统 API 调用
     * @return TRTCMeeting 实例
     * @note 可以调用 {@link TRTCMeeting#destroySharedInstance()} 销毁单例对象
     */
    public static synchronized TRTCMeeting sharedInstance(Context context) {
        return TRTCMeetingImpl.sharedInstance(context);
    }

    /**
     * 销毁 TRTCMeeting 单例对象
     *
     * @note 销毁实例后，外部缓存的 TRTCMeeting 实例不能再使用，需要重新调用 {@link TRTCMeeting#sharedInstance(Context)} 获取新实例
     */
    public static void destroySharedInstance() {
        TRTCMeetingImpl.destroySharedInstance();
    }

    //////////////////////////////////////////////////////////
    //
    //                 基础接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 设置组件回调接口
     * <p>
     * 您可以通过 TRTCMeeting 获得 TRTCMeeting 的各种状态通知
     *
     * @param delegate 回调接口
     * @note TRTCMeeting 中的事件，默认是在 Main Thread 中回调给您；如果您需要指定事件回调所在的线程，可使用 {@link TRTCMeeting#setDelegateHandler(Handler)}
     */
    public abstract void setDelegate(TRTCMeetingDelegate delegate);

    /**
     * 设置事件回调所在的线程
     *
     * @param handler 线程，TRTCMeeting 中的各种状态通知回调会通过该 handler 通知给您，注意不要跟 setDelegate 进行混用。
     */
    public abstract void setDelegateHandler(Handler handler);

    /**
     * 登录
     *
     * @param sdkAppId 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
     * @param userId 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
     * @param userSig 腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。
     * @param callback 登录回调，成功时 code 为0
     */
    public abstract void login(int sdkAppId, String userId, String userSig, TRTCMeetingCallback.ActionCallback callback);

    /**
     * 退出登录
     */
    public abstract void logout(TRTCMeetingCallback.ActionCallback callback);

    /**
     * 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
     *
     * @param userName 用户昵称
     * @param avatarURL 用户头像
     * @param callback 是否设置成功的结果回调
     */
    public abstract void setSelfProfile(String userName, String avatarURL, TRTCMeetingCallback.ActionCallback callback);

    /**
     * 创建会议（房主调用）
     *
     * @param roomId 房间标识，需要由您分配并进行统一管理。
     * @param callback 创建房间的结果回调，成功时 code 为0.
     */
    public abstract void createMeeting(int roomId, TRTCMeetingCallback.ActionCallback callback);

    /**
     * 销毁会议（房主调用）
     *
     * 房主在创建会议房间后，可以调用这个函数来销毁房间。
     * @param roomId 房间标识，需要由您分配并进行统一管理。
     * @param callback 创建房间的结果回调，成功时 code 为0.
     */
    public abstract void destroyMeeting(int roomId, TRTCMeetingCallback.ActionCallback callback);

    /**
     * 进入会议（其他参会者调用）
     *
     * @param roomId 房间标识，需要由您分配并进行统一管理。
     * @param callback 结果回调，成功时 code 为0.
     */
    public abstract void enterMeeting(int roomId, TRTCMeetingCallback.ActionCallback callback);

    /**
     * 离开会议（其他参会者调用）
     *
     * @param callback 结果回调，成功时 code 为0.
     */
    public abstract void leaveMeeting(TRTCMeetingCallback.ActionCallback callback);


    //////////////////////////////////////////////////////////
    //
    //                 远端用户接口
    //
    //////////////////////////////////////////////////////////
    /**
     * 获取房间内所有的人员列表，enterMeeting() 成功后调用才有效。
     * @param userListCallback 用户详细信息回调
     */
    public abstract void getUserInfoList(TRTCMeetingCallback.UserListCallback userListCallback);

    /**
     * 获取房间内指定人员的详细信息，enterMeeting() 成功后调用才有效。
     * @param userListCallback 用户详细信息回调
     */
    public abstract void getUserInfo(String userId, TRTCMeetingCallback.UserListCallback userListCallback);

    /**
     * 播放远端视频画面
     *
     * @param userId 需要观看的用户id
     * @param view 承载视频画面的 view 控件
     * @param callback 操作回调
     *
     * @note 在 onUserVideoAvailable 为 true 回调时，调用这个接口
     */
    public abstract void startRemoteView(String userId, TXCloudVideoView view, final TRTCMeetingCallback.ActionCallback callback);

    /**
     * 停止播放远端视频画面
     *
     * @param userId 对方的用户信息
     * @param callback 操作回调
     *
     * @note 在 onUserVideoAvailable 为 false 回调时，调用这个接口
     */
    public abstract void stopRemoteView(String userId, final TRTCMeetingCallback.ActionCallback callback);

    /**
     * 根据用户id和设置远端图像的渲染模式
     *
     * @param userId     用户id
     * @param fillMode   TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL
     *                   填充（画面可能会被拉伸裁剪）
     *                   TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT
     *                   适应（画面可能会有黑边）
     */
    public abstract void setRemoteViewFillMode(String userId, int fillMode);

    /**
     * 设置远端图像的顺时针旋转角度
     * @param userId 用户id
     * @param rotation
     */
    public abstract void setRemoteViewRotation(String userId, int rotation);

    /**
     * 静音某一个用户的声音
     *
     * @param userId 用户id
     * @param mute true:静音 false：解除静音
     */
    public abstract void muteRemoteAudio(String userId, boolean mute);

    /**
     * 屏蔽某个远程用户的视频
     *
     * @param userId 用户id
     * @param mute true:屏蔽 false：解除屏蔽
     */
    public abstract void muteRemoteVideoStream(String userId, boolean mute);

    //////////////////////////////////////////////////////////
    //
    //                 本地视频操作接口
    //
    //////////////////////////////////////////////////////////
    /**
     * 开启本地视频的预览画面
     *
     * @param isFront true：前置摄像头；false：后置摄像头。
     * @param view 承载视频画面的控件
     */
    public abstract void startCameraPreview(boolean isFront, TXCloudVideoView view);

    /**
     * 停止本地视频采集及预览
     */
    public abstract void stopCameraPreview();

    /**
     * 切换前后摄像头
     * @param isFront true：前置摄像头；false：后置摄像头。
     */
    public abstract void switchCamera(boolean isFront);

    /**
     * 设置分辨率
     *
     * @param resolution 详细设置见 TRTCCloudDef.TRTC_VIDEO_RESOLUTION_xx
     */
    public abstract void setVideoResolution(int resolution);

    /**
     * 设置帧率
     *
     * @param fps
     */
    public abstract void setVideoFps(int fps);

    /**
     * 设置码率
     *
     * @param bitrate 码率
     */
    public abstract void setVideoBitrate(int bitrate);

    /**
     * 设置本地画面镜像预览模式
     * @param type 见 TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO / TRTC_VIDEO_MIRROR_TYPE_ENABLE / TRTC_VIDEO_MIRROR_TYPE_DISABLE
     */
    public abstract void setLocalViewMirror(int type);

    /**
     * 设置网络qos参数
     * @param qosParam
     */
    public abstract void setNetworkQosParam(TRTCCloudDef.TRTCNetworkQosParam qosParam);

    //////////////////////////////////////////////////////////
    //
    //                 本地音频操作接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 开启麦克风采集
     */
    public abstract void startMicrophone();

    /**
     * 停止麦克风采集
     */
    public abstract void stopMicrophone();

    /**
     * 设置音质
     * @param quality TRTC_AUDIO_QUALITY_MUSIC/TRTC_AUDIO_QUALITY_DEFAULT/TRTC_AUDIO_QUALITY_SPEECH
     */
    public abstract void setAudioQuality(int quality);

    /**
     * 开启本地静音
     * @param mute 是否静音
     */
    public abstract void muteLocalAudio(boolean mute);

    /**
     * 设置开启扬声器
     * @param useSpeaker true:扬声器 false:听筒
     */
    public abstract void setSpeaker(boolean useSpeaker);

    /**
     * 设置麦克风采集音量
     * @param volume 采集音量 0-100
     */
    public abstract void setAudioCaptureVolume(int volume);

    /**
     * 设置播放音量
     * @param volume 播放音量 0-100
     */
    public abstract void setAudioPlayoutVolume(int volume);

    /**
     * 开始录音
     *
     * 该方法调用后， SDK 会将通话过程中的所有音频（包括本地音频，远端音频，BGM 等）录制到一个文件里。
     * 无论是否进房，调用该接口都生效。
     * 如果调用 exitMeeting 时还在录音，录音会自动停止。
     * @param trtcAudioRecordingParams
     */
    public abstract void startFileDumping(TRTCCloudDef.TRTCAudioRecordingParams trtcAudioRecordingParams);

    /**
     * 停止录音
     *
     * 如果调用 exitMeeting 时还在录音，录音会自动停止。
     */
    public abstract void stopFileDumping();

    /**
     * 启用音量大小提示
     *
     * 开启后会在 onUserVolumeUpdate 中获取到 SDK 对音量大小值的评估。
     * @param enable true 打开 false 关闭
     */
    public abstract void enableAudioEvaluation(boolean enable);

    //////////////////////////////////////////////////////////
    //
    //                 美颜接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 获取美颜管理对象
     *
     * 通过美颜管理，您可以使用以下功能：
     * - 设置”美颜风格”、”美白”、“红润”、“大眼”、“瘦脸”、“V脸”、“下巴”、“短脸”、“瘦鼻”、“亮眼”、“白牙”、“祛眼袋”、“祛皱纹”、“祛法令纹”等美容效果。
     * - 调整“发际线”、“眼间距”、“眼角”、“嘴形”、“鼻翼”、“鼻子位置”、“嘴唇厚度”、“脸型”
     * - 设置人脸挂件（素材）等动态效果
     * - 添加美妆
     * - 进行手势识别
     * @return
     */
    public abstract TXBeautyManager getBeautyManager();

    //////////////////////////////////////////////////////////
    //
    //                 录屏接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 启动屏幕分享
     *
     * Android 手机的屏幕分享的推荐配置参数：
     * - 分辨率(videoResolution)：1280 x 720
     * - 帧率(videoFps)：10 FPS
     * - 码率(videoBitrate)：1200 kbps
     * - 分辨率自适应(enableAdjustRes)：false
     *
     * @param encParams 设置屏幕分享时的编码参数，推荐采用上述推荐配置，如果您指定 encParams 为 null，则使用您调用 startScreenCapture 之前的编码参数设置。
     * @param screenShareParams 设置屏幕分享的特殊配置，其中推荐设置 floatingView，一方面可以避免 App 被系统强杀；另一方面也能助于保护用户隐私。
     */
    public abstract void startScreenCapture(TRTCCloudDef.TRTCVideoEncParam encParams, TRTCCloudDef.TRTCScreenShareParams screenShareParams);

    /**
     * 停止屏幕采集
     */
    public abstract void stopScreenCapture();

    /**
     * 暂停屏幕分享
     */
    public abstract void pauseScreenCapture();

    /**
     * 恢复屏幕分享
     */
    public abstract void resumeScreenCapture();

    //////////////////////////////////////////////////////////
    //
    //                 分享接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 获取cdn分享链接
     * @return 返回CDN分享链接
     */
    public abstract String getLiveBroadcastingURL();


    //////////////////////////////////////////////////////////
    //
    //                 发送消息接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 在房间中广播文本消息，一般用于文本聊天
     * @param message 文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomTextMsg(String message, TRTCMeetingCallback.ActionCallback callback);

    /**
     * 在房间中广播自定义（信令）消息，一般用于广播点赞和礼物消息
     *
     * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
     * @param message 文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomCustomMsg(String cmd, String message, TRTCMeetingCallback.ActionCallback callback);

}