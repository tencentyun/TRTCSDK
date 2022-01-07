package com.tencent.trtc.audiocall;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.Constant;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/**
 * TRTC 语音通话的主页面
 *
 * 包含如下简单功能：
 * - 进入语音通话房间{@link AudioCallingActivity#enterRoom()}
 * - 退出语音通话房间{@link AudioCallingActivity#exitRoom()}
 * - 关闭/打开麦克风{@link AudioCallingActivity#muteAudio()}
 * - 免提(听筒/扬声器切换){@link AudioCallingActivity#audioRoute()}
 *
 * - 详见接入文档{https://cloud.tencent.com/document/product/647/42047}
 */

/**
 * Audio Call
 *
 * Features:
 * - Enter an audio call room: {@link AudioCallingActivity#enterRoom()}
 * - Exit an audio call room: {@link AudioCallingActivity#exitRoom()}
 * - Turn on/off the mic: {@link AudioCallingActivity#muteAudio()}
 * - Switch between the speaker (hands-free mode) and receiver: {@link AudioCallingActivity#audioRoute()}
 *
 * - For more information, please see the integration document {https://cloud.tencent.com/document/product/647/42047}.
 */
public class AudioCallingActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String             TAG = "AudioCallingActivity";
    private static final int                MAX_USER_COUNT = 6;

    private TextView                        mTextTitle;
    private ImageView                       mImageBack;
    private List<LinearLayout>              mListUserView;
    private List<TextView>                  mListUserIdView;
    private List<TextView>                  mListVoiceInfo;
    private List<TextView>                  mListNetWorkInfo;
    private Button                          mButtonMuteAudio;
    private Button                          mButtonAudioRoute;
    private Button                          mButtonHangUp;

    private TRTCCloud                       mTRTCCloud;
    private String                          mRoomId;
    private String                          mUserId;
    private boolean                         mAudioRouteFlag = true;
    private List<String>                    mRemoteUserList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.audiocall_activity_calling);
        getSupportActionBar().hide();
        handleIntent();

        if (checkPermission()) {
            initView();
            enterRoom();
        }
    }

    private void handleIntent() {
        Intent intent = getIntent();
        if (null != intent) {
            if (intent.getStringExtra(Constant.USER_ID) != null) {
                mUserId = intent.getStringExtra(Constant.USER_ID);
            }
            if (intent.getStringExtra(Constant.ROOM_ID) != null) {
                mRoomId = intent.getStringExtra(Constant.ROOM_ID);
            }
        }
    }

    protected void initView() {
        mTextTitle = findViewById(R.id.tv_room_number);
        mImageBack = findViewById(R.id.iv_back);
        mButtonMuteAudio = findViewById(R.id.btn_mute_audio);
        mButtonAudioRoute = findViewById(R.id.btn_audio_route);
        mButtonHangUp = findViewById(R.id.btn_hangup);

        mListUserView       = new ArrayList<>();
        mListUserIdView     = new ArrayList<>();
        mListVoiceInfo      = new ArrayList<>();
        mListNetWorkInfo    = new ArrayList<>();

        mListUserView.add((LinearLayout)findViewById(R.id.ll_user1));
        mListUserView.add((LinearLayout)findViewById(R.id.ll_user2));
        mListUserView.add((LinearLayout)findViewById(R.id.ll_user3));
        mListUserView.add((LinearLayout)findViewById(R.id.ll_user4));
        mListUserView.add((LinearLayout)findViewById(R.id.ll_user5));
        mListUserView.add((LinearLayout)findViewById(R.id.ll_user6));

        mListUserIdView.add((TextView)findViewById(R.id.tv_user1));
        mListUserIdView.add((TextView)findViewById(R.id.tv_user2));
        mListUserIdView.add((TextView)findViewById(R.id.tv_user3));
        mListUserIdView.add((TextView)findViewById(R.id.tv_user4));
        mListUserIdView.add((TextView)findViewById(R.id.tv_user5));
        mListUserIdView.add((TextView)findViewById(R.id.tv_user6));

        mListVoiceInfo.add((TextView)findViewById(R.id.tv_voice1));
        mListVoiceInfo.add((TextView)findViewById(R.id.tv_voice2));
        mListVoiceInfo.add((TextView)findViewById(R.id.tv_voice3));
        mListVoiceInfo.add((TextView)findViewById(R.id.tv_voice4));
        mListVoiceInfo.add((TextView)findViewById(R.id.tv_voice5));
        mListVoiceInfo.add((TextView)findViewById(R.id.tv_voice6));

        mListNetWorkInfo.add((TextView)findViewById(R.id.tv_network1));
        mListNetWorkInfo.add((TextView)findViewById(R.id.tv_network2));
        mListNetWorkInfo.add((TextView)findViewById(R.id.tv_network3));
        mListNetWorkInfo.add((TextView)findViewById(R.id.tv_network4));
        mListNetWorkInfo.add((TextView)findViewById(R.id.tv_network5));
        mListNetWorkInfo.add((TextView)findViewById(R.id.tv_network6));

        mButtonAudioRoute.setSelected(mAudioRouteFlag);
        if (!TextUtils.isEmpty(mRoomId)) {
            mTextTitle.setText(getString(R.string.audiocall_roomid) + mRoomId);
        }
        mImageBack.setOnClickListener(this);
        mButtonMuteAudio.setOnClickListener(this);
        mButtonAudioRoute.setOnClickListener(this);
        mButtonHangUp.setOnClickListener(this);

        refreshUserView();
    }

    @Override
    protected void onPermissionGranted() {
        initView();
        enterRoom();
    }

    protected void enterRoom() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(AudioCallingActivity.this));

        TRTCCloudDef.TRTCParams trtcParams = new TRTCCloudDef.TRTCParams();
        trtcParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        trtcParams.userId = mUserId;
        trtcParams.roomId = Integer.parseInt(mRoomId);
        trtcParams.userSig = GenerateTestUserSig.genTestUserSig(trtcParams.userId);

        mTRTCCloud.enableAudioVolumeEvaluation(2000);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
        mTRTCCloud.enterRoom(trtcParams, TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }

    private void exitRoom() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.iv_back) {
            finish();
        } else if (id == R.id.btn_mute_audio) {
            muteAudio();
        } else if (id == R.id.btn_audio_route) {
            audioRoute();
        } else if (id == R.id.btn_hangup){
            hangUp();
        }
    }

    private void hangUp() {
        finish();
    }

    private void audioRoute() {
        mAudioRouteFlag = !mAudioRouteFlag;
        mButtonAudioRoute.setSelected(mAudioRouteFlag);
        if(mAudioRouteFlag){
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
            mButtonAudioRoute.setText(getString(R.string.audiocall_use_receiver));
        }else{
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
            mButtonAudioRoute.setText(getString(R.string.audiocall_use_speaker));
        }
    }


    private void muteAudio() {
        boolean isSelected = mButtonMuteAudio.isSelected();
        if (!isSelected) {
            mTRTCCloud.muteLocalAudio(true);
            mButtonMuteAudio.setText( getString(R.string.audiocall_stop_mute_audio));
        } else {
            mTRTCCloud.muteLocalAudio(false);
            mButtonMuteAudio.setText( getString(R.string.audiocall_mute_audio));
        }
        mButtonMuteAudio.setSelected(!isSelected);
    }

    private class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<AudioCallingActivity> mContext;

        public TRTCCloudImplListener(AudioCallingActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> arrayList, int i) {
            Log.d(TAG, "onUserVoiceVolume:i = " + i);
            if (arrayList != null && arrayList.size() > 0) {
                Log.d(TAG, "onUserVoiceVolume:arrayList.size = " + arrayList.size());
                int index = 0;
                for (TRTCCloudDef.TRTCVolumeInfo info : arrayList) {
                    if (info != null && !mUserId.equals(info.userId) && index < MAX_USER_COUNT) {
                        Log.d(TAG, "onUserVoiceVolume:userId = " + info.userId + ", volume = " + info.volume);
                        mListVoiceInfo.get(index).setVisibility(View.VISIBLE);
                        mListVoiceInfo.get(index).setText(info.userId + ":" + info.volume);
                        index++;
                    }
                }
                for (int j = index; j < MAX_USER_COUNT; j++) {
                    mListVoiceInfo.get(j).setVisibility(View.GONE);
                }
            }
        }

        @Override
        public void onNetworkQuality(TRTCCloudDef.TRTCQuality trtcQuality, ArrayList<TRTCCloudDef.TRTCQuality> arrayList) {
            Log.d(TAG, "onNetworkQuality");
            if (arrayList != null && arrayList.size() > 0) {
                int index = 0;
                for (TRTCCloudDef.TRTCQuality info : arrayList) {
                    if (info != null && index < MAX_USER_COUNT) {
                        Log.d(TAG, "onNetworkQuality:userId = " + info.userId + ", quality = " + info.quality);
                        mListNetWorkInfo.get(index).setText(info.userId + ":" + NetQuality.getMsg(info.quality));
                        mListNetWorkInfo.get(index).setVisibility(View.VISIBLE);
                        index++;
                    }
                }
                for (int j = index; j < MAX_USER_COUNT; j++) {
                    mListNetWorkInfo.get(j).setVisibility(View.GONE);
                }
            }
        }

        @Override
        public void onRemoteUserEnterRoom(String s) {
            Log.d(TAG, "onRemoteUserEnterRoom userId " + s);
            mRemoteUserList.add(s);
            refreshUserView();
        }

        @Override
        public void onRemoteUserLeaveRoom(String s, int i) {
            Log.d(TAG, "onRemoteUserLeaveRoom userId " + s);
            mRemoteUserList.remove(s);
            refreshUserView();
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            AudioCallingActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

    private void refreshUserView() {
        if (mRemoteUserList != null) {
            for (int i = 0; i < MAX_USER_COUNT; i++) {
                if (i < mRemoteUserList.size()) {
                    mListUserView.get(i).setVisibility(View.VISIBLE);
                    mListUserIdView.get(i).setText(mRemoteUserList.get(i));
                } else {
                    mListUserView.get(i).setVisibility(View.GONE);
                }
            }
        }
    }

    public enum NetQuality{
        UNKNOW(0, "未定义"),
        EXCELLENT(1, "最好"),
        GOOD(2, "好"),
        POOR(3, "一般"),
        BAD(4, "差"),
        VBAD(5, "很差"),
        DOWN(6, "不可用");

        private int     code;
        private String  msg;

        NetQuality(int code, String msg){
            this.code = code;
            this.msg  = msg;
        }

        public static String getMsg(int code){
            for (NetQuality item : NetQuality.values()) {
                if (item.code == code){
                    return item.msg;
                }
            }
            return "未定义";
        }
    }

}
