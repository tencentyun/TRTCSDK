package com.tencent.liteav.meeting.ui.widget.feature;

import com.tencent.trtc.TRTCCloudDef;

/**
 * 用于展示设置界面的数据
 */
public class FeatureConfig {
    public static final String AUDIO_EVALUATION_CHANGED = "AUDIO_EVALUATION_CHANGED";
    final static int DEFAULT_BITRATE = 800;
    final static int DEFAULT_FPS     = 15;

    //    private final static String  PER_DATA            = "per_feature_data";
    //    private final static String  PER_DATA_PARAM      = "per_feature_param";
    //    private final static String  PER_SAVE_FLAG       = "per_save_flag";

    // 分辨率
    private           int     mVideoResolution       = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
    // 帧率
    private           int     mVideoFps              = DEFAULT_FPS;
    // 码率
    private           int     mVideoBitrate          = DEFAULT_BITRATE;
    // 是否本地镜像
    private           boolean mIsMirror              = true;
    // 采集音量
    private           int     mMicVolume             = 100;
    // 播放音量
    private           int     mPlayoutVolume         = 100;
    // 是否打开音量提示
    private           boolean mAudioVolumeEvaluation = true;
    // 录音状态， true 正在录音 false 结束录音
    private transient boolean mRecording             = false;
    // 需要分享出去的 url
    private           String  mPlayUrl;

    public static FeatureConfig getInstance() {
        return SingletonHolder.instance;
    }

    public int getVideoResolution() {
        return mVideoResolution;
    }

    public void setVideoResolution(int videoResolution) {
        mVideoResolution = videoResolution;
    }

    public int getVideoFps() {
        return mVideoFps;
    }

    public void setVideoFps(int videoFps) {
        mVideoFps = videoFps;
    }

    public int getVideoBitrate() {
        return mVideoBitrate;
    }

    public void setVideoBitrate(int videoBitrate) {
        mVideoBitrate = videoBitrate;
    }

    public boolean isMirror() {
        return mIsMirror;
    }

    public void setMirror(boolean mirror) {
        mIsMirror = mirror;
    }

    public int getMicVolume() {
        return mMicVolume;
    }

    public void setMicVolume(int micVolume) {
        mMicVolume = micVolume;
    }

    public int getPlayoutVolume() {
        return mPlayoutVolume;
    }

    public void setPlayoutVolume(int playoutVolume) {
        mPlayoutVolume = playoutVolume;
    }

    public boolean isAudioVolumeEvaluation() {
        return mAudioVolumeEvaluation;
    }

    public void setAudioVolumeEvaluation(boolean audioVolumeEvaluation) {
        mAudioVolumeEvaluation = audioVolumeEvaluation;
    }

    public boolean isRecording() {
        return mRecording;
    }

    public void setRecording(boolean recording) {
        mRecording = recording;
    }

    public String getPlayUrl() {
        return mPlayUrl;
    }

    public void setPlayUrl(String playUrl) {
        mPlayUrl = playUrl;
    }

    private static class SingletonHolder {
        /**
         * 由JVM来保证线程安全
         */
        private static FeatureConfig instance = new FeatureConfig();
    }
}
