package com.tencent.trtc.screenshare;

import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.Constant;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;

import static com.tencent.trtc.TRTCCloudDef.TRTCRoleAnchor;
import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;

/**
 * TRTC 屏幕分享的主播页面
 *
 * 包含如下简单功能：
 * - 进入直播共享房间{@link ScreenAnchorActivity#enterRoom()}
 * - 退出直播共享房间{@link ScreenAnchorActivity#exitRoom()}
 * - 开启屏幕分享{@link ScreenAnchorActivity#startScreenCapture()}
 * - 关闭屏幕共享{@link ScreenAnchorActivity#stopScreenCapture()}
 * - 打开/关闭麦克风{@link ScreenAnchorActivity#muteAudio()}
 * 
 * - 详见API文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#aa6671fc587513dad7df580556e43be58}
 */

/**
 * Screen Sharing View for Anchor
 *
 * Features:
 * - Enter a room: {@link ScreenAnchorActivity#enterRoom()}
 * - Exit a room: {@link ScreenAnchorActivity#exitRoom()}
 * - Start screen sharing: {@link ScreenAnchorActivity#startScreenCapture()}
 * - End screen sharing: {@link ScreenAnchorActivity#stopScreenCapture()}
 * - Turn on/off the mic: {@link ScreenAnchorActivity#muteAudio()}
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#aa6671fc587513dad7df580556e43be58}.
 */
public class ScreenAnchorActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String TAG                                 = "ScreenAnchorActivity";
    private static final int    OVERLAY_PERMISSION_REQ_CODE         = 1234;
    private static final int    OVERLAY_PERMISSION_SHARE_REQ_CODE   = 1235;

    private TextView        mTextStartScreenTips;
    private TextView        mTextScreenCaptureInfo;
    private ImageView       mImageBack;
    private Button          mButtonMuteAudio;
    private Button          mButtonStartCapture;

    private TRTCCloud       mTRTCCloud;
    private String          mRoomId;
    private String          mUserId;
    private boolean         mIsCapturing = false;
    private FloatingView    mFloatingView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().setFormat(PixelFormat.TRANSLUCENT);
        setContentView(R.layout.screenshare_activity_anchor);
        getSupportActionBar().hide();
        handleIntent();

        if (checkPermission()) {
            initView();
            enterRoom();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mFloatingView != null && mFloatingView.isShown()) {
            mFloatingView.dismiss();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
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
        mImageBack = findViewById(R.id.screen_ic_back);
        mButtonMuteAudio = findViewById(R.id.screen_btn_mute_audio);
        mButtonStartCapture = findViewById(R.id.bt_start_capture);
        mTextStartScreenTips = findViewById(R.id.tv_start_screen);
        mTextScreenCaptureInfo = findViewById(R.id.tv_watch_tips);

        mImageBack.setOnClickListener(this);
        mButtonMuteAudio.setOnClickListener(this);
        mButtonStartCapture.setOnClickListener(this);

        mFloatingView = new FloatingView(getApplicationContext(), R.layout.screenshare_window_floating);
        mFloatingView.setPopupWindow(R.layout.screenshare_popup_layout);
        mFloatingView.setOnPopupItemClickListener(this);
    }

    private void enterRoom() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(ScreenAnchorActivity.this));

        final TRTCCloudDef.TRTCParams screenParams = new TRTCCloudDef.TRTCParams();
        screenParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        screenParams.userId = mUserId;
        screenParams.roomId = Integer.parseInt(mRoomId);
        screenParams.userSig = GenerateTestUserSig.genTestUserSig(screenParams.userId);
        screenParams.role = TRTCRoleAnchor;

        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(screenParams, TRTC_APP_SCENE_VIDEOCALL);

        String text = getString(R.string.screenshare_room_id) + mRoomId + "\n"
                + getString(R.string.screenshare_username) + mUserId + "\n"
                + getString(R.string.screenshare_resolution) + "\n"
                + getString(R.string.screenshare_watch_tips);
        mTextScreenCaptureInfo.setVisibility(View.VISIBLE);
        mTextScreenCaptureInfo.setText(text);
    }

    @Override
    protected void onStop() {
        super.onStop();
        requestDrawOverLays();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mFloatingView != null && mFloatingView.isShown()) {
            mFloatingView.dismiss();
        }
        exitRoom();
    }

    public void requestDrawOverLays() {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(ScreenAnchorActivity.this)) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + ScreenAnchorActivity.this.getPackageName()));
            startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
        } else {
            showFloatingView();
        }
    }

    private void showFloatingView() {
        if (mFloatingView != null && !mFloatingView.isShown()) {
            if ((null != mTRTCCloud)) {
                mFloatingView.show();
                mFloatingView.setOnPopupItemClickListener(this);
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == OVERLAY_PERMISSION_REQ_CODE) {
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(ScreenAnchorActivity.this)) {
                Toast.makeText(getApplicationContext(), getString(R.string.screenshare_permission_toast), Toast.LENGTH_SHORT).show();
            } else {
                showFloatingView();
            }
        }else if(resultCode == OVERLAY_PERMISSION_SHARE_REQ_CODE){
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(ScreenAnchorActivity.this)) {
                Toast.makeText(getApplicationContext(),  getString(R.string.screenshare_permission_toast), Toast.LENGTH_SHORT).show();
            } else {
                screenCapture();
            }
        }
    }

    private void exitRoom() {
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

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.screen_ic_back) {
            finish();
        } else if (id == R.id.screen_btn_mute_audio) {
            muteAudio();
        } else if (id == R.id.bt_start_capture) {
            if (mIsCapturing) {
                stopScreenCapture();
            } else {
                startScreenCapture();
            }
        } else if (id == R.id.btn_return) {
            Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            }
            try {
                PendingIntent pendingIntent = PendingIntent.getActivity(getApplicationContext(), 0, intent, 0);
                pendingIntent.send();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void startScreenCapture() {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(ScreenAnchorActivity.this)) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + ScreenAnchorActivity.this.getPackageName()));
            startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
        } else {
            screenCapture();
        }
    }

    private void screenCapture() {
        TRTCCloudDef.TRTCVideoEncParam encParams = new TRTCCloudDef.TRTCVideoEncParam();
        encParams.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
        encParams.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
        encParams.videoFps = 10;
        encParams.enableAdjustRes = false;
        encParams.videoBitrate = 1200;

        TRTCCloudDef.TRTCScreenShareParams params = new TRTCCloudDef.TRTCScreenShareParams();
        mTRTCCloud.startScreenCapture(encParams, params);
        mIsCapturing = true;
        mTextStartScreenTips.setVisibility(View.VISIBLE);
        mButtonStartCapture.setText(getString(R.string.screenshare_stop));
    }

    private void stopScreenCapture() {
        mTRTCCloud.stopScreenCapture();
        mIsCapturing = false;
        mTextStartScreenTips.setVisibility(View.GONE);
        mButtonStartCapture.setText(getString(R.string.screenshare_start));
    }

    private void muteAudio() {
        boolean isSelected = mButtonMuteAudio.isSelected();
        if (!isSelected) {
            mTRTCCloud.muteLocalAudio(true);
            mButtonMuteAudio.setText(getString(R.string.screenshare_stop_mute_audio));
        } else {
            mTRTCCloud.muteLocalAudio(false);
            mButtonMuteAudio.setText(getString(R.string.screenshare_mute_audio));
        }
        mButtonMuteAudio.setSelected(!isSelected);
    }

    private class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<ScreenAnchorActivity> mContext;

        public TRTCCloudImplListener(ScreenAnchorActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            ScreenAnchorActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                } else if (errCode == -1308) {
                   Toast.makeText(ScreenAnchorActivity.this, getString(R.string.screenshare_start_failed), Toast.LENGTH_SHORT).show();
                    stopScreenCapture();
                }
            }
        }
    }

}
