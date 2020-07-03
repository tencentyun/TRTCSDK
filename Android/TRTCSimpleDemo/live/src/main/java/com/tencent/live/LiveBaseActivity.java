package com.tencent.live;

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
import com.tencent.liteav.debug.Constant;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/**
 * 基类，主要是公用的控件和 Android 系统权限动态申请
 */
public abstract class LiveBaseActivity extends AppCompatActivity implements View.OnClickListener {

    private static final String TAG = "LiveBaseActivity";
    protected static final int REQ_PERMISSION_CODE  = 0x1000;
    protected static final int DEFAULT_CAPACITY     = 5;

    protected TXCloudVideoView                mAnchorPreviewView;         // 主播画面View
    protected LiveSubVideoView                mLinkMicSelfPreviewView;    // 位置1连麦后画面View
    protected Button                          mSwitchCameraButton;        // 切换摄像头
    protected Button                          mMuteVideoButton;           // 关闭/打开画面
    protected Button                          mMuteAudioButton;           // 关闭/打开声音
    protected ImageView                       mBackButton;                // 页面顶部返回按钮
    protected TextView                        mTitleText;                 // 页面顶部标题
    protected LinearLayout                    mBigPreviewMuteVideoDefault;// 主画面关闭画面后默认图
    protected Button                          mLogInfoButton;             // 关闭/打开日志信息

    protected TRTCCloud                       mTRTCCloud;                 // SDK 核心类
    protected TRTCCloudDef.TRTCParams         mTRTCParams;                // SDK 参数
    protected boolean                         mIsFrontCamera = true;      // 默认摄像头前置

    protected int                             mGrantedCount = 0;          // 权限个数计数，获取Android系统权限
    protected int                             mRoleType;                  // 房间角色类型
    protected int                             mLogLevel = 0;              // 日志等级
    protected int                             mRoomUserCount = 0;         // 房间里人数（除去自己）
    protected String                          mRoomId;                    // 房间Id
    protected String                          mUserId;                    // 用户Id
    protected String                          mMainRoleAnchorId;          // 大主播Id（Demo中为演示和roomId相同）

    protected List<String>                    mRemoteUidList;             // 远端用户列表（不包括位置1用户）
    protected List<LiveSubVideoView>          mRemoteViewList;            // 远端画面列表（不包括位置1用户）
    protected LiveRoomManager                 mLiveRoomManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live);
        getSupportActionBar().hide();
        handleIntent();

        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(LiveBaseActivity.this));
        mLiveRoomManager = new LiveRoomManager();
    }

    protected void initView() {
        mBackButton                 = findViewById(R.id.ic_back);
        mTitleText                  = findViewById(R.id.tv_room_number);
        mMuteVideoButton            = findViewById(R.id.live_btn_mute_video);
        mMuteAudioButton            = findViewById(R.id.live_btn_mute_audio);
        mSwitchCameraButton         = findViewById(R.id.live_btn_switch_camera);
        mAnchorPreviewView          = findViewById(R.id.live_cloud_view_main);
        mLogInfoButton              = findViewById(R.id.live_btn_log_info);
        mBigPreviewMuteVideoDefault = findViewById(R.id.ll_big_preview_default);
        mLinkMicSelfPreviewView     = findViewById(R.id.live_cloud_view_1); // 位置1画面View

        mMainRoleAnchorId = mRoomId;
        if (!TextUtils.isEmpty(mRoomId)) {
            mTitleText.setText(mRoomId);
        }

        mRemoteUidList = new ArrayList<>(DEFAULT_CAPACITY);
        mRemoteViewList = new ArrayList<>(DEFAULT_CAPACITY);

        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_2));
        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_3));
        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_4));
        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_5));
        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_6));

        mBackButton.setOnClickListener(this);
        mLogInfoButton.setOnClickListener(this);
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
            if (intent.getIntExtra(Constant.ROLE_TYPE, 0) != 0) {
                mRoleType = intent.getIntExtra(Constant.ROLE_TYPE, 0);
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
        if (mRoomUserCount == 0) {
            mLiveRoomManager.destoryLiveRoom(mRoomId);
        }
        //销毁 trtc 实例
        if (mTRTCCloud != null) {
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    protected void switchCamera() {
        if (mIsFrontCamera) {
            mIsFrontCamera = false;
            mSwitchCameraButton.setBackgroundResource(R.mipmap.live_camera_back);
        } else {
            mIsFrontCamera = true;
            mSwitchCameraButton.setBackgroundResource(R.mipmap.live_camera_front);
        }
        mTRTCCloud.switchCamera();
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<LiveBaseActivity> mContext;

        public TRTCCloudImplListener(LiveBaseActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
            mRoomUserCount ++;
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
            mRoomUserCount --;
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            int index = mRemoteUidList.indexOf(userId);
            Log.d(TAG, "onUserVideoAvailable index " + index + ", available " + available + " userId " + userId);
            if (available) {
                if (index == -1 && !userId.equals(mRoomId)) { //找不到
                    mRemoteUidList.add(userId);
                    refreshRemoteVideoViews();
                } else if (userId.equals(mRoomId)) {
                    mTRTCCloud.startRemoteView(userId, mAnchorPreviewView);
                    mBigPreviewMuteVideoDefault.setVisibility(View.GONE);
                }
            } else {
                if (index != -1 && !userId.equals(mRoomId)) { //找到
                    // 关闭用户userId的视频画面
                    mTRTCCloud.stopRemoteView(userId);
                    mRemoteUidList.remove(index);
                    refreshRemoteVideoViews();
                } else if (userId.equals(mRoomId)) {
                    mBigPreviewMuteVideoDefault.setVisibility(View.VISIBLE);
                }
            }
        }

        // SDK 错误通知回调，错误通知意味着 SDK 不能继续运行了
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            LiveBaseActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }

        private void refreshRemoteVideoViews() {
            for (int i = 0; i < mRemoteViewList.size(); i++) {
                if (i < mRemoteUidList.size()) {
                    String remoteUid = mRemoteUidList.get(i);
                    mRemoteViewList.get(i).setVisibility(View.VISIBLE);
                    // 开始显示用户userId的视频画面
                    mTRTCCloud.startRemoteView(remoteUid, mRemoteViewList.get(i).getVideoView());
                } else {
                    mRemoteViewList.get(i).setVisibility(View.GONE);
                }
            }
        }
    }

    protected class LiveSubViewListenerImpl implements LiveSubVideoView.LiveSubViewListener {

        private int mIndex;

        public LiveSubViewListenerImpl (int index) {
            mIndex = index;
        }

        @Override
        public void onMuteRemoteAudioClicked(View view) {
            boolean isSelected = view.isSelected();
            if (!isSelected) {
                mTRTCCloud.muteRemoteAudio(mRemoteUidList.get(mIndex),true);
                view.setBackground(getResources().getDrawable(R.mipmap.live_subview_sound_mute));
            } else {
                mTRTCCloud.muteRemoteAudio(mRemoteUidList.get(mIndex),false);
                view.setBackground(getResources().getDrawable(R.mipmap.live_subview_sound_unmute));
            }
            view.setSelected(!isSelected);
        }

        @Override
        public void onMuteRemoteVideoClicked(View view) {
            boolean isSelected = view.isSelected();
            if (!isSelected) {
                mTRTCCloud.stopRemoteView(mRemoteUidList.get(mIndex));
                mRemoteViewList.get(mIndex).getMuteVideoDefault().setVisibility(View.VISIBLE);
                view.setBackground(getResources().getDrawable(R.mipmap.live_subview_video_mute));
            } else {
                mTRTCCloud.startRemoteView(mRemoteUidList.get(mIndex), mRemoteViewList.get(mIndex).getVideoView());
                view.setBackground(getResources().getDrawable(R.mipmap.live_subview_video_unmute));
                mRemoteViewList.get(mIndex).getMuteVideoDefault().setVisibility(View.GONE);
            }
            view.setSelected(!isSelected);
        }
    }

    protected void exitRoom() {
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.stopLocalPreview();
        mTRTCCloud.exitRoom();
        mRemoteUidList.clear();
        mRemoteViewList.clear();
    }

    //////////////////////////////////    动态权限申请   ////////////////////////////////////////

    protected boolean checkPermission() {
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
                ActivityCompat.requestPermissions(LiveBaseActivity.this,
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
        switch (requestCode) {
            case REQ_PERMISSION_CODE:
                for (int ret : grantResults) {
                    if (PackageManager.PERMISSION_GRANTED == ret) {
                        mGrantedCount ++;
                    }
                }
                if (mGrantedCount == permissions.length) {
                    initView();
                    enterRoom(); //首次启动，权限都获取到，才能正常进入通话
                } else {
                    Toast.makeText(this, "用户没有允许需要的权限，加入通话失败", Toast.LENGTH_SHORT).show();
                }
                mGrantedCount = 0;
                break;
            default:
                break;
        }
    }

    protected abstract void enterRoom();

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.ic_back) {
            finish();
        } else if (id == R.id.live_btn_log_info) {
            showDebugView();
        }
    }

    private void showDebugView() {
        mLogLevel = (mLogLevel + 1) % 3;
        mLogInfoButton.setBackgroundResource((0 == mLogLevel) ? R.mipmap.live_log_close : R.mipmap.live_log_open);
        mTRTCCloud.showDebugView(mLogLevel);
    }
}
