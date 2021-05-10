package com.tencent.trtc.bgm;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * TRTC设置背景音乐页面
 *
 * 包含如下简单功能：
 * - 设置背景音乐{@link TXAudioEffectManager#startPlayMusic(TXAudioEffectManager.AudioMusicParam)}
 * - 设置背景音乐本地播放的音量{@link TXAudioEffectManager#setMusicPlayoutVolume(int, int)}
 * - 设置背景音乐远端播放的音量{@link TXAudioEffectManager#setMusicPublishVolume(int, int)}
 *
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TXAudioEffectManager__android.html#acaf02cbac9aa369c166ce60f600fb246}
 */

/**
 * Setting Background Music
 *
 * Features:
 * - Set the background music: {@link TXAudioEffectManager#startPlayMusic(TXAudioEffectManager.AudioMusicParam)}
 * - Set the local playback volume of background music: {@link TXAudioEffectManager#setMusicPlayoutVolume(int, int)}
 * - Set the remote playback volume of background music: {@link TXAudioEffectManager#setMusicPublishVolume(int, int)}
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TXAudioEffectManager__android.html#acaf02cbac9aa369c166ce60f600fb246}.
 */
public class SetBGMActivity extends TRTCBaseActivity implements View.OnClickListener {
    private static final String     TAG = "SetBGMActivity";

    private ImageView               mImageBack;
    private TextView                mTextTitle;
    private SeekBar                 mSeekProgress;
    private Button                  mButtonBGM1;
    private Button                  mButtonBGM2;
    private Button                  mButtonBGM3;
    private Button                  mButtonStartPush;
    private EditText                mEditRoomId;
    private EditText                mEdituserId;
    private TXCloudVideoView        mTXCloudPreviewView;
    private List<TXCloudVideoView>  mRemoteVideoList;
    private TextView                mTextVolume;

    private TRTCCloud               mTRTCCloud;
    private TXAudioEffectManager    mTXAudioEffectManager;
    private int                     mPlayBGMId          = 1024;
    private int                     mLastPlayBGMId      = 1024;
    private List<String>            mRemoteUserIdList;
    private boolean                 mStartPushFlag      = false;
    private boolean                 mStartPlayMusicFlag = false;

    private String[]                mBgmUrlArray = {
            "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/PositiveHappyAdvertising.mp3",
            "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/SadCinematicPiano.mp3",
            "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/WonderWorld.mp3"
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bgm_activity_set);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
    }

    private void enterRoom(String roomId,  String userId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(SetBGMActivity.this));
        mTXAudioEffectManager = mTRTCCloud.getAudioEffectManager();

        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = userId;
        mTRTCParams.roomId = Integer.parseInt(roomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(true, mTXCloudPreviewView);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
        playMusic();
    }

    private void hideRemoteView(){
        mRemoteUserIdList.clear();
        for(TXCloudVideoView videoView : mRemoteVideoList){
            videoView.setVisibility(View.GONE);
        }
    }

    private void exitRoom(){
        hideRemoteView();
        if(mTXAudioEffectManager != null && mStartPlayMusicFlag){
            mTXAudioEffectManager.stopPlayMusic(mPlayBGMId);
        }
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAllRemoteView();
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.stopLocalPreview();
            mTRTCCloud.exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    private void initView() {
        mRemoteUserIdList       = new ArrayList<>();
        mRemoteVideoList        = new ArrayList<>();

        mImageBack              = findViewById(R.id.iv_back);
        mTextTitle              = findViewById(R.id.tv_room_number);
        mButtonBGM1             = findViewById(R.id.btn_bgm_1);
        mButtonBGM2             = findViewById(R.id.btn_bgm_2);
        mButtonBGM3             = findViewById(R.id.btn_bgm_3);
        mButtonStartPush        = findViewById(R.id.btn_start_push);
        mEditRoomId             = findViewById(R.id.et_room_id);
        mEdituserId             = findViewById(R.id.et_user_id);
        mSeekProgress           = findViewById(R.id.sb_voice_volume);
        mTXCloudPreviewView     = findViewById(R.id.txcvv_main_local);
        mTextVolume             = findViewById(R.id.tv_volume);

        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote1));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote2));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote3));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote4));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote5));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote6));

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);
        mButtonBGM1.setOnClickListener(this);
        mButtonBGM2.setOnClickListener(this);
        mButtonBGM3.setOnClickListener(this);

        mSeekProgress.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Log.d("onStopTrackingTouch", "onStopTrackingTouch : progrsss = " + seekBar.getProgress());
                if(!mStartPushFlag){
                    seekBar.setProgress(100);
                    return;
                }
                mTextVolume.setText(seekBar.getProgress() + "");
                mTXAudioEffectManager.setMusicPublishVolume(mPlayBGMId, seekBar.getProgress());
                mTXAudioEffectManager.setMusicPlayoutVolume(mPlayBGMId, seekBar.getProgress());
            }
        });

        mEdituserId.setText(new Random().nextInt(100000) + 1000000 + "");
        mTextTitle.setText(getString(R.string.bgm_roomid) + ":" + mEditRoomId.getText().toString());
    }

    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.iv_back){
            finish();
        }else if(view.getId() == R.id.btn_start_push){
            String roomId = mEditRoomId.getText().toString();
            String userId = mEdituserId.getText().toString();
            if(!mStartPushFlag){
                if(!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)){
                    mButtonStartPush.setText(R.string.bgm_stop_push);
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                }else{
                    Toast.makeText(SetBGMActivity.this, getString(R.string.bgm_please_input_roomid_userid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonStartPush.setText(R.string.bgm_start_push);
                exitRoom();
                mStartPushFlag = false;
            }

        }else if(view.getId() == R.id.btn_bgm_1){
            if(!mStartPushFlag){
                return;
            }
            if(mPlayBGMId != 1024){
                mPlayBGMId = 1024;
                playMusic();
                mLastPlayBGMId = 1024;
                mButtonBGM1.setBackgroundColor(getResources().getColor(R.color.bgm_button_select));
                mButtonBGM2.setBackgroundColor(getResources().getColor(R.color.bgm_button_select_off));
                mButtonBGM3.setBackgroundColor(getResources().getColor(R.color.bgm_button_select_off));
            }
        }else if(view.getId() == R.id.btn_bgm_2){
            if(!mStartPushFlag){
                return;
            }
            if(mPlayBGMId != 1025){
                mPlayBGMId = 1025;
                playMusic();
                mLastPlayBGMId = 1025;
                mButtonBGM1.setBackgroundColor(getResources().getColor(R.color.bgm_button_select_off));
                mButtonBGM2.setBackgroundColor(getResources().getColor(R.color.bgm_button_select));
                mButtonBGM3.setBackgroundColor(getResources().getColor(R.color.bgm_button_select_off));
            }
        }else if(view.getId() == R.id.btn_bgm_3){
            if(!mStartPushFlag){
                return;
            }
            if(mPlayBGMId != 1026){
                mPlayBGMId = 1026;
                playMusic();
                mLastPlayBGMId = 1026;
                mButtonBGM1.setBackgroundColor(getResources().getColor(R.color.bgm_button_select_off));
                mButtonBGM2.setBackgroundColor(getResources().getColor(R.color.bgm_button_select_off));
                mButtonBGM3.setBackgroundColor(getResources().getColor(R.color.bgm_button_select));
            }
        }

    }

    private void playMusic() {
        if(mStartPlayMusicFlag){
            mTXAudioEffectManager.stopPlayMusic(mLastPlayBGMId);
        }
        TXAudioEffectManager.AudioMusicParam param = new TXAudioEffectManager.AudioMusicParam(mPlayBGMId, mBgmUrlArray[mPlayBGMId - 1024]);
        param.publish = true;
        mTXAudioEffectManager.startPlayMusic(param);
        mStartPlayMusicFlag = true;
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<SetBGMActivity> mContext;

        public TRTCCloudImplListener(SetBGMActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            if(available){
                mRemoteUserIdList.add(userId);
            }else{
                if(mRemoteUserIdList.contains(userId)){
                    mRemoteUserIdList.remove(userId);
                    mTRTCCloud.stopRemoteView(userId);
                }
            }
            refreshRemoteVideo();
        }

        private void refreshRemoteVideo() {
            if(mRemoteUserIdList.size() > 0){
                for(int i =0 ; i < mRemoteUserIdList.size() || i < 6; i++){
                    if(i < mRemoteUserIdList.size() && !TextUtils.isEmpty(mRemoteUserIdList.get(i))){
                        mRemoteVideoList.get(i).setVisibility(View.VISIBLE);
                        mTRTCCloud.startRemoteView(mRemoteUserIdList.get(i),TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mRemoteVideoList.get(i));
                    }else{
                        mRemoteVideoList.get(i).setVisibility(View.GONE);
                    }
                }
            }else{
                for(int i = 0; i < 6; i++){
                    mRemoteVideoList.get(i).setVisibility(View.GONE);
                }
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            SetBGMActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

    @Override
    protected void onPermissionGranted() {
        initView();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }
}
