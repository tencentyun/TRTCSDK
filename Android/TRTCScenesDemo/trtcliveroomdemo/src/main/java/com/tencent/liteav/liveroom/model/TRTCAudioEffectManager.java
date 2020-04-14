package com.tencent.liteav.liveroom.model;

import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

public interface TRTCAudioEffectManager {
    /**
     * ==================================BGM控制==================================
     */
    /**
     * 播放背景音乐
     *
     * @param url  背景音乐文件路径
     * @param loopTimes 循环次数
     * @param bgmVol BGM音量
     * @param micVol 采集音量
     * @param notify 通知
     */
    void playBGM(String url, int loopTimes, int bgmVol, int micVol, TRTCCloud.BGMNotify notify);

    /**
     * 播放背景音乐
     *
     * @param url 背景音乐文件路径
     * @return true：播放成功；false：播放失败
     */
    boolean playBGM(String url);

    /**
     * 继续播放背景音乐
     */
    void resumeBGM();

    /**
     * 暂停播放背景音乐
     */
    void pauseBGM();

    /**
     * 停止播放背景音乐
     */
    void stopBGM();

    /**
     * 获取音乐文件总时长
     *
     * @param path 音乐文件路径，如果 path 为空，那么返回当前正在播放的 music 时长
     *
     * @return 成功返回时长，单位毫秒，失败返回-1
     */
    int getBGMDuration(String path);

    /**
     * 设置 BGM 播放进度
     *
     * @param position 单位毫秒
     * @return 0：成功；-1：失败
     */
    int setBGMPosition(int position);

    /**
     * 设置背景音乐播放音量的大小
     *
     * 播放背景音乐混音时使用，用来控制背景音乐播放音量的大小，
     * 该接口会同时控制远端播放音量的大小和本地播放音量的大小，
     * 因此调用该接口后，setBGMPlayoutVolume 和 setBGMPublishVolume 设置的音量值会被覆盖
     *
     * @param volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
     */
    void setBGMVolume(int volume);

    /**
     * ==================================音效面板控制==================================
     */
    /**
     * 播放音效
     * 每个音效都需要您指定具体的 ID，您可以通过该 ID 对音效的开始、停止、音量等进行设置。
     * 支持的文件格式：aac, mp3。
     *
     * @note 若您想同时播放多个音效，请分配不同的 ID 进行播放。如果使用同一个 ID 播放不同音效，SDK 会先停止播放旧的音效，再播放新的音效。
     *
     * @param effectId  音效id
     * @param path 音效路径
     * @param count 循环次数
     * @param publish 是否推送/ true 推送给观众，false 本地预览
     * @param volume 音量大小
     */
    void playAudioEffect(int effectId, String path, int count, boolean publish, int volume);

    /**
     * 暂停音效
     *
     * 每个音效都需要您指定具体的 ID，您可以通过该 ID 对音效的开始、停止、音量等进行设置。
     * 支持的文件格式：aac, mp3。
     *
     * @note 若您想同时播放多个音效，请分配不同的 ID 进行播放。如果使用同一个 ID 播放不同音效，SDK 会先停止播放旧的音效，再播放新的音效。
     *
     * @param effectId 音效 ID
     */
    void pauseAudioEffect(int effectId);

    /**
     * 恢复音效
     *
     * @param effectId 音效 ID
     */
    void resumeAudioEffect(int effectId);

    /**
     * 停止音效
     *
     * @param effectId 音效 ID
     */
    void stopAudioEffect(int effectId);

    /**
     * 停止所有音效
     */
    void stopAllAudioEffects();

    /**
     * 设置音效的音量
     *
     * @note 该操作会覆盖通过 setAllAudioEffectsVolume 指定的整体音效音量。
     *
     * @param effectId 音效 ID
     * @param volume 音量大小，取值范围为0 - 100；默认值：100
     */
    void setAudioEffectVolume(int effectId, int volume);

    /**
     * 设置所有音效的音量
     *
     * @note 该操作会覆盖通过 setAudioEffectVolume 指定的单独音效音量。
     *
     * @param volume 音量大小，取值范围为0 - 100；默认值：100
     */
    void setAllAudioEffectsVolume(int volume);

    /**
     * ==================================变声和混响==================================
     */
    /**
     * 设置 mic 音量
     *
     * @param volume 音量大小，取值0 - 100，默认值为100
     */
    void setMicVolume(int volume);

    /**
     * 设置混响效果
     *  *
     *  * @param type 混响类型，详见 TRTC_REVERB_TYPE，默认值：{@link TRTCCloudDef ::TRTC_REVERB_TYPE_0}
     */
    void setReverbType(int type);

    /**
     * 设置变声类型
     *
     *  @param type 变声类型, 详见 TRTC_VOICE_CHANGER_TYPE，默认值：{@link TRTCCloudDef::TRTC_VOICE_CHANGER_TYPE_0}
     */
    void setVoiceChangerType(int type);
}
