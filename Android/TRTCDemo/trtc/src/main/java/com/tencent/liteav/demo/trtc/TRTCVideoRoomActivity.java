package com.tencent.liteav.demo.trtc;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.constraint.Group;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Gravity;
import android.view.TextureView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.beauty.BeautyPanel;
import com.tencent.liteav.demo.trtc.customcapture.TestRenderVideoFrame;
import com.tencent.liteav.demo.trtc.customcapture.TestSendCustomData;
import com.tencent.liteav.demo.trtc.sdkadapter.ConfigHelper;
import com.tencent.liteav.demo.trtc.sdkadapter.TRTCCloudListenerImpl;
import com.tencent.liteav.demo.trtc.sdkadapter.TRTCCloudManager;
import com.tencent.liteav.demo.trtc.sdkadapter.TRTCCloudManagerListener;
import com.tencent.liteav.demo.trtc.sdkadapter.beauty.TRTCBeautyKit;
import com.tencent.liteav.demo.trtc.sdkadapter.bgm.TRTCBgmManager;
import com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayManager;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.AudioConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.PkConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.VideoConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.remoteuser.RemoteUserConfigHelper;
import com.tencent.liteav.demo.trtc.sdkadapter.remoteuser.TRTCRemoteUserManager;
import com.tencent.liteav.demo.trtc.widget.bgm.BgmSettingFragmentDialog;
import com.tencent.liteav.demo.trtc.widget.cdnplay.CdnPlayerSettingFragmentDialog;
import com.tencent.liteav.demo.trtc.widget.feature.FeatureSettingFragmentDialog;
import com.tencent.liteav.demo.trtc.widget.remoteuser.RemoteUserManagerFragmentDialog;
import com.tencent.liteav.demo.trtc.widget.videolayout.TRTCVideoLayoutManager;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCStatistics;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;

/**
 * Module: TRTCVideoRoomActivity
 * <p>
 * Function:  腾讯云实时音视频 SDK 使用范例，提供 SDK 常用的接口使用范例，您可以参考相关代码快速实现、快速上线项目。
 * <p>
 * 1. SDK 提供两种模式在线直播模式{@link TRTCCloudDef#TRTC_APP_SCENE_LIVE}、视频通话模式{@link TRTCCloudDef#TRTC_APP_SCENE_VIDEOCALL}
 * 在线直播（TRTC_APP_SCENE_LIVE）：内部编码器和网络协议优化侧重性能和兼容性，性能和清晰度表现更佳。
 * 视频通话（TRTC_APP_SCENE_VIDEOCALL）：内部编码器和网络协议优化侧重流畅性，降低通话延迟和卡顿率。
 * 详细您可以了解：https://cloud.tencent.com/document/product/647/32266#2.1-.E5.BA.94.E7.94.A8.E5.9C.BA.E6.99.AF
 * 2. 您可以参考 {@link TRTCCloudManager} {@link TRTCRemoteUserManager} {@link TRTCBgmManager} 进行sdk的设置和操作，这三个类封装了 {@link TRTCCloud} 常用的函数
 * 3. {@link com.tencent.liteav.demo.trtc.widget.feature} 文件夹是设置页相关的界面，您可以参考里面的函数对sdk的视频、音频、混流、PK等相关参数进行设置
 * 4. {@link com.tencent.liteav.demo.trtc.widget.bgm} 文件夹是BGM和音效相关的设置界面
 * 5. {@link com.tencent.liteav.demo.trtc.widget.remoteuser} 文件夹是远程用户管理的设置界面
 * 6. {@link com.tencent.liteav.demo.trtc.widget.cdnplay} 文件夹是cdn播放的设置界面
 */
public class TRTCVideoRoomActivity extends AppCompatActivity implements View.OnClickListener, TRTCCloudManagerListener, TRTCCloudManager.IView, TRTCRemoteUserManager.IView, ITXLivePlayListener {
    public static final String KEY_SDK_APP_ID      = "sdk_app_id";
    public static final String KEY_ROOM_ID         = "room_id";
    public static final String KEY_USER_ID         = "user_id";
    public static final String KEY_USER_SIG        = "user_sig";
    public static final String KEY_APP_SCENE       = "app_scene";
    public static final String KEY_ROLE            = "role";
    public static final String KEY_CUSTOM_CAPTURE  = "custom_capture";
    public static final String KEY_VIDEO_FILE_PATH = "file_path";
    public static final String KEY_RECEIVED_VIDEO  = "auto_received_video";
    public static final String KEY_RECEIVED_AUDIO  = "auto_received_audio";

    private static final String TAG                    = "TRTCVideoRoomActivity";
    public static final  String KEY_AUDIO_VOLUMETYOE   = "auto_audio_volumeType";
    public static final  String KEY_AUDIO_HANDFREEMODE = "HandFreeMode";

    /**
     * 【关键】TRTC SDK 组件
     */
    private TRTCCloud                       mTRTCCloud;                 // SDK 核心类
    private TRTCCloudDef.TRTCParams         mTRTCParams;                // 进房参数
    private int                             mAppScene;                  // 推流模式，文件头第一点注释
    private TRTCCloudManager                mTRTCCloudManager;          // 提供核心的trtc
    private TRTCRemoteUserManager           mTRTCRemoteUserManager;
    private TRTCBgmManager                  mBgmManager;
    private CdnPlayManager                  mCdnPlayManager;
    /**
     * 控件布局相关
     */
    private TRTCVideoLayoutManager          mTRTCVideoLayout;           // 视频 View 的管理类，包括：预览自身的 View、观看其他主播的 View。
    private TextView                        mTvRoomId;                  // 标题栏
    private ImageView                       mIvSwitchRole;              // 切换角色按钮
    private FeatureSettingFragmentDialog    mFeatureSettingFragmentDialog; //更多设置面板
    private BgmSettingFragmentDialog        mBgmSettingFragmentDialog;//音效设置面板
    private RemoteUserManagerFragmentDialog mRemoteUserManagerFragmentDialog;
    private BeautyPanel                     mTRTCBeautyPanel;           // 美颜设置控件
    private CdnPlayerSettingFragmentDialog  mCdnPlayerSettingFragmentDialog;
    private ImageView                       mIvSwitchCamera;
    private ImageView                       mIvEnableAudio;
    private Group                           mCdnPlayViewGroup;
    private TXCloudVideoView                mCdnPlayView;
    private Button                          mSwitchCdnBtn;
    private ProgressDialog                  mLoadingDialog;
    private Handler                         mMainHandler;

    // 用于loading超时处理
    private Runnable mLoadingTimeoutRunnable = new Runnable() {
        @Override
        public void run() {
            dismissLoading();
        }
    };

    private int     mLogLevel       = 0;  // 日志等级
    private boolean isCdnPlay       = false;
    private boolean isNeedSwitchCdn = false;
    private String  mMainUserId     = ""; //主播id

    /**
     * 自定义采集和渲染相关
     */
    private boolean              mIsCustomCaptureAndRender = false;
    private String               mVideoFilePath;             // 视频文件路径
    private TestSendCustomData   mCustomCapture;             // 外部采集
    private TestRenderVideoFrame mCustomRender;              // 外部渲染
    private Group                mRoleAudienceGroup;
    private ImageView            mIvMoreTrtc;
    private boolean              mReceivedVideo            = true;
    private boolean              mReceivedAudio            = true;
    private int                  mVolumeType               = 0;
    private boolean              mIsAudioHandFreeMode      = true;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(R.style.BeautyTheme);
        // 获取进房参数
        Intent intent = getIntent();
        // [*****]注意
        // Demo 通过 mAppScene 来区分低延时大房间以及视频通话
        // 视频通话：里面所有的角色都是{@link TRTCCloudDef#TRTCRoleAnchor}主播，服务端会分配主干网上核心机房的服务器供主播连接，能够极大提高视频通话的质量。
        // 低延时大房间：里面可以有多个主播角色，但是绝大部分都是观众，适合直播场景；服务端会分配高速网上机房的服务器供观众连接；
        // 相比其他方案如 CDN 方案等，低延时大房间在直播时延、画面质量等，都有极大的提升，特别是在弱网下，是其他方案无法媲美的。
        mAppScene = intent.getIntExtra(KEY_APP_SCENE, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
        int    sdkAppId = intent.getIntExtra(KEY_SDK_APP_ID, 0);
        int    roomId   = intent.getIntExtra(KEY_ROOM_ID, 0);
        String userId   = intent.getStringExtra(KEY_USER_ID);
        String userSig  = intent.getStringExtra(KEY_USER_SIG);
        int    role     = intent.getIntExtra(KEY_ROLE, TRTCCloudDef.TRTCRoleAnchor);
        mIsCustomCaptureAndRender = intent.getBooleanExtra(KEY_CUSTOM_CAPTURE, false);
        mReceivedVideo = intent.getBooleanExtra(KEY_RECEIVED_VIDEO, true);
        mReceivedAudio = intent.getBooleanExtra(KEY_RECEIVED_AUDIO, true);
        mVolumeType = intent.getIntExtra(KEY_AUDIO_VOLUMETYOE, 0);
        mIsAudioHandFreeMode = intent.getBooleanExtra(KEY_AUDIO_HANDFREEMODE, true);
        Log.d(TAG, "onCreate, intent.getIntExtra  mVolumeType " + mVolumeType);
        //        // 若您的项目有纯音频的旁路直播需求，请配置参数。
        //        // 配置该参数后，音频达到服务器，即开始自动旁路；
        //        // 否则无此参数，旁路在收到第一个视频帧之前，会将收到的音频包丢弃。
        //        JSONObject businessInfo = new JSONObject();
        //        JSONObject pureAudio    = new JSONObject();
        //        try {
        //            pureAudio.put("pure_audio_push_mod",1);
        //            businessInfo.put("Str_uc_params", pureAudio);
        //        } catch (Exception e) {
        //
        //        }
        //
        //        mTRTCParams = new TRTCCloudDef.TRTCParams(sdkAppId, userId, userSig, roomId, "", businessInfo.toString());

        // 设置直播cdn流ID
        // 默认进来，还没处于混流状态
        VideoConfig videoConfig = ConfigHelper.getInstance().getVideoConfig();
        videoConfig.setCurIsMix(false);

        mTRTCParams = new TRTCCloudDef.TRTCParams(sdkAppId, userId, userSig, roomId, "", "");
        mTRTCParams.role = role;

        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // 设置布局
        setContentView(R.layout.trtc_activity_video_room);
        // 初始化
        initTRTCSDK();
        // 初始化 View
        initViews();
        // 初始化外部采集和渲染
        if (mIsCustomCaptureAndRender) {
            initCustomCapture();
        }

        // 开始进房
        enterRoom();
    }

    private void initCustomCapture() {
        mVideoFilePath = getIntent().getStringExtra(KEY_VIDEO_FILE_PATH);
        mCustomCapture = new TestSendCustomData(this, mVideoFilePath, true);
        mCustomRender = new TestRenderVideoFrame(mTRTCParams.userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }

    private void enterRoom() {
        VideoConfig videoConfig = ConfigHelper.getInstance().getVideoConfig();
        AudioConfig audioConfig = ConfigHelper.getInstance().getAudioConfig();
        mTRTCCloudManager.setSystemVolumeType(mVolumeType);
        // 如果当前角色是主播, 才能打开本地摄像头
        if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
            // 开启本地预览
            startLocalPreview();
            videoConfig.setEnableVideo(true);
            videoConfig.setPublishVideo(true);
            // 开始采集声音
            mTRTCCloudManager.startLocalAudio();
            audioConfig.setEnableAudio(true);
        } else {
            videoConfig.setEnableVideo(false);
            audioConfig.setEnableAudio(false);
            videoConfig.setPublishVideo(false);
        }
        // 耳返
        mTRTCCloudManager.enableEarMonitoring(audioConfig.isEnableEarMonitoring());
        mTRTCCloudManager.enterRoom();
    }

    /**
     * 退房
     */
    private void exitRoom() {
        stopLocalPreview();
        // 退房设置为非录制状态
        ConfigHelper.getInstance().getAudioConfig().setRecording(false);
        mTRTCCloudManager.exitRoom();
    }

    private void initViews() {
        // 界面底部功能键初始化
        findViewById(R.id.trtc_iv_mode).setOnClickListener(this);
        findViewById(R.id.trtc_iv_beauty).setOnClickListener(this);
        mIvSwitchCamera = (ImageView) findViewById(R.id.trtc_iv_camera);
        mIvSwitchCamera.setOnClickListener(this);
        mIvEnableAudio = (ImageView) findViewById(R.id.trtc_iv_mic);
        mIvEnableAudio.setOnClickListener(this);
        findViewById(R.id.trtc_iv_log).setOnClickListener(this);
        findViewById(R.id.trtc_iv_setting).setOnClickListener(this);
        findViewById(R.id.trtc_ib_back).setOnClickListener(this);
        findViewById(R.id.trtc_iv_music).setOnClickListener(this);
        mTvRoomId = (TextView) findViewById(R.id.trtc_tv_room_id);
        mTvRoomId.setText(String.valueOf(mTRTCParams.roomId));
        mCdnPlayView = (TXCloudVideoView) findViewById(R.id.trtc_cdn_play_view);
        mCdnPlayViewGroup = (Group) findViewById(R.id.trtc_cdn_view_group);
        mCdnPlayViewGroup.setVisibility(View.GONE);
        mSwitchCdnBtn = (Button) findViewById(R.id.btn_switch_cdn);
        mRoleAudienceGroup = (Group) findViewById(R.id.group_role_audience);
        mIvMoreTrtc = (ImageView) findViewById(R.id.trtc_iv_more);
        mIvMoreTrtc.setOnClickListener(this);

        // 美颜参数回调设置
        mTRTCBeautyPanel = (BeautyPanel) findViewById(R.id.trtc_beauty_panel);

        TRTCBeautyKit manager = new TRTCBeautyKit(mTRTCCloud);
        mTRTCBeautyPanel.setProxy(manager);

        // 更多设置面板
        mFeatureSettingFragmentDialog = new FeatureSettingFragmentDialog();
        mFeatureSettingFragmentDialog.setTRTCCloudManager(mTRTCCloudManager, mTRTCRemoteUserManager);

        // BGM、音效设置面板
        mBgmSettingFragmentDialog = new BgmSettingFragmentDialog();
        mBgmSettingFragmentDialog.setTRTCBgmManager(mBgmManager);

        // 成员列表面板
        mRemoteUserManagerFragmentDialog = new RemoteUserManagerFragmentDialog();
        mRemoteUserManagerFragmentDialog.setTRTCRemoteUserManager(mTRTCRemoteUserManager);
        RemoteUserConfigHelper.getInstance().clear();

        // 界面视频 View 的管理类
        mTRTCVideoLayout = (TRTCVideoLayoutManager) findViewById(R.id.trtc_video_view_layout);
        mTRTCVideoLayout.setMySelfUserId(mTRTCParams.userId);

        // 观众或者主播的控制面板
        mIvSwitchRole = (ImageView) findViewById(R.id.trtc_iv_switch_role);
        mIvSwitchRole.setOnClickListener(this);
        mSwitchCdnBtn.setOnClickListener(this);

        if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
            mRoleAudienceGroup.setVisibility(View.VISIBLE);
            mIvSwitchRole.setVisibility(View.GONE);
            mSwitchCdnBtn.setVisibility(View.GONE);
        } else {
            mRoleAudienceGroup.setVisibility(View.GONE);
            mIvSwitchRole.setVisibility(View.VISIBLE);
            // 观众需要显示cdn按钮
            mSwitchCdnBtn.setVisibility(View.VISIBLE);
        }
        mIvSwitchCamera.setImageResource(mTRTCCloudManager.isFontCamera() ? R.drawable.trtc_ic_camera_front : R.drawable.trtc_ic_camera_back);

        // loading初始化
        mLoadingDialog = new ProgressDialog(this);
        mLoadingDialog.setMessage("切换中");
        mLoadingDialog.setCancelable(false);
        mLoadingDialog.setCanceledOnTouchOutside(false);
        mMainHandler = new Handler();
    }

    /**
     * 初始化 SDK
     */
    private void initTRTCSDK() {
        Log.e(TAG, "enter initTRTCSDK ");

        mTRTCCloud = TRTCCloud.sharedInstance(this);
        mTRTCCloudManager = new TRTCCloudManager(this, mTRTCCloud, mTRTCParams, mAppScene);
        mTRTCCloudManager.setViewListener(this);
        mTRTCCloudManager.setTRTCListener(this);
        mTRTCCloudManager.initTRTCManager(mIsCustomCaptureAndRender, mReceivedAudio, mReceivedVideo);
        mTRTCCloudManager.setSystemVolumeType(mVolumeType);
        mTRTCCloudManager.enableAudioHandFree(mIsAudioHandFreeMode);

        mTRTCRemoteUserManager = new TRTCRemoteUserManager(mTRTCCloud, this, mIsCustomCaptureAndRender);
        mTRTCRemoteUserManager.setMixUserId(mTRTCParams.userId);
        mBgmManager = new TRTCBgmManager(mTRTCCloud, mTRTCParams);

        Log.e(TAG, "exit initTRTCSDK ");
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        // 点击其他Button，关闭美颜面板，否则美颜面板在最下层，被覆盖
        if (id != R.id.trtc_iv_beauty) {
            mTRTCBeautyPanel.setVisibility(View.GONE);
        }

        if (id == R.id.trtc_ib_back) {
            finish();
        } else if (id == R.id.trtc_iv_switch_role) {
            switchRole();
        } else if (id == R.id.trtc_iv_mode) {
            int mode = mTRTCVideoLayout.switchMode();
            ((ImageView) v).setImageResource(mode == TRTCVideoLayoutManager.MODE_FLOAT ? R.drawable.ic_float : R.drawable.ic_gird);
        } else if (id == R.id.trtc_iv_beauty) {
            mTRTCBeautyPanel.setVisibility(mTRTCBeautyPanel.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
        } else if (id == R.id.trtc_iv_camera) {
            mTRTCCloudManager.switchCamera();
            ((ImageView) v).setImageResource(mTRTCCloudManager.isFontCamera() ? R.drawable.trtc_ic_camera_front : R.drawable.trtc_ic_camera_back);
        } else if (id == R.id.trtc_iv_mic) {
            AudioConfig audioConfig = ConfigHelper.getInstance().getAudioConfig();
            audioConfig.setEnableAudio(!audioConfig.isEnableAudio());
            mTRTCCloudManager.muteLocalAudio(!audioConfig.isEnableAudio());
            ((ImageView) v).setImageResource(audioConfig.isEnableAudio() ? R.drawable.mic_enable : R.drawable.mic_disable);
        } else if (id == R.id.trtc_iv_log) {
            if (isCdnPlay) {
                mLogLevel = (mLogLevel + 1) % 2;
                ((ImageView) v).setImageResource((0 == mLogLevel) ? R.drawable.log2 : R.drawable.log);
                mCdnPlayManager.setDebug(1 == mLogLevel);
            } else {
                mLogLevel = (mLogLevel + 1) % 3;
                ((ImageView) v).setImageResource((0 == mLogLevel) ? R.drawable.log2 : R.drawable.log);
                mTRTCCloudManager.showDebugView(mLogLevel);
            }
        } else if (id == R.id.trtc_iv_setting) {
            showDialogFragment(mFeatureSettingFragmentDialog, "FeatureSettingFragmentDialog");
        } else if (id == R.id.trtc_iv_more) {
            if (isCdnPlay) {
                if (mCdnPlayerSettingFragmentDialog == null) {
                    // cdn播放设置
                    mCdnPlayerSettingFragmentDialog = new CdnPlayerSettingFragmentDialog();
                    if (mCdnPlayManager == null) {
                        mCdnPlayManager = new CdnPlayManager(mCdnPlayView, this);
                    }
                    mCdnPlayerSettingFragmentDialog.setCdnPlayManager(mCdnPlayManager);
                }
                showDialogFragment(mCdnPlayerSettingFragmentDialog, "CdnPlayerSettingFragmentDialog");
            } else {
                showDialogFragment(mRemoteUserManagerFragmentDialog, "RemoteUserManagerFragmentDialog");
                if (mRemoteUserManagerFragmentDialog.isVisible()) {
                    mIvMoreTrtc.setImageResource(R.drawable.trtc_ic_member_show);
                } else {
                    mIvMoreTrtc.setImageResource(R.drawable.trtc_ic_member_dismiss);
                }
            }
        } else if (id == R.id.trtc_iv_music) {
            showDialogFragment(mBgmSettingFragmentDialog, "BgmSettingFragmentDialog");
        } else if (id == R.id.btn_switch_cdn) {
            toggleCdnPlay();
        }
    }

    /**
     * 界面中触发cdn播放
     */
    private void toggleCdnPlay() {
        if (mCdnPlayManager == null) {
            mCdnPlayManager = new CdnPlayManager(mCdnPlayView, this);
        }
        if (isCdnPlay) {
            //cdn播放的情况下，需要切换成正常模式
            showLoading();
            isCdnPlay = false;
            mTRTCVideoLayout.setVisibility(View.VISIBLE);
            mCdnPlayViewGroup.setVisibility(View.GONE);
            mCdnPlayManager.stopPlay();
            enterRoom();
            mSwitchCdnBtn.setText("切换CDN播放");
            mIvMoreTrtc.setImageResource(R.drawable.trtc_ic_member_dismiss);
        } else {
            showLoading();
            exitRoom();
            //退出播放必须等退房成功后才可以播放
            isNeedSwitchCdn = true;
        }
    }

    private void showLoading() {
        Log.d(TAG, "showLoading");
        mLoadingDialog.show();
        mMainHandler.removeCallbacks(mLoadingTimeoutRunnable);
        mMainHandler.postDelayed(mLoadingTimeoutRunnable, 6000);
    }

    private void dismissLoading() {
        Log.d(TAG, "dismissLoading");
        if (mLoadingDialog != null && mLoadingDialog.isShowing()) {
            mLoadingDialog.dismiss();
        }
    }

    private void actuallyCdnPlay() {
        isCdnPlay = true;
        mCdnPlayViewGroup.setVisibility(View.VISIBLE);
        mTRTCVideoLayout.setVisibility(View.GONE);
        mCdnPlayManager.initPlayUrl(mTRTCParams.roomId, mMainUserId);
        mCdnPlayManager.startPlay();
        mSwitchCdnBtn.setText("切换UDP播放");
        mIvMoreTrtc.setImageResource(R.drawable.trtc_ic_setting);
    }

    /**
     * 展示dialog界面
     */
    private void showDialogFragment(DialogFragment dialogFragment, String tag) {
        if (dialogFragment != null) {
            if (dialogFragment.isVisible()) {
                try {
                    dialogFragment.dismissAllowingStateLoss();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            } else {
                dialogFragment.show(getSupportFragmentManager(), tag);
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
        mTRTCCloudManager.destroy();
        mTRTCRemoteUserManager.destroy();
        if (mCdnPlayManager != null) {
            mCdnPlayManager.destroy();
        }
        mBgmManager.destroy();
        if (mAppScene == TRTCCloudDef.TRTC_APP_SCENE_LIVE) {
            TRTCCloud.destroySharedInstance();
        }
        mMainHandler.removeCallbacks(mLoadingTimeoutRunnable);
    }

    /**
     * 切换角色
     */
    private void switchRole() {
        AudioConfig audioConfig = ConfigHelper.getInstance().getAudioConfig();
        VideoConfig videoConfig = ConfigHelper.getInstance().getVideoConfig();
        // 目标的切换角色
        int targetRole = mTRTCCloudManager.switchRole();
        // 如果当前角色是主播
        if (targetRole == TRTCCloudDef.TRTCRoleAnchor) {
            mIvSwitchRole.setImageResource(R.drawable.linkmic);
            mSwitchCdnBtn.setVisibility(View.GONE);
            mRoleAudienceGroup.setVisibility(View.VISIBLE);
            // cdn播放中，需要先停止cdn播放，cdn播放里面已经包含了进房的逻辑，所以不用再执行startLocalPreview
            if (isCdnPlay) {
                toggleCdnPlay();
                mCdnPlayViewGroup.setVisibility(View.GONE);
                mIvMoreTrtc.setImageResource(R.drawable.trtc_ic_member_dismiss);
            } else {
                // 开启本地预览
                startLocalPreview();
                videoConfig.setEnableVideo(true);
                videoConfig.setPublishVideo(true);
                // 开启本地声音
                mTRTCCloudManager.startLocalAudio();
                audioConfig.setEnableAudio(true);
            }
        } else {
            // 关闭本地预览
            stopLocalPreview();
            videoConfig.setEnableVideo(false);
            videoConfig.setPublishVideo(false);
            // 关闭音频采集
            mTRTCCloudManager.stopLocalAudio();
            audioConfig.setEnableAudio(false);
            mIvSwitchRole.setImageResource(R.drawable.linkmic2);
            mSwitchCdnBtn.setVisibility(View.VISIBLE);
            mRoleAudienceGroup.setVisibility(View.GONE);
        }
        mIvSwitchCamera.setImageResource(mTRTCCloudManager.isFontCamera() ? R.drawable.trtc_ic_camera_front : R.drawable.trtc_ic_camera_back);
        mIvEnableAudio.setImageResource(audioConfig.isEnableAudio() ? R.drawable.mic_enable : R.drawable.mic_disable);
    }

    private void startLocalPreview() {
        TXCloudVideoView localVideoView = mTRTCVideoLayout.allocCloudVideoView(mTRTCParams.userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        if (!mIsCustomCaptureAndRender) {
            // 开启本地预览
            mTRTCCloudManager.setLocalPreviewView(localVideoView);
            mTRTCCloudManager.startLocalPreview();
        } else {
            if (mCustomCapture != null) {
                mCustomCapture.start();
            }
            // 设置 TRTC SDK 的状态为本地自定义渲染，视频格式为纹理
            mTRTCCloudManager.setLocalVideoRenderListener(mCustomRender);
            if (mCustomRender != null) {
                TextureView textureView = new TextureView(this);
                localVideoView.addVideoView(textureView);
                mCustomRender.start(textureView);
            }
        }
    }

    private void stopLocalPreview() {
        if (!mIsCustomCaptureAndRender) {
            // 关闭本地预览
            mTRTCCloudManager.stopLocalPreview();
        } else {
            if (mCustomCapture != null) {
                mCustomCapture.stop();
            }
            if (mCustomRender != null) {
                mCustomRender.stop();
            }
        }
        mTRTCVideoLayout.recyclerCloudViewView(mTRTCParams.userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }

    /**
     * 显示连麦loading
     */
    private void startLinkMicLoading() {
        FrameLayout layout = (FrameLayout) findViewById(R.id.trtc_fl_link_loading);
        layout.setVisibility(View.VISIBLE);

        ImageView imageView = (ImageView) findViewById(R.id.trtc_iv_link_loading);
        imageView.setImageResource(R.drawable.trtc_linkmic_loading);
        AnimationDrawable animation = (AnimationDrawable) imageView.getDrawable();
        if (animation != null) {
            animation.start();
        }
    }

    /**
     * 隐藏连麦loading
     */
    private void stopLinkMicLoading() {
        FrameLayout layout = (FrameLayout) findViewById(R.id.trtc_fl_link_loading);
        layout.setVisibility(View.GONE);

        ImageView         imageView = (ImageView) findViewById(R.id.trtc_iv_link_loading);
        AnimationDrawable animation = (AnimationDrawable) imageView.getDrawable();
        if (animation != null) {
            animation.stop();
        }
    }


    private void onVideoChange(String userId, int streamType, boolean available) {
        if (available) {
            // 首先需要在界面中分配对应的TXCloudVideoView
            TXCloudVideoView renderView = mTRTCVideoLayout.findCloudViewView(userId, streamType);
            if (renderView == null) {
                renderView = mTRTCVideoLayout.allocCloudVideoView(userId, streamType);
            }
            // 启动远程画面的解码和显示逻辑
            if (renderView != null) {
                mTRTCRemoteUserManager.remoteUserVideoAvailable(userId, streamType, renderView);
            }
            if (!userId.equals(mMainUserId)) {
                mMainUserId = userId;
            }
        } else {
            mTRTCRemoteUserManager.remoteUserVideoUnavailable(userId, streamType);
            if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB) {
                // 辅路直接移除画面，不会更新状态。主流需要更新状态，所以保留
                mTRTCVideoLayout.recyclerCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
            }
        }
        if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG) {
            // 根据当前视频流的状态，展示相关的 UI 逻辑。
            mTRTCVideoLayout.updateVideoStatus(userId, available);
        }
        mTRTCRemoteUserManager.updateCloudMixtureParams();
    }

    /**
     * 加入房间回调
     *
     * @param elapsed 加入房间耗时，单位毫秒
     */
    @Override
    public void onEnterRoom(long elapsed) {
        dismissLoading();
        if (elapsed >= 0) {
            Toast.makeText(this, "加入房间成功，耗时 " + elapsed + " 毫秒", Toast.LENGTH_SHORT).show();
            // 发起云端混流
            mTRTCRemoteUserManager.updateCloudMixtureParams();
        } else {
            Toast.makeText(this, "加入房间失败", Toast.LENGTH_SHORT).show();
            exitRoom();
        }
    }

    @Override
    public void onExitRoom(int reason) {
        if (isNeedSwitchCdn && mTRTCParams.role == TRTCCloudDef.TRTCRoleAudience) {
            //等待播放回调再停止dialog
            actuallyCdnPlay();
            isNeedSwitchCdn = false;
        }
    }

    /**
     * ERROR 大多是不可恢复的错误，需要通过 UI 提示用户
     * 然后执行退房操作
     *
     * @param errCode   错误码 TXLiteAVError
     * @param errMsg    错误信息
     * @param extraInfo 扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
     */
    @Override
    public void onError(int errCode, String errMsg, Bundle extraInfo) {
        Toast.makeText(this, "onError: " + errMsg + "[" + errCode + "]", Toast.LENGTH_SHORT).show();
        // 执行退房
        exitRoom();
        finish();
    }

    /**
     * 有新的主播{@link TRTCCloudDef#TRTCRoleAnchor}加入了当前视频房间
     * 该方法会在主播加入房间的时候进行回调，此时音频数据会自动拉取下来，但是视频需要有 View 承载才会开始渲染。
     * 为了更好的交互体验，Demo 选择在 onUserVideoAvailable 中，申请 View 并且开始渲染。
     * 您可以根据实际需求，选择在 onUserEnter 还是 onUserVideoAvailable 中发起渲染。
     *
     * @param userId 用户标识
     */
    @Override
    public void onUserEnter(String userId) {
    }

    /**
     * 主播{@link TRTCCloudDef#TRTCRoleAnchor}离开了当前视频房间
     * 主播离开房间，要释放相关资源。
     * 1. 释放主画面、辅路画面
     * 2. 如果您有混流的需求，还需要重新发起混流，保证混流的布局是您所期待的。
     *
     * @param userId 用户标识
     * @param reason 离开原因代码，区分用户是正常离开，还是由于网络断线等原因离开。
     */
    @Override
    public void onUserExit(String userId, int reason) {
        mTRTCRemoteUserManager.removeRemoteUser(userId);
        // 回收分配的渲染的View
        mTRTCVideoLayout.recyclerCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        mTRTCVideoLayout.recyclerCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
        // 更新混流参数
        mTRTCRemoteUserManager.updateCloudMixtureParams();
    }

    /**
     * 若当对应 userId 的主播有上行的视频流的时候，该方法会被回调，available 为 true；
     * 若对应的主播通过{@link TRTCCloud#muteLocalVideo(boolean)}，该方法也会被回调，available 为 false。
     * Demo 在收到主播有上行流的时候，会通过{@link TRTCCloud#startRemoteView(String, TXCloudVideoView)} 开始渲染
     * Demo 在收到主播停止上行的时候，会通过{@link TRTCCloud#stopRemoteView(String)} 停止渲染，并且更新相关 UI
     *
     * @param userId    用户标识
     * @param available 画面是否开启
     */
    @Override
    public void onUserVideoAvailable(String userId, boolean available) {
        onVideoChange(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, available);
    }


    /**
     * 是否有辅路上行的回调，Demo 中处理方式和主画面的一致 {@link TRTCCloudListenerImpl#onUserVideoAvailable(String, boolean)}
     *
     * @param userId    用户标识
     * @param available 屏幕分享是否开启
     */
    @Override
    public void onUserSubStreamAvailable(final String userId, boolean available) {
        onVideoChange(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB, available);
    }

    /**
     * 是否有音频上行的回调
     * <p>
     * 您可以根据您的项目要求，设置相关的 UI 逻辑，比如显示对端闭麦的图标等
     *
     * @param userId    用户标识
     * @param available true：音频可播放，false：音频被关闭
     */
    @Override
    public void onUserAudioAvailable(String userId, boolean available) {
    }

    /**
     * 视频首帧渲染回调
     * <p>
     * 一般客户可不关注，专业级客户质量统计等；您可以根据您的项目情况决定是否进行统计或实现其他功能。
     *
     * @param userId     用户 ID
     * @param streamType 视频流类型
     * @param width      画面宽度
     * @param height     画面高度
     */
    @Override
    public void onFirstVideoFrame(String userId, int streamType, int width, int height) {
        Log.i(TAG, "onFirstVideoFrame: userId = " + userId + " streamType = " + streamType + " width = " + width + " height = " + height);
    }

    /**
     * 音量大小回调
     * <p>
     * 您可以用来在 UI 上显示当前用户的声音大小，提高用户体验
     *
     * @param userVolumes 所有正在说话的房间成员的音量（取值范围0 - 100）。即 userVolumes 内仅包含音量不为0（正在说话）的用户音量信息。其中本地进房 userId 对应的音量，表示 local 的音量，也就是自己的音量。
     * @param totalVolume 所有远端成员的总音量, 取值范围 [0, 100]
     */
    @Override
    public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
        for (int i = 0; i < userVolumes.size(); ++i) {
            mTRTCVideoLayout.updateAudioVolume(userVolumes.get(i).userId, userVolumes.get(i).volume);
        }
    }

    /**
     * SDK 状态数据回调
     * <p>
     * 一般客户无需关注，专业级客户可以用来进行统计相关的性能指标；您可以根据您的项目情况是否实现统计等功能
     *
     * @param statics 状态数据
     */
    @Override
    public void onStatistics(TRTCStatistics statics) {
    }

    /**
     * 跨房连麦会结果回调
     *
     * @param userID
     * @param err
     * @param errMsg
     */
    @Override
    public void onConnectOtherRoom(final String userID, final int err, final String errMsg) {
        PkConfig pkConfig = ConfigHelper.getInstance().getPkConfig();
        stopLinkMicLoading();
        if (err == 0) {
            pkConfig.setConnected(true);
            Toast.makeText(this, "跨房连麦成功", Toast.LENGTH_LONG).show();
        } else {
            pkConfig.setConnected(false);
            Toast.makeText(this, "跨房连麦失败", Toast.LENGTH_LONG).show();
        }
    }

    /**
     * 断开跨房连麦结果回调
     *
     * @param err
     * @param errMsg
     */
    @Override
    public void onDisConnectOtherRoom(final int err, final String errMsg) {
        PkConfig pkConfig = ConfigHelper.getInstance().getPkConfig();
        pkConfig.reset();
    }

    /**
     * 网络行质量回调
     * <p>
     * 您可以用来在 UI 上显示当前用户的网络质量，提高用户体验
     *
     * @param localQuality  上行网络质量
     * @param remoteQuality 下行网络质量
     */
    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality) {
        mTRTCVideoLayout.updateNetworkQuality(localQuality.userId, localQuality.quality);
        for (TRTCCloudDef.TRTCQuality qualityInfo : remoteQuality) {
            mTRTCVideoLayout.updateNetworkQuality(qualityInfo.userId, qualityInfo.quality);
        }
    }

    /**
     * 音效播放回调
     *
     * @param effectId
     * @param code     0：表示播放正常结束；其他为异常结束，暂无异常值
     */
    @Override
    public void onAudioEffectFinished(int effectId, int code) {
        Toast.makeText(this, "effect id = " + effectId + " 播放结束" + " code = " + code, Toast.LENGTH_SHORT).show();
        mBgmSettingFragmentDialog.onAudioEffectFinished(effectId, code);
    }

    @Override
    public void onRecvCustomCmdMsg(String userId, int cmdID, int seq, byte[] message) {
        String msg = "";
        if (message != null && message.length > 0) {
            try {
                msg = new String(message, "UTF-8");
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
            ToastUtils.showLong("收到" + userId + "的消息：" + msg);
        }
    }

    @Override
    public void onRecvSEIMsg(String userId, byte[] data) {
        String msg = "";
        if (data != null && data.length > 0) {
            try {
                msg = new String(data, "UTF-8");
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
            ToastUtils.showLong("收到" + userId + "的消息：" + msg);
        }
    }

    @Override
    public void onAudioVolumeEvaluationChange(boolean enable) {
        if (enable) {
            mTRTCVideoLayout.showAllAudioVolumeProgressBar();
        } else {
            mTRTCVideoLayout.hideAllAudioVolumeProgressBar();
        }
    }

    @Override
    public void onStartLinkMic() {
        startLinkMicLoading();
    }

    @Override
    public void onMuteLocalVideo(boolean isMute) {
        mTRTCVideoLayout.updateVideoStatus(mTRTCParams.userId, !isMute);
    }

    @Override
    public void onMuteLocalAudio(boolean isMute) {
        mIvEnableAudio.setImageResource(!isMute ? R.drawable.mic_enable : R.drawable.mic_disable);
    }

    @Override
    public void onSnapshotLocalView(final Bitmap bmp) {
        showSnapshotImage(bmp);
    }

    @Override
    public TXCloudVideoView getRemoteUserViewById(String userId, int steamType) {
        TXCloudVideoView view = mTRTCVideoLayout.findCloudViewView(userId, steamType);
        if (view == null) {
            view = mTRTCVideoLayout.allocCloudVideoView(userId, steamType);
        }
        return view;
    }

    @Override
    public void onRemoteViewStatusUpdate(String userId, boolean enableVideo) {
        mTRTCVideoLayout.updateVideoStatus(userId, enableVideo);
    }

    @Override
    public void onSnapshotRemoteView(Bitmap bm) {
        showSnapshotImage(bm);
    }

    @Override
    public void onPlayEvent(int event, Bundle param) {
        if (event == TXLiveConstants.PLAY_EVT_PLAY_BEGIN) {
            dismissLoading();
            ToastUtils.showLong("播放成功：" + event);
        } else if (event == TXLiveConstants.PLAY_EVT_GET_MESSAGE) {
            if (param != null) {
                byte[] data       = param.getByteArray(TXLiveConstants.EVT_GET_MSG);
                String seiMessage = "";
                if (data != null && data.length > 0) {
                    try {
                        seiMessage = new String(data, "UTF-8");
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                ToastUtils.showLong(seiMessage);
            }
        } else if (event < 0) {
            dismissLoading();
            ToastUtils.showLong("播放失败：" + event);
        }
    }

    @Override
    public void onNetStatus(Bundle status) {

    }

    private void showSnapshotImage(final Bitmap bmp) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (bmp == null) {
                    ToastUtils.showLong("截图失败");
                } else {
                    ImageView imageView = new ImageView(TRTCVideoRoomActivity.this);
                    imageView.setImageBitmap(bmp);
                    AlertDialog dialog = new AlertDialog.Builder(TRTCVideoRoomActivity.this)
                            .setView(imageView)
                            .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                }
                            }).create();

                    dialog.show();

                    final Button              positiveButton   = dialog.getButton(AlertDialog.BUTTON_POSITIVE);
                    LinearLayout.LayoutParams positiveButtonLL = (LinearLayout.LayoutParams) positiveButton.getLayoutParams();
                    positiveButtonLL.gravity = Gravity.CENTER;
                    positiveButton.setLayoutParams(positiveButtonLL);
                }
            }
        });
    }
}
