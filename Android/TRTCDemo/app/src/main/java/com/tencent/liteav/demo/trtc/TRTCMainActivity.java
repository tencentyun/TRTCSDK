package com.tencent.liteav.demo.trtc;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.AnimationDrawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.TextureView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.trtc.customCapture.TestRenderVideoFrame;
import com.tencent.liteav.demo.trtc.customCapture.TestSendCustomVideoData;
import com.tencent.liteav.demo.trtc.utils.Utils;
import com.tencent.liteav.demo.trtc.widget.TRTCBeautySettingPanel;
import com.tencent.liteav.demo.trtc.widget.TRTCMoreDialog;
import com.tencent.liteav.demo.trtc.widget.TRTCSettingDialog;
import com.tencent.liteav.demo.trtc.widget.videolayout.TRTCVideoLayoutManager;
import com.tencent.rtmp.TXLog;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.TRTCStatistics;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Module : TRTCMainActivity
 *
 * Function: 腾讯云实时音视频 SDK 使用范例，提供 SDK 常用的接口使用范例，您可以参考相关代码快速实现、快速上线项目。
 *
 * 1. {@link TRTCCloud} 实现方式是单例，通过 {@link com.tencent.trtc.impl.TRTCCloudImpl#sharedInstance(Context)} 可以获取到实例
 *
 * 2. 主播推流参数设置，您可以参考{@link TRTCMainActivity#setTRTCCloudParam()} 对视频码率、分辨率、FPS、流控模式进行配置；以及参考 {@link TRTCSettingDialog} 中相关参数配置。
 *
 * 3. SDK 提供两种模式在线直播模式{@link TRTCCloudDef#TRTC_APP_SCENE_LIVE}、视频通话模式{@link TRTCCloudDef#TRTC_APP_SCENE_VIDEOCALL}
 *      在线直播（TRTC_APP_SCENE_LIVE）：内部编码器和网络协议优化侧重性能和兼容性，性能和清晰度表现更佳。
 *      视频通话（TRTC_APP_SCENE_VIDEOCALL）：内部编码器和网络协议优化侧重流畅性，降低通话延迟和卡顿率。
 *      详细您可以了解：https://cloud.tencent.com/document/product/647/32266#2.1-.E5.BA.94.E7.94.A8.E5.9C.BA.E6.99.AF
 *
 * 4. 如何进退房？ 请参考：{@link TRTCMainActivity#enterRoom()} 与 {@link TRTCMainActivity#exitRoom()}
 *
 * 5. SDK 所有的回调我都需要做什么？ 请参考：{@link TRTCCloudListenerImpl} Demo 层实现了对 SDK 所有回调的处理，您可以根据代码以及注释理解到在这个回调中，实现什么功能。
 *
 * 6. 美颜参数配置与实现？ 请参考：{@link TRTCBeautySettingPanel} 与 {@link TRTCMainActivity#onBeautyParamsChange(TRTCBeautySettingPanel.BeautyParams, int)} 回调，设置相关参数
 *
 * 7. 如何实现连麦？ 请参考：{@link TRTCCloudListenerImpl#onUserVideoAvailable(String, boolean)} 与 {@link TRTCMainActivity#startSDKRender(String, boolean, int)}
 *      监听回调，实现 SDK 渲染
 *      
 * 8. 如何实现跨房连麦？ 请参考：{@link TRTCMainActivity#startLinkMic()} 与 {@link TRTCCloudListenerImpl#onConnectOtherRoom(String, int, String)}
 *
 * 9. 如何将 SDK 主播之间的视频通话，通过 CDN 分发到网站、QQ、微信等其他应用内置的网页或播放器中进行播放？
 *      请参考Demo {@link TRTCMainActivity#updateCloudMixtureParams()} 对混流参数进行配置
 *      以及 Demo {@link TRTCMainActivity#onClickButtonGetPlayUrl()} 获取播放地址
 *
 * 10. 视频通话与低延时大房间是什么关系？怎么代码都基本是同一套？
 *      视频通话：里面所有的角色都是{@link TRTCCloudDef#TRTCRoleAnchor}主播，服务端会分配主干网上核心机房的服务器供主播连接，能够极大提高视频通话的质量。
 *      低延时大房间：里面可以有多个主播角色，但是绝大部分都是观众，适合直播场景；服务端会分配高速网上机房的服务器供观众连接；
 *      相比其他方案如 CDN 方案等，低延时大房间在直播时延、画面质量等，都有极大的提升，特别是在弱网下，是其他方案无法媲美的。
 *
 * 11. 如何实现外部采集与外部渲染？ 一般性客户不推荐使用，SDK已经为您做了最优的优化；若您是专业级客户，您可以通过相关接口实现外部采集与渲染，
 *      请参考：{@link TestSendCustomVideoData} 与 {@link TestRenderVideoFrame} 类的实现
 *      以及 Demo 示例 {@link TRTCMainActivity#initTRTCSDK()}中开启自采集开关、{@link TRTCMainActivity#startCustomLocalPreview(boolean)} 实现本地预览、{@link TRTCMainActivity#startCustomRender(String, boolean)}实现自定义渲染
 *      此外您还可以参考文档：https://cloud.tencent.com/document/product/647/34066
 *
 * 12. Demo 是如何实现对复杂的视频布局，堆叠布局与九宫格布局切换的？ 请参考：{@link TRTCVideoLayoutManager} 布局管理类
 */
public class TRTCMainActivity extends Activity implements View.OnClickListener, TRTCBeautySettingPanel.IOnBeautyParamsChangeListener, TRTCSettingDialog.ISettingListener, TRTCMoreDialog.IMoreListener, TRTCVideoLayoutManager.IVideoLayoutListener {
    private static final String                 TAG = "TRTCMainActivity";

    public static final String                  KEY_SDK_APP_ID      = "sdk_app_id";
    public static final String                  KEY_ROOM_ID         = "room_id";
    public static final String                  KEY_USER_ID         = "user_id";
    public static final String                  KEY_USER_SIG        = "user_sig";
    public static final String                  KEY_APP_SCENE       = "app_scene";
    public static final String                  KEY_ROLE            = "role";
    public static final String                  KEY_CUSTOM_CAPTURE  = "custom_capture";
    public static final String                  KEY_VIDEO_FILE_PATH = "file_path";

    /**
     * 【关键】TRTC SDK 组件
     */
    private TRTCCloudListener                   mTRTCListener;              // 回调监听
    private TRTCCloud                           mTRTCCloud;                 // SDK 核心类
    private TRTCCloudDef.TRTCParams             mTRTCParams;                // 进房参数
    private int                                 mAppScene;                  // 推流模式，文件头第三点注释

    /**
     * 控件布局相关
     */
    private TRTCVideoLayoutManager              mTRTCVideoLayout;           // 视频 View 的管理类，包括：预览自身的 View、观看其他主播的 View。
    private TextView                            mTvRoomId;                  // 标题栏
    private EditText                            mEtRoomId, mEtUserId;       // 跨房连麦的 room id、 user id
    private TRTCSettingDialog                   mSettingDialog;             // 设置面板
    private TRTCMoreDialog                      mMoreDialog;                // 更多设置面板
    private ImageView                           mIvSwitchRole;              // 切换角色按钮
    private LinearLayout                        mLlAnchorPanel;             // 主播功能面板
    private RelativeLayout                      mRlQRCode;                 // 二维码布局
    private ImageView                           mIvQRCode;                  // 二维码分享

    /**
     * 美颜相关
     */
    private TRTCBeautySettingPanel              mTRTCBeautyPanel;           // 美颜设置控件
    private int                                 mBeautyLevel = 5;           // 美颜等级
    private int                                 mWhiteningLevel = 3;        // 美白等级
    private int                                 mRuddyLevel = 2;            // 红润等级
    private int                                 mBeautyStyle = TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH;// 美颜风格

    /**
     * 跨房连麦相关参数
     */
    private boolean                             mIsConnectingOtherRoom;     // 当前是否正在进行跨房连麦
    private String                              mConnectingUserId;          // 当前跨房连麦的 userId
    private String                              mConnectingRoomId;          // 当前跨房连麦的 roomId

    /**
     * 自定义采集和渲染相关
     */
    private boolean                             mIsCustomCaptureAndRender;  // 是否使用外部采集和渲染
    private String                              mVideoFilePath;             // 视频文件路径
    private TestSendCustomVideoData             mCustomCapture;             // 外部采集
    private TestRenderVideoFrame                mCustomRender;              // 外部渲染
    private HashMap<String, TestRenderVideoFrame> mCustomRemoteRenderMap;         // 自定义渲染远端的主播 Map


    private ImageView                           mIvEnableVideo, mIvEnableAudio;
    private boolean                             mIsEnableVideo, mIsEnableAudio; // 是否开启视频\音频上行
    private int                                 mLogLevel = 0;                  // 日志等级

    /**
     * 混流配置相关
     */
    private ArrayList<TRTCVideoStream>          mTRTCVideoStreams;          // 记录当前视频上行（大画面、辅路）的信息，用于配置混流参数

    private static class TRTCVideoStream {
        public String userId;
        public int streamType;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 获取进房参数
        Intent intent = getIntent();
        // [*****]注意
        // Demo 通过 mAppScene 来区分低延时大房间以及视频通话
        // 视频通话：里面所有的角色都是{@link TRTCCloudDef#TRTCRoleAnchor}主播，服务端会分配主干网上核心机房的服务器供主播连接，能够极大提高视频通话的质量。
        // 低延时大房间：里面可以有多个主播角色，但是绝大部分都是观众，适合直播场景；服务端会分配高速网上机房的服务器供观众连接；
        // 相比其他方案如 CDN 方案等，低延时大房间在直播时延、画面质量等，都有极大的提升，特别是在弱网下，是其他方案无法媲美的。
        mAppScene = intent.getIntExtra(KEY_APP_SCENE, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
        int sdkAppId = intent.getIntExtra(KEY_SDK_APP_ID, 0);
        int roomId = intent.getIntExtra(KEY_ROOM_ID, 0);
        String userId = intent.getStringExtra(KEY_USER_ID);
        String userSig = intent.getStringExtra(KEY_USER_SIG);
        int role = intent.getIntExtra(KEY_ROLE, TRTCCloudDef.TRTCRoleAnchor);
        mIsCustomCaptureAndRender = intent.getBooleanExtra(KEY_CUSTOM_CAPTURE, false);

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

        mTRTCParams = new TRTCCloudDef.TRTCParams(sdkAppId, userId, userSig, roomId, "", "");
        mTRTCParams.role = role;


        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // 设置布局
        setContentView(R.layout.activity_trtc_main);
        mTRTCVideoStreams = new ArrayList<>();
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
        mCustomCapture = new TestSendCustomVideoData(this);
        mCustomRender = new TestRenderVideoFrame(this);
        mVideoFilePath = getIntent().getStringExtra(KEY_VIDEO_FILE_PATH);
        mCustomRemoteRenderMap = new HashMap<>();
    }


    private void initViews() {
        // 界面底部功能键初始化
        findViewById(R.id.trtc_iv_mode).setOnClickListener(this);
        findViewById(R.id.trtc_iv_beauty).setOnClickListener(this);
        mIvEnableVideo = (ImageView) findViewById(R.id.trtc_iv_camera);
        mIvEnableVideo.setOnClickListener(this);
        mIvEnableAudio = (ImageView) findViewById(R.id.trtc_iv_mic);
        mIvEnableAudio.setOnClickListener(this);
        findViewById(R.id.trtc_iv_log).setOnClickListener(this);
        findViewById(R.id.trtc_iv_setting).setOnClickListener(this);
        findViewById(R.id.trtc_iv_more).setOnClickListener(this);
        findViewById(R.id.trtc_ib_back).setOnClickListener(this);
        findViewById(R.id.trtc_btn_sure).setOnClickListener(this);
        findViewById(R.id.trtc_btn_cancel).setOnClickListener(this);
        mRlQRCode = (RelativeLayout) findViewById(R.id.trtc_rl_main_qrcode);
        mIvQRCode = (ImageView) findViewById(R.id.trtc_iv_main_qrcode);
        mRlQRCode.setOnClickListener(this);
        // 标题栏
        mTvRoomId = (TextView) findViewById(R.id.trtc_tv_room_id);
        mTvRoomId.setText(String.valueOf(mTRTCParams.roomId));

        // 跨房连麦需要的参数
        mEtRoomId = (EditText) findViewById(R.id.trtc_et_room_id);
        mEtUserId = (EditText) findViewById(R.id.trtc_et_user_id);

        // 美颜参数回调设置
        mTRTCBeautyPanel = (TRTCBeautySettingPanel) findViewById(R.id.trtc_beauty_panel);
        mTRTCBeautyPanel.setBeautyParamsChangeListener(this);

        // 设置面板
        mSettingDialog = new TRTCSettingDialog(this, this, mAppScene);

        // 更多设置面板
        mMoreDialog = new TRTCMoreDialog(this, this);

        // 界面视频 View 的管理类
        mTRTCVideoLayout = (TRTCVideoLayoutManager) findViewById(R.id.trtc_video_view_layout);
        mTRTCVideoLayout.setMySelfUserId(mTRTCParams.userId);
        mTRTCVideoLayout.setIVideoLayoutListener(this);

        // 观众或者主播的控制面板
        mIvSwitchRole = (ImageView) findViewById(R.id.trtc_iv_switch_role);
        mIvSwitchRole.setOnClickListener(this);

        mLlAnchorPanel = (LinearLayout) findViewById(R.id.trtc_ll_anchor_controller_panel);

        if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
            mIvSwitchRole.setVisibility(View.GONE);
            mLlAnchorPanel.setVisibility(View.VISIBLE);
        } else {
            mIvSwitchRole.setVisibility(View.VISIBLE);
            mLlAnchorPanel.setVisibility(View.GONE);
        }
    }

    /**
     * ==================================TRTC SDK相关==================================
     */
    /**
     * 初始化 SDK
     */
    private void initTRTCSDK() {
        mTRTCListener = new TRTCCloudListenerImpl(this);
        mTRTCCloud = TRTCCloud.sharedInstance(this);
        mTRTCCloud.setListener(mTRTCListener);
        // 初始化的时候，确定是否开启自定义采集
        mTRTCCloud.enableCustomVideoCapture(mIsCustomCaptureAndRender);
    }


    /**
     * SDK 回调实现类
     */
    private static class TRTCCloudListenerImpl extends TRTCCloudListener {
        private WeakReference<TRTCMainActivity> mWefActivity;

        public TRTCCloudListenerImpl(TRTCMainActivity activity) {
            super();
            mWefActivity = new WeakReference<>(activity);
        }

        /**
         * 加入房间回调
         *
         * @param elapsed 加入房间耗时，单位毫秒
         */
        @Override
        public void onEnterRoom(long elapsed) {
            Log.i(TAG, "onEnterRoom: elapsed = " + elapsed);
            final TRTCMainActivity activity = mWefActivity.get();
            if (activity != null) {
                if (elapsed >= 0) {
                    Toast.makeText(activity, "加入房间成功，耗时 " + elapsed + " 毫秒", Toast.LENGTH_SHORT).show();
                    // 发起云端混流
                    activity.updateCloudMixtureParams();
                } else {
                    Toast.makeText(activity, "加入房间失败", Toast.LENGTH_SHORT).show();
                    activity.exitRoom();
                }
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
            Log.i(TAG, "onError: errCode = " + errCode + " errMsg = " + errMsg);
            TRTCMainActivity activity = mWefActivity.get();
            Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
            // 执行退房
            activity.exitRoom();
            // 关闭 Activity
            activity.finish();
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
            //
            Log.i(TAG, "onUserEnter: userId = " + userId);
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
            Log.i(TAG, "onUserExit: userId = " + userId + " reason = " + reason);
            TRTCMainActivity activity = mWefActivity.get();
            if (activity != null) {
                if (activity.mCustomRemoteRenderMap != null) {
                    // 停止自定义渲染
                    TestRenderVideoFrame render = activity.mCustomRemoteRenderMap.remove(userId);
                    if (render != null)
                        render.stop();
                }

                //停止观看画面
                activity.mTRTCCloud.stopRemoteView(userId);
                activity.mTRTCCloud.stopRemoteSubStreamView(userId);

                // 回收分配的渲染的View
                activity.mTRTCVideoLayout.recyclerCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                activity.mTRTCVideoLayout.recyclerCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);

                // 连麦主播退出房间，需要将相关参数置为空；否则会导致混流异常
                if (userId.equals(activity.mConnectingUserId)) {
                    activity.mConnectingUserId = "";
                    activity.mConnectingRoomId = "";
                    activity.mIsConnectingOtherRoom = false;
                }

                // 更新混流参数
                activity.updateCloudMixtureParams();
            }
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
        public void onUserVideoAvailable(final String userId, boolean available) {
            Log.i(TAG, "onUserVideoAvailable: userId = " + userId + " available = " + available);
            TRTCVideoStream stream = new TRTCVideoStream();
            stream.userId = userId;
            stream.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;

            TRTCMainActivity activity = mWefActivity.get();
            if (activity != null) {
                // 是否为外部渲染，如果不是：
                if (!activity.mIsCustomCaptureAndRender) {
                    activity.startSDKRender(userId, available, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                } else {
                    activity.startCustomRender(userId, available);
                }
                if (available) {
                    // 记录当前流的类型，以供设置混流参数时使用：
                    if (!activity.isContainVideoStream(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG)) {
                        activity.mTRTCVideoStreams.add(stream);
                        TXLog.i(TAG,"addVideoStream "+stream.userId+", stream "+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG+", size "+activity.mTRTCVideoStreams.size());
                    } else {
                        Log.i(TAG, "onUserVideoAvailable: already contains video");
                    }
                } else {
                    // 移除当前记录，以供设置混流参数时使用：
                    activity.removeVideoStream(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                }
                // 根据当前视频流的状态，更新混流参数
                activity.updateCloudMixtureParams();
                // 根据当前视频流的状态，展示相关的 UI 逻辑。
                activity.mTRTCVideoLayout.updateVideoStatus(userId, available);
            }
        }

        /**
         * 是否有辅路上行的回调，Demo 中处理方式和主画面的一致 {@link TRTCCloudListenerImpl#onUserVideoAvailable(String, boolean)}
         *
         * @param userId    用户标识
         * @param available 屏幕分享是否开启
         */
        @Override
        public void onUserSubStreamAvailable(final String userId, boolean available) {
            Log.i(TAG, "onUserSubStreamAvailable: userId = " + userId + " available = " + available);
            TRTCVideoStream stream = new TRTCVideoStream();
            stream.userId = userId;
            stream.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB;
            TRTCMainActivity activity = mWefActivity.get();
            if (activity != null) {
                // 开始\停止 SDK 渲染
                activity.startSDKRender(userId, available, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
                if (available) {

                    // 记录当前流的类型，以供设置混流参数时使用：
                    if (!activity.isContainVideoStream(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB)) {
                        activity.mTRTCVideoStreams.add(stream);
                        TXLog.i(TAG,"addVideoStream "+stream.userId+", stream "+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB+", size "+activity.mTRTCVideoStreams.size());
                    }
                } else {
                    // 移除当前记录，以供设置混流参数时使用：
                    activity.removeVideoStream(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
                }
                activity.updateCloudMixtureParams();
            }
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
            Log.i(TAG, "onUserAudioAvailable: userId = " + userId + " available = " + available);

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
            Log.i(TAG, "onFirstVideoFrame: userId = " + userId + " streamType = " + streamType + " width = " + width + " height = "+ height);
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
                mWefActivity.get().mTRTCVideoLayout.updateAudioVolume(userVolumes.get(i).userId, userVolumes.get(i).volume);
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
            TRTCMainActivity activity = mWefActivity.get();
            if (activity != null) {
                activity.stopLinkMicLoading();
                if (err == 0) {
                    activity.mIsConnectingOtherRoom = true;
                    activity.mMoreDialog.updateLinkMicState(true);
                    Toast.makeText(activity.getApplicationContext(), "跨房连麦成功", Toast.LENGTH_LONG).show();
                } else {
                    activity.mIsConnectingOtherRoom = false;
                    activity.mMoreDialog.updateLinkMicState(false);
                    Toast.makeText(activity.getApplicationContext(), "跨房连麦失败", Toast.LENGTH_LONG).show();
                }
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
            TRTCMainActivity activity = mWefActivity.get();
            if (activity != null) {
                activity.mIsConnectingOtherRoom = false;
                activity.mMoreDialog.updateLinkMicState(false);
            }
            activity.mConnectingRoomId = "";
            activity.mConnectingUserId = "";
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
            TRTCMainActivity activity = mWefActivity.get();
            if (activity != null) {
                activity.mTRTCVideoLayout.updateNetworkQuality(localQuality.userId, localQuality.quality);
                for (TRTCCloudDef.TRTCQuality qualityInfo : remoteQuality) {
                    activity.mTRTCVideoLayout.updateNetworkQuality(qualityInfo.userId, qualityInfo.quality);
                }
            }
        }
    }

    /**
     * 进房
     */
    private void enterRoom() {
        // 是否为自采集，请在调用 SDK 相关配置前优先设置好，避免时序导致的异常问题。
        mTRTCCloud.enableCustomVideoCapture(mIsCustomCaptureAndRender);

        // 是否开启音量回调 需要在 startLocalAudio 之前调用
        enableAudioVolumeEvaluation(mMoreDialog.isAudioVolumeEvaluation());

        // 如果当前角色是主播
        if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
            // 开启本地预览
            startLocalPreview(true);
            mIsEnableVideo = true;
            // 是否允许采集声音
            if (mMoreDialog.isEnableAudioCapture()) {
                mIsEnableAudio = true;
                mTRTCCloud.startLocalAudio();
                mIsEnableAudio = true;
            } else {
                mIsEnableAudio = false;
            }
        } else {
            mIsEnableAudio = false;
            mIsEnableVideo = false;
        }
        mIvEnableVideo.setImageResource(mIsEnableVideo ? R.mipmap.remote_video_enable : R.mipmap.remote_video_disable);
        mIvEnableAudio.setImageResource(mIsEnableAudio ? R.mipmap.remote_audio_enable : R.mipmap.remote_audio_disable);

        // 设置美颜参数
        mTRTCCloud.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH, 5, 5, 5);

        // 设置视频渲染模式
        setVideoFillMode(mMoreDialog.isVideoFillMode());

        // 设置视频旋转角
        setVideoRotation(mMoreDialog.isVideoVertical());

        // 是否开启免提
        enableAudioHandFree(mMoreDialog.isAudioHandFreeMode());

        // 是否开启重力感应
        enableGSensor(mMoreDialog.isEnableGSensorMode());


        // 是否开启推流画面镜像
        enableVideoEncMirror(mMoreDialog.isRemoteVideoMirror());

        // 设置本地画面是否镜像预览
        setLocalViewMirror(mMoreDialog.getLocalVideoMirror());

        // 【关键】设置 TRTC 推流参数
        setTRTCCloudParam();

        // 【关键】 TRTC进房
        mTRTCCloud.enterRoom(mTRTCParams, mAppScene);
    }

    /**
     * 设置视频通话的视频参数：需要 TRTCSettingDialog 提供的分辨率、帧率和流畅模式等参数
     */
    private void setTRTCCloudParam() {
        // 大画面的编码器参数设置
        // 设置视频编码参数，包括分辨率、帧率、码率等等，这些编码参数来自于 TRTCSettingDialog 的设置
        // 注意（1）：不要在码率很低的情况下设置很高的分辨率，会出现较大的马赛克
        // 注意（2）：不要设置超过25FPS以上的帧率，因为电影才使用24FPS，我们一般推荐15FPS，这样能将更多的码率分配给画质
        TRTCCloudDef.TRTCVideoEncParam encParam = new TRTCCloudDef.TRTCVideoEncParam();
        encParam.videoResolution = mSettingDialog.getResolution();
        encParam.videoFps = mSettingDialog.getVideoFps();
        encParam.videoBitrate = mSettingDialog.getVideoBitrate();
        encParam.videoResolutionMode = mSettingDialog.isVideoVertical() ? TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT : TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_LANDSCAPE;
        mTRTCCloud.setVideoEncoderParam(encParam);

        TRTCCloudDef.TRTCNetworkQosParam qosParam = new TRTCCloudDef.TRTCNetworkQosParam();
        qosParam.controlMode = mSettingDialog.getQosMode();
        qosParam.preference = mSettingDialog.getQosPreference();
        mTRTCCloud.setNetworkQosParam(qosParam);

        //小画面的编码器参数设置
        //TRTC SDK 支持大小两路画面的同时编码和传输，这样网速不理想的用户可以选择观看小画面
        //注意：iPhone & Android 不要开启大小双路画面，非常浪费流量，大小路画面适合 Windows 和 MAC 这样的有线网络环境
        TRTCCloudDef.TRTCVideoEncParam smallParam = new TRTCCloudDef.TRTCVideoEncParam();
        smallParam.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_160_90;
        smallParam.videoFps = mSettingDialog.getVideoFps();
        smallParam.videoBitrate = 100;
        smallParam.videoResolutionMode = mSettingDialog.isVideoVertical() ? TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT : TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_LANDSCAPE;

        mTRTCCloud.enableEncSmallVideoStream(mSettingDialog.enableSmall, smallParam);
        mTRTCCloud.setPriorRemoteVideoStreamType(mSettingDialog.priorSmall ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }

    /**
     * 退房
     */
    private void exitRoom() {
        startLocalPreview(false);
        if (mTRTCCloud != null) {
            mTRTCCloud.exitRoom();
        }
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.trtc_ib_back:
                finish();
                break;
            case R.id.trtc_iv_switch_role:
                switchRole();
                break;
            case R.id.trtc_iv_mode:
                int mode = mTRTCVideoLayout.switchMode();
                ((ImageView) v).setImageResource(mode == TRTCVideoLayoutManager.MODE_FLOAT ? R.mipmap.ic_float : R.mipmap.ic_gird);
                break;
            case R.id.trtc_iv_beauty:
                mTRTCBeautyPanel.setVisibility(mTRTCBeautyPanel.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                break;
            case R.id.trtc_iv_camera:
                mIsEnableVideo = !mIsEnableVideo;
                mTRTCCloud.muteLocalVideo(!mIsEnableVideo);
                // 布局管理切换到对应的无视频页面
                mTRTCVideoLayout.updateVideoStatus(mTRTCParams.userId, mIsEnableVideo);
                ((ImageView) v).setImageResource(mIsEnableVideo ? R.mipmap.remote_video_enable : R.mipmap.remote_video_disable);
                break;
            case R.id.trtc_iv_mic:
                mIsEnableAudio = !mIsEnableAudio;
                mTRTCCloud.muteLocalAudio(!mIsEnableAudio);
                ((ImageView) v).setImageResource(mIsEnableAudio ? R.mipmap.mic_enable : R.mipmap.mic_disable);
                break;
            case R.id.trtc_iv_log:
                mLogLevel = (mLogLevel + 1) % 3;
                ((ImageView) v).setImageResource((0 == mLogLevel) ? R.mipmap.log2 : R.mipmap.log);
                mTRTCCloud.showDebugView(mLogLevel);
                break;
            case R.id.trtc_iv_setting:
                mSettingDialog.show();
                break;
            case R.id.trtc_iv_more:
                mMoreDialog.show(mIsConnectingOtherRoom);
                break;
            case R.id.trtc_btn_sure:
                startLinkMic();
                break;
            case R.id.trtc_btn_cancel:
                hideLinkMicLayout();
                break;
            case R.id.trtc_rl_main_qrcode:
                mRlQRCode.setVisibility(View.GONE);
                break;
        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
        mTRTCCloud.setListener(null);
        TRTCCloud.destroySharedInstance();

        // 移除自定义渲染
        if (mCustomRemoteRenderMap != null) {
            for (TestRenderVideoFrame render : mCustomRemoteRenderMap.values()) {
                if (render != null) render.stop();
            }
            mCustomRemoteRenderMap.clear();
        }
    }


    /**
     * ==================================设置页面完成回调==================================
     */
    @Override
    public void onSettingComplete() {
        setTRTCCloudParam();
        setVideoFillMode(mSettingDialog.isVideoVertical());
        mMoreDialog.updateVideoFillMode(mSettingDialog.isVideoVertical());
    }


    /**
     * ==================================更多设置页面回调==================================
     */
    @Override
    public void onSwitchCamera(boolean bCameraFront) {
        mTRTCCloud.switchCamera();
    }

    @Override
    public void onFillModeChange(boolean bFillMode) {
        setVideoFillMode(bFillMode);
    }

    @Override
    public void onVideoRotationChange(boolean bVertical) {
        setVideoRotation(bVertical);
    }

    @Override
    public void onEnableAudioCapture(boolean bEnable) {
        if (bEnable) {
            mTRTCCloud.startLocalAudio();
        } else {
            mTRTCCloud.stopLocalAudio();
        }
    }

    @Override
    public void onEnableAudioHandFree(boolean bEnable) {
        enableAudioHandFree(bEnable);
    }

    @Override
    public void onMirrorLocalVideo(int localViewMirror) {
        setLocalViewMirror(localViewMirror);
    }

    @Override
    public void onMirrorRemoteVideo(boolean bMirror) {
        enableVideoEncMirror(bMirror);
    }

    @Override
    public void onEnableGSensor(boolean bEnable) {
        enableGSensor(bEnable);
    }

    @Override
    public void onEnableAudioVolumeEvaluation(boolean bEnable) {
        enableAudioVolumeEvaluation(bEnable);
    }


    @Override
    public void onEnableCloudMixture(boolean bEnable) {
        updateCloudMixtureParams();
    }

    @Override
    public void onClickButtonGetPlayUrl() {
        if (mTRTCParams == null) {
            return;
        }
        // 注意：该功能需要在控制台开启【旁路直播】功能，
        // 此功能是获取 CDN 直播地址，通过此功能，方便您能够在常见播放器中，播放音视频流。
        // 【*****】更多信息，您可以参考：https://cloud.tencent.com/document/product/647/16826

        // 拼接流id
        String streamId = "3891_" + Utils.md5("" + mTRTCParams.roomId + "_" + mTRTCParams.userId + "_main");
        // 拼接旁路流地址
        final String playUrl = "http://3891.liveplay.myqcloud.com/live/" + streamId + ".flv";

        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.putExtra(Intent.EXTRA_TEXT, playUrl);
        intent.setType("text/plain");
        startActivity(Intent.createChooser(intent, "分享"));

        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                final Bitmap bitmap = Utils.createQRCodeBitmap(playUrl, 400, 400);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mIvQRCode == null) return;
                        mRlQRCode.setVisibility(View.VISIBLE);
                        mIvQRCode.setImageBitmap(bitmap);
                    }
                });
            }
        });
    }

    /**
     * 开启\关闭跨房连麦
     */
    @Override
    public void onClickButtonLinkMicWithOtherRoom() {
        if (!mIsConnectingOtherRoom) {
            showLinkMicLayout();
        } else {
            mTRTCCloud.DisconnectOtherRoom();
            hideLinkMicLayout();
        }
    }

    /**
     * 切换角色
     */
    private void switchRole() {
        // 目标的切换角色
        int targetRole = mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor ? TRTCCloudDef.TRTCRoleAudience : TRTCCloudDef.TRTCRoleAnchor;
        if (mTRTCCloud != null) {
            mTRTCCloud.switchRole(targetRole);
        }
        mTRTCParams.role = targetRole;
        // 如果当前角色是主播
        if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
            // 开启本地预览
            startLocalPreview(true);
            mIsEnableVideo = true;
            // 是否允许采集声音
            if (mMoreDialog.isEnableAudioCapture()) {
                mIsEnableAudio = true;
                mTRTCCloud.startLocalAudio();
                mIsEnableAudio = true;
            } else {
                mIsEnableAudio = false;
            }
            mIvSwitchRole.setImageResource(R.mipmap.linkmic);
            mLlAnchorPanel.setVisibility(View.VISIBLE);
        } else {
            mIsEnableAudio = false;
            mIsEnableVideo = false;
            // 关闭本地预览
            startLocalPreview(false);
            // 关闭音频采集
            mTRTCCloud.stopLocalAudio();
            mIvSwitchRole.setImageResource(R.mipmap.linkmic2);
            mLlAnchorPanel.setVisibility(View.GONE);
        }
        mIvEnableVideo.setImageResource(mIsEnableVideo ? R.mipmap.remote_video_enable : R.mipmap.remote_video_disable);
        mIvEnableAudio.setImageResource(mIsEnableAudio ? R.mipmap.remote_audio_enable : R.mipmap.remote_audio_disable);
    }


    private boolean isContainVideoStream(String userId, int streamType) {
        for (TRTCVideoStream stream : mTRTCVideoStreams) {
            if (stream != null && stream.userId != null && stream.userId.equals(userId) && stream.streamType == streamType) {
                return true;
            }
        }
        return false;
    }

    private void removeVideoStream(String userId, int streamType) {
        int indexRemove = -1;
        for (int i = 0; i < mTRTCVideoStreams.size(); i++) {
            TRTCVideoStream stream = mTRTCVideoStreams.get(i);
            if (stream != null && stream.userId != null && stream.userId.equals(userId) && stream.streamType == streamType) {
                indexRemove = i;
                break;
            }
        }
        if (indexRemove != -1) {
            mTRTCVideoStreams.remove(indexRemove);
            TXLog.i(TAG,"removeVideoStream "+userId+", stream "+streamType+", size "+mTRTCVideoStreams.size());
        }
    }
    /**
     * 更新混流参数
     */
    private void updateCloudMixtureParams() {
        // 背景大画面宽高
        int videoWidth = 720;
        int videoHeight = 1280;

        // 小画面宽高
        int subWidth = 180;
        int subHeight = 320;

        int offsetX = 5;
        int offsetY = 50;

        int bitrate = 200;

        int resolution = mSettingDialog.getResolution();
        switch (resolution) {
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_160_160: {
                videoWidth = 160;
                videoHeight = 160;
                subWidth = 27;
                subHeight = 48;
                offsetY = 20;
                bitrate = 200;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_180: {
                videoWidth = 192;
                videoHeight = 336;
                subWidth = 54;
                subHeight = 96;
                offsetY = 30;
                bitrate = 400;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_240: {
                videoWidth = 240;
                videoHeight = 320;
                subWidth = 54;
                subHeight = 96;
                bitrate = 400;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_480: {
                videoWidth = 480;
                videoHeight = 480;
                subWidth = 72;
                subHeight = 128;
                bitrate = 600;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360: {
                videoWidth = 368;
                videoHeight = 640;
                subWidth = 90;
                subHeight = 160;
                bitrate = 800;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480: {
                videoWidth = 480;
                videoHeight = 640;
                subWidth = 90;
                subHeight = 160;
                bitrate = 800;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540: {
                videoWidth = 544;
                videoHeight = 960;
                subWidth = 171;
                subHeight = 304;
                bitrate = 1000;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720: {
                videoWidth = 720;
                videoHeight = 1280;
                subWidth = 180;
                subHeight = 320;
                bitrate = 1500;
                break;
            }
        }

        TRTCCloudDef.TRTCTranscodingConfig config = new TRTCCloudDef.TRTCTranscodingConfig();
        ///【字段含义】腾讯云直播 AppID
        ///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】后，在“直播信息”中获取
        config.appId = 0;
        ///【字段含义】腾讯云直播 bizid
        ///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】后，在“直播信息”中获取
        config.bizId = 0;
        config.videoWidth = videoWidth;
        config.videoHeight = videoHeight;
        config.videoGOP = 1;
        config.videoFramerate = 15;
        config.videoBitrate = bitrate;
        config.audioSampleRate = 48000;
        config.audioBitrate = 64;
        config.audioChannels = 1;

        // 设置混流后主播的画面位置
        TRTCCloudDef.TRTCMixUser mixUser = new TRTCCloudDef.TRTCMixUser();
        mixUser.userId = mTRTCParams.userId; // 以主播uid为broadcaster为例
        mixUser.zOrder = 0;
        mixUser.x = 0;
        mixUser.y = 0;
        mixUser.width = videoWidth;
        mixUser.height = videoHeight;

        config.mixUsers = new ArrayList<>();
        config.mixUsers.add(mixUser);

        // 设置混流后各个小画面的位置
        if (mMoreDialog.isEnableCloudMixture()) {
            int index = 0;
            TXLog.i(TAG,"updateCloudMixtureParams "+mTRTCVideoStreams.size());
            for (TRTCVideoStream userStream : mTRTCVideoStreams) {
                TRTCCloudDef.TRTCMixUser _mixUser = new TRTCCloudDef.TRTCMixUser();

                if (mIsConnectingOtherRoom && userStream.userId.equalsIgnoreCase(mConnectingUserId)) {
                    _mixUser.roomId = mConnectingRoomId;
                }

                _mixUser.userId = userStream.userId;
                _mixUser.streamType = userStream.streamType;
                _mixUser.zOrder = 1 + index;
                if (index < 3) {
                    // 前三个小画面靠右从下往上铺
                    _mixUser.x = videoWidth - offsetX - subWidth;
                    _mixUser.y = videoHeight - offsetY - index * subHeight - subHeight;
                    _mixUser.width = subWidth;
                    _mixUser.height = subHeight;
                } else if (index < 6) {
                    // 后三个小画面靠左从下往上铺
                    _mixUser.x = offsetX;
                    _mixUser.y = videoHeight - offsetY - (index - 3) * subHeight - subHeight;
                    _mixUser.width = subWidth;
                    _mixUser.height = subHeight;
                } else {
                    // 最多只叠加六个小画面
                }
                TXLog.i(TAG,"updateCloudMixtureParams userId "+_mixUser.userId);
                config.mixUsers.add(_mixUser);
                ++index;
            }
        }
        mTRTCCloud.setMixTranscodingConfig(config);
    }

    /**
     * 设置本地渲染模式：全屏铺满\自适应
     *
     * @param bFillMode
     */
    private void setVideoFillMode(boolean bFillMode) {
        if (bFillMode) {
            // 全屏铺满模式
            mTRTCCloud.setLocalViewFillMode(TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL);
        } else {
            // 自适应模式
            mTRTCCloud.setLocalViewFillMode(TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
        }
    }

    /**
     * 设置竖屏\横屏推流
     *
     * @param bVertical
     */
    private void setVideoRotation(boolean bVertical) {
        if (bVertical) {
            // 竖屏直播
            mTRTCCloud.setLocalViewRotation(TRTCCloudDef.TRTC_VIDEO_ROTATION_0);
        } else {
            // 横屏直播
            mTRTCCloud.setLocalViewRotation(TRTCCloudDef.TRTC_VIDEO_ROTATION_90);
        }
    }

    /**
     * 是否开启免提
     *
     * @param bEnable
     */
    private void enableAudioHandFree(boolean bEnable) {
        if (bEnable) {
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        } else {
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
        }
    }

    /**
     * 是否开启画面镜像推流
     * <p>
     * 开启后，画面将会进行左右镜像，推到远端
     *
     * @param bMirror
     */
    private void enableVideoEncMirror(boolean bMirror) {
        mTRTCCloud.setVideoEncoderMirror(bMirror);
    }


    /**
     * 是否开启本地画面镜像
     */
    private void setLocalViewMirror(int mode) {
        mTRTCCloud.setLocalViewMirror(mode);
    }

    /**
     * 是否开启重力该应
     *
     * @param bEnable
     */
    private void enableGSensor(boolean bEnable) {
        if (bEnable) {
            mTRTCCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_UIFIXLAYOUT);
        } else {
            mTRTCCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_DISABLE);
        }
    }

    /**
     * 是否开启音量回调
     *
     * @param bEnable
     */
    private void enableAudioVolumeEvaluation(boolean bEnable) {
        if (bEnable) {
            mTRTCCloud.enableAudioVolumeEvaluation(300);
            mTRTCVideoLayout.showAllAudioVolumeProgressBar();
        } else {
            mTRTCCloud.enableAudioVolumeEvaluation(0);
            mTRTCVideoLayout.hideAllAudioVolumeProgressBar();
        }
    }


    /**
     * 开启\关闭本地预览
     *
     * @param enable
     */
    private void startLocalPreview(boolean enable) {
        if (!mIsCustomCaptureAndRender) {
            startSDKLocalPreview(enable);
        } else {
            startCustomLocalPreview(enable);
        }
    }

    /**
     * 外部自采集和渲染
     *
     * @param enable
     */
    private void startCustomLocalPreview(boolean enable) {
        if (enable) {
            TXCloudVideoView localVideoView = mTRTCVideoLayout.allocCloudVideoView(mTRTCParams.userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            if (mCustomCapture != null) {
                mCustomCapture.start(mVideoFilePath);
            }

            // 设置 TRTC SDK 的状态为本地自定义渲染，视频格式为纹理
            mTRTCCloud.setLocalVideoRenderListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, mCustomRender);

            //启动本地自定义渲染
            if (mCustomRender != null) {
                TextureView textureView = new TextureView(this);
                localVideoView.addVideoView(textureView);
                mCustomRender.start(textureView);
            }
        } else {
            if (mCustomCapture != null) mCustomCapture.stop();
            if (mCustomRender != null) mCustomRender.stop();
            mTRTCVideoLayout.recyclerCloudViewView(mTRTCParams.userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        }
    }

    /**
     * SDK 采集和渲染
     *
     * @param enable
     */
    private void startSDKLocalPreview(final boolean enable) {
        if (enable) {
            TXCloudVideoView localVideoView = mTRTCVideoLayout.allocCloudVideoView(mTRTCParams.userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            // 获取一个当前空闲的 View
            if (localVideoView != null) {
                mTRTCCloud.startLocalPreview(mMoreDialog.isCameraFront(), localVideoView);
            } else {
                Toast.makeText(TRTCMainActivity.this, "无法找到一个空闲的 View 进行预览，本地预览失败。", Toast.LENGTH_SHORT).show();
            }
        } else {
            mTRTCCloud.stopLocalPreview();
            mTRTCVideoLayout.recyclerCloudViewView(mTRTCParams.userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        }
    }

    /**
     * 开始\停止 SDK 渲染
     *
     * @param userId
     * @param enable
     */
    private void startSDKRender(String userId, boolean enable, int streamType) {
        if (enable) {
            TXCloudVideoView renderView = mTRTCVideoLayout.findCloudViewView(userId, streamType);
            if (renderView == null)
                renderView = mTRTCVideoLayout.allocCloudVideoView(userId, streamType);
            // 启动远程画面的解码和显示逻辑，FillMode 可以设置是否显示黑边
            if (renderView != null) {
                // 设置日志调试窗口的边距
                mTRTCCloud.setDebugViewMargin(userId, new TRTCCloud.TRTCViewMargin(0.0f, 0.0f, 0.1f, 0.0f));
                //  TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT模式下，当 View 的宽高比与视频宽高此不一致时，有黑边。
                //  若您想铺满可以使用 TRTC_VIDEO_RENDER_MODE_FILL
                // 启动渲染
                if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG) {
                    mTRTCCloud.setRemoteViewFillMode(userId, TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
                    mTRTCCloud.startRemoteView(userId, renderView);
                } else if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB) {
                    mTRTCCloud.setRemoteSubStreamViewFillMode(userId, TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
                    mTRTCCloud.startRemoteSubStreamView(userId, renderView);
                }
            }
        } else {
            // 停止渲染
            if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG) {
                mTRTCCloud.stopRemoteView(userId);
            } else if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB) {
                mTRTCCloud.stopRemoteSubStreamView(userId);
                // 辅路直接移除画面，不会更新状态。主流需要更新状态，所以保留
                mTRTCVideoLayout.recyclerCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
            }
        }
    }

    /**
     * 开始\停止 自定义渲染
     * @param userId
     * @param enable
     */
    private void startCustomRender(String userId, boolean enable) {
        if (enable) {
            TXCloudVideoView renderView = mTRTCVideoLayout.findCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            if (renderView == null)
                renderView = mTRTCVideoLayout.allocCloudVideoView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);

            // 创建自定义渲染类
            TestRenderVideoFrame customRender = new TestRenderVideoFrame(this);
            // 创建渲染的View
            TextureView textureView = new TextureView(this);
            // 添加到父布局
            renderView.addVideoView(textureView);
            // 同调 SDK api：绑定 userId 与自定义渲染器 customRender
            mTRTCCloud.setRemoteVideoRenderListener(userId, TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_I420, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY, customRender);
            // 自定义渲染器与渲染的 View 绑定
            customRender.start(textureView);
            // 存储记录
            mCustomRemoteRenderMap.put(userId, customRender);
            // 调用 SDK api 开始渲染（view 传 null）
            mTRTCCloud.startRemoteView(userId, null);
        } else {
            // 停止自定义渲染
            TestRenderVideoFrame render = mCustomRemoteRenderMap.remove(userId);
            if (render != null)
                render.stop();
            // 移除自定义渲染的 View
            TXCloudVideoView renderView = mTRTCVideoLayout.findCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            if (renderView != null) {
                renderView.removeVideoView();
            }
            mTRTCCloud.stopRemoteSubStreamView(userId);
        }
    }

    /**
     * ==================================美颜相关回调==================================
     */
    /**
     * 美颜设置回调
     *
     * @param params
     * @param key
     */
    @Override
    public void onBeautyParamsChange(TRTCBeautySettingPanel.BeautyParams params, int key) {
        switch (key) {
            case TRTCBeautySettingPanel.BEAUTYPARAM_BEAUTY:
                mBeautyStyle = params.mBeautyStyle;
                mBeautyLevel = params.mBeautyLevel;
                // 设置美颜风格、美颜等级
                if (mTRTCCloud != null) {
                    mTRTCCloud.setBeautyStyle(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_WHITE:
                mWhiteningLevel = params.mWhiteLevel;
                // 设置美白等级
                if (mTRTCCloud != null) {
                    mTRTCCloud.setBeautyStyle(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_BIG_EYE:
                // 设置大眼等级
                if (mTRTCCloud != null) {
                    mTRTCCloud.setEyeScaleLevel(params.mBigEyeLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_FACE_LIFT:
                // 设置瘦脸等级
                if (mTRTCCloud != null) {
                    mTRTCCloud.setFaceSlimLevel(params.mFaceSlimLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_FILTER:
                // 设置美颜滤镜
                if (mTRTCCloud != null) {
                    mTRTCCloud.setFilter(params.mFilterBmp);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_GREEN:
                // 设置绿幕
                if (mTRTCCloud != null) {
                    mTRTCCloud.setGreenScreenFile(params.mGreenFile);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_MOTION_TMPL:
                // 设置动效
                if (mTRTCCloud != null) {
                    mTRTCCloud.selectMotionTmpl(params.mMotionTmplPath);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_RUDDY:
                mRuddyLevel = params.mRuddyLevel;
                // 设置红润
                if (mTRTCCloud != null) {
                    mTRTCCloud.setBeautyStyle(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_FACEV:
                // 设置 V 脸级别
                if (mTRTCCloud != null) {
                    mTRTCCloud.setFaceVLevel(params.mFaceVLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_FACESHORT:
                // 设置短脸级别
                if (mTRTCCloud != null) {
                    mTRTCCloud.setFaceShortLevel(params.mFaceShortLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_CHINSLIME:
                // 设置下巴拉伸或缩短
                if (mTRTCCloud != null) {
                    mTRTCCloud.setChinLevel(params.mChinSlimLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_NOSESCALE:
                // 设置瘦鼻等级
                if (mTRTCCloud != null) {
                    mTRTCCloud.setNoseSlimLevel(params.mNoseScaleLevel);
                }
                break;
            case TRTCBeautySettingPanel.BEAUTYPARAM_FILTER_MIX_LEVEL:
                // 设置滤镜级别
                if (mTRTCCloud != null) {
                    mTRTCCloud.setFilterConcentration(params.mFilterMixLevel / 10.f);
                }
                break;
        }
    }


    /**
     * ==================================九宫格布局下点击事件==================================
     */
    @Override
    public void onClickItemFill(String userId, int streamType, boolean enableFill) {
        if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG || streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL)
            mTRTCCloud.setRemoteViewFillMode(userId, enableFill ? TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL : TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
        else
            mTRTCCloud.setRemoteSubStreamViewFillMode(userId, enableFill ? TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL : TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
    }

    @Override
    public void onClickItemMuteAudio(String userId, boolean isMute) {
        mTRTCCloud.muteRemoteAudio(userId, isMute);
    }

    @Override
    public void onClickItemMuteVideo(String userId,int streamType, boolean isMute) {
        if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG) {
            mTRTCCloud.muteRemoteVideoStream(userId, isMute);
        } else if (streamType == TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB) {
            if (isMute) {
                // mute 直接停止拉流
                mTRTCCloud.stopRemoteView(userId);
            } else {
                // 不mute重新拉流
                TXCloudVideoView view = mTRTCVideoLayout.findCloudViewView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
                if (view != null) {
                    mTRTCCloud.startRemoteView(userId, view);
                }
            }
        }
    }
    /**
     * ==================================跨房连麦相关==================================
     */
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

        ImageView imageView = (ImageView) findViewById(R.id.trtc_iv_link_loading);
        AnimationDrawable animation = (AnimationDrawable) imageView.getDrawable();
        if (animation != null) {
            animation.stop();
        }
    }

    /**
     * 开始跨房连麦
     */
    private void startLinkMic() {
        String roomId = mEtRoomId.getText().toString();
        String userId = mEtUserId.getText().toString();
        if (roomId == null || roomId.isEmpty()) {
            Toast.makeText(getApplicationContext(), "请输入目标房间名", Toast.LENGTH_SHORT).show();
            return;
        }
        if (userId == null || userId.isEmpty()) {
            Toast.makeText(getApplicationContext(), "请输入目标用户ID", Toast.LENGTH_SHORT).show();
            return;
        }

        mConnectingRoomId = roomId;
        mConnectingUserId = userId;

        // 根据userId，以及roomid 发起跨房连接
        mTRTCCloud.ConnectOtherRoom(String.format("{\"roomId\":%s,\"userId\":\"%s\"}", roomId, userId));
        hideLinkMicLayout();
        startLinkMicLoading();
    }


    /**
     * 显示跨房连麦布局
     */
    private void showLinkMicLayout() {
        FrameLayout layout = (FrameLayout) findViewById(R.id.trtc_fl_connect_other_room);
        layout.setVisibility(View.VISIBLE);
    }

    /**
     * 隐藏跨房连麦布局
     */
    private void hideLinkMicLayout() {
        FrameLayout layout = (FrameLayout) findViewById(R.id.trtc_fl_connect_other_room);
        layout.setVisibility(View.GONE);
    }
}
