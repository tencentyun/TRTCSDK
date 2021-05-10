package com.tencent.trtc.stringroomid;

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
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;
import java.util.Random;

/**
 * TRTC 字符串房间号功能
 *
 * 包含如下简单功能：
 * - 进入房间{@link TRTCCloud#enterRoom(TRTCCloudDef.TRTCParams, int)}
 * - 退出房间{@link TRTCCloud#exitRoom()}
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#abfc1841af52e8f6a5f239a846a1e5d5c}
 */

/**
 * String-type Room ID
 *
 * Features:
 * - Enter a room: {@link TRTCCloud#enterRoom(TRTCCloudDef.TRTCParams, int)}
 * - Exit a room: {@link TRTCCloud#exitRoom()}
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#abfc1841af52e8f6a5f239a846a1e5d5c}.
 */
public class StringRoomIdActivity extends TRTCBaseActivity implements View.OnClickListener {
    private static final String     TAG = "StringRoomIdActivity";

    private ImageView               mImageBack;
    private TextView                mTextTitle;
    private Button                  mButtonStartPush;
    private EditText                mEditRoomId;
    private EditText                mEdituserId;

    private TXCloudVideoView        mTXCloudPreviewView;
    private TRTCCloud               mTRTCCloud;
    private boolean                 mStartPushFlag      = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.stringroomid_activity);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
    }

    private void enterRoom(String roomId,  String userId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(StringRoomIdActivity.this));

        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId    = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId      = userId;
        mTRTCParams.strRoomId   = roomId;
        mTRTCParams.userSig     = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role        = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(true, mTXCloudPreviewView);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
    }


    private void exitRoom(){
        if (mTRTCCloud != null) {
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.stopLocalPreview();
            mTRTCCloud.exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    private void initView() {
        mImageBack              = findViewById(R.id.iv_back);
        mButtonStartPush        = findViewById(R.id.btn_start_push);
        mTXCloudPreviewView     = findViewById(R.id.txcvv_main_local);
        mTextTitle              = findViewById(R.id.tv_room_number);
        mEditRoomId             = findViewById(R.id.et_room_id);
        mEdituserId             = findViewById(R.id.et_user_id);

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);

        mEdituserId.setText(new Random().nextInt(100000) + 1000000 + "");
        mTextTitle.setText(getString(R.string.stringroomid_roomid)+ ":" + mEditRoomId.getText().toString());
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
                    mButtonStartPush.setText(R.string.stringroomid_stop_push);
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                    mTextTitle.setText(getString(R.string.stringroomid_roomid)+ ":" + roomId);
                }else{
                    Toast.makeText(StringRoomIdActivity.this, getString(R.string.stringroomid_please_input_roomid_userid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonStartPush.setText(R.string.stringroomid_start_push);
                exitRoom();
                mStartPushFlag = false;
            }

        }
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<StringRoomIdActivity> mContext;

        public TRTCCloudImplListener(StringRoomIdActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            StringRoomIdActivity activity = mContext.get();
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
