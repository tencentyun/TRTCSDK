package com.tencent.trtc.localrecord;

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

import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.Random;

/**
 * TRTC本地视频录制页面
 *
 * 包含如下简单功能：
 * - 开始视频录制{@link TRTCCloud#startLocalRecording(TRTCCloudDef.TRTCLocalRecordingParams)}
 * - 停止视频录制{@link TRTCCloud#stopLocalRecording()}
 *
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a5d6bf60e9d3051f601988e55106b296c}
 */

/**
 * Local Video Recording
 *
 * Features:
 * - Start video recording: {@link TRTCCloud#startLocalRecording(TRTCCloudDef.TRTCLocalRecordingParams)}
 * - Stop video recording: {@link TRTCCloud#stopLocalRecording()}
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a5d6bf60e9d3051f601988e55106b296c}.
 */
public class LocalRecordActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String     TAG                     = "LocalRecordActivity";

    private ImageView               mImageBack;
    private TextView                mTextTitle;
    private Button                  mButtonStartPush;
    private Button                  mButtonRecord;
    private EditText                mEditRoomId;
    private EditText                mEditRecordPath;
    private TXCloudVideoView        mTXCloudPreviewView;


    private TRTCCloud               mTRTCCloud;
    private boolean                 mStartPushFlag      = false;
    private boolean                 mStartRecordFlag    = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_local_record);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
    }

    private void initView() {
        mImageBack              = findViewById(R.id.iv_back);
        mTextTitle              = findViewById(R.id.tv_room_number);
        mButtonStartPush        = findViewById(R.id.btn_start_push);
        mButtonRecord           = findViewById(R.id.btn_record);
        mEditRoomId             = findViewById(R.id.et_room_id);
        mEditRecordPath         = findViewById(R.id.et_record_path);
        mTXCloudPreviewView     = findViewById(R.id.txcvv_main_local);


        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);
        mButtonRecord.setOnClickListener(this);
        mTextTitle.setText(getString(R.string.localrecord_roomid) + ":" + mEditRoomId.getText().toString());
    }

    private void enterRoom(String roomId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(LocalRecordActivity.this));
        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = new Random().nextInt(100000) + 1000000 + "";
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

    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.iv_back){
            finish();
        }else if(view.getId() == R.id.btn_start_push){
            String roomId = mEditRoomId.getText().toString();
            if(!mStartPushFlag){
                if(!TextUtils.isEmpty(roomId)){
                    mButtonStartPush.setText(getString(R.string.localrecord_stop_push));
                    enterRoom(roomId);
                    mButtonRecord.setBackgroundColor(getResources().getColor(R.color.localrecord_button_select));
                    mStartPushFlag = true;
                }else{
                    Toast.makeText(LocalRecordActivity.this, getString(R.string.localrecord_please_input_roomid_and_userid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonRecord.setBackgroundColor(getResources().getColor(R.color.localrecord_button_select_off));
                mButtonStartPush.setText(getString(R.string.localrecord_start_push));
                exitRoom();
                mStartPushFlag = false;
            }
        }else if(view.getId() == R.id.btn_record){
            if(!mStartPushFlag){
                return;
            }
            String recordFile = mEditRecordPath.getText().toString();
            if(!mStartRecordFlag){
                if(!TextUtils.isEmpty(recordFile)){
                    mStartRecordFlag = true;
                    mButtonRecord.setText(R.string.localrecord_stop_record);
                    startRecord(recordFile);
                }else{
                    Toast.makeText(LocalRecordActivity.this, getString(R.string.localrecord_please_input_record_file_name), Toast.LENGTH_SHORT).show();
                }
            }else{
                mStartRecordFlag = false;
                mButtonRecord.setText(R.string.localrecord_start_record);
                stopRecord();
            }
        }
    }

    private void stopRecord() {
        mTRTCCloud.stopLocalRecording();
        saveVideo();
    }

    private void saveVideo() {
        String videoPath = getExternalFilesDir(null).getAbsolutePath() + File.separator + mEditRecordPath.getText().toString();
        String coverPath = getExternalFilesDir(null).getAbsolutePath() + File.separator + "albun.png";
        AlbumUtils.saveVideoToDCIM(LocalRecordActivity.this, videoPath, coverPath);
    }

    private void startRecord(String recordFile) {
        String recordPath = getExternalFilesDir(null).getAbsolutePath();
        Log.d(TAG, "recordPath = " + recordPath);
        File file = new File(recordPath + File.separator + recordFile);
        if(file.exists()){
            file.delete();
        }
        try {
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
        TRTCCloudDef.TRTCLocalRecordingParams params = new TRTCCloudDef.TRTCLocalRecordingParams();
        params.recordType = TRTCCloudDef.TRTC_RECORD_TYPE_BOTH;
        params.filePath = recordPath + File.separator + recordFile;
        mTRTCCloud.startLocalRecording(params);
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<LocalRecordActivity> mContext;

        public TRTCCloudImplListener(LocalRecordActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            LocalRecordActivity activity = mContext.get();
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
