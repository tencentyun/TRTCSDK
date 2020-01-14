package com.tencent.liteav.demo.trtc.sdkadapter.cdn;

import android.text.TextUtils;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.trtc.debug.GenerateTestUserSig;
import com.tencent.liteav.demo.trtc.sdkadapter.ConfigHelper;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.net.URLEncoder;

import static com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayerConfig.CACHE_STRATEGY_AUTO;
import static com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayerConfig.CACHE_STRATEGY_FAST;
import static com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayerConfig.CACHE_STRATEGY_SMOOTH;
import static com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayerConfig.CACHE_TIME_FAST;
import static com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayerConfig.CACHE_TIME_SMOOTH;

/**
 * cdn播放管理类
 *
 * @author guanyifeng
 */
public class CdnPlayManager {
    private final ITXLivePlayListener mLivePlayListener;
    /**
     * SDK player 相关
     */
    private       TXLivePlayer        mLivePlayer;
    private       TXCloudVideoView    mPlayerView;
    private       String              mPlayUrl;
    private       CdnPlayerConfig     mCdnPlayerConfig;
    private       TXLivePlayConfig    mPlayConfig;

    public CdnPlayManager(TXCloudVideoView playerView, ITXLivePlayListener livePlayListener) {
        mPlayerView = playerView;
        mLivePlayListener = livePlayListener;
        mLivePlayer = new TXLivePlayer(playerView.getContext());
        mPlayConfig = new TXLivePlayConfig();
        mPlayConfig.setEnableMessage(true);
        mLivePlayer.setPlayerView(mPlayerView);
        mLivePlayer.setPlayListener(mLivePlayListener);
    }

    public void initPlayUrl(int roomId, String userId) {
        // 注意：该功能需要在控制台开启【旁路直播】功能，
        // 此功能是获取 CDN 直播地址，通过此功能，方便您能够在常见播放器中，播放音视频流。
        // 【*****】更多信息，您可以参考：https://cloud.tencent.com/document/product/647/16826
        // 拼接流id
        String streamId = "" + GenerateTestUserSig.SDKAPPID + "_" + roomId + "_" + userId + "_main";
        try {
            streamId = URLEncoder.encode(streamId, "utf-8");
        } catch (Exception e) {
            e.printStackTrace();
        }
        // 拼接旁路流地址
        final String playUrl = "http://3891.liveplay.myqcloud.com/live/" + streamId + ".flv";
        mPlayUrl = playUrl;
    }

    /**
     * 应用所有被设置的config
     */
    public void applyConfigToPlayer() {
        mCdnPlayerConfig = ConfigHelper.getInstance().getCdnPlayerConfig();
        mLivePlayer.setRenderRotation(mCdnPlayerConfig.getCurrentRenderRotation());
        mLivePlayer.setRenderMode(mCdnPlayerConfig.getCurrentRenderMode());
        mPlayerView.showLog(mCdnPlayerConfig.isDebug());
        setCacheStrategy(mCdnPlayerConfig.getCacheStrategy());
    }

    public void setDebug(boolean enable) {
        mPlayerView.showLog(enable);
    }

    public void startPlay() {
        if (TextUtils.isEmpty(mPlayUrl)) {
            ToastUtils.showLong("请先设置播放url");
            return;
        }
        applyConfigToPlayer();
        int res = mLivePlayer.startPlay(mPlayUrl, TXLivePlayer.PLAY_TYPE_LIVE_FLV);
        if (res == 0) {
        } else {
            ToastUtils.showLong("播放失败：" + res);
        }
    }

    public void destroy() {
        if (isPlaying()) {
            mLivePlayer.stopPlay(true);
            mLivePlayer.stopRecord();
        }
    }

    public void stopPlay() {
        mLivePlayer.stopPlay(true);
    }

    public boolean isPlaying() {
        return mLivePlayer.isPlaying();
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      缓存策略配置
    //
    /////////////////////////////////////////////////////////////////////////////////
    private void setCacheStrategy(int nCacheStrategy) {
        switch (nCacheStrategy) {
            case CACHE_STRATEGY_FAST:
                mPlayConfig.setAutoAdjustCacheTime(true);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_FAST);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayConfig);
                break;
            case CACHE_STRATEGY_SMOOTH:
                mPlayConfig.setAutoAdjustCacheTime(false);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mLivePlayer.setConfig(mPlayConfig);
                break;
            case CACHE_STRATEGY_AUTO:
                mPlayConfig.setAutoAdjustCacheTime(true);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayConfig);
                break;
            default:
                break;
        }
    }
}
