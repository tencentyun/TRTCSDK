package com.tencent.trtc.live;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.Constant;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_LIVE;

/**
 * TRTC 主播视角下的RTC视频互动直播房间页面
 *
 * 包含如下简单功能：
 * - 进入直播房间{@link LiveAnchorActivity#enterRoom()}
 * - 退出直播房间{@link LiveAnchorActivity#exitRoom()}
 * - 切换前置/后置摄像头{@link LiveAnchorActivity#switchCamera()}
 * - 打开/关闭摄像头{@link LiveAnchorActivity#muteVideo()}
 * - 关闭/打开麦克风{@link LiveAnchorActivity#muteAudio()}
 *
 * 详见接入文档{https://cloud.tencent.com/document/product/647/43182}
 */

/**
 * Room View of Interactive Live Video Streaming for Anchor
 *
 * Features:
 * - Enter a room: {@link LiveAnchorActivity#enterRoom()}
 * - Exit a room: {@link LiveAnchorActivity#exitRoom()}
 * - Switch between the front and rear cameras: {@link LiveAnchorActivity#switchCamera()}
 * - Turn on/off the camera: {@link LiveAnchorActivity#muteVideo()}
 * - Turn on/off the mic: {@link LiveAnchorActivity#muteAudio()}
 *
 * For more information, please see the integration document {https://cloud.tencent.com/document/product/647/43182}.
 */
public class LiveAnchorActivity extends TRTCBaseActivity implements View.OnClickListener {
    private static final String             TAG                     = "LiveBaseActivity";
    private static final int                DEFAULT_CAPACITY        = 5;

    private TXCloudVideoView                mTxcvvAnchorPreviewView;
    private Button                          mButtonSwitchCamera;
    private Button                          mButtonMuteVideo;
    private Button                          mButtonMuteAudio;
    private ImageView                       mButtonBack;
    private TextView                        mTextTitle;

    private TRTCCloud                       mTRTCCloud;
    private TXDeviceManager                 mTXDeviceManager;
    private TRTCCloudDef.TRTCParams         mTRTCParams;
    private boolean                         mIsFrontCamera = true;
    private String                          mRoomId;
    private String                          mUserId;
    private List<String>                    mRemoteUidList;
    private List<LiveSubVideoView>          mRemoteViewList;
    private boolean                         mMuteVideoFlag = true;
    private boolean                         mMuteAudioFlag = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.live_activity_anchor);
        getSupportActionBar().hide();
        handleIntent();

        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTXDeviceManager = mTRTCCloud.getDeviceManager();
        mTRTCCloud.setListener(new TRTCCloudImplListener(LiveAnchorActivity.this));
        if (checkPermission()) {
            initView();
            enterRoom();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
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

    protected void initView() {
        mButtonBack = findViewById(R.id.iv_back);
        mTextTitle = findViewById(R.id.tv_room_number);
        mButtonMuteVideo = findViewById(R.id.btn_mute_video);
        mButtonMuteAudio = findViewById(R.id.btn_mute_audio);
        mButtonSwitchCamera = findViewById(R.id.live_btn_switch_camera);
        mTxcvvAnchorPreviewView = findViewById(R.id.live_cloud_view_main);

        if (!TextUtils.isEmpty(mRoomId)) {
            mTextTitle.setText(getString(R.string.live_roomid) + mRoomId);
        }

        mRemoteUidList = new ArrayList<>(DEFAULT_CAPACITY);
        mRemoteViewList = new ArrayList<>(DEFAULT_CAPACITY);

        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_2));
        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_3));
        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_4));
        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_5));
        mRemoteViewList.add((LiveSubVideoView)findViewById(R.id.live_cloud_view_6));

        mButtonBack.setOnClickListener(this);
        mTRTCCloud.setListener(new TRTCCloudImplListener(LiveAnchorActivity.this));
        for (int index = 0 ; index < mRemoteViewList.size(); index++) {
            mRemoteViewList.get(index).setLiveSubViewListener(new LiveSubViewListenerImpl(index));
        }
        mButtonMuteVideo.setOnClickListener(this);
        mButtonMuteAudio.setOnClickListener(this);
        mButtonSwitchCamera.setOnClickListener(this);
    }

    public void enterRoom() {
        mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = mUserId;
        mTRTCParams.roomId = Integer.parseInt(mRoomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(mIsFrontCamera, mTxcvvAnchorPreviewView);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTC_APP_SCENE_LIVE);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.btn_mute_video) {
            muteVideo();
        } else if (id == R.id.btn_mute_audio) {
            muteAudio();
        } else if (id == R.id.live_btn_switch_camera) {
            switchCamera();
        } else if (id == R.id.iv_back) {
            finish();
        }
    }

    protected void switchCamera() {
        if (mIsFrontCamera) {
            mIsFrontCamera = false;
            mButtonSwitchCamera.setText( getString(R.string.live_user_front_camera));
        } else {
            mIsFrontCamera = true;
            mButtonSwitchCamera.setText( getString(R.string.live_user_back_camera));
        }
        mTXDeviceManager.switchCamera(mIsFrontCamera);
    }

    private void muteVideo() {
        if (mMuteVideoFlag) {
            mMuteVideoFlag = false;
            mTRTCCloud.stopLocalPreview();
            mButtonMuteVideo.setText(getString(R.string.live_open_camera));
        } else {
            mMuteVideoFlag = true;
            mTRTCCloud.startLocalPreview(mIsFrontCamera, mTxcvvAnchorPreviewView);
            mButtonMuteVideo.setText(getString(R.string.live_close_camera));
        }
    }

    private void muteAudio() {
        if (mMuteAudioFlag) {
            mMuteAudioFlag = false;
            mTRTCCloud.muteLocalAudio(true);
            mButtonMuteAudio.setText( getString(R.string.live_open_mic));
        } else {
            mMuteAudioFlag = true;
            mTRTCCloud.muteLocalAudio(false);
            mButtonMuteAudio.setText( getString(R.string.live_close_mic));
        }
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<LiveAnchorActivity> mContext;

        public TRTCCloudImplListener(LiveAnchorActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {

        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {

        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            int index = mRemoteUidList.indexOf(userId);
            Log.d(TAG, "onUserVideoAvailable index " + index + ", available " + available + " userId " + userId);
            if (available) {
                if (index == -1 && !userId.equals(mRoomId)) {
                    mRemoteUidList.add(userId);
                    refreshRemoteVideoViews();
                }
            } else {
                if (index != -1 && !userId.equals(mRoomId)) {
                    mTRTCCloud.stopRemoteView(userId);
                    mRemoteUidList.remove(index);
                    refreshRemoteVideoViews();
                }
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            LiveAnchorActivity activity = mContext.get();
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
                    mTRTCCloud.startRemoteView(remoteUid, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, mRemoteViewList.get(i).getVideoView());
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
                mTRTCCloud.startRemoteView(mRemoteUidList.get(mIndex), TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, mRemoteViewList.get(mIndex).getVideoView());
                view.setBackground(getResources().getDrawable(R.mipmap.live_subview_video_unmute));
                mRemoteViewList.get(mIndex).getMuteVideoDefault().setVisibility(View.GONE);
            }
            view.setSelected(!isSelected);
        }
    }

    protected void exitRoom() {
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
