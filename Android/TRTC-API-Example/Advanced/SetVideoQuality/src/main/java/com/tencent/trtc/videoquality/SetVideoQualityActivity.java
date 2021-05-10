package com.tencent.trtc.videoquality;

import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.SeekBar;
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
import com.tencent.trtc.debug.Constant;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

/**
 * TRTC 设置视频质量页面
 *
 * 包含如下简单功能：
 * - 设置视频质量{@link TRTCCloud#setVideoEncoderParam(TRTCCloudDef.TRTCVideoEncParam)},详见参数说明
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#ae047d96922cb1c19135433fa7908e6ce}
 */

/**
 * Setting Video Quality
 *
 * Features:
 *- Set video quality: {@link TRTCCloud#setVideoEncoderParam(TRTCCloudDef.TRTCVideoEncParam)}. For details, see the parameter description.
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#ae047d96922cb1c19135433fa7908e6ce}.
 */
public class SetVideoQualityActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String     TAG                     = "SetVideoQualityActivity";

    private ImageView               mImageBack;
    private TextView                mTextTitle;
    private SeekBar                 mSeekFPS;
    private SeekBar                 mSeekBitRate;
    private Button                  mButtonQuality360;
    private Button                  mButtonQuality540;
    private Button                  mButtonQuality720;
    private Button                  mButtonQuality1080;
    private Button                  mButtonStartPush;
    private EditText                mEditRoomId;
    private EditText                mEdituserId;
    private TXCloudVideoView        mTXCloudPreviewView;
    private List<TXCloudVideoView>  mRemoteVideoList;
    private TextView                mTextKPS;
    private TextView                mTextFPS;

    private TRTCCloud               mTRTCCloud;
    private int                     mQualityFlag        = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
    private int                     mFPSFlag            = Constant.VIDEO_FPS;
    private int                     mBitRateFlag        = Constant.LIVE_540_960_VIDEO_BITRATE;
    private List<String>            mRemoteUserIdList;
    private boolean                 mStartPushFlag      = false;

    private Map<String,BitRateBean> mBitRateMap;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.videoquality_activity_set);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
            initData();
        }
    }

    private void initData() {
        mBitRateMap = new HashMap<>();
        mBitRateMap.put(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360 + "", new BitRateBean(200, 1000, 800));
        mBitRateMap.put(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540 + "", new BitRateBean(400, 1600, 900));
        mBitRateMap.put(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720 + "", new BitRateBean(500, 2000, 1250));
        mBitRateMap.put(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1920_1080 + "", new BitRateBean(800, 3000, 1900));
    }

    private void initView() {
        mRemoteUserIdList       = new ArrayList<>();
        mRemoteVideoList        = new ArrayList<>();

        mImageBack              = findViewById(R.id.iv_back);
        mTextTitle              = findViewById(R.id.tv_room_number);
        mButtonQuality360       = findViewById(R.id.btn_quality_360);
        mButtonQuality540       = findViewById(R.id.btn_quality_540);
        mButtonQuality720       = findViewById(R.id.btn_quality_720);
        mButtonQuality1080      = findViewById(R.id.btn_quality_1080);
        mButtonStartPush        = findViewById(R.id.btn_start_push);
        mEditRoomId             = findViewById(R.id.et_room_id);
        mEdituserId             = findViewById(R.id.et_user_id);
        mSeekBitRate            = findViewById(R.id.sb_bit_rate);
        mSeekFPS                = findViewById(R.id.sb_fps);
        mTXCloudPreviewView     = findViewById(R.id.txcvv_main_local);
        mTextFPS                = findViewById(R.id.tv_fps);
        mTextKPS                = findViewById(R.id.tv_kps);

        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote1));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote2));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote3));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote4));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote5));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote6));

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);
        mButtonQuality360.setOnClickListener(this);
        mButtonQuality540.setOnClickListener(this);
        mButtonQuality720.setOnClickListener(this);
        mButtonQuality1080.setOnClickListener(this);

        mSeekBitRate.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Log.d("onStopTrackingTouch", "onStopTrackingTouch : progrsss = " + seekBar.getProgress());
                if(!mStartPushFlag){
                    seekBar.setProgress(mBitRateFlag);
                    return;
                }
                mBitRateFlag = seekBar.getProgress();
                mTextKPS.setText(mBitRateFlag + "kbps");
                setVideoEncoderParam(false);

            }
        });

        mSeekFPS.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Log.d("onStopTrackingTouch", "onStopTrackingTouch : progrsss = " + seekBar.getProgress());
                if(!mStartPushFlag){
                    seekBar.setProgress(mFPSFlag);
                    return;
                }
                mFPSFlag = seekBar.getProgress();
                mTextFPS.setText(mFPSFlag + "fps");
                setVideoEncoderParam(false);
            }
        });

        mEdituserId.setText(new Random().nextInt(100000) + 1000000 + "");
        mTextTitle.setText(getString(R.string.videoquality_roomid) + ":" + mEditRoomId.getText().toString());
    }

    private void enterRoom(String roomId,  String userId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(SetVideoQualityActivity.this));
        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = userId;
        mTRTCParams.roomId = Integer.parseInt(roomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(true, mTXCloudPreviewView);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
        setVideoEncoderParam(false);
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

    private void setVideoEncoderParam(boolean isSwitchQuality){
        if(isSwitchQuality){
            BitRateBean bean = mBitRateMap.get("" + mQualityFlag);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                mSeekBitRate.setMin(bean.min);
            }
            mSeekBitRate.setMax(bean.max);
            mSeekBitRate.setProgress(bean.progress);
            mBitRateFlag = bean.progress;
            mTextKPS.setText(mBitRateFlag + "kbps");
        }
        TRTCCloudDef.TRTCVideoEncParam encParam = new TRTCCloudDef.TRTCVideoEncParam();
        encParam.videoResolution = mQualityFlag;
        encParam.videoFps = mFPSFlag;
        encParam.videoBitrate = mBitRateFlag;
        encParam.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
        mTRTCCloud.setVideoEncoderParam(encParam);
    }


    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.iv_back){
            finish();
        }else if(view.getId() == R.id.btn_start_push){
            String roomId = mEditRoomId.getText().toString();
            String userId = mEdituserId.getText().toString();
            if(!mStartPushFlag){
                if(!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)){
                    mButtonStartPush.setText(getString(R.string.videoquality_stop_push));
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                }else{
                    Toast.makeText(SetVideoQualityActivity.this, getString(R.string.videoquality_please_input_roomid_and_userid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonStartPush.setText(getString(R.string.videoquality_start_push));
                exitRoom();
                mStartPushFlag = false;
            }

        }else if(view.getId() == R.id.btn_quality_360){
            if(!mStartPushFlag){
                return;
            }
            if(mQualityFlag != TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360){
                mQualityFlag = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
                setVideoEncoderParam(true);
                mButtonQuality360.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select));
                mButtonQuality540.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality720.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality1080.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
            }
        }else if(view.getId() == R.id.btn_quality_540){
            if(!mStartPushFlag){
                return;
            }
            if(mQualityFlag != TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540){
                mQualityFlag = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
                setVideoEncoderParam(true);
                mButtonQuality360.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality540.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select));
                mButtonQuality720.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality1080.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
            }
        }else if(view.getId() == R.id.btn_quality_720){
            if(!mStartPushFlag){
                return;
            }
            if(mQualityFlag != TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720){
                mQualityFlag = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
                setVideoEncoderParam(true);
                mButtonQuality360.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality540.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality720.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select));
                mButtonQuality1080.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
            }
        }else if(view.getId() == R.id.btn_quality_1080){
            if(!mStartPushFlag){
                return;
            }
            if(mQualityFlag != TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1920_1080){
                mQualityFlag = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1920_1080;
                setVideoEncoderParam(true);
                mButtonQuality360.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality540.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality720.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select_off));
                mButtonQuality1080.setBackgroundColor(getResources().getColor(R.color.videoquality_button_select));
            }
        }

    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<SetVideoQualityActivity> mContext;

        public TRTCCloudImplListener(SetVideoQualityActivity activity) {
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
                        mTRTCCloud.startRemoteView(mRemoteUserIdList.get(i),TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mRemoteVideoList.get(i));
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
            SetVideoQualityActivity activity = mContext.get();
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
        initData();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }

    public class BitRateBean{
        public int min;
        public int max;
        public int progress;

        public BitRateBean(int min, int max, int progress){
            this.min = min;
            this.max = max;
            this.progress = progress;
        }
    }
}
