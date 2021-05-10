package com.tencent.trtc.pk;

import android.annotation.SuppressLint;
import android.os.Build;
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
import androidx.annotation.RequiresApi;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.GenerateTestUserSig;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.Random;

/**
 * TRTC跨房连麦-PK功能
 *
 * 包含如下简单功能：
 * - A主播跨房连麦B主播{@link TRTCCloud#ConnectOtherRoom(String)}
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#ac1ab7e4a017b99bb91d89ce1b0fac5fd}
 */

/**
 * Cross-room Co-anchoring
 *
 * Features:
 * - Anchor A co-anchors with anchor B: {@link TRTCCloud#ConnectOtherRoom(String)}
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#ac1ab7e4a017b99bb91d89ce1b0fac5fd}.
 *
 */
public class RoomPKActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String     TAG                     = "ConnectOtherRoom";

    private ImageView               mImageBack;
    private TextView                mTextTitle;
    private Button                  mButtonStartPush;
    private Button                  mButtonStartPK;
    private EditText                mEditRoomId;
    private EditText                mEditUserId;
    private EditText                mEditRemoteRoomId;
    private EditText                mEditRemoteUserId;
    private TXCloudVideoView        mTXCloudPreviewView;
    private TXCloudVideoView        mTXCloudRemoteView;


    private TRTCCloud               mTRTCCloud;
    private boolean                 mStartPushFlag      = false;
    private boolean                 mStartPKFlag        = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.connectotherroom_activity_set);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
    }

    private void initView() {
        mImageBack              = findViewById(R.id.iv_back);
        mTextTitle              = findViewById(R.id.tv_room_number);
        mButtonStartPush        = findViewById(R.id.btn_start_push);
        mButtonStartPK          = findViewById(R.id.btn_start_pk);
        mEditRoomId             = findViewById(R.id.et_room_id);
        mEditUserId             = findViewById(R.id.et_user_id);
        mEditRemoteRoomId       = findViewById(R.id.et_remote_room_id);
        mEditRemoteUserId       = findViewById(R.id.et_remote_user_id);
        mTXCloudPreviewView     = findViewById(R.id.txcvv_main_local);
        mTXCloudRemoteView      = findViewById(R.id.txcvv_video_remote);

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);
        mButtonStartPK.setOnClickListener(this);

        mEditUserId.setText(new Random().nextInt(100000) + 1000000 + "");
        mTextTitle.setText(getString(R.string.connectotherroom_roomid) + ":" + mEditRoomId.getText().toString());
    }

    private void enterRoom(String roomId,  String userId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(RoomPKActivity.this));
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

    private void exitRoom(){
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

    @SuppressLint("SetTextI18n")
    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.iv_back){
            finish();
        }else if(view.getId() == R.id.btn_start_push){
            String roomId = mEditRoomId.getText().toString();
            String userId = mEditUserId.getText().toString();
            if(!mStartPushFlag){
                if(!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)){
                    mButtonStartPush.setText(getString(R.string.connectotherroom_stop_push));
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                }else{
                    Toast.makeText(RoomPKActivity.this, getString(R.string.connectotherroom_please_input_roomid_and_userid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonStartPush.setText(getString(R.string.connectotherroom_start_push));
                exitRoom();
                mStartPushFlag = false;
            }

        }else if(view.getId() == R.id.btn_start_pk){
            if(!mStartPushFlag){
                return;
            }
            String roomId = mEditRemoteRoomId.getText().toString();
            String userId = mEditRemoteUserId.getText().toString();
            if(!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)){
                if(mStartPKFlag){
                    mButtonStartPK.setText(getString(R.string.connectotherroom_start_pk));
                    mTRTCCloud.DisconnectOtherRoom();
                    mStartPKFlag = false;
                }else{
                    try {
                        JSONObject jsonObj = new JSONObject();
                        jsonObj.put("strRoomId", roomId);
                        jsonObj.put("userId", userId);
                        mTRTCCloud.ConnectOtherRoom(jsonObj.toString());
                        mButtonStartPK.setText(R.string.connectotherroom_stop_pk);
                        mStartPKFlag = true;
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }else{
                Toast.makeText(RoomPKActivity.this, getString(R.string.connectotherroom_please_input_roomid_and_userid), Toast.LENGTH_SHORT).show();
            }

        }
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<RoomPKActivity> mContext;

        public TRTCCloudImplListener(RoomPKActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onRemoteUserEnterRoom(String s) {
            mTRTCCloud.startRemoteView(s, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mTXCloudRemoteView);
        }

        @Override
        public void onRemoteUserLeaveRoom(String s, int i) {
            mTRTCCloud.stopRemoteView(s);
            mStartPKFlag = false;
            mButtonStartPK.setText(R.string.connectotherroom_start_pk);
        }

        @Override
        public void onConnectOtherRoom(String s, int i, String s1) {
            Log.d(TAG, "onConnectOtherRoom: s = " + s + " , i = " + i + " , s1 = " + s1);
        }

        @Override
        public void onDisConnectOtherRoom(int i, String s) {
            Log.d(TAG, "onConnectOtherRoom: s = " + s + " , i = " + i);
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            RoomPKActivity activity = mContext.get();
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
