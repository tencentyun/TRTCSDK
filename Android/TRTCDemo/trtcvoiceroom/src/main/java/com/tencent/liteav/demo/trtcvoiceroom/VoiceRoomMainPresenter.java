package com.tencent.liteav.demo.trtcvoiceroom;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.trtcvoiceroom.model.SeiMessageData;
import com.tencent.liteav.demo.trtcvoiceroom.model.SettingConfig;
import com.tencent.liteav.demo.trtcvoiceroom.model.VoiceRoomConfig;
import com.tencent.liteav.demo.trtcvoiceroom.widgets.BGMPlayer;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static com.tencent.rtmp.TXLivePlayer.PLAY_TYPE_LIVE_FLV;

public class VoiceRoomMainPresenter implements VoiceRoomContract.IPresenter {
    private static final String TAG = VoiceRoomMainPresenter.class.getName();

    public static final  int    MIN_TALK_VOL        = 10;
    private static final String LOCAL_BGM_FILE_NAME = "zhouye.mp3";
    private static final int    CDN_MAX_VOLUME      = 255;
    private static final String ONLINE_BGM_PATH     = "https://bgm-1252463788.cos.ap-guangzhou.myqcloud.com/keluodiya.mp3";
	private String mTestMusicPath;

    private TRTCCloud               mTRTCCloud;
    private VoiceRoomConfig         mVoiceRoomConfig;
    private TXLivePlayer            mTXLivePlayer;
    private VoiceRoomContract.IView mIView;
    private int                     mAnchorNum;
    private BGMPlayer               mLocalBgmPlayer;
    private BGMPlayer               mOnlineBgmPlayer;
    private boolean                 isCdnPlay     = false;
    private boolean                 isNeedCdnPlay = false;
    private List<String>            mCdnAnchorList;

    // 需要储存的状态
    private int    mReverbType       = TRTCCloudDef.TRTC_REVERB_TYPE_0;
    private String mReverbName       = "关闭混响";
    private int    mVoiceChangerType = TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_0;
    private String mVoiceChangerName = "关闭变声";

    /**
     * 用于监听TRTC事件
     */
    private TRTCCloudListener mChatRoomTRTCListener = new TRTCCloudListener() {
        @Override
        public void onExitRoom(int reason) {
            super.onExitRoom(reason);
            if (mVoiceRoomConfig.role == TRTCCloudDef.TRTCRoleAudience && isNeedCdnPlay) {
                //现在是观众模式
                isCdnPlay = true;
                isNeedCdnPlay = false;
                startCdnPlay();
                enableAudio(SettingConfig.getInstance().mEnableAudio);
            }
        }

        @Override
        public void onSwitchRole(int errCode, String errMsg) {
            mIView.stopLoading();
        }

        @Override
        public void onEnterRoom(long result) {
            mIView.stopLoading();
            // 处理现在是否播放声音
            enableAudio(SettingConfig.getInstance().mEnableAudio);
            if (result == 0) {
                ToastUtils.showShort("进房成功");
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            mIView.stopLoading();
            ToastUtils.showLong("进房失败: " + errCode);
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean available) {
            if (available) {
                mIView.updateAnchorEnter(userId);
                mAnchorNum++;
                mIView.updateOnlineNum(mAnchorNum);
            }
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
            mIView.updateAnchorExit(userId);
            mAnchorNum--;
            mIView.updateOnlineNum(mAnchorNum);
        }

        @Override
        public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
            List<String> userList = new ArrayList<>();
            for (TRTCCloudDef.TRTCVolumeInfo info : userVolumes) {
                if (info.userId == null || info.userId.equals(mVoiceRoomConfig.userId)) {
                    if (mVoiceRoomConfig.role == TRTCCloudDef.TRTCRoleAnchor
                            && info.volume > MIN_TALK_VOL) {
                        mIView.updateSelfTalk(true);
                    } else {
                        mIView.updateSelfTalk(false);
                    }
                } else {
                    if (info.volume > MIN_TALK_VOL) {
                        userList.add(info.userId);
                    }
                }
            }
            mIView.updateRemoteUserTalk(userList);
        }

        @Override
        public void onAudioEffectFinished(int effectId, int code) {
            mIView.updateEffectView(false);
        }
    };

    /**
     * 用于监听cdn播放的事件
     */
    private ITXLivePlayListener mChatRoomCdnListener = new ITXLivePlayListener() {
        @Override
        public void onPlayEvent(int event, Bundle param) {
            Log.d(TAG, "onPlayEvent: " + event);
            if (event == TXLiveConstants.PLAY_EVT_PLAY_BEGIN) {
                mIView.stopLoading();
                ToastUtils.showLong("CDN播放");
            } else if (event == TXLiveConstants.PLAY_EVT_PLAY_END) {
                mIView.stopLoading();
                ToastUtils.showLong("播放结束");
            } else if (event < 0) {
                mIView.stopLoading();
                ToastUtils.showLong("播放出错 " + event);
            } else if (event == TXLiveConstants.PLAY_EVT_GET_MESSAGE) {
                if (param != null) {
                    byte[] data       = param.getByteArray(TXLiveConstants.EVT_GET_MSG);
                    String seiMessage = "";
                    if (data != null && data.length > 0) {
                        try {
                            seiMessage = new String(data, "UTF-8");
                            Log.d(TAG, "消息: " + seiMessage);
                            handleSeiMessage(seiMessage);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }

        @Override
        public void onNetStatus(Bundle status) {

        }
    };

    public VoiceRoomMainPresenter(Context context, @NonNull VoiceRoomConfig config, VoiceRoomContract.IView view) {
        //初始化trtc
        mTRTCCloud = TRTCCloud.sharedInstance(context);
        mTXLivePlayer = new TXLivePlayer(context);
        TXLivePlayConfig playConfig = new TXLivePlayConfig();
        playConfig.setEnableMessage(true);
        mTXLivePlayer.setConfig(playConfig);
        mCdnAnchorList = new ArrayList<>();
        mVoiceRoomConfig = config;
        mIView = view;
        File sdcardDir = context.getExternalFilesDir(null);
        if (sdcardDir != null) {
            mTestMusicPath = sdcardDir.getAbsolutePath() + "/testMusic/" + LOCAL_BGM_FILE_NAME;
        }
    }

    @Override
    public void init(Context context) {
        // 重置设置项
        SettingConfig.getInstance().reset();
        if (mVoiceRoomConfig.role == TRTCCloudDef.TRTCRoleAnchor) {
            // 主播方式，需要进房
            mAnchorNum = 1;
            enterTRTCRoom();
        } else {
            // 观众方式，默认以低延时大房间的方式观看
            mAnchorNum = 0;
            if (isCdnPlay) {
                startCdnPlay();
            } else {
                enterTRTCRoom();
            }
        }
        mIView.updateOnlineNum(mAnchorNum);
        copyAssets(context);
    }

    private void handleSeiMessage(String msg) {
        SeiMessageData data = null;
        try {
            data = GsonUtils.fromJson(msg, SeiMessageData.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (data != null && !CollectionUtils.isEmpty(data.regions)) {
            List<String> newUser  = new ArrayList<>();
            List<String> talkUser = new ArrayList<>();
            for (SeiMessageData.Region region : data.regions) {
                String userId = region.uid;
                if (!TextUtils.isEmpty(userId)) {
                    newUser.add(userId);
                    int realVolume = (int) ((region.volume / (float) CDN_MAX_VOLUME) * 100);
                    if (realVolume > MIN_TALK_VOL) {
                        talkUser.add(userId);
                    }
                }
            }
            Iterator<String> iterator = mCdnAnchorList.iterator();
            while (iterator.hasNext()) {
                String userId = iterator.next();
                if (!newUser.contains(userId)) {
                    iterator.remove();
                    mIView.updateAnchorExit(userId);
                } else {
                    newUser.remove(userId);
                }
            }
            iterator = newUser.iterator();
            while (iterator.hasNext()) {
                String userId = iterator.next();
                mCdnAnchorList.add(userId);
                mIView.updateAnchorEnter(userId);
            }
            mIView.updateRemoteUserTalk(talkUser);
        }
    }

    private void copyAssets(final Context context) {
        // 本地文件拷贝
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                if (TextUtils.isEmpty(mTestMusicPath)){
                    return;
                }
                File file = new File(mTestMusicPath);
                if (file.exists()) {
                    return;
                }
                Utils.copyFilesFromAssets(context.getApplicationContext(),
                        LOCAL_BGM_FILE_NAME,
                        mTestMusicPath);
            }
        });
    }


    private void startCdnPlay() {
        mTXLivePlayer.stopPlay(false);
        mCdnAnchorList.clear();
        mTXLivePlayer.setPlayListener(mChatRoomCdnListener);
        mTXLivePlayer.startPlay(getPlayUrl(mVoiceRoomConfig.sdkAppId, mVoiceRoomConfig.roomId), PLAY_TYPE_LIVE_FLV);
    }

    private String getPlayUrl(int sdkAppId, int roomId) {
        return "http://3891.liveplay.myqcloud.com/live/mix_" + sdkAppId + "_" + roomId + ".flv";
    }

    private void enterTRTCRoom() {
        //进房前先清一下座位
        mIView.resetSeatView();
        mTRTCCloud.enableAudioVolumeEvaluation(800);

        mTRTCCloud.setListener(mChatRoomTRTCListener);
        if (mVoiceRoomConfig.role == TRTCCloudDef.TRTCRoleAnchor) {
            mTRTCCloud.startLocalAudio();
        } else {
            mTRTCCloud.stopLocalAudio();
        }
        // 拼接进房参数
        TRTCCloudDef.TRTCParams params = new TRTCCloudDef.TRTCParams();
        params.userSig = mVoiceRoomConfig.userSig;
        params.roomId = mVoiceRoomConfig.roomId;
        params.sdkAppId = mVoiceRoomConfig.sdkAppId;
        params.role = mVoiceRoomConfig.role;
        params.userId = mVoiceRoomConfig.userId;
        // 若您的项目有纯音频的旁路直播需求，请配置参数businessInfo。
        // 配置该参数后，音频达到服务器，即开始自动旁路；
        // 否则无此参数，旁路在收到第一个视频帧之前，会将收到的音频包丢弃。
        JSONObject businessInfo = new JSONObject();
        JSONObject pureAudio    = new JSONObject();
        try {
            pureAudio.put("pure_audio_push_mod", 1);
            businessInfo.put("Str_uc_params", pureAudio);
        } catch (Exception e) {

        }
        params.businessInfo = businessInfo.toString();
        //设置音频采样率，高音质是48k，标准音质是16k
        enable16KSampleRate(!mVoiceRoomConfig.isHighQuality);
        mTRTCCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM);
    }

    /**
     * 声音采样率
     *
     * @param enable true 开启16k采样率 false 开启48k采样率
     */
    public void enable16KSampleRate(boolean enable) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "setAudioSampleRate");
            JSONObject params = new JSONObject();
            params.put("sampleRate", enable ? 16000 : 48000);
            jsonObject.put("params", params);
            mTRTCCloud.callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    @Override
    public void enableMic(boolean enable) {
        SettingConfig.getInstance().mEnableMic = enable;
        if (enable) {
            mTRTCCloud.startLocalAudio();
            setReverbType(mReverbType, mReverbName);
            setVoiceChanger(mVoiceChangerType, mVoiceChangerName);
        } else {
            mTRTCCloud.stopLocalAudio();
        }
    }

    @Override
    public void enableAudio(boolean enable) {
        SettingConfig.getInstance().mEnableAudio = enable;
        if (isCdnPlay) {
            // 观众模式操作 TXLivePlayer
            mTXLivePlayer.setMute(!enable);
        } else {
            mTRTCCloud.muteAllRemoteAudio(!enable);
        }
    }

    @Override
    public void playOnlineBGM(boolean isPlay) {
        SettingConfig config = SettingConfig.getInstance();
        if (config.isPlayingOnline == isPlay) {
            return;
        }
        if (mOnlineBgmPlayer == null) {
            mOnlineBgmPlayer = new BGMPlayer(ONLINE_BGM_PATH, new BGMPlayer.Listener() {
                @Override
                public void onProgress(int progress) {
                    mIView.updateBGMProgress(false, progress);
                }

                @Override
                public void onStop() {
                    SettingConfig config = SettingConfig.getInstance();
                    config.isPlayingOnline = false;
                    mIView.updateBGMView();
                    mIView.updateBGMProgress(false, 0);
                }
            });

        }
        if (isPlay) {
            //检查一下是否有在播放本地BGM
            if (mLocalBgmPlayer != null && mLocalBgmPlayer.isWorking()) {
                mLocalBgmPlayer.stopPlay(mTRTCCloud);
            }
            //播放网络音乐
            mOnlineBgmPlayer.startPlay(mTRTCCloud);
            mTRTCCloud.setBGMVolume(config.mBgmVol);
            mTRTCCloud.setMicVolumeOnMixing(config.mMicVol);
            config.isPlayingOnline = true;
        } else {
            //停止播放音乐
            mOnlineBgmPlayer.pausePlay(mTRTCCloud);
            config.isPlayingOnline = false;
        }
        mIView.updateBGMView();
    }

    @Override
    public void playLocalBGM(boolean isPlay) {
        SettingConfig config = SettingConfig.getInstance();
        if (config.isPlayingLocal == isPlay) {
            return;
        }
        if (mLocalBgmPlayer == null) {
            if (TextUtils.isEmpty(mTestMusicPath))
                return;
            mLocalBgmPlayer = new BGMPlayer(mTestMusicPath, new BGMPlayer.Listener() {
                @Override
                public void onProgress(int progress) {
                    mIView.updateBGMProgress(true, progress);
                }

                @Override
                public void onStop() {
                    SettingConfig config = SettingConfig.getInstance();
                    config.isPlayingLocal = false;
                    mIView.updateBGMView();
                    mIView.updateBGMProgress(true, 0);
                }
            });
        }
        if (isPlay) {
            //检查一下是否有在播放网络BGM
            if (mOnlineBgmPlayer != null && mOnlineBgmPlayer.isWorking()) {
                mOnlineBgmPlayer.stopPlay(mTRTCCloud);
            }
            if (mLocalBgmPlayer != null) {
                mLocalBgmPlayer.startPlay(mTRTCCloud);
            }
            mTRTCCloud.setBGMVolume(config.mBgmVol);
            mTRTCCloud.setMicVolumeOnMixing(config.mMicVol);
            config.isPlayingLocal = true;
        } else {
            if (mLocalBgmPlayer != null) {
                mLocalBgmPlayer.pausePlay(mTRTCCloud);
            }
            config.isPlayingLocal = false;
        }
        mIView.updateBGMView();
    }

    @Override
    public void setBGMVol(int vol) {
        mTRTCCloud.setBGMVolume(vol);
        SettingConfig.getInstance().mBgmVol = vol;
    }

    @Override
    public void stopAllAudioEffects() {
        mTRTCCloud.stopAllAudioEffects();
    }

    @Override
    public void setAllAudioEffectsVolume(int progress) {
        mTRTCCloud.setAllAudioEffectsVolume(progress);
    }

    @Override
    public void setAudioEffectVolume(int id, int gain) {
        mTRTCCloud.setAudioEffectVolume(id, gain);
    }

    @Override
    public void stopAudioEffect(int id) {
        mTRTCCloud.stopAudioEffect(id);
    }

    @Override
    public void playAudioEffect(int id, String path, int loopTime, boolean checkUpload, int vol) {
        TRTCCloudDef.TRTCAudioEffectParam param = new TRTCCloudDef.TRTCAudioEffectParam(id, path);
        param.loopCount = loopTime;
        param.publish = checkUpload;
        param.volume = vol;
        mTRTCCloud.playAudioEffect(param);
        mIView.updateEffectView(true);
    }

    @Override
    public void setVoiceChanger(int type, String name) {
        mVoiceChangerType = type;
        mVoiceChangerName = name;
        mTRTCCloud.setVoiceChangerType(type);
        mIView.updateVoiceChangeView(type, name);
    }

    @Override
    public int switchRole() {
        if (mVoiceRoomConfig.role == TRTCCloudDef.TRTCRoleAnchor) {
            // 主播切观众, 默认以低延时大房间播放
            mVoiceRoomConfig.role = TRTCCloudDef.TRTCRoleAudience;
            isCdnPlay = false;
            mIView.startLoading();
            enableMic(false);
            enableAudio(true);
            //停止播放背景音乐
            if (mOnlineBgmPlayer != null) {
                mOnlineBgmPlayer.stopPlay(mTRTCCloud);
            }
            if (mLocalBgmPlayer != null) {
                mLocalBgmPlayer.stopPlay(mTRTCCloud);
            }
            //停止所有的音效
            stopAllAudioEffects();
            mTRTCCloud.switchRole(mVoiceRoomConfig.role);
            mAnchorNum = 0;
            mIView.updateOnlineNum(mAnchorNum);
        } else {
            // 观众切主播分为两种情况
            // 1. 现在是cdn播放的状态，需要先停止cdn播放，再以主播方式进房
            // 2. 现在低延时播放的状态，这个时候直接切换角色就可以了
            mVoiceRoomConfig.role = TRTCCloudDef.TRTCRoleAnchor;
            mIView.startLoading();
            enableMic(true);
            enableAudio(true);
            if (isCdnPlay) {
                // cdn播放直接切换状态就可以了
                switchLivePlay();
            } else {
                // 如果是已经在房间里了直接切换角色就可以了
                //切换角色
                mTRTCCloud.switchRole(mVoiceRoomConfig.role);
                mIView.stopLoading();
            }
            mAnchorNum = 1;
            mIView.updateOnlineNum(mAnchorNum);
        }

        return mVoiceRoomConfig.role;
    }

    @Override
    public void setMicVol(int vol) {
        mTRTCCloud.setMicVolumeOnMixing(vol);
        SettingConfig.getInstance().mMicVol = vol;
    }

    @Override
    public void setReverbType(int type, String name) {
        mReverbType = type;
        mReverbName = name;
        mTRTCCloud.setReverbType(type);
        mIView.updateReverBView(type, name);
    }

    @Override
    public boolean isCdnPlay() {
        return isCdnPlay;
    }

    @Override
    public void switchLivePlay() {
        //切换直播状态
        if (isCdnPlay) {
            mIView.startLoading();
            // 停止CDN播放
            mTXLivePlayer.stopPlay(true);
            // 进房
            enterTRTCRoom();
            isCdnPlay = false;
            mIView.updateLiveView(false);
        } else {
            mIView.startLoading();
            // 退房
            exitRoom();
            // 需要等到退房成功后再进行播放
            // 见com.tencent.trtc.TRTCCloudListener.onExitRoom
            isNeedCdnPlay = true;
            mIView.updateLiveView(true);
        }
    }

    private void exitRoom() {
        //退房前先清一下座位
        mIView.resetSeatView();
        mTRTCCloud.exitRoom();
    }

    @Override
    public void destroy() {
        exitRoom();
        TRTCCloud.destroySharedInstance();
        mTXLivePlayer.stopPlay(true);
        mTXLivePlayer.stopRecord();
        mTRTCCloud = null;
    }
}
