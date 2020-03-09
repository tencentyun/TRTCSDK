package com.tencent.liteav.demo.trtc.sdkadapter.bgm;

import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

/**
 * BGM的控制类
 *
 * @author guanyifeng
 */
public class TRTCBgmManager {
    private TRTCCloud               mTRTCCloud;                 // SDK 核心类
    private TRTCCloudDef.TRTCParams mTRTCParams;                // 进房参数

    public TRTCBgmManager(TRTCCloud trtcCloud, TRTCCloudDef.TRTCParams trtcParams) {
        mTRTCCloud = trtcCloud;
        mTRTCParams = trtcParams;
    }

    public void destroy() {
        stopBGM();
        stopAllAudioEffects();
    }

    /**
     * ==================================音效面板控制==================================
     */
    public void playAudioEffect(int effectId, String path, int count, boolean publish, double volume) {
        if (mTRTCCloud != null) {
            TRTCCloudDef.TRTCAudioEffectParam effect = new TRTCCloudDef.TRTCAudioEffectParam(effectId, path);
            effect.loopCount = count;
            effect.publish = publish;
            effect.effectId = effectId;
            effect.volume = (int) volume;
            mTRTCCloud.playAudioEffect(effect);
        }
    }

    public void pauseAudioEffect(int effectId) {
        if (mTRTCCloud != null) {
            mTRTCCloud.pauseAudioEffect(effectId);
        }
    }


    public void resumeAudioEffect(int effectId) {
        if (mTRTCCloud != null) {
            mTRTCCloud.resumeAudioEffect(effectId);
        }
    }

    public void stopAudioEffect(int effectId) {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAudioEffect(effectId);
        }
    }

    public void setAudioEffectVolume(int effectId, int gain) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setAudioEffectVolume(effectId, gain);
        }
    }

    public void stopAllAudioEffects() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAllAudioEffects();
        }
    }

    public void setAllAudioEffectsVolume(int gain) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setAllAudioEffectsVolume(gain);
        }
    }

    /**
     * ==================================BGM控制==================================
     */
    public void playBGM(String url, int loopTimes, int bgmVol, int micVol, TRTCCloud.BGMNotify notify) {
        if (mTRTCCloud != null) {
            mTRTCCloud.playBGM(url, notify);
            mTRTCCloud.setBGMVolume(bgmVol);
            mTRTCCloud.setMicVolumeOnMixing(micVol);
        }
    }

    public void resumeBGM() {
        if (mTRTCCloud != null) {
            mTRTCCloud.resumeBGM();
        }
    }

    public void pauseBGM() {
        if (mTRTCCloud != null) {
            mTRTCCloud.pauseBGM();
        }
    }

    public void stopBGM() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopBGM();
        }
    }

    public void setBGMVolume(int volume) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setBGMVolume(volume);
        }
    }

    public void setMicVolumeOnMixing(int volume) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setMicVolumeOnMixing(volume);
        }
    }

    public void setPlayoutVolume(int volume) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setBGMPlayoutVolume(volume);
        }
    }

    public void setPublishVolume(int volume) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setBGMPublishVolume(volume);
        }
    }

    public void setReverbType(int type) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setReverbType(type);
        }
    }

    public void setVoiceChangerType(int type) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setVoiceChangerType(type);
        }
    }
}
