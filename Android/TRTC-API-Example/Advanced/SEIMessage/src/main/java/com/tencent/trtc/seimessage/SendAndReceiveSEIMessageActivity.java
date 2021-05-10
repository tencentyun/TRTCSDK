package com.tencent.trtc.seimessage;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
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
 * 接收和发送SEI页面
 *
 * <p>
 * 包含如下功能：
 * - 发送SEI消息{@link TRTCCloud#sendSEIMsg}，详见API说明文档 {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a034f9e1effbdadf8b9bfb7f3f06486c4}；
 * - 接收SEI消息{@link TRTCCloudListener#onRecvSEIMsg}，详见API说明文档 {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloudListener__android.html#ad3640e6bf80a1f93991644701e9b0d96}；
 * </p>
 */

/**
 * SEI Message Receiving/Sending
 *
 * <p>
 * Features:
 * - Send SEI messages: {@link TRTCCloud#sendSEIMsg}. For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a034f9e1effbdadf8b9bfb7f3f06486c4}.
 * - Receive SEI messages: {@link TRTCCloudListener#onRecvSEIMsg}. For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloudListener__android.html#ad3640e6bf80a1f93991644701e9b0d96}.
 * </p>
 */
public class SendAndReceiveSEIMessageActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String    TAG                 = "SendAndReceiveSEIMessageActivity";

    private ImageView              mImageBack;
    private TextView               mTextTitle;
    private Button                 mButtonStartPush;
    private Button                 mButtonSendSEIMessage;
    private EditText               mEditRoomId;
    private EditText               mEditUserId;
    private EditText               mEditSEIMessage;
    private TXCloudVideoView       mTXCloudPreviewView;
    private List<TXCloudVideoView> mRemoteVideoList;

    private TRTCCloud              mTRTCCloud;
    private List<String>           mRemoteUserIdList;
    private boolean                mStartPushFlag = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_send_and_receive_sei_message);

        getSupportActionBar().hide();

        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(SendAndReceiveSEIMessageActivity.this));
        if (checkPermission()) {
            initView();
        }
    }

    private void enterRoom(String roomId, String userId) {
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

    private void exitRoom() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAllRemoteView();
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.stopLocalPreview();
            mTRTCCloud.exitRoom();
        }
    }

    private void destroyRoom() {
        if (mTRTCCloud != null) {
            exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    private void initView() {
        mRemoteUserIdList = new ArrayList<>();
        mRemoteVideoList = new ArrayList<>();

        mImageBack              = findViewById(R.id.iv_back);
        mTextTitle              = findViewById(R.id.tv_room_number);
        mButtonStartPush        = findViewById(R.id.btn_start_push);
        mButtonSendSEIMessage   = findViewById(R.id.btn_send_sei_message);
        mEditRoomId             = findViewById(R.id.et_room_id);
        mEditUserId             = findViewById(R.id.et_user_id);
        mEditSEIMessage         = findViewById(R.id.et_sei_message);
        mTXCloudPreviewView     = findViewById(R.id.txcvv_main_local);

        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote1));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote2));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote3));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote4));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote5));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote6));

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);
        mButtonSendSEIMessage.setOnClickListener(this);

        String time = String.valueOf(System.currentTimeMillis());
        String userId = time.substring(time.length() - 8);
        mEditUserId.setText(userId);
        mTextTitle.setText(getString(R.string.seimessage_room_id) + ":" + mEditRoomId.getText().toString());
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.iv_back) {
            finish();
        } else if (id == R.id.btn_start_push) {
            String roomId = mEditRoomId.getText().toString();
            String userId = mEditUserId.getText().toString();
            if (!mStartPushFlag) {
                if (!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)) {
                    mButtonStartPush.setText(R.string.seimessage_stop_push);
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                    mButtonSendSEIMessage.setEnabled(true);
                } else {
                    Toast.makeText(SendAndReceiveSEIMessageActivity.this, getString(R.string.seimessage_please_input_roomid_and_userid), Toast.LENGTH_SHORT).show();
                }
            } else {
                mButtonStartPush.setText(R.string.seimessage_start_push);
                exitRoom();
                mStartPushFlag = false;
                mButtonSendSEIMessage.setEnabled(false);
            }
        } else if (id == R.id.btn_send_sei_message) {
            sendSEIMessage();
        }
    }

    private void sendSEIMessage() {
        if (mTRTCCloud != null && mStartPushFlag) {
            String message = mEditSEIMessage.getText().toString();
            if (TextUtils.isEmpty(message)) {
                Toast.makeText(SendAndReceiveSEIMessageActivity.this, getString(R.string.seimessage_content_empty_toast), Toast.LENGTH_SHORT).show();
            } else {
                mTRTCCloud.sendSEIMsg(message.getBytes(), 1);
                Toast.makeText(SendAndReceiveSEIMessageActivity.this, getString(R.string.seimessage_send_message_success_toast, message), Toast.LENGTH_SHORT).show();
            }
        } else {
            Toast.makeText(SendAndReceiveSEIMessageActivity.this, getString(R.string.seimessage_send_message_error_toast), Toast.LENGTH_SHORT).show();
        }
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<SendAndReceiveSEIMessageActivity> mContext;

        public TRTCCloudImplListener(SendAndReceiveSEIMessageActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            if (available) {
                mRemoteUserIdList.add(userId);
            } else {
                if (mRemoteUserIdList.contains(userId)) {
                    mRemoteUserIdList.remove(userId);
                    mTRTCCloud.stopRemoteView(userId);
                }
            }
            refreshRemoteVideo();
        }

        private void refreshRemoteVideo() {
            if (mRemoteUserIdList.size() > 0) {
                for (int i = 0; i < mRemoteUserIdList.size() || i < 6; i++) {
                    if (i < mRemoteUserIdList.size() && !TextUtils.isEmpty(mRemoteUserIdList.get(i))) {
                        mRemoteVideoList.get(i).setVisibility(View.VISIBLE);
                        mTRTCCloud.startRemoteView(mRemoteUserIdList.get(i), TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mRemoteVideoList.get(i));
                    } else {
                        mRemoteVideoList.get(i).setVisibility(View.GONE);
                    }
                }
            } else {
                for (int i = 0; i < 6; i++) {
                    mRemoteVideoList.get(i).setVisibility(View.GONE);
                }
            }
        }

        @Override
        public void onExitRoom(int i) {
            mRemoteUserIdList.clear();
            refreshRemoteVideo();
        }

        @Override
        public void onRecvSEIMsg(String userId, byte[] data) {
            SendAndReceiveSEIMessageActivity activity = mContext.get();
            if (activity != null) {
                try {
                    String message = new String(data, "UTF-8");
                    Toast.makeText(activity, getString(R.string.seimessage_receive_sei_message_toast, userId, message), Toast.LENGTH_SHORT).show();
                } catch (Exception e) {
                    e.printStackTrace();
                    Toast.makeText(activity, getString(R.string.seimessage_receive_sei_message_toast_error, e.getMessage()), Toast.LENGTH_SHORT).show();
                }
            }
        }

        @SuppressLint("LongLogTag")
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            SendAndReceiveSEIMessageActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode + "]", Toast.LENGTH_SHORT).show();
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
        destroyRoom();
    }

}