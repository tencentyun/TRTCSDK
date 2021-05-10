package com.tencent.trtc.screenshare;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;
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

import static com.tencent.trtc.TRTCCloudDef.TRTCRoleAudience;
import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_LIVE;

/**
 * TRTC 屏幕分享的观众页面
 *
 * 包含如下简单功能：
 * - 进入直播共享房间{@link ScreenAudienceActvity#enterRoom()}
 * - 退出直播共享房间{@link ScreenAudienceActvity#exitRoom()}
 * - 监听到分享之后观看分享{@link ScreenAudienceActvity.TRTCCloudImplListener#onUserVideoAvailable(String, boolean) 方法中的 {@link TRTCCloud#startRemoteView }}
 *
 * - 详见API文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#aa6671fc587513dad7df580556e43be58}
 */

/**
 * Screen Sharing View for Audience
 *
 * Features:
 * - Enter a room: {@link ScreenAudienceActvity#enterRoom()}
 * - Exit a room: {@link ScreenAudienceActvity#exitRoom()}
 * - After receiving the callback of screen sharing, watch screen sharing streams: {@link TRTCCloud#startRemoteView} in {@link ScreenAudienceActvity.TRTCCloudImplListener#onUserVideoAvailable(String, boolean)}}
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#aa6671fc587513dad7df580556e43be58}.
 */
public class ScreenAudienceActvity extends TRTCBaseActivity {
    private static final String TAG = "ScreenAudienceActvity";

    private TRTCCloud          mTRTCCloud;
    private TXCloudVideoView   mScreenShareView;
    private LinearLayout       mLLRoomInfo;

    private String             mRoomId;
    private String             mUserId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.screenshare_activity_audience);
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
            }else{
                finish();
            }
            if (intent.getStringExtra(Constant.ROOM_ID) != null) {
                mRoomId = intent.getStringExtra(Constant.ROOM_ID);
            }else{
                finish();
            }
        }
    }

    private void initView() {
        mScreenShareView = findViewById(R.id.live_cloud_remote_screenshare);
        ((TextView)findViewById(R.id.trtc_tv_room_number)).setText(mRoomId);
        mLLRoomInfo = findViewById(R.id.ll_room_info);
        findViewById(R.id.trtc_ic_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
    }

    protected void enterRoom() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(ScreenAudienceActvity.this));

        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = mUserId;
        mTRTCParams.roomId = Integer.parseInt(mRoomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCRoleAudience;

        mTRTCCloud.enterRoom(mTRTCParams, TRTC_APP_SCENE_LIVE);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }

    private class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<ScreenAudienceActvity> mContext;

        public TRTCCloudImplListener(ScreenAudienceActvity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onFirstVideoFrame(String s, int i, int i1, int i2) {
            super.onFirstVideoFrame(s, i, i1, i2);

        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            Log.d(TAG, "onUserVideoAvailable userId " + userId + ",available " + available);
            if(available){
                mLLRoomInfo.setVisibility(View.GONE);
                mScreenShareView.setVisibility(View.VISIBLE);
                mTRTCCloud.startRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, mScreenShareView);
            }else{
                mLLRoomInfo.setVisibility(View.VISIBLE);
                mScreenShareView.setVisibility(View.GONE);
                mTRTCCloud.stopRemoteView(userId);
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            ScreenAudienceActvity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    exitRoom();
                }
            }
        }
    }

    private void exitRoom() {
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
