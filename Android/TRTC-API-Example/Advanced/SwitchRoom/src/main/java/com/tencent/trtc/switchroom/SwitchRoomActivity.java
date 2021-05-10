package com.tencent.trtc.switchroom;

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

import java.lang.ref.WeakReference;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * TRTC 切换房间功能
 *
 * 包含如下简单功能：
 * - 切换房间{@link TRTCCloud#switchRoom(TRTCCloudDef.TRTCSwitchRoomConfig)} ,详见参数说明
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a09fbe471def0c1790357fc2b70149784}
 */

/**
 * Room Switching
 *
 * Features:
 * - Switch rooms: {@link TRTCCloud#switchRoom(TRTCCloudDef.TRTCSwitchRoomConfig)}. For details, see the parameter description.
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a09fbe471def0c1790357fc2b70149784}.
 */
public class SwitchRoomActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String     TAG                     = "SwitchRoomActivity";

    private ImageView               mImageBack;
    private Button                  mButtonStartPush;
    private Button                  mButtonSwitchRoom;
    private EditText                mEditRoomId;
    private TXCloudVideoView        mTXCloudPreviewView;
    private TextView                mTextTitle;

    private TRTCCloud               mTRTCCloud;
    private String                  mLocalUserId;
    private boolean                 mStartPushFlag      = false;
    private int                     mRemoteRoomId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.switchroom_activity_set);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
    }

    private void initView() {

        mTextTitle              = findViewById(R.id.tv_room_number);
        mImageBack              = findViewById(R.id.iv_back);
        mButtonStartPush        = findViewById(R.id.btn_start_push);
        mEditRoomId             = findViewById(R.id.et_room_id);
        mTXCloudPreviewView     = findViewById(R.id.txcvv_main_local);
        mButtonSwitchRoom       = findViewById(R.id.btn_switch_room);

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);
        mButtonSwitchRoom.setOnClickListener(this);

        mLocalUserId = new Random().nextInt(100000) + 1000000 + "";
        mTextTitle.setText(getString(R.string.switchroom_roomid) + ":" + mEditRoomId.getText().toString());
    }

    private void enterRoom(String roomId,  String userId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(SwitchRoomActivity.this));
        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = userId;
        mTRTCParams.roomId = Integer.parseInt(roomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(true, mTXCloudPreviewView);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
        mTextTitle.setText(getString(R.string.switchroom_roomid) + ":" + roomId);
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

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.iv_back){
            finish();
        }else if(view.getId() == R.id.btn_start_push){
            String roomId = mEditRoomId.getText().toString();
            if(!mStartPushFlag){
                if(!TextUtils.isEmpty(roomId)){
                    mButtonSwitchRoom.setBackgroundColor(getResources().getColor(R.color.switchroom_button_select));
                    mButtonStartPush.setText(getString(R.string.switchroom_stop_push));
                    enterRoom(roomId, mLocalUserId);
                    mStartPushFlag = true;
                }else{
                    Toast.makeText(SwitchRoomActivity.this, getString(R.string.switchroom_please_input_roomid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonSwitchRoom.setBackgroundColor(getResources().getColor(R.color.switchroom_button_select_off));
                mButtonStartPush.setText(getString(R.string.switchroom_start_push));
                exitRoom();
                mStartPushFlag = false;
            }

        }else if(view.getId() == R.id.btn_switch_room){
            String roomId = mEditRoomId.getText().toString();
            if(!mStartPushFlag){
                return;
            }
            if(isRoomNumber(roomId)){
                mRemoteRoomId = Integer.parseInt(roomId);
                switchRoom(roomId);
            }else{
                Toast.makeText(SwitchRoomActivity.this, getString(R.string.switchroom_please_input_roomid), Toast.LENGTH_SHORT).show();
            }
        }
    }

    public static boolean isRoomNumber(String roomId){
        if(TextUtils.isEmpty(roomId)){
            return false;
        }
        String regex = "[1-9]{1}[0-9]{7}";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(roomId);
        return m.matches();
    }

    private void switchRoom(String roomId) {
        TRTCCloudDef.TRTCSwitchRoomConfig config = new TRTCCloudDef.TRTCSwitchRoomConfig();
        config.roomId = Integer.parseInt(roomId);
        mTRTCCloud.switchRoom(config);
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<SwitchRoomActivity> mContext;

        public TRTCCloudImplListener(SwitchRoomActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onSwitchRoom(int i, String s) {
            Log.d(TAG, "onSwitchRoom: i = " + i + " , s " + s);
            if(i == 0){
                Toast.makeText(SwitchRoomActivity.this,getString(R.string.switchroom_toast_switch_success), Toast.LENGTH_SHORT).show();
                mTextTitle.setText(getString(R.string.switchroom_roomid) + ":" + mRemoteRoomId);
            }else{
                Toast.makeText(SwitchRoomActivity.this,getString(R.string.switchroom_toast_switch_failed), Toast.LENGTH_SHORT).show();
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            SwitchRoomActivity activity = mContext.get();
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
