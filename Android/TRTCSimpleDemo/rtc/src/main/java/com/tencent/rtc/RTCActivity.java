package com.tencent.rtc;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.tencent.liteav.TXLiteAVCode;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.debug.Constant;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.rtc.R;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import static com.tencent.trtc.TRTCCloudDef.TRTCRoleAnchor;
import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;

/**
 * RTC视频通话的主页面
 *
 * 包含如下简单功能：
 * - 进入/退出视频通话房间
 * - 切换前置/后置摄像头
 * - 打开/关闭摄像头
 * - 打开/关闭麦克风
 * - 显示房间内其他用户的视频画面（当前示例最多可显示6个其他用户的视频画面）
 */
public class RTCActivity extends AppCompatActivity implements View.OnClickListener {

    private static final String TAG = "RTCActivity";
    private static final int REQ_PERMISSION_CODE  = 0x1000;

    private TextView                        mTitleText;                 //【控件】页面Title
    private TXCloudVideoView                mLocalPreviewView;          //【控件】本地画面View
    private ImageView                       mBackButton;                //【控件】返回上一级页面
    private Button                          mMuteVideo;                 //【控件】是否停止推送本地的视频数据
    private Button                          mMuteAudio;                 //【控件】开启、关闭本地声音采集并上行
    private Button                          mSwitchCamera;              //【控件】切换摄像头
    private LinearLayout                    mVideoMutedTipsView;        //【控件】关闭视频时，显示默认头像

    private TRTCCloud                       mTRTCCloud;                 // SDK 核心类
    private boolean                         mIsFrontCamera = true;      // 默认摄像头前置
    private List<String>                    mRemoteUidList;             // 远端用户Id列表
    private List<TXCloudVideoView>          mRemoteViewList;            // 远端画面列表
    private int                             mGrantedCount = 0;          // 权限个数计数，获取Android系统权限
    private int                             mUserCount = 0;             // 房间通话人数个数
    private String                          mRoomId;                    // 房间Id
    private String                          mUserId;                    // 用户Id

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rtc);
        getSupportActionBar().hide();
        handleIntent();
        // 先检查权限再加入通话
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

    private void initView() {
        mTitleText          = findViewById(R.id.trtc_tv_room_number);
        mBackButton         = findViewById(R.id.trtc_ic_back);
        mLocalPreviewView   = findViewById(R.id.trtc_tc_cloud_view_main);
        mMuteVideo          = findViewById(R.id.trtc_btn_mute_video);
        mMuteAudio          = findViewById(R.id.trtc_btn_mute_audio);
        mSwitchCamera       = findViewById(R.id.trtc_btn_switch_camera);
        mVideoMutedTipsView = findViewById(R.id.ll_trtc_mute_video_default);

        if (!TextUtils.isEmpty(mRoomId)) {
            mTitleText.setText(mRoomId);
        }
        mBackButton.setOnClickListener(this);
        mMuteVideo.setOnClickListener(this);
        mMuteAudio.setOnClickListener(this);
        mSwitchCamera.setOnClickListener(this);

        mRemoteUidList = new ArrayList<>();
        mRemoteViewList = new ArrayList<>();
        mRemoteViewList.add((TXCloudVideoView)findViewById(R.id.trtc_tc_cloud_view_1));
        mRemoteViewList.add((TXCloudVideoView)findViewById(R.id.trtc_tc_cloud_view_2));
        mRemoteViewList.add((TXCloudVideoView)findViewById(R.id.trtc_tc_cloud_view_3));
        mRemoteViewList.add((TXCloudVideoView)findViewById(R.id.trtc_tc_cloud_view_4));
        mRemoteViewList.add((TXCloudVideoView)findViewById(R.id.trtc_tc_cloud_view_5));
        mRemoteViewList.add((TXCloudVideoView)findViewById(R.id.trtc_tc_cloud_view_6));
    }

    private void enterRoom() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(RTCActivity.this));

        // 初始化配置 SDK 参数
        TRTCCloudDef.TRTCParams trtcParams = new TRTCCloudDef.TRTCParams();
        trtcParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        trtcParams.userId = mUserId;
        trtcParams.roomId = Integer.parseInt(mRoomId);
        // userSig是进入房间的用户签名，相当于密码（这里生成的是测试签名，正确做法需要业务服务器来生成，然后下发给客户端）
        trtcParams.userSig = GenerateTestUserSig.genTestUserSig(trtcParams.userId);
        trtcParams.role = TRTCRoleAnchor;

        // 进入通话
        mTRTCCloud.enterRoom(trtcParams, TRTC_APP_SCENE_VIDEOCALL);
        // 开启本地声音采集并上行
        mTRTCCloud.startLocalAudio();
        // 开启本地画面采集并上行
        mTRTCCloud.startLocalPreview(mIsFrontCamera, mLocalPreviewView);

        /**
         * 设置默认美颜效果（美颜效果：自然，美颜级别：5, 美白级别：1）
         * 美颜风格.三种美颜风格：0 ：光滑  1：自然  2：朦胧
         * 视频通话场景推荐使用“自然”美颜效果
         */
        TXBeautyManager beautyManager = mTRTCCloud.getBeautyManager();
        beautyManager.setBeautyStyle(Constant.BEAUTY_STYLE_NATURE);
        beautyManager.setBeautyLevel(5);
        beautyManager.setWhitenessLevel(1);

        TRTCCloudDef.TRTCVideoEncParam encParam = new TRTCCloudDef.TRTCVideoEncParam();
        encParam.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
        encParam.videoFps = Constant.VIDEO_FPS;
        encParam.videoBitrate = Constant.RTC_VIDEO_BITRATE;
        encParam.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
        mTRTCCloud.setVideoEncoderParam(encParam);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }

    /**
     * 离开通话
     */
    private void exitRoom() {
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.stopLocalPreview();
        mTRTCCloud.exitRoom();
        //销毁 trtc 实例
        if (mTRTCCloud != null) {
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    //////////////////////////////////    Android动态权限申请   ////////////////////////////////////////

    private boolean checkPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)) {
                permissions.add(Manifest.permission.RECORD_AUDIO);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
            }
            if (permissions.size() != 0) {
                ActivityCompat.requestPermissions(RTCActivity.this,
                        permissions.toArray(new String[0]),
                        REQ_PERMISSION_CODE);
                return false;
            }
        }
        return true;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQ_PERMISSION_CODE) {
            for (int ret : grantResults) {
                if (PackageManager.PERMISSION_GRANTED == ret) mGrantedCount++;
            }
            if (mGrantedCount == permissions.length) {
                initView();
                enterRoom(); //首次启动，权限都获取到，才能正常进入通话
            } else {
                Toast.makeText(this, getString(R.string.rtc_permisson_error_tip), Toast.LENGTH_SHORT).show();
            }
            mGrantedCount = 0;
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.trtc_ic_back) {
            finish();
        } else if (id == R.id.trtc_btn_mute_video) {
            muteVideo();
        } else if (id == R.id.trtc_btn_mute_audio) {
            muteAudio();
        } else if (id == R.id.trtc_btn_switch_camera) {
            switchCamera();
        }
    }

    private void muteVideo() {
        boolean isSelected = mMuteVideo.isSelected();
        if (!isSelected) {
            mTRTCCloud.stopLocalPreview();
            mMuteVideo.setBackground(getResources().getDrawable(R.mipmap.rtc_camera_off));
            mVideoMutedTipsView.setVisibility(View.VISIBLE);
        } else {
            mTRTCCloud.startLocalPreview(mIsFrontCamera, mLocalPreviewView);
            mMuteVideo.setBackground(getResources().getDrawable(R.mipmap.rtc_camera_on));
            mVideoMutedTipsView.setVisibility(View.GONE);
        }
        mMuteVideo.setSelected(!isSelected);
    }

    private void muteAudio() {
        boolean isSelected = mMuteAudio.isSelected();
        if (!isSelected) {
            mTRTCCloud.stopLocalAudio();
            mMuteAudio.setBackground(getResources().getDrawable(R.mipmap.rtc_mic_off));
        } else {
            mTRTCCloud.startLocalAudio();
            mMuteAudio.setBackground(getResources().getDrawable(R.mipmap.rtc_mic_on));
        }
        mMuteAudio.setSelected(!isSelected);
    }

    private void switchCamera() {
        mTRTCCloud.switchCamera();
        boolean isSelected = mSwitchCamera.isSelected();
        mIsFrontCamera = !isSelected;
        mSwitchCamera.setSelected(!isSelected);
    }

    private class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<RTCActivity>      mContext;

        public TRTCCloudImplListener(RTCActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            Log.d(TAG, "onUserVideoAvailable userId " + userId + ", mUserCount " + mUserCount + ",available " + available);
            int index = mRemoteUidList.indexOf(userId);
            if (available) {
                if (index != -1) { //如果mRemoteUidList有，就不重复添加
                    return;
                }
                mRemoteUidList.add(userId);
                refreshRemoteVideoViews();
            } else {
                if (index == -1) { //如果mRemoteUidList没有，说明已关闭画面
                    return;
                }
                /// 关闭用户userId的视频画面
                mTRTCCloud.stopRemoteView(userId);
                mRemoteUidList.remove(index);
                refreshRemoteVideoViews();
            }

        }

        private void refreshRemoteVideoViews() {
            for (int i = 0; i < mRemoteViewList.size(); i++) {
                if (i < mRemoteUidList.size()) {
                    String remoteUid = mRemoteUidList.get(i);
                    mRemoteViewList.get(i).setVisibility(View.VISIBLE);
                    // 开始显示用户userId的视频画面
                    mTRTCCloud.startRemoteView(remoteUid, mRemoteViewList.get(i));
                } else {
                    mRemoteViewList.get(i).setVisibility(View.GONE);
                }
            }
        }

        // 错误通知监听，错误通知意味着 SDK 不能继续运行
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            RTCActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

}
