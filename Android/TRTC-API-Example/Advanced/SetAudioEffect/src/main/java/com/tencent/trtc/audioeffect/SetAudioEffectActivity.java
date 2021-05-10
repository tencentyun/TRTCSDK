package com.tencent.trtc.audioeffect;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
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
 * TRTC设置音效页面
 *
 * 具体步骤如下：
 * - 1.获取音效管理类{@link TRTCCloud#getAudioEffectManager()} 返回对象{@link TXAudioEffectManager}
 * - 2.使用音效管理类设置音效{@link TXAudioEffectManager#setVoiceChangerType(TXAudioEffectManager.TXVoiceChangerType)}
 * - 3.使用音效管理类设置混响效果{@link TXAudioEffectManager#setVoiceReverbType(TXAudioEffectManager.TXVoiceReverbType)}
 *
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TXAudioEffectManager__android.html#adad5c18fa6883bef2edae8bc343bcec2}
 */

/**
 * Setting Audio Effects

 * The steps are detailed below:
 * - 1. Get the audio effect management class {@link TXAudioEffectManager}: {@link TRTCCloud#getAudioEffectManager()}
 * - 2. Set audio effects: {@link TXAudioEffectManager#setVoiceChangerType(TXAudioEffectManager.TXVoiceChangerType)}
 * - 3. Set reverb effects: {@link TXAudioEffectManager#setVoiceReverbType(TXAudioEffectManager.TXVoiceReverbType)}

 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TXAudioEffectManager__android.html#adad5c18fa6883bef2edae8bc343bcec2}.
 */
public class SetAudioEffectActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String     TAG                     = "SetVideoQualityActivity";

    private EditText                mEditRoomId;
    private EditText                mEdituserId;
    private TXCloudVideoView        mTXCloudPreviewView;
    private List<TXCloudVideoView>  mRemoteVideoList;
    private Button                  mButtonEffectDefault;
    private Button                  mButtonEffectChild;
    private Button                  mButtonEffectLolita;
    private Button                  mButtonEffectMetal;
    private Button                  mButtonEffectUncle;
    private Button                  mButtonReverbDefault;
    private Button                  mButtonReverbKTV;
    private Button                  mButtonReverbSmall;
    private Button                  mButtonReverbBig;
    private Button                  mButtonReverbLow;
    private Button                  mButtonStartPush;
    private ImageView               mImageBack;
    private TextView                mTextTitle;

    private TRTCCloud               mTRTCCloud;
    private TXAudioEffectManager    mTXAudioEffectManager;
    private List<String>            mRemoteUserIdList;
    private boolean                 mStartPushFlag      = false;

    private TXAudioEffectManager.TXVoiceChangerType mEffectFlag = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
    private TXAudioEffectManager.TXVoiceReverbType  mReverbFlag = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.audioeffect_activity_set);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
    }

    private void initView() {
        mRemoteUserIdList       = new ArrayList<>();
        mRemoteVideoList        = new ArrayList<>();

        mEditRoomId             = findViewById(R.id.et_room_id);
        mEdituserId             = findViewById(R.id.et_user_id);
        mImageBack              = findViewById(R.id.iv_back);
        mTextTitle              = findViewById(R.id.tv_room_number);
        mTXCloudPreviewView     = findViewById(R.id.txcvv_main_local);
        mButtonEffectDefault    = findViewById(R.id.btn_effect_default);
        mButtonEffectChild      = findViewById(R.id.btn_effect_child);
        mButtonEffectLolita     = findViewById(R.id.btn_effect_lolita);
        mButtonEffectMetal      = findViewById(R.id.btn_effect_metal);
        mButtonEffectUncle      = findViewById(R.id.btn_effect_uncle);

        mButtonReverbDefault    = findViewById(R.id.btn_reverb_default);
        mButtonReverbKTV        = findViewById(R.id.btn_reverb_ktv);
        mButtonReverbSmall      = findViewById(R.id.btn_reverb_small);
        mButtonReverbBig        = findViewById(R.id.btn_reverb_big);
        mButtonReverbLow        = findViewById(R.id.btn_reverb_low);

        mButtonStartPush        = findViewById(R.id.btn_start_push);

        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote1));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote2));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote3));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote4));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote5));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote6));

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);
        mButtonEffectDefault.setOnClickListener(this);
        mButtonEffectChild.setOnClickListener(this);
        mButtonEffectLolita.setOnClickListener(this);
        mButtonEffectMetal.setOnClickListener(this);
        mButtonEffectUncle.setOnClickListener(this);

        mButtonReverbDefault.setOnClickListener(this);
        mButtonReverbKTV.setOnClickListener(this);
        mButtonReverbSmall.setOnClickListener(this);
        mButtonReverbBig.setOnClickListener(this);
        mButtonReverbLow.setOnClickListener(this);

        mEdituserId.setText(new Random().nextInt(100000) + 1000000 + "");
        mTextTitle.setText(getString(R.string.audioeffect_roomid) + ":" + mEditRoomId.getText().toString());
    }

    private void enterRoom(String roomId,  String userId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(SetAudioEffectActivity.this));
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

    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.iv_back){
            finish();
        }else if(view.getId() == R.id.btn_start_push){
            String roomId = mEditRoomId.getText().toString();
            String userId = mEdituserId.getText().toString();
            if(!mStartPushFlag){
                if(!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)){
                    mButtonStartPush.setText(getString(R.string.audioeffect_stop_push));
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                }else{
                    Toast.makeText(SetAudioEffectActivity.this, getString(R.string.audioeffect_please_input_roomid_and_userid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonStartPush.setText(getString(R.string.audioeffect_start_push));
                exitRoom();
                mStartPushFlag = false;
            }

        }else if(view.getId() == R.id.btn_effect_default){
            if(!mStartPushFlag){
                return;
            }
            mEffectFlag =  TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
            mTXAudioEffectManager.setVoiceChangerType(TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0);
        }else if(view.getId() == R.id.btn_effect_child){
            if(!mStartPushFlag){
                return;
            }
            mEffectFlag =  TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_1;
            mTXAudioEffectManager.setVoiceChangerType(TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_1);
        }else if(view.getId() == R.id.btn_effect_lolita){
            if(!mStartPushFlag){
                return;
            }
            mEffectFlag =  TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_2;
            mTXAudioEffectManager.setVoiceChangerType(TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_2);
        }else if(view.getId() == R.id.btn_effect_metal){
            if(!mStartPushFlag){
                return;
            }
            mEffectFlag =  TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_4;
            mTXAudioEffectManager.setVoiceChangerType(TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_4);
        }else if(view.getId() == R.id.btn_effect_uncle){
            if(!mStartPushFlag){
                return;
            }
            mEffectFlag =  TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_3;
            mTXAudioEffectManager.setVoiceChangerType(TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_3);
        }else if(view.getId() == R.id.btn_reverb_default){
            if(!mStartPushFlag){
                return;
            }
            mReverbFlag =  TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
            mTXAudioEffectManager.setVoiceReverbType(TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0);
        }else if(view.getId() == R.id.btn_reverb_ktv){
            if(!mStartPushFlag){
                return;
            }
            mReverbFlag =  TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_1;
            mTXAudioEffectManager.setVoiceReverbType(TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_1);
        }else if(view.getId() == R.id.btn_reverb_small){
            if(!mStartPushFlag){
                return;
            }
            mReverbFlag =  TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_2;
            mTXAudioEffectManager.setVoiceReverbType(TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_2);
        }else if(view.getId() == R.id.btn_reverb_big){
            if(!mStartPushFlag){
                return;
            }
            mReverbFlag =  TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_3;
            mTXAudioEffectManager.setVoiceReverbType(TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_3);
        }else if(view.getId() == R.id.btn_reverb_low){
            if(!mStartPushFlag){
                return;
            }
            mReverbFlag =  TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_4;
            mTXAudioEffectManager.setVoiceReverbType(TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_4);
        }

    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<SetAudioEffectActivity> mContext;

        public TRTCCloudImplListener(SetAudioEffectActivity activity) {
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
                        mTRTCCloud.startRemoteView(mRemoteUserIdList.get(i), TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mRemoteVideoList.get(i));
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
            SetAudioEffectActivity activity = mContext.get();
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
