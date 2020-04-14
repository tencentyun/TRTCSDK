package com.tencent.liteav.liveroom.model.impl;

import com.tencent.liteav.liveroom.model.TRTCAudioEffectManager;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

/**
 * BGM的控制类
 *
 * @author guanyifeng
 */
public class TRTCAudioEffectManagerImpl implements TRTCAudioEffectManager {
    private TRTCCloud mTRTCCloud;

    public TRTCAudioEffectManagerImpl(TRTCCloud trtcCloud) {
        mTRTCCloud = trtcCloud;
    }

    public void destroy() {
        stopBGM();
        stopAllAudioEffects();
    }

    /**
     * ==================================音效面板控制==================================
     */
    @Override
    public void playAudioEffect(int effectId, String path, int count, boolean publish, int volume) {
        if (mTRTCCloud != null) {
            TRTCCloudDef.TRTCAudioEffectParam effect = new TRTCCloudDef.TRTCAudioEffectParam(effectId, path);
            effect.loopCount = count;
            effect.publish = publish;
            effect.effectId = effectId;
            effect.volume = volume;
            mTRTCCloud.playAudioEffect(effect);
        }
    }

    @Override
    public void pauseAudioEffect(int effectId) {
        if (mTRTCCloud != null) {
            mTRTCCloud.pauseAudioEffect(effectId);
        }
    }

    @Override
    public void resumeAudioEffect(int effectId) {
        if (mTRTCCloud != null) {
            mTRTCCloud.resumeAudioEffect(effectId);
        }
    }

    @Override
    public void stopAudioEffect(int effectId) {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAudioEffect(effectId);
        }
    }

    @Override
    public void setAudioEffectVolume(int effectId, int volume) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setAudioEffectVolume(effectId, volume);
        }
    }

    @Override
    public void stopAllAudioEffects() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAllAudioEffects();
        }
    }

    @Override
    public void setAllAudioEffectsVolume(int volume) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setAllAudioEffectsVolume(volume);
        }
    }

    /**
     * ==================================BGM控制==================================
     */
    @Override
    public void playBGM(String url, int loopTimes, int bgmVol, int micVol, TRTCCloud.BGMNotify notify) {
        if (mTRTCCloud != null) {
            mTRTCCloud.playBGM(url, notify);
            mTRTCCloud.setBGMVolume(bgmVol);
            mTRTCCloud.setAudioCaptureVolume(micVol);
        }
    }

    @Override
    public boolean playBGM(String url) {
        if (mTRTCCloud != null) {
            mTRTCCloud.playBGM(url, null);
            return true;
        }
        return false;
    }

    @Override
    public void resumeBGM() {
        if (mTRTCCloud != null) {
            mTRTCCloud.resumeBGM();
        }
    }

    @Override
    public void pauseBGM() {
        if (mTRTCCloud != null) {
            mTRTCCloud.pauseBGM();
        }
    }

    @Override
    public void stopBGM() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopBGM();
        }
    }

    @Override
    public void setBGMVolume(int volume) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setBGMVolume(volume);
        }
    }

    @Override
    public void setMicVolume(int volume) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setAudioCaptureVolume(volume);
        }
    }

    @Override
    public void setReverbType(int type) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setReverbType(type);
        }
    }

    @Override
    public void setVoiceChangerType(int type) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setVoiceChangerType(type);
        }
    }

    @Override
    public int getBGMDuration(String path) {
        if (mTRTCCloud != null) {
            return mTRTCCloud.getBGMDuration(path);
        }
        return 0;
    }

    @Override
    public int setBGMPosition(int position) {
        if (mTRTCCloud != null) {
            return mTRTCCloud.setBGMPosition(position);
        }
        return position;
    }
}
