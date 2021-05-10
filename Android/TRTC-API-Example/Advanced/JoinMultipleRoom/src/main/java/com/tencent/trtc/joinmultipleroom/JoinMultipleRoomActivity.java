package com.tencent.trtc.joinmultipleroom;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

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

/**
 * 加入多个房间页面
 *
 * <p>
 * 包含如下功能:
 * - 创建子 TRTCCloud 实例 {@link TRTCCloud#createSubCloud}
 * - 销毁子 TRTCCloud 实例 {@link TRTCCloud#destroySubCloud}
 * - 详见API说明文档 {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a3c4a93d24e0ef076168b44cf3545a8d4}
 * </p>
 */

/**
 * Entering Multiple Rooms
 *
 * Features:
 * - Create a TRTCCloud instance: {@link TRTCCloud#createSubCloud}
 * - Destroy a TRTCCloud instance: {@link TRTCCloud#destroySubCloud}
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a3c4a93d24e0ef076168b44cf3545a8d4}.
 */
public class JoinMultipleRoomActivity extends TRTCBaseActivity {

    private static final String       TAG                 = "JoinMultipleRoom";

    private TRTCCloud                 mTRTCCloud;
    private List<TRTCSubCloudManager> mTRTCSubCloudManagerList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_join_multiple_room);

        getSupportActionBar().hide();

        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());

        if (checkPermission()) {
            initView();
        }
    }

    private void initView() {
        findViewById(R.id.iv_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mTRTCSubCloudManagerList = new ArrayList<>();
        TRTCSubCloudManager subCloudManager1 = new TRTCSubCloudManager(JoinMultipleRoomActivity.this, mTRTCCloud);
        subCloudManager1.initView(R.id.txcvv_video_remote1, R.id.et_room_id1, R.id.btn_start_play1);
        mTRTCSubCloudManagerList.add(subCloudManager1);

        TRTCSubCloudManager subCloudManager2 = new TRTCSubCloudManager(JoinMultipleRoomActivity.this, mTRTCCloud);
        subCloudManager2.initView(R.id.txcvv_video_remote2, R.id.et_room_id2, R.id.btn_start_play2);
        mTRTCSubCloudManagerList.add(subCloudManager2);

        TRTCSubCloudManager subCloudManager3 = new TRTCSubCloudManager(JoinMultipleRoomActivity.this, mTRTCCloud);
        subCloudManager3.initView(R.id.txcvv_video_remote3, R.id.et_room_id3, R.id.btn_start_play3);
        mTRTCSubCloudManagerList.add(subCloudManager3);

        TRTCSubCloudManager subCloudManager4 = new TRTCSubCloudManager(JoinMultipleRoomActivity.this, mTRTCCloud);
        subCloudManager4.initView(R.id.txcvv_video_remote4, R.id.et_room_id4, R.id.btn_start_play4);
        mTRTCSubCloudManagerList.add(subCloudManager4);
    }

    private void destroyRoom() {
        if (mTRTCSubCloudManagerList != null) {
            for (TRTCSubCloudManager trtcSubCloudManager : mTRTCSubCloudManagerList) {
                trtcSubCloudManager.destroyRoom();
            }
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    protected static class TRTCSubCloudManager {

        private TXCloudVideoView mRemoteVideo;
        private Button           mButtonStartPlay;
        private EditText         mEditRoomId;

        private TRTCCloud        mTRTCCloud;
        private TRTCCloud        mSubCloud;
        private boolean          mStartPlayFlag = false;

        private WeakReference<JoinMultipleRoomActivity> mContext;

        public TRTCSubCloudManager(JoinMultipleRoomActivity activity, TRTCCloud tRTCCloud) {
            super();
            mContext = new WeakReference<>(activity);
            mTRTCCloud = tRTCCloud;
            mSubCloud = mTRTCCloud.createSubCloud();
            mSubCloud.setListener(new TRTCCloudImplListener());
        }

        public void initView(int remoteViewResId, int editTextResId, int buttonResId) {
            JoinMultipleRoomActivity activity = mContext.get();
            if (activity != null) {
                mRemoteVideo = activity.findViewById(remoteViewResId);
                mEditRoomId = activity.findViewById(editTextResId);
                mButtonStartPlay = activity.findViewById(buttonResId);
                mButtonStartPlay.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (!mStartPlayFlag) {
                            String roomId = mEditRoomId.getText().toString();
                            String time = String.valueOf(System.currentTimeMillis());
                            String userId = time.substring(time.length() - 8);
                            enterRoom(roomId, userId);
                            mButtonStartPlay.setText(activity.getText(R.string.joinmultipleroom_stop_play));
                        } else {
                            exitRoom();
                            mButtonStartPlay.setText(activity.getText(R.string.joinmultipleroom_start_play));
                        }

                        mStartPlayFlag = !mStartPlayFlag;
                    }
                });
            }
        }

        private void enterRoom(String roomId, String userId) {
            TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
            mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
            mTRTCParams.userId = userId;
            mTRTCParams.roomId = Integer.parseInt(roomId);
            mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
            mTRTCParams.role = TRTCCloudDef.TRTCRoleAudience;

            mSubCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
        }

        private void exitRoom() {
            if (mSubCloud != null) {
                mSubCloud.stopAllRemoteView();
                mSubCloud.stopLocalAudio();
                mSubCloud.stopLocalPreview();
                mSubCloud.exitRoom();
            }
        }

        public void destroyRoom() {
            if (mSubCloud != null) {
                exitRoom();
                mSubCloud.setListener(null);
            }

            if (mTRTCCloud != null) {
                mTRTCCloud.destroySubCloud(mSubCloud);
            }
        }

        protected class TRTCCloudImplListener extends TRTCCloudListener {

            @Override
            public void onUserVideoAvailable(String userId, boolean available) {
                if (available) {
                    mSubCloud.startRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mRemoteVideo);
                } else {
                    mSubCloud.stopRemoteView(userId);
                }
            }

            @Override
            public void onExitRoom(int i) {
                mSubCloud.stopAllRemoteView();
            }

            @Override
            public void onError(int errCode, String errMsg, Bundle extraInfo) {
                Log.d(TAG, "sdk callback onError");
                JoinMultipleRoomActivity activity = mContext.get();
                if (activity != null) {
                    Toast.makeText(activity, "onError: " + errMsg + "[" + errCode + "]", Toast.LENGTH_SHORT).show();
                    if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                        exitRoom();
                    }
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
        destroyRoom();
    }
}