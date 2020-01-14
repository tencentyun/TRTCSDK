package com.tencent.liteav.demo.trtcvoiceroom.model;

public class SettingConfig {
    // BGM设置
    public boolean isPlayingOnline = false;
    public boolean isPlayingLocal  = false;
    public int     mBgmVol         = 100;
    public int     mMicVol         = 100;

    // 变声类型的下标
    public int mVoiceChangerIndex = 0;

    // 混响设置
    public int mReverbIndex = 0;

    public boolean mEnableMic   = true;
    public boolean mEnableAudio = true;

    private static SettingConfig ourInstance = null;

    public static SettingConfig getInstance() {
        if (ourInstance == null) {
            ourInstance = new SettingConfig();
        }
        return ourInstance;
    }

    private SettingConfig() {
    }

    public void reset() {
        isPlayingOnline = false;
        isPlayingLocal = false;
        mBgmVol = 100;
        mMicVol = 100;
        mVoiceChangerIndex = 0;
        mReverbIndex = 0;
        mEnableMic = true;
        mEnableAudio = true;
    }
}
