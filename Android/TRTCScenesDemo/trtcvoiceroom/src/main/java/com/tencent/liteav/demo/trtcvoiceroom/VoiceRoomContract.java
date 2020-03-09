package com.tencent.liteav.demo.trtcvoiceroom;

import android.content.Context;

import java.util.List;

public class VoiceRoomContract {
    public interface IPresenter {
        void init(Context context);

        void destroy();

        void enableMic(boolean enable);

        void enableAudio(boolean enable);

        void playOnlineBGM(boolean isPlay);

        void playLocalBGM(boolean isPlay);

        void setBGMVol(int vol);

        void stopAllAudioEffects();

        void setAllAudioEffectsVolume(int progress);

        void setAudioEffectVolume(int id, int gain);

        void stopAudioEffect(int id);

        void playAudioEffect(int id, String path, int loopTime, boolean checkUpload, int vol);

        void setVoiceChanger(int type, String name);

        int switchRole();

        void setMicVol(int vol);

        void setReverbType(int type, String name);

        boolean isCdnPlay();

        void switchLivePlay();

    }

    interface IView {
        void updateOnlineNum(int number);

        void updateAnchorEnter(String userId);

        void updateAnchorExit(String userId);

        void updateRemoteUserTalk(List<String> userIdList);

        void updateSelfTalk(boolean isTalk);

        void updateBGMView();

        void updateBGMProgress(boolean isLocal, int progress);

        void updateVoiceChangeView(int type, String name);

        void updateReverBView(int type, String name);

        void updateEffectView(boolean isPlay);

        void updateLiveView(boolean isCdnPlay);

        void resetSeatView();

        void stopLoading();

        void startLoading();
    }
}
