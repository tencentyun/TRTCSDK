package com.tencent.trtc.audioquality;

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
 * TRTC设置音频质量页面
 *
 * 包含如下简单功能：
 * - 设置音频质量{@link TRTCCloud#startLocalAudio(int)},其方法中参数为音频质量参数。
 * - 设置音频采集音量{@link TRTCCloud#setAudioCaptureVolume(int)}
 *
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a6af5e2c4819a683042f382688aff41e9}
 */

/**
 * Setting Audio Quality
 *
 * Features:
 * - Set audio quality: {@link TRTCCloud#startLocalAudio(int)}. The parameter in the API indicates audio quality.
 * - Set the audio capturing volume: {@link TRTCCloud#setAudioCaptureVolume(int)}
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a6af5e2c4819a683042f382688aff41e9}.
 */
public class SetAudioQualityActivity extends TRTCBaseActivity implements View.OnClickListener {
    private static final String     TAG = "SetAudioQualityActivity";

    private ImageView               mImageBack;
    private TextView                mTextTitle;
    private SeekBar                 mSeekProgress;
    private Button                  mButtonQualityDefault;
    private Button                  mButtonQualitySpeech;
    private Button                  mButtonQualityMusic;
    private Button                  mButtonStartPush;
    private EditText                mEditRoomId;
    private EditText                mEdituserId;
    private TXCloudVideoView        mTXCloudPreviewView;
    private List<TXCloudVideoView>  mRemoteVideoList;
    private TextView                mTextVolume;

    private TRTCCloud               mTRTCCloud;
    private int                     mQualityFlag = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
    private List<String>            mRemoteUserIdList;
    private boolean                 mStartPushFlag = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.audioquality_activity_set);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
    }

    private void enterRoom(String roomId,  String userId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(SetAudioQualityActivity.this));
        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = userId;
        mTRTCParams.roomId = Integer.parseInt(roomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(true, mTXCloudPreviewView);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
    }
    private void hideRemoteView(){
        mRemoteUserIdList.clear();
        for(TXCloudVideoView videoView : mRemoteVideoList){
            videoView.setVisibility(View.GONE);
        }
    }

    private void exitRoom(){
        hideRemoteView();
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
        mButtonQualityDefault   = findViewById(R.id.btn_quality_default);
        mButtonQualitySpeech    = findViewById(R.id.btn_quality_speech);
        mButtonQualityMusic     = findViewById(R.id.btn_quality_music);
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
        mButtonQualityDefault.setOnClickListener(this);
        mButtonQualitySpeech.setOnClickListener(this);
        mButtonQualityMusic.setOnClickListener(this);

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
                mTRTCCloud.setAudioCaptureVolume(seekBar.getProgress());
            }
        });

        mEdituserId.setText(new Random().nextInt(100000) + 1000000 + "");
        mTextTitle.setText(getString(R.string.audioquality_roomid) + ":" + mEditRoomId.getText().toString());
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
                    mButtonStartPush.setText(R.string.audioquality_stop_push);
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                }else{
                    Toast.makeText(SetAudioQualityActivity.this, getString(R.string.audioquality_please_input_roomid_userid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonStartPush.setText(R.string.audioquality_start_push);
                exitRoom();
                mStartPushFlag = false;
            }

        }else if(view.getId() == R.id.btn_quality_default){
            if(!mStartPushFlag){
                return;
            }
            if(mQualityFlag != TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT){
                mQualityFlag = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
                mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
                mButtonQualityDefault.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select));
                mButtonQualitySpeech.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select_off));
                mButtonQualityMusic.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select_off));
            }
        }else if(view.getId() == R.id.btn_quality_speech){
            if(!mStartPushFlag){
                return;
            }
            if(mQualityFlag != TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH){
                mQualityFlag = TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH;
                mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
                mButtonQualityDefault.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select_off));
                mButtonQualitySpeech.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select));
                mButtonQualityMusic.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select_off));
            }
        }else if(view.getId() == R.id.btn_quality_music){
            if(!mStartPushFlag){
                return;
            }
            if(mQualityFlag != TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC){
                mQualityFlag = TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC;
                mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);
                mButtonQualityDefault.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select_off));
                mButtonQualitySpeech.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select_off));
                mButtonQualityMusic.setBackgroundColor(getResources().getColor(R.color.audioquality_button_select));
            }
        }

    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<SetAudioQualityActivity> mContext;

        public TRTCCloudImplListener(SetAudioQualityActivity activity) {
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
            SetAudioQualityActivity activity = mContext.get();
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
