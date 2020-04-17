package com.tencent.liteav.demo.trtc.sdkadapter.feature;

import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.SPUtils;
import com.tencent.trtc.TRTCCloudDef;

import java.io.Serializable;

import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO;

/**
 * 视频设置项，通过json的形式保存到本地，在初始化时取出
 *
 * @author guanyifeng
 */
public class VideoConfig implements Serializable {
    final static         int     DEFAULT_BITRATE     = 600;
    final static         int     DEFAULT_FPS         = 15;
    private final static String  PER_DATA            = "per_video_data";
    private final static String  PER_DATA_PARAM      = "per_video_param";
    private final static String  PER_SAVE_FLAG       = "per_save_flag";
    // 分辨率
    private              int     mVideoResolution    = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
    // 帧率
    private              int     mVideoFps           = DEFAULT_FPS;
    // 码率
    private              int     mVideoBitrate       = DEFAULT_BITRATE;
    // 流控模式：默认云端流控
    private              int     mQosMode            = TRTCCloudDef.VIDEO_QOS_CONTROL_SERVER;
    // 画质偏好
    private              int     mQosPreference      = TRTCCloudDef.TRTC_VIDEO_QOS_PREFERENCE_CLEAR;
    // 竖屏模式，true为竖屏
    private              boolean mVideoVertical      = true;
    // 画面填充方向是否为充满， true为充满
    private              boolean mVideoFillMode      = false;
    // 画面预览镜像类型
    private              int     mMirrorType         = TRTC_VIDEO_MIRROR_TYPE_AUTO;
    // 是否打开视频采集
    private              boolean mEnableVideo        = true;
    // 是否推送视频
    private              boolean mPublishVideo       = true;
    // 远端镜像
    private              boolean mRemoteMirror       = false;
    // 是否开启水印
    private              boolean mWatermark          = false;
    // 双路编码:是否开启小流
    private              boolean mEnableSmall        = false;
    // 是否开启默认小流
    private              boolean mPriorSmall         = false;
    // 重力感应
    private              boolean mEnableGSensorMode  = false;
    // 云端混流模式
    private              int mCloudMixtureMode      = TRTCCloudDef.TRTC_TranscodingConfigMode_Manual;
    // 本地视频旋转角
    private              int     mLocalRotation      = TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
    // 自定义流Id
    private              String  mCustomLiveId;
    // 当前是否处于混流状态
    private transient    boolean mCurIsMix           = false;
    // 是否已经暂停屏幕采集
    private              boolean mIsScreenCapturePaused = false;

    /**
     * 是否默认保存到本地，第二次启动的时候，会自动从本地加载
     * transient 表示这个参数不会序列化
     */
    private transient boolean mSaveFlag = true;

    public VideoConfig() {
        //loadCache();
    }

    public boolean isCurIsMix() {
        return mCurIsMix;
    }

    public void setCurIsMix(boolean curIsMix) {
        mCurIsMix = curIsMix;
    }

    public boolean isPublishVideo() {
        return mPublishVideo;
    }

    public void setPublishVideo(boolean publishVideo) {
        mPublishVideo = publishVideo;
    }

    public int getCloudMixtureMode() {
        return mCloudMixtureMode;
    }

    public void setCloudMixtureMode(int mode) {
        mCloudMixtureMode = mode;
    }

    public void copyFromSetting(VideoConfig other) {
        this.mVideoResolution = other.mVideoResolution;
        this.mVideoFps = other.mVideoFps;
        this.mVideoBitrate = other.mVideoBitrate;
        this.mQosPreference = other.mQosPreference;
        this.mVideoVertical = other.mVideoVertical;
        this.mVideoFillMode = other.mVideoFillMode;
        this.mMirrorType = other.mMirrorType;
        this.mEnableVideo = other.mEnableVideo;
        this.mPublishVideo = other.mPublishVideo;
        this.mRemoteMirror = other.mRemoteMirror;
        this.mWatermark = other.mWatermark;
        this.mQosMode = other.mQosMode;
        this.mEnableSmall = other.mEnableSmall;
        this.mPriorSmall = other.mPriorSmall;
        this.mEnableGSensorMode = other.mEnableGSensorMode;
        this.mCloudMixtureMode = other.mCloudMixtureMode;
        this.mLocalRotation = other.mLocalRotation;
        this.mCustomLiveId = other.mCustomLiveId;
        this.mIsScreenCapturePaused = other.mIsScreenCapturePaused;
        this.mSaveFlag = other.mSaveFlag;
    }

    public int getLocalRotation() {
        return mLocalRotation;
    }

    public void setLocalRotation(int localRotation) {
        mLocalRotation = localRotation;
    }

    public boolean isEnableGSensorMode() {
        return mEnableGSensorMode;
    }

    public void setEnableGSensorMode(boolean enableGSensorMode) {
        mEnableGSensorMode = enableGSensorMode;
    }

    public int getQosMode() {
        return mQosMode;
    }

    public void setQosMode(int qosMode) {
        mQosMode = qosMode;
    }

    public boolean isEnableSmall() {
        return mEnableSmall;
    }

    public void setEnableSmall(boolean enableSmall) {
        mEnableSmall = enableSmall;
    }

    public boolean isPriorSmall() {
        return mPriorSmall;
    }

    public void setPriorSmall(boolean priorSmall) {
        mPriorSmall = priorSmall;
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

    public boolean isVideoVertical() {
        return mVideoVertical;
    }

    public void setVideoVertical(boolean videoVertical) {
        mVideoVertical = videoVertical;
    }

    public int getQosPreference() {
        return mQosPreference;
    }

    public void setQosPreference(int qosPreference) {
        mQosPreference = qosPreference;
    }

    public boolean isVideoFillMode() {
        return mVideoFillMode;
    }

    public void setVideoFillMode(boolean videoFillMode) {
        mVideoFillMode = videoFillMode;
    }

    public int getMirrorType() {
        return mMirrorType;
    }

    public void setMirrorType(int mirrorType) {
        mMirrorType = mirrorType;
    }

    public boolean isEnableVideo() {
        return mEnableVideo;
    }

    public void setEnableVideo(boolean enableVideo) {
        mEnableVideo = enableVideo;
    }

    public boolean isRemoteMirror() {
        return mRemoteMirror;
    }

    public void setRemoteMirror(boolean remoteMirror) {
        mRemoteMirror = remoteMirror;
    }

    public boolean isWatermark() {
        return mWatermark;
    }

    public void setWatermark(boolean watermark) {
        mWatermark = watermark;
    }

    public boolean isSaveFlag() {
        return mSaveFlag;
    }

    public String getCustomLiveId() {
        return mCustomLiveId;
    }

    public void setCustomLiveId(String customLiveId) {
        mCustomLiveId = customLiveId;
    }

    public void setSaveFlag(boolean saveFlag) {
        mSaveFlag = saveFlag;
    }

    public void setScreenCapturePaused(boolean paused) {
        mIsScreenCapturePaused = paused;
    }

    public boolean isScreenCapturePaused() {
        return mIsScreenCapturePaused;
    }

    public void saveCache() {
        try {
            SPUtils.getInstance(PER_DATA).put(PER_SAVE_FLAG, mSaveFlag);
            if (mSaveFlag) {
                SPUtils.getInstance(PER_DATA).put(PER_DATA_PARAM, GsonUtils.toJson(this));
            }
        } catch (Exception e) {
        }
    }

    public void loadCache() {
        try {
            String      json       = SPUtils.getInstance(PER_DATA).getString(PER_DATA_PARAM);
            boolean     isSaveFlag = SPUtils.getInstance(PER_DATA).getBoolean(PER_SAVE_FLAG, mSaveFlag);
            VideoConfig setting    = GsonUtils.fromJson(json, VideoConfig.class);
            setting.setSaveFlag(isSaveFlag);
            copyFromSetting(setting);
        } catch (Exception e) {

        }
    }
}
