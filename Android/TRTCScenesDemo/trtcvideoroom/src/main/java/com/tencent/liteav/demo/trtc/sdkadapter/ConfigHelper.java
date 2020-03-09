package com.tencent.liteav.demo.trtc.sdkadapter;

import com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayerConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.AudioConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.MoreConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.PkConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.VideoConfig;

/**
 * 用来管理setting的配置项，全局维护一个实例，避免重复初始化
 *
 * @author guanyifeng
 */
public class ConfigHelper {
    // 视频相关设置项
    private VideoConfig     mVideoConfig;
    // 音频相关设置项
    private AudioConfig     mAudioConfig;
    // 连麦相关设置项
    private PkConfig        mPkConfig;
    // 其他的设置项
    private MoreConfig      mMoreConfig;
    // CDN播放设置项
    private CdnPlayerConfig mCdnPlayerConfig;

    private ConfigHelper() {
    }

    public static ConfigHelper getInstance() {
        return SingletonHolder.instance;
    }

    public CdnPlayerConfig getCdnPlayerConfig() {
        if (mCdnPlayerConfig == null) {
            mCdnPlayerConfig = new CdnPlayerConfig();
        }
        return mCdnPlayerConfig;
    }

    public VideoConfig getVideoConfig() {
        if (mVideoConfig == null) {
            mVideoConfig = new VideoConfig();
            mVideoConfig.loadCache();
        }
        return mVideoConfig;
    }

    public AudioConfig getAudioConfig() {
        if (mAudioConfig == null) {
            mAudioConfig = new AudioConfig();
            mAudioConfig.loadCache();
        }
        return mAudioConfig;
    }

    public PkConfig getPkConfig() {
        if (mPkConfig == null) {
            mPkConfig = new PkConfig();
        }
        return mPkConfig;
    }

    public MoreConfig getMoreConfig() {
        if (mMoreConfig == null) {
            mMoreConfig = new MoreConfig();
        }
        return mMoreConfig;
    }

    private static class SingletonHolder {
        /**
         * 由JVM来保证线程安全
         */
        private static ConfigHelper instance = new ConfigHelper();
    }

}
