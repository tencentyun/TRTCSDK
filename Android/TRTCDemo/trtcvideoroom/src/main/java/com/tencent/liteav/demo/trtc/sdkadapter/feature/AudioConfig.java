package com.tencent.liteav.demo.trtc.sdkadapter.feature;

import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.SPUtils;
import com.tencent.trtc.TRTCCloudDef;

import java.io.Serializable;

/**
 * 音频设置项，通过json的形式保存到本地，在初始化时取出
 *
 * @author guanyifeng
 */
public class AudioConfig implements Serializable {
    private final static String PER_DATA       = "per_audio_data";
    private final static String PER_DATA_PARAM = "per_audio_param";
    private final static String PER_SAVE_FLAG  = "per_save_flag";

    // 是否打开16k采样率，true 16k false 48k
    private boolean mEnable16KSampleRate   = false;
    // 系统音量类型
    private int     mAudioVolumeType       = TRTCCloudDef.TRTCSystemVolumeTypeAuto;
    // 自动增益
    private boolean mAGC                   = false;
    // 噪音消除
    private boolean mANS                   = false;
    // 是否打开音频采集
    private boolean mEnableAudio           = true;
    // 耳返开关
    private boolean mEnableEarMonitoring   = false;
    // 免提模式 true 免提 false 听筒
    private boolean mAudioHandFreeMode     = true;
    // 是否打开音量提示，界面上表示为底下的音量条
    private boolean mAudioVolumeEvaluation = true;
    // 采集音量
    private int     mRecordVolume          = 100;
    // 播放音量
    private int     mPlayoutVolume         = 100;

    /**
     * 是否默认保存到本地，第二次启动的时候，会自动从本地加载
     * transient 表示这个参数不会序列化
     */
    private transient boolean mSaveFlag  = true;
    // 录音状态， true 正在录音 false 结束录音
    private transient boolean mRecording = false;

    public AudioConfig() {
        //loadCache();
    }

    public void copyFromSetting(AudioConfig other) {
        this.mEnable16KSampleRate = other.mEnable16KSampleRate;
        this.mAudioVolumeType = other.mAudioVolumeType;
        this.mAGC = other.mAGC;
        this.mANS = other.mANS;
        this.mEnableAudio = other.mEnableAudio;
        this.mAudioHandFreeMode = other.mAudioHandFreeMode;
        this.mAudioVolumeEvaluation = other.mAudioVolumeEvaluation;
        this.mSaveFlag = other.mSaveFlag;
        this.mRecording = other.mRecording;
        this.mEnableEarMonitoring = other.mEnableEarMonitoring;
        this.mRecordVolume = other.mRecordVolume;
        this.mPlayoutVolume = other.mPlayoutVolume;
    }

    public boolean isEnable16KSampleRate() {
        return mEnable16KSampleRate;
    }

    public void setEnable16KSampleRate(boolean enable16KSampleRate) {
        mEnable16KSampleRate = enable16KSampleRate;
    }

    public int getAudioVolumeType() {
        return mAudioVolumeType;
    }

    public void setAudioVolumeType(int audioVolumeType) {
        mAudioVolumeType = audioVolumeType;
    }

    public boolean isAGC() {
        return mAGC;
    }

    public void setAGC(boolean AGC) {
        mAGC = AGC;
    }

    public boolean isANS() {
        return mANS;
    }

    public void setANS(boolean ANS) {
        mANS = ANS;
    }

    public boolean isEnableAudio() {
        return mEnableAudio;
    }

    public void setEnableAudio(boolean enableAudio) {
        mEnableAudio = enableAudio;
    }

    public void setEnableEarMonitoring(boolean enable) {
        mEnableEarMonitoring = enable;
    }

    public boolean isEnableEarMonitoring() {
        return mEnableEarMonitoring;
    }

    public boolean isAudioHandFreeMode() {
        return mAudioHandFreeMode;
    }

    public void setAudioHandFreeMode(boolean audioHandFreeMode) {
        mAudioHandFreeMode = audioHandFreeMode;
    }

    public boolean isAudioVolumeEvaluation() {
        return mAudioVolumeEvaluation;
    }

    public void setAudioVolumeEvaluation(boolean audioVolumeEvaluation) {
        mAudioVolumeEvaluation = audioVolumeEvaluation;
    }

    public int getRecordVolume() {
        return mRecordVolume;
    }

    public void setRecordVolume(int recordVolume) {
        mRecordVolume = recordVolume;
    }

    public int getPlayoutVolume() {
        return mPlayoutVolume;
    }

    public void setPlayoutVolume(int playoutVolume) {
        mPlayoutVolume = playoutVolume;
    }

    public boolean isSaveFlag() {
        return mSaveFlag;
    }

    public void setSaveFlag(boolean saveFlag) {
        mSaveFlag = saveFlag;
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
            AudioConfig setting    = GsonUtils.fromJson(json, AudioConfig.class);
            setting.setSaveFlag(isSaveFlag);
            copyFromSetting(setting);
        } catch (Exception e) {
        }
    }

    public boolean isRecording() {
        return mRecording;
    }

    public void setRecording(boolean recording) {
        mRecording = recording;
    }
}
