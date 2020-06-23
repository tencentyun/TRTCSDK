package com.tencent.liteav.screen;

import android.Manifest;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.pm.PackageManager;
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

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.liteav.debug.Constant;
import com.tencent.liteav.debug.GenerateTestUserSig;
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
 * 屏幕分享的主页面
 *
 * 包含如下简单功能：
 * - 进入/退出语音通话房间
 * - 开启/停止屏幕分享
 * - 打开/关闭麦克风
 */
public class ScreenActivity extends AppCompatActivity implements View.OnClickListener {

    private static final String TAG = "ScreenActivity";
    //主播退出广播字段
    public static final String EXIT_APP         = "EXIT_APP";
    private static final int REQ_PERMISSION_CODE  = 0x1000;
    private static final int OVERLAY_PERMISSION_REQ_CODE = 1234;

    private TextView                        mTitleText;                 //【控件】页面Title
    private TextView                        mStartScreenTips;           //【控件】开始屏幕共享时提示信息
    private TextView                        mScreenCaptureInfo;         //【控件】屏幕共享时，用户名，房间好，分辨率信息
    private TXCloudVideoView                mLocalPreviewView;          //【控件】本地画面View
    private ImageView                       mBackButton;                //【控件】返回上一级页面
    private Button                          mMuteAudio;                 //【控件】开启、关闭本地声音采集并上行
    private Button                          mStartCapture;              //【控件】开启、关闭屏幕共享

    private TRTCCloud                       mTRTCCloud;                 // SDK 核心类
    private int                             mGrantedCount = 0;          // 权限个数计数，获取Android系统权限
    private String                          mRoomId;                    // 房间Id
    private String                          mUserId;                    // 用户Id
    private boolean                         mIsCapturing = false;       // 是否正在屏幕共享
    private FloatingView                    mFloatingView;              // 悬浮球

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().setFormat(PixelFormat.TRANSLUCENT);
        setContentView(R.layout.activity_screen);
        getSupportActionBar().hide();
        handleIntent();
        // 先检查权限再加入通话
        if (checkPermission()) {
            initView();
            enterRoom();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mFloatingView.isShown()) {
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
        mTitleText          = findViewById(R.id.screen_tv_room_number);
        mBackButton         = findViewById(R.id.screen_ic_back);
        mLocalPreviewView   = findViewById(R.id.screen_tc_cloud_view_main);
        mMuteAudio          = findViewById(R.id.screen_btn_mute_audio);
        mStartCapture       = findViewById(R.id.bt_start_capture);
        mStartScreenTips    = findViewById(R.id.tv_start_screen);
        mScreenCaptureInfo  = findViewById(R.id.tv_watch_tips);

        if (!TextUtils.isEmpty(mRoomId)) {
            mTitleText.setText(mRoomId);
        }
        mBackButton.setOnClickListener(this);
        mMuteAudio.setOnClickListener(this);
        mStartCapture.setOnClickListener(this);

        //悬浮球界面
        mFloatingView = new FloatingView(getApplicationContext(), R.layout.view_floating_default);
        mFloatingView.setPopupWindow(R.layout.screen_popup_layout);

        mFloatingView.setOnPopupItemClickListener(this);
    }

    private void enterRoom() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(ScreenActivity.this));

        // 初始化配置 SDK 参数
        TRTCCloudDef.TRTCParams screenParams = new TRTCCloudDef.TRTCParams();
        screenParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        screenParams.userId = mUserId;
        screenParams.roomId = Integer.parseInt(mRoomId);
        // userSig是进入房间的用户签名，相当于密码（这里生成的是测试签名，正确做法需要业务服务器来生成，然后下发给客户端）
        screenParams.userSig = GenerateTestUserSig.genTestUserSig(screenParams.userId);
        screenParams.role = TRTCRoleAnchor;

        // 进入通话
        mTRTCCloud.enterRoom(screenParams, TRTC_APP_SCENE_VIDEOCALL);
        // 开启本地声音采集并上行
        mTRTCCloud.startLocalAudio();
        String text = getString(R.string.screen_username) + mUserId + "\n"
                + getString(R.string.screen_room_id) + mRoomId + "\n"
                + getString(R.string.screen_resolution) + "\n"
                + getString(R.string.screen_watch_tips);
        mScreenCaptureInfo.setVisibility(View.VISIBLE);
        mScreenCaptureInfo.setText(text);
    }

    @Override
    protected void onStop() {
        super.onStop();
        requestDrawOverLays();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mFloatingView.isShown()) {
            mFloatingView.dismiss();
        }
        exitRoom();
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      浮窗相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    public void requestDrawOverLays() {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(ScreenActivity.this)) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + ScreenActivity.this.getPackageName()));
            startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
        } else {
            showFloatingView();
        }
    }

    private void showFloatingView() {
        if (!mFloatingView.isShown()) {
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
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(ScreenActivity.this)) {
                Toast.makeText(getApplicationContext(), "请在设置-权限设置里打开悬浮窗权限", Toast.LENGTH_SHORT).show();
            } else {
                showFloatingView();
            }
        }
    }

    /**
     * 离开通话
     */
    private void exitRoom() {
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.stopLocalPreview();
        mTRTCCloud.exitRoom();
        //销毁 screen 实例
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
                ActivityCompat.requestPermissions(ScreenActivity.this,
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
                Toast.makeText(this, getString(R.string.screen_permission_error_tip), Toast.LENGTH_SHORT).show();
            }
            mGrantedCount = 0;
        }
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
            //悬浮球返回主界面按钮
            Toast.makeText(getApplicationContext(), "返回主界面", Toast.LENGTH_SHORT).show();
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!PermissionUtils.isGrantedDrawOverlays()) {
                ToastUtils.showLong(getString(R.string.screen_permission_overlay));
                PermissionUtils.requestDrawOverlays(new PermissionUtils.SimpleCallback() {
                    @Override
                    public void onGranted() {
                        screenCapture();
                    }

                    @Override
                    public void onDenied() {
                        ToastUtils.showLong(getString(R.string.screen_permission_overlay));
                    }
                });
            } else {
                screenCapture();
            }
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
        mStartScreenTips.setVisibility(View.VISIBLE);
        mStartCapture.setText(getString(R.string.screen_stop));
    }

    private void stopScreenCapture() {
        mTRTCCloud.stopScreenCapture();
        mIsCapturing = false;
        mStartScreenTips.setVisibility(View.GONE);
        mStartCapture.setText(getString(R.string.screen_start));
    }

    private void muteAudio() {
        boolean isSelected = mMuteAudio.isSelected();
        if (!isSelected) {
            mTRTCCloud.stopLocalAudio();
            mMuteAudio.setBackground(getResources().getDrawable(R.mipmap.screen_mic_off));
        } else {
            mTRTCCloud.startLocalAudio();
            mMuteAudio.setBackground(getResources().getDrawable(R.mipmap.screen_mic_on));
        }
        mMuteAudio.setSelected(!isSelected);
    }

    private class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<ScreenActivity>      mContext;

        public TRTCCloudImplListener(ScreenActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        // 错误通知监听，错误通知意味着 SDK 不能继续运行
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            ScreenActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                } else if (errCode == -1308) {
                    ToastUtils.showLong(getString(R.string.screen_start_failed));
                    stopScreenCapture();
                }
            }
        }
    }

}
