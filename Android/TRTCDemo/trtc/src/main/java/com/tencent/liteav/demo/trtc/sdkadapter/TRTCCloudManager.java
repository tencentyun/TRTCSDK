package com.tencent.liteav.demo.trtc.sdkadapter;

import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;

import com.blankj.utilcode.util.ImageUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.AudioConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.MoreConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.PkConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.VideoConfig;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;

/**
 * 封装了 TRTCCloud 的基本功能，方便直接调用
 * 1. 通过 {@link IView} 接口和界面进行联系，如果您编写的界面需要监听sdk的一些变化，可以通过 {@link TRTCCloudManager#setViewListener} 设置 listener
 * 2. 很多设置参数通过 {@link ConfigHelper} 获取，您可以改变 {@link ConfigHelper} 中的每个设置选项来达到修改预设参数的目的
 *
 * @author guanyifeng
 */
public class TRTCCloudManager {
    public              String                  mTestRecordAACPath;
    private             Context                 mContext;
    private             TRTCCloud               mTRTCCloud;                 // SDK 核心类
    private             TRTCCloudDef.TRTCParams mTRTCParams;                // 进房参数
    private             int                     mAppScene;                  // 推流模式
    /**
     * 接收模式
     * 可以参考 {@link TRTCCloudManager#initTRTCManager(boolean, int)} 中对 mReceivedMode 中的操作
     * RECEIVED_MODE_AUTO  自动接收视频和音频
     * RECEIVED_MODE_AUDIO 自动接收音频，不自动接收视频
     * RECEIVED_MODE_VIDEO 自动接收视频，不自动接收音频
     * RECEIVED_MODE_MANUAL 音视频都需要手动调用
     * 详细的设置见 {@link TRTCCloud#setDefaultStreamRecvMode(boolean, boolean)}
     */
    public static final int                     RECEIVED_MODE_AUTO   = 0;
    public static final int                     RECEIVED_MODE_AUDIO  = 1;
    public static final int                     RECEIVED_MODE_VIDEO  = 2;
    public static final int                     RECEIVED_MODE_MANUAL = 3;

    // 是否用前置摄像头
    private boolean          mIsFontCamera = true;
    // 本地预览窗口
    private TXCloudVideoView mLocalPreviewView;
    private int              mMsgCmdIndex  = 0;

    /**
     * 美颜相关
     */
    private int mBeautyLevel    = 5;        // 美颜等级
    private int mWhiteningLevel = 3;        // 美白等级
    private int mRuddyLevel     = 2;        // 红润等级
    private int mBeautyStyle    = TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH;// 美颜风格

    /**
     * 界面回调相关
     */
    private IView mIView;

    /**
     * 音频相关
     */
    public int     mVolumeType          = 0;
    public boolean mIsAudioHandFreeMode = true;

    /**
     * @param context    上下文
     * @param trtcCloud  核心类
     * @param trtcParams 进房参数
     * @param appScene   推流模式 0-视频通话，1-在线直播
     */
    public TRTCCloudManager(Context context, TRTCCloud trtcCloud, TRTCCloudDef.TRTCParams trtcParams, int appScene) {
        mContext = context;
        mTRTCCloud = trtcCloud;
        mTRTCParams = trtcParams;
        mAppScene = appScene;

        mTestRecordAACPath = createFilePath();
    }

    private String createFilePath() {
        File sdcardDir = mContext.getExternalFilesDir(null);
        if (sdcardDir == null) {
            return null;
        }

        String dirPath = sdcardDir.getAbsolutePath() + "/test/record/";
        File   dir     = new File(dirPath);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        File file = new File(dir, "record.aac");

        file.delete();
        try {
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return file.getAbsolutePath();
    }

    public void destroy() {
        mTRTCCloud.setListener(null);
        // 需要将默认的PK参数重置
        ConfigHelper.getInstance().getPkConfig().reset();
    }

    public void setViewListener(IView IView) {
        mIView = IView;
    }

    public void setTRTCListener(TRTCCloudManagerListener trtcCloudListener) {
        mTRTCCloud.setListener(new TRTCCloudListenerImpl(trtcCloudListener));
    }

    public void setLocalPreviewView(TXCloudVideoView localPreviewView) {
        mLocalPreviewView = localPreviewView;
    }

    /**
     * 对进房的设置进行初始化
     *
     * @param isCustomCaptureAndRender 是否为自采集，开启该模式，SDK 只保留编码和发送能力
     */
    public void initTRTCManager(boolean isCustomCaptureAndRender, boolean isReceivedAudio, boolean isReceivedVideo) {
        AudioConfig audioConfig = ConfigHelper.getInstance().getAudioConfig();
        VideoConfig videoConfig = ConfigHelper.getInstance().getVideoConfig();


        // 是否为自采集，请在调用 SDK 相关配置前优先设置好，避免时序导致的异常问题。
        if (isCustomCaptureAndRender) {
            mTRTCCloud.enableCustomVideoCapture(isCustomCaptureAndRender);
            mTRTCCloud.enableCustomAudioCapture(isCustomCaptureAndRender);
        }

        // 对接收模式进行操作
        mTRTCCloud.setDefaultStreamRecvMode(isReceivedAudio, isReceivedVideo);

        // 设置美颜参数
        mTRTCCloud.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH, 5, 5, 5);

        // 设置视频渲染模式
        setVideoFillMode(videoConfig.isVideoFillMode());

        // 设置视频旋转角
        setLocalVideoRotation(videoConfig.getLocalRotation());

        // 是否开启免提
        //enableAudioHandFree(audioConfig.isAudioHandFreeMode());

        // 是否开启重力感应
        enableGSensor(videoConfig.isEnableGSensorMode());

        // 是否开启媒体音量
        //setSystemVolumeType(audioConfig.getAudioVolumeType());

        // 采样率设置
        enable16KSampleRate(audioConfig.isEnable16KSampleRate());

        // AGC设置
        enableAGC(audioConfig.isAGC());

        // ANS设置
        enableANS(audioConfig.isANS());

        // 是否开启推流画面镜像
        enableVideoEncMirror(videoConfig.isRemoteMirror());

        // 设置本地画面是否镜像预览
        setLocalViewMirror(videoConfig.getMirrorType());

        // 是否开启水印
        enableWatermark(videoConfig.isWatermark());

        // 【关键】设置 TRTC 推流参数
        setTRTCCloudParam();
    }

    public boolean isFontCamera() {
        return mIsFontCamera;
    }

    /**
     * TRTC进房
     */
    public void enterRoom() {
        enableAudioVolumeEvaluation(ConfigHelper.getInstance().getAudioConfig().isAudioVolumeEvaluation());
        mTRTCCloud.enterRoom(mTRTCParams, mAppScene);
    }

    /**
     * 设置 TRTC 推流参数
     */
    public void setTRTCCloudParam() {
        setBigSteam();
        setQosParam();
        setSmallSteam();
    }

    public void setBigSteam() {
        // 大画面的编码器参数设置
        // 设置视频编码参数，包括分辨率、帧率、码率等等，这些编码参数来自于 videoConfig 的设置
        // 注意（1）：不要在码率很低的情况下设置很高的分辨率，会出现较大的马赛克
        // 注意（2）：不要设置超过25FPS以上的帧率，因为电影才使用24FPS，我们一般推荐15FPS，这样能将更多的码率分配给画质
        VideoConfig                    videoConfig = ConfigHelper.getInstance().getVideoConfig();
        TRTCCloudDef.TRTCVideoEncParam encParam    = new TRTCCloudDef.TRTCVideoEncParam();
        encParam.videoResolution = videoConfig.getVideoResolution();
        encParam.videoFps = videoConfig.getVideoFps();
        encParam.videoBitrate = videoConfig.getVideoBitrate();
        encParam.videoResolutionMode = videoConfig.isVideoVertical() ? TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT : TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_LANDSCAPE;
        if (mAppScene == TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL) {
            encParam.enableAdjustRes = true;
        }
        mTRTCCloud.setVideoEncoderParam(encParam);
    }

    public void setQosParam() {
        VideoConfig                      videoConfig = ConfigHelper.getInstance().getVideoConfig();
        TRTCCloudDef.TRTCNetworkQosParam qosParam    = new TRTCCloudDef.TRTCNetworkQosParam();
        qosParam.controlMode = videoConfig.getQosMode();
        qosParam.preference = videoConfig.getQosPreference();
        mTRTCCloud.setNetworkQosParam(qosParam);
    }

    public void setSmallSteam() {
        //小画面的编码器参数设置
        //TRTC SDK 支持大小两路画面的同时编码和传输，这样网速不理想的用户可以选择观看小画面
        //注意：iPhone & Android 不要开启大小双路画面，非常浪费流量，大小路画面适合 Windows 和 MAC 这样的有线网络环境
        VideoConfig videoConfig = ConfigHelper.getInstance().getVideoConfig();

        TRTCCloudDef.TRTCVideoEncParam smallParam = new TRTCCloudDef.TRTCVideoEncParam();
        smallParam.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_160_90;
        smallParam.videoFps = videoConfig.getVideoFps();
        smallParam.videoBitrate = 100;
        smallParam.videoResolutionMode = videoConfig.isVideoVertical() ? TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT : TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_LANDSCAPE;

        mTRTCCloud.enableEncSmallVideoStream(videoConfig.isEnableSmall(), smallParam);
        mTRTCCloud.setPriorRemoteVideoStreamType(videoConfig.isPriorSmall() ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }

    /**
     * 退房
     */
    public void exitRoom() {
        if (mTRTCCloud != null) {
            mTRTCCloud.exitRoom();
        }
    }

    /**
     * 系统音量类型
     *
     * @param type {@link TRTCCloudDef#TRTCSystemVolumeTypeAuto}
     */
    public void setSystemVolumeType(int type) {
        mTRTCCloud.setSystemVolumeType(type);
        mVolumeType = type;
    }

    /**
     * 设置本地渲染模式：全屏铺满\自适应
     *
     * @param bFillMode
     */
    public void setVideoFillMode(boolean bFillMode) {
        if (bFillMode) {
            // 全屏铺满模式
            mTRTCCloud.setLocalViewFillMode(TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL);
        } else {
            // 自适应模式
            mTRTCCloud.setLocalViewFillMode(TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
        }
    }

    /**
     * 设置旋转角
     */
    public void setLocalVideoRotation(int rotation) {
        mTRTCCloud.setLocalViewRotation(rotation);
    }

    /**
     * 是否开启免提
     *
     * @param bEnable
     */
    public void enableAudioHandFree(boolean bEnable) {
        if (bEnable) {
            // 扬声器
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        } else {
            // 听筒
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
        }
        mIsAudioHandFreeMode = bEnable;
    }

    /**
     * 是否开启画面镜像推流
     * 开启后，画面将会进行左右镜像，推到远端
     *
     * @param bMirror
     */
    public void enableVideoEncMirror(boolean bMirror) {
        mTRTCCloud.setVideoEncoderMirror(bMirror);
    }


    /**
     * 是否开启本地画面镜像
     */
    public void setLocalViewMirror(int mode) {
        mTRTCCloud.setLocalViewMirror(mode);
    }

    /**
     * 是否开启重力该应
     *
     * @param bEnable
     */
    public void enableGSensor(boolean bEnable) {
        if (bEnable) {
            mTRTCCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_UIFIXLAYOUT);
        } else {
            mTRTCCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_DISABLE);
        }
    }

    /**
     * 是否开启音量回调
     *
     * @param bEnable
     */
    public void enableAudioVolumeEvaluation(boolean bEnable) {
        if (bEnable) {
            mTRTCCloud.enableAudioVolumeEvaluation(300);
        } else {
            mTRTCCloud.enableAudioVolumeEvaluation(0);
        }
        if (mIView != null) {
            mIView.onAudioVolumeEvaluationChange(bEnable);
        }
    }

    /**
     * 开始本地预览
     */
    public void startLocalPreview() {
        if (mLocalPreviewView == null) {
            ToastUtils.showLong("无法找到一个空闲的 View 进行预览，本地预览失败。");
        }
        mTRTCCloud.startLocalPreview(mIsFontCamera, mLocalPreviewView);
    }

    public void switchCamera() {
        mIsFontCamera = !mIsFontCamera;
        mTRTCCloud.switchCamera();
    }

    /**
     * 打开自定义声音采集
     *
     * @param bEnable
     */
    public void enableCustomAudioCapture(boolean bEnable) {
        if (bEnable) {
            mTRTCCloud.startLocalAudio();
        } else {
            mTRTCCloud.stopLocalAudio();
        }
    }

    public void muteInSpeaderAudio(String userId, boolean isMute) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "muteRemoteAudioInSpeaker");
            JSONObject params = new JSONObject();
            params.put("userID", userId);
            params.put("mute", isMute ? 1 : 0);
            jsonObject.put("params", params);
            mTRTCCloud.callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 声音采样率
     *
     * @param enable true 开启16k采样率 false 开启48k采样率
     */
    public void enable16KSampleRate(boolean enable) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "setAudioSampleRate");
            JSONObject params = new JSONObject();
            params.put("sampleRate", enable ? 16000 : 48000);
            jsonObject.put("params", params);
            mTRTCCloud.callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 是否开启自动增益补偿功能, 可以自动调麦克风的收音量到一定的音量水平
     *
     * @param enable
     */
    public void enableAGC(boolean enable) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "enableAudioAGC");
            JSONObject params = new JSONObject();
            params.put("enable", enable ? 1 : 0);
            jsonObject.put("params", params);
            mTRTCCloud.callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 回声消除器，可以消除各种延迟的回声
     *
     * @param enable
     */
    public void enableAEC(boolean enable) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "enableAudioAEC");
            JSONObject params = new JSONObject();
            params.put("enable", enable ? 1 : 0);
            jsonObject.put("params", params);
            mTRTCCloud.callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 背景噪音抑制功能，可探测出背景固定频率的杂音并消除背景噪音
     *
     * @param enable
     */
    public void enableANS(boolean enable) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "enableAudioANS");
            JSONObject params = new JSONObject();
            params.put("enable", enable ? 1 : 0);
            jsonObject.put("params", params);
            mTRTCCloud.callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 切换角色，用在直播的场景
     *
     * @return 切换后的角色
     */
    public int switchRole() {
        // 目标的切换角色
        int targetRole = mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor ? TRTCCloudDef.TRTCRoleAudience : TRTCCloudDef.TRTCRoleAnchor;
        if (mTRTCCloud != null) {
            mTRTCCloud.switchRole(targetRole);
        }
        mTRTCParams.role = targetRole;
        return mTRTCParams.role;
    }

    /**
     * 启动麦克风采集，并将音频数据传输给房间里的其他用户
     */
    public void startLocalAudio() {
        mTRTCCloud.startLocalAudio();
    }

    /**
     * 关闭麦克风采集，其他用户会受到 onUserAudioAvailable(false)
     */
    public void stopLocalAudio() {
        mTRTCCloud.stopLocalAudio();
    }

    /**
     * 停止本地视频采集及预览
     */
    public void stopLocalPreview() {
        mTRTCCloud.stopLocalPreview();
    }

    /**
     * 函数会停止向其他用户发送视频数据
     * 当屏蔽本地视频后，房间里的其它成员将会收到 onUserVideoAvailable 回调通知
     *
     * @param mute true 屏蔽本地视频  false 开启本地视频
     */
    public void muteLocalVideo(boolean mute) {
        mTRTCCloud.muteLocalVideo(mute);
        if (mIView != null) {
            mIView.onMuteLocalVideo(mute);
        }
    }

    /**
     * 见 {@link TRTCCloud#muteLocalAudio(boolean)}
     *
     * @param mute
     */
    public void muteLocalAudio(boolean mute) {
        mTRTCCloud.muteLocalAudio(mute);
    }

    /**
     * 开始跨房连麦
     *
     * @param roomId   房间id
     * @param username 用户id
     */
    public void startLinkMic(String roomId, String username) {
        PkConfig pkConfig = ConfigHelper.getInstance().getPkConfig();
        pkConfig.setConnectRoomId(roomId);
        pkConfig.setConnectUserName(username);
        // 根据userId，以及roomid 发起跨房连接
        mTRTCCloud.ConnectOtherRoom(String.format("{\"roomId\":%s,\"userId\":\"%s\"}", roomId, username));
        if (mIView != null) {
            mIView.onStartLinkMic();
        }
    }

    /**
     * 停止连麦
     */
    public void stopLinkMic() {
        mTRTCCloud.DisconnectOtherRoom();
    }

    /**
     * 开启耳返
     *
     * @param enable
     */
    public void enableEarMonitoring(boolean enable) {
        mTRTCCloud.enableAudioEarMonitoring(enable);
    }

    /**
     * 是否展示debug信息在界面中
     *
     * @param logLevel
     */
    public void showDebugView(int logLevel) {
        mTRTCCloud.showDebugView(logLevel);
    }

    /**
     * 开/关 闪光灯，根据 {@link MoreConfig#isEnableFlash } 的状态来操作
     *
     * @return true 成功打开或者关闭 false 打开或者关闭失败
     */
    public boolean openFlashlight() {
        MoreConfig config     = ConfigHelper.getInstance().getMoreConfig();
        boolean    openStatus = mTRTCCloud.enableTorch(!config.isEnableFlash());
        if (openStatus) {
            config.setEnableFlash(!config.isEnableFlash());
        }
        return openStatus;
    }

    /**
     * 打开水印，这里默认打开 R.drawable.watermark 这个文件
     * 如果您需要打开其他的水印，可以参考 {@link TRTCCloud#setWatermark(android.graphics.Bitmap, int, float, float, float)}
     *
     * @param watermark 是否打开水印
     */
    public void enableWatermark(boolean watermark) {
        if (watermark) {
            Bitmap bitmap = ImageUtils.getBitmap(R.drawable.watermark);
            mTRTCCloud.setWatermark(bitmap, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, 0.1f, 0.1f, 0.2f);
        } else {
            mTRTCCloud.setWatermark(null, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, 0.1f, 0.1f, 0.2f);
        }
    }

    /**
     * 开始录音，默认保存到 /app私有目录/test/record/record.aac 中
     * 您可以参考 {@link TRTCCloud#startAudioRecording(com.tencent.trtc.TRTCCloudDef.TRTCAudioRecordingParams)} 保存到其他文件中
     *
     * @return
     */
    public boolean startRecord() {
        AudioConfig                           audioConfig = ConfigHelper.getInstance().getAudioConfig();
        TRTCCloudDef.TRTCAudioRecordingParams params      = new TRTCCloudDef.TRTCAudioRecordingParams();
        params.filePath = mTestRecordAACPath;

        if (TextUtils.isEmpty(params.filePath)) {
            return false;
        }
        int res = mTRTCCloud.startAudioRecording(params);
        if (res == 0) {
            audioConfig.setRecording(true);
            ToastUtils.showLong("开始录制" + mTestRecordAACPath);
            return true;
        } else if (res == -1) {
            audioConfig.setRecording(true);
            ToastUtils.showLong("正在录制中");
            return true;
        } else {
            audioConfig.setRecording(false);
            ToastUtils.showLong("录制失败");
            return false;
        }
    }

    /**
     * 停止录音
     */
    public void stopRecord() {
        AudioConfig audioConfig = ConfigHelper.getInstance().getAudioConfig();
        audioConfig.setRecording(false);
        mTRTCCloud.stopAudioRecording();
        ToastUtils.showLong("录制成功，文件保存在" + mTestRecordAACPath);
    }

    /**
     * 截取本地预览画面
     */
    public void snapshotLocalView() {
        AudioConfig audioConfig = ConfigHelper.getInstance().getAudioConfig();
        audioConfig.setRecording(false);
        mTRTCCloud.snapshotVideo(null, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, new TRTCCloudListener.TRTCSnapshotListener() {
            @Override
            public void onSnapshotComplete(Bitmap bmp) {
                if (bmp == null) {
                    ToastUtils.showLong("截图失败");
                } else {
                    if (mIView != null) {
                        mIView.onSnapshotLocalView(bmp);
                    }
                }
            }
        });

    }

    /**
     * 发送自定义消息，见 {@link TRTCCloud#sendCustomCmdMsg }
     *
     * @param msg
     */
    public void sendCustomMsg(String msg) {
        int     index      = mMsgCmdIndex % 10 + 1;
        boolean sendStatus = mTRTCCloud.sendCustomCmdMsg(index, msg.getBytes(), true, true);
        if (sendStatus) {
            ToastUtils.showLong("发送自定义消息成功");
            mMsgCmdIndex++;
        }
    }

    /**
     * 发送sei消息，见 {@link TRTCCloud#sendSEIMsg }
     *
     * @param msg
     */
    public void sendSEIMsg(String msg) {
        mTRTCCloud.sendSEIMsg(msg.getBytes(), 1);
    }

    public void setLocalVideoRenderListener(TRTCCloudListener.TRTCVideoRenderListener listener) {
        // 设置 TRTC SDK 的状态为本地自定义渲染，视频格式为纹理
        mTRTCCloud.setLocalVideoRenderListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, listener);
    }

    public void setRecordVolume(int volume) {
        mTRTCCloud.setAudioCaptureVolume(volume);
    }

    public void setPlayoutVolume(int volume) {
        mTRTCCloud.setAudioPlayoutVolume(volume);
    }

    public void startPublishing() {
        VideoConfig videoConfig  = ConfigHelper.getInstance().getVideoConfig();
        String      customLiveId = videoConfig.getCustomLiveId();
        if (!TextUtils.isEmpty(customLiveId)) {
            mTRTCCloud.startPublishing(customLiveId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        }
    }

    public void stopPublishing() {
        mTRTCCloud.stopPublishing();
    }

    public String getDefaultPlayUrl() {
        String streamId = mTRTCParams.sdkAppId + "_" + mTRTCParams.roomId + "_" + mTRTCParams.userId + "_main";
        try {
            streamId = URLEncoder.encode(streamId, "utf-8");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return streamId;
    }

    /**
     * 可能会与界面相关的回调
     */
    public interface IView {
        /**
         * 是否开启音量提示条，界面可以显示/隐藏音量提示条
         *
         * @param enable
         */
        void onAudioVolumeEvaluationChange(boolean enable);

        /**
         * 开始连麦回调，界面可以展示loading状态
         */
        void onStartLinkMic();

        /**
         * 屏蔽本地视频回调，界面可以更新对应按钮状态
         *
         * @param isMute
         */
        void onMuteLocalVideo(boolean isMute);

        /**
         * 屏蔽本地音频回调，界面可以更新对应按钮状态
         *
         * @param isMute
         */
        void onMuteLocalAudio(boolean isMute);

        /**
         * 视频截图回调
         *
         * @param bmp
         */
        void onSnapshotLocalView(Bitmap bmp);
    }
}
