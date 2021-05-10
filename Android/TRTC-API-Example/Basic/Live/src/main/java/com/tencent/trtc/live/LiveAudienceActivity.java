package com.tencent.trtc.live;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.Constant;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;

import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_LIVE;

/**
 * TRTC 观众视角下的RTC视频互动直播房间页面
 *
 * 包含如下简单功能：
 * - 进入直播房间{@link LiveAudienceActivity#enterRoom()}
 * - 退出直播房间{@link LiveAudienceActivity#exitRoom()}
 * - 静音{@link LiveAudienceActivity#muteAudio()}
 *
 * - 详见接入文档{https://cloud.tencent.com/document/product/647/43182}
 */

/**
 * Room View of Interactive Live Video Streaming for Audience
 *
 * Features:
 * - Enter a room: {@link LiveAudienceActivity#enterRoom()}
 * - Exit a room: {@link LiveAudienceActivity#exitRoom()}
 * - Mute: {@link LiveAudienceActivity#muteAudio()}
 *
 * - For more information, please see the integration document {https://cloud.tencent.com/document/product/647/43182}.
 */
public class LiveAudienceActivity extends TRTCBaseActivity implements View.OnClickListener {
    private static final String             TAG                     = "LiveAudienceActivity";

    private TXCloudVideoView                mTxcvvAnchorPreviewView;
    private ImageView                       mImageBack;
    private TextView                        mTextTitle;
    private Button                          mButtonMuteAudio;

    private TRTCCloud                       mTRTCCloud;
    private TRTCCloudDef.TRTCParams         mTRTCParams;

    private String                          mRoomId;
    private String                          mUserId;
    private String                          mRemoteUserId;
    private boolean                         mMuteAudioFlag = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.live_activity_audience);
        getSupportActionBar().hide();
        handleIntent();

        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(LiveAudienceActivity.this));
        if (checkPermission()) {
            initView();
            enterRoom();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
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
        mImageBack = findViewById(R.id.iv_back);
        mTextTitle = findViewById(R.id.tv_room_number);
        mButtonMuteAudio = findViewById(R.id.btn_remote_mute_audio);
        mTxcvvAnchorPreviewView = findViewById(R.id.live_cloud_view_main);

        ((TextView)findViewById(R.id.tv_room_number)).setText(mRoomId);

        if (!TextUtils.isEmpty(mRoomId)) {
            mTextTitle.setText(getString(R.string.live_roomid) + mRoomId);
        }
        mImageBack.setOnClickListener(this);
        mButtonMuteAudio.setOnClickListener(this);
        mTRTCCloud.setListener(new TRTCCloudImplListener(LiveAudienceActivity.this));
    }

    protected void enterRoom() {
        mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = mUserId;
        mTRTCParams.roomId = Integer.parseInt(mRoomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role =TRTCCloudDef.TRTCRoleAudience;

        mTRTCCloud.enterRoom(mTRTCParams, TRTC_APP_SCENE_LIVE);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.btn_remote_mute_audio) {
            muteAudio();
        } else if (id == R.id.iv_back) {
            finish();
        }
    }

    private void muteAudio() {
        mMuteAudioFlag = !mMuteAudioFlag;
        if(mMuteAudioFlag){
            if(!TextUtils.isEmpty(mRemoteUserId)){
                mTRTCCloud.muteRemoteAudio(mRemoteUserId, true);
            }
            mButtonMuteAudio.setText( getString(R.string.live_close_mute_audio));
        } else {
            if(!TextUtils.isEmpty(mRemoteUserId)){
                mTRTCCloud.muteRemoteAudio(mRemoteUserId,false);
            }
            mButtonMuteAudio.setText( getString(R.string.live_mute));
        }
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<LiveAudienceActivity> mContext;

        public TRTCCloudImplListener(LiveAudienceActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            Log.d(TAG, "onUserVideoAvailable  available " + available + " userId " + userId);
            if (available) {
                mRemoteUserId = userId;
                mTRTCCloud.startRemoteView(mRemoteUserId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, mTxcvvAnchorPreviewView);
            } else {
                mRemoteUserId = "";
                mTRTCCloud.stopRemoteView(mRemoteUserId);
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            LiveAudienceActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

    protected void exitRoom() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.stopLocalPreview();
            mTRTCCloud.exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    @Override
    protected void onPermissionGranted() {
        initView();
        enterRoom();
    }
}
