package com.tencent.liteav.demo.trtc;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.TXLiteAVCode;
//import com.tencent.liteav.demo.CustomAudioFileReader;
import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.trtc.TestCustomVideo.TestRenderVideoFrame;
import com.tencent.liteav.demo.trtc.TestCustomVideo.TestSendCustomVideoData;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.TRTCStatistics;

import java.lang.ref.WeakReference;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashSet;


/**
 * Module:   TRTCMainActivity
 *
 * Function: 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
 *
 *    1. 支持九宫格平铺和前后叠加两种不同的视频画面布局方式，该部分由 TRTCVideoViewLayout 来计算每个视频画面的位置排布和大小尺寸
 *
 *    2. 支持对视频通话的分辨率、帧率和流畅模式进行调整，该部分由 TRTCSettingDialog 来实现
 *
 *    3. 创建或者加入某一个通话房间，需要先指定 roomId 和 userId，这部分由 TRTCNewActivity 来实现
 */
public class TRTCMainActivity extends Activity implements View.OnClickListener, TRTCSettingDialog.ISettingListener, TRTCMoreDialog.IMoreListener, TRTCVideoViewLayout.ITRTCVideoViewLayoutListener {
    private final static String TAG = TRTCMainActivity.class.getSimpleName();

    private boolean bBeautyEnable = true, bEnableVideo = true, bEnableAudio = true, beingLinkMic = false;
    private int iDebugLevel = 0;
    private String mUserIdBeingLink = "";

    private TextView tvRoomId;
    private EditText etRoomId, etUserId;
    private ImageView ivShowMode, ivBeauty, ivCamera, ivVoice, ivLog;
    private TRTCSettingDialog settingDlg;
    private TRTCMoreDialog moreDlg;
    private TRTCVideoViewLayout mVideoViewLayout;

    private TRTCCloudDef.TRTCParams trtcParams;     /// TRTC SDK 视频通话房间进入所必须的参数
    private TRTCCloud trtcCloud;              /// TRTC SDK 实例对象
    private TRTCCloudListenerImpl trtcListener;    /// TRTC SDK 回调监听

    private HashSet<String> mRoomMembers = new HashSet<>();

    private boolean mEnableCustomAudioCapture = false;

    private boolean mEnableCustomVideoCapture;
    private TestSendCustomVideoData mCustomCapture;
    private TestRenderVideoFrame mCustomRender;
    private String mVideoFile;
    private int mSdkAppId = -1;
    @Override
    protected void onCreate( Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //应用运行时，保持屏幕高亮，不锁屏
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN , WindowManager.LayoutParams.FLAG_FULLSCREEN);

        //获取前一个页面得到的进房参数
        Intent intent       = getIntent();
        mSdkAppId        = intent.getIntExtra("sdkAppId", 0);
        int roomId          = intent.getIntExtra("roomId", 0);
        String selfUserId   = intent.getStringExtra("userId");
        String userSig      = intent.getStringExtra("userSig");
        mEnableCustomVideoCapture = intent.getBooleanExtra("customVideoCapture", false);
        mEnableCustomAudioCapture = intent.getBooleanExtra("customAudioCapture", false);

        if (mEnableCustomVideoCapture) {
            mVideoFile = intent.getStringExtra("videoFile");
            mCustomCapture = new TestSendCustomVideoData(this);
            mCustomRender = new TestRenderVideoFrame(this);
        }
        trtcParams = new TRTCCloudDef.TRTCParams(mSdkAppId, selfUserId, userSig, roomId, "", "");

        //初始化 UI 控件
        initView();

        //创建 TRTC SDK 实例
        trtcListener = new TRTCCloudListenerImpl(this);
        trtcCloud = TRTCCloud.sharedInstance(this);
        trtcCloud.setListener(trtcListener);

        //开始进入视频通话房间
        enterRoom();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        //销毁 trtc 实例
        TRTCCloud.destroySharedInstance();
        trtcCloud = null;
    }

    @Override
    public void onBackPressed() {
        exitRoom();
    }

    /**
     * 初始化界面控件，包括主要的视频显示View，以及底部的一排功能按钮
     */
    private void initView() {
        setContentView(R.layout.main_activity);

        initClickableLayout(R.id.ll_beauty);
        initClickableLayout(R.id.ll_camera);
        initClickableLayout(R.id.ll_voice);
        initClickableLayout(R.id.ll_log);
        initClickableLayout(R.id.ll_role);
        initClickableLayout(R.id.ll_more);

        mVideoViewLayout = (TRTCVideoViewLayout) findViewById(R.id.ll_mainview);
        mVideoViewLayout.setUserId(trtcParams.userId);
        mVideoViewLayout.setListener(this);
        TXCloudVideoView localVideoView = mVideoViewLayout.getCloudVideoViewByIndex(0);
        localVideoView.setUserId(trtcParams.userId);

        ivShowMode = (ImageView) findViewById(R.id.iv_show_mode);
        ivShowMode.setOnClickListener(this);
        ivBeauty = (ImageView) findViewById(R.id.iv_beauty);
        ivLog = (ImageView) findViewById(R.id.iv_log);
        ivVoice = (ImageView) findViewById(R.id.iv_mic);
        ivCamera = (ImageView) findViewById(R.id.iv_camera);

        etRoomId = (EditText)findViewById(R.id.edit_room_id);
        etUserId = (EditText)findViewById(R.id.edit_user_id);

        findViewById(R.id.btn_confirm).setOnClickListener(this);
        findViewById(R.id.btn_cancel).setOnClickListener(this);

        tvRoomId = (TextView) findViewById(R.id.tv_room_id);
        tvRoomId.setText("" + trtcParams.roomId);

        settingDlg = new TRTCSettingDialog(this, this);
        moreDlg = new TRTCMoreDialog(this, this);
        findViewById(R.id.rtc_double_room_back_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                exitRoom();
            }
        });
    }

    private LinearLayout initClickableLayout(int resId) {
        LinearLayout layout = (LinearLayout) findViewById(resId);
        layout.setOnClickListener(this);
        return layout;
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
        encParam.videoResolution = settingDlg.getResolution();
        encParam.videoFps = settingDlg.getVideoFps();
        encParam.videoBitrate = settingDlg.getVideoBitrate();
        encParam.videoResolutionMode = settingDlg.isVideoVertical() ? TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT : TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_LANDSCAPE;
        trtcCloud.setVideoEncoderParam(encParam);

        TRTCCloudDef.TRTCNetworkQosParam qosParam = new TRTCCloudDef.TRTCNetworkQosParam();
        qosParam.controlMode    = settingDlg.getQosMode();
        qosParam.preference     = settingDlg.getQosPreference();
        trtcCloud.setNetworkQosParam(qosParam);

        //小画面的编码器参数设置
        //TRTC SDK 支持大小两路画面的同时编码和传输，这样网速不理想的用户可以选择观看小画面
        //注意：iPhone & Android 不要开启大小双路画面，非常浪费流量，大小路画面适合 Windows 和 MAC 这样的有线网络环境
        TRTCCloudDef.TRTCVideoEncParam smallParam = new TRTCCloudDef.TRTCVideoEncParam();
        smallParam.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_160_90;
        smallParam.videoFps = settingDlg.getVideoFps();
        smallParam.videoBitrate = 100;
        smallParam.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
        trtcCloud.enableEncSmallVideoStream(settingDlg.enableSmall, smallParam);

        trtcCloud.setPriorRemoteVideoStreamType(settingDlg.priorSmall?TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL:TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }

    /**
     * 加入视频房间：需要 TRTCNewViewActivity 提供的  TRTCParams 函数
     */
    private void enterRoom() {
        // 预览前配置默认参数
        setTRTCCloudParam();

        TXCloudVideoView localVideoView = mVideoViewLayout.getCloudVideoViewByUseId(trtcParams.userId);;
        localVideoView.setUserId(trtcParams.userId);
        localVideoView.setVisibility(View.VISIBLE);

        // 开启视频采集预览
        // 设置 TRTC SDK 的状态
        trtcCloud.enableCustomVideoCapture(mEnableCustomVideoCapture);
        if (mEnableCustomVideoCapture) {
            //启动本地视频文件采集
            if (mCustomCapture != null) {
                mCustomCapture.start(mVideoFile);
            }

            // 设置 TRTC SDK 的状态为本地自定义渲染，视频格式为纹理
            trtcCloud.setLocalVideoRenderListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, (TRTCCloudListener.TRTCVideoRenderListener)mCustomRender);

            //启动本地自定义渲染
            if (mCustomRender != null) {
                TextureView textureView = new TextureView(this);
                localVideoView.addVideoView(textureView);
                mCustomRender.start(textureView);
            }
        } else {
            //启动SDK摄像头采集和渲染
            trtcCloud.startLocalPreview(moreDlg.isCameraFront(), localVideoView);
        }

        trtcCloud.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH, 5, 5, 5);

        if (moreDlg.isEnableAudioCapture()) {
            enableCustomAudioCapture();
            trtcCloud.startLocalAudio();
        }

        setVideoFillMode(moreDlg.isVideoFillMode());

        setVideoRotation(moreDlg.isVideoVertical());

        enableAudioHandFree(moreDlg.isAudioHandFreeMode());

        enableGSensor(moreDlg.isEnableGSensorMode());

        enableAudioVolumeEvaluation(moreDlg.isAudioVolumeEvaluation());

        mRoomMembers.clear();

        trtcCloud.enterRoom(trtcParams, settingDlg.getAppScene());

        Toast.makeText(this, "开始进房", Toast.LENGTH_SHORT).show();
    }

    /**
     * 退出视频房间
     */
    private void exitRoom() {
        if (mCustomCapture != null) {
            mCustomCapture.stop();
        }
        if (mCustomRender != null) {
            mCustomRender.stop();
        }
        if (trtcCloud != null) {
            trtcCloud.exitRoom();
        }
//        CustomAudioFileReader.getInstance().stop();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_show_mode) {
            onChangeMode();
        } else if (v.getId() == R.id.ll_beauty) {
            onChangeBeauty();
        } else if (v.getId() == R.id.ll_camera) {
            onEnableVideo();
        } else if (v.getId() == R.id.ll_voice) {
            onEnableAudio();
        } else if (v.getId() == R.id.ll_log) {
            onChangeLogStatus();
        } else if (v.getId() == R.id.ll_role) {
            onShowSettingDlg();
        } else if (v.getId() == R.id.ll_more) {
            onShowMoreDlg();
        } else if (v.getId() == R.id.btn_confirm) {
            startLinkMic();
        } else if (v.getId() == R.id.btn_cancel) {
            hideLinkMicLayout();
        }
    }

    /**
     * 在前后堆叠模式下，响应手指触控事件，用来切换视频画面的布局
     */
    private void onChangeMode() {
        int mode = mVideoViewLayout.changeMode();
        ivShowMode.setImageResource(mode == TRTCVideoViewLayout.MODE_FLOAT ? R.mipmap.ic_float : R.mipmap.ic_gird);
    }

    /**
     * 点击开启或关闭美颜
     */
    private void onChangeBeauty() {
        bBeautyEnable = !bBeautyEnable;
        if (bBeautyEnable) {
            // 为了简单，全部使用默认值
            trtcCloud.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH, 5, 5, 5);
        } else {
            // 全部设置0表示关闭美颜
            trtcCloud.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_NATURE, 0, 0, 0);
        }
        ivBeauty.setImageResource(bBeautyEnable ? R.mipmap.beauty : R.mipmap.beauty2);
    }

    /**
     * 开启/关闭视频上行
     */
    private void onEnableVideo() {

        bEnableVideo = !bEnableVideo;

        startLocalVideo(bEnableVideo);

        mVideoViewLayout.updateVideoStatus(trtcParams.userId, bEnableVideo);

        ivCamera.setImageResource(bEnableVideo ? R.mipmap.remote_video_enable : R.mipmap.remote_video_disable);
    }

    /**
     * 开启/关闭音频上行
     */
    private void onEnableAudio() {
        bEnableAudio = !bEnableAudio;
        trtcCloud.muteLocalAudio(!bEnableAudio);
        ivVoice.setImageResource(bEnableAudio ? R.mipmap.mic_enable : R.mipmap.mic_disable);
    }

    /**
     * 点击打开仪表盘浮层，仪表盘浮层是SDK中覆盖在视频画面上的一系列数值状态
     */
    private void onChangeLogStatus() {
        iDebugLevel = (iDebugLevel + 1) % 3;
        ivLog.setImageResource((0 == iDebugLevel) ? R.mipmap.log2 : R.mipmap.log);

        trtcCloud.showDebugView(iDebugLevel);
    }

    /**
     * 打开编码参数设置面板，用于调整画质
     */
    private void onShowSettingDlg() {
        settingDlg.show();
    }

    /*
     * 打开更多参数设置面板
     */
    private void onShowMoreDlg() {
        moreDlg.show(beingLinkMic);
    }

    @Override
    public void onComplete() {
        setTRTCCloudParam();
        setVideoFillMode(settingDlg.isVideoVertical());
        moreDlg.updateVideoFillMode(settingDlg.isVideoVertical());
    }

    /**
     * SDK内部状态回调
     */
    static class TRTCCloudListenerImpl extends TRTCCloudListener implements TRTCCloudListener.TRTCVideoRenderListener {

        private WeakReference<TRTCMainActivity> mContext;
        public TRTCCloudListenerImpl(TRTCMainActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        /**
         * 加入房间
         */
        @Override
        public void onEnterRoom(long elapsed) {
            final TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "加入房间成功", Toast.LENGTH_SHORT).show();
                activity.mVideoViewLayout.onRoomEnter();
                activity.updateCloudMixtureParams();
            }
        }

        /**
         * 离开房间
         */
        @Override
        public void onExitRoom(int reason) {
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                activity.finish();
            }
        }

        /**
         * ERROR 大多是不可恢复的错误，需要通过 UI 提示用户
         */
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }

        /**
         * WARNING 大多是一些可以忽略的事件通知，SDK内部会启动一定的补救机制
         */
        @Override
        public void onWarning(int warningCode, String warningMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onWarning");
        }

        /**
         * 有新的用户加入了当前视频房间
         */
        @Override
        public void onUserEnter(String userId) {
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                // 创建一个View用来显示新的一路画面
                TXCloudVideoView renderView = activity.mVideoViewLayout.onMemberEnter(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                if (renderView != null) {
                    // 设置仪表盘数据显示
                    renderView.setVisibility(View.VISIBLE);
                    activity.trtcCloud.showDebugView(activity.iDebugLevel);
                    activity.trtcCloud.setDebugViewMargin(userId, new TRTCCloud.TRTCViewMargin(0.0f, 0.0f, 0.1f, 0.0f));
//                    activity.trtcCloud.setRemoteVideoRenderListener(userId, TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_I420, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY, this);
                }
            }
        }

        /**
         * 有用户离开了当前视频房间
         */
        @Override
        public void onUserExit(String userId, int reason) {
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                //停止观看画面
                activity.trtcCloud.stopRemoteView(userId);
                activity.trtcCloud.stopRemoteSubStreamView(userId);
                //更新视频UI
                activity.mVideoViewLayout.onMemberLeave(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                activity.mVideoViewLayout.onMemberLeave(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
                activity.mRoomMembers.remove(userId);
                activity.updateCloudMixtureParams();

                //跨房连麦
                if (activity.beingLinkMic) {
                    if (userId.equalsIgnoreCase(activity.mUserIdBeingLink)) {
                        activity.stopLinkMic();
                    }
                }
            }
        }
        /**
         * 有用户屏蔽了画面
         */
        @Override
        public void onUserVideoAvailable(final String userId, boolean available){
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                if (available) {
                    final TXCloudVideoView renderView = activity.mVideoViewLayout.onMemberEnter(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                    if (renderView != null) {
                        // 启动远程画面的解码和显示逻辑，FillMode 可以设置是否显示黑边
                        activity.trtcCloud.setRemoteViewFillMode(userId, TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
                        activity.trtcCloud.startRemoteView(userId, renderView);
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                renderView.setUserId(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                            }
                        });
                    }

                    activity.mRoomMembers.add(userId);
                    activity.updateCloudMixtureParams();
                } else {
                    activity.trtcCloud.stopRemoteView(userId);
                    //activity.mVideoViewLayout.onMemberLeave(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);

                    activity.mRoomMembers.remove(userId);
                    activity.updateCloudMixtureParams();
                }
                activity.mVideoViewLayout.updateVideoStatus(userId, available);
            }

        }

        public void onUserSubStreamAvailable(final String userId, boolean available){
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                if (available) {
                    final TXCloudVideoView renderView = activity.mVideoViewLayout.onMemberEnter(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
                    if (renderView != null) {
                        // 启动远程画面的解码和显示逻辑，FillMode 可以设置是否显示黑边
                        activity.trtcCloud.setRemoteSubStreamViewFillMode(userId, TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
                        activity.trtcCloud.startRemoteSubStreamView(userId, renderView);

                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                renderView.setUserId(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
                            }
                        });
                    }

                } else {
                    activity.trtcCloud.stopRemoteSubStreamView(userId);
                    activity.mVideoViewLayout.onMemberLeave(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
                }
            }
        }
        /**
         * 有用户屏蔽了声音
         */
        @Override
        public void onUserAudioAvailable(String userId, boolean available){
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                if (available) {
                    final TXCloudVideoView renderView = activity.mVideoViewLayout.onMemberEnter(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                    if (renderView != null) {
                        renderView.setVisibility(View.VISIBLE);
                    }
                }
            }
        }

        /**
         * 首帧渲染回调
         */
        @Override
        public void onFirstVideoFrame(String userId, int width, int height){
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                activity.mVideoViewLayout.freshToolbarLayoutOnMemberEnter(userId + TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            }
        }

        public void onStartPublishCDNStream(int err, String errMsg) {

        }

        public void onStopPublishCDNStream(int err, String errMsg) {

        }

        public void onRenderVideoFrame(String userId, int streamType, TRTCCloudDef.TRTCVideoFrame frame) {
//            Log.w(TAG, String.format("onRenderVideoFrame userId: %s, type: %d",userId, streamType));
        }

        public  void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
            for (int i = 0; i < userVolumes.size(); ++i) {
                mContext.get().mVideoViewLayout.updateAudioVolume(userVolumes.get(i).userId, userVolumes.get(i).volume);
            }
        }

        public void onStatistics(TRTCStatistics statics){

        }

        @Override
        public void onConnectOtherRoom(final String userID, final int err, final String errMsg) {
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                activity.stopLinkMicLoading();
                if (err == 0) {
                    activity.beingLinkMic = true;
                    activity.moreDlg.updateLinkMicState(true);
                    Toast.makeText(activity.getApplicationContext(), "连麦成功", Toast.LENGTH_LONG).show();
                }
                else {
                    activity.mUserIdBeingLink = "";
                    activity.beingLinkMic = false;
                    activity.moreDlg.updateLinkMicState(false);
                    Toast.makeText(activity.getApplicationContext(), "连麦失败", Toast.LENGTH_LONG).show();
                }
            }
        }

        @Override
        public void onDisConnectOtherRoom(final int err, final String errMsg) {
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                activity.mUserIdBeingLink = "";
                activity.beingLinkMic = false;
                activity.moreDlg.updateLinkMicState(false);
            }
        }

        @Override
        public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality){
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                activity.mVideoViewLayout.updateNetworkQuality(localQuality.userId, localQuality.quality);
                for (TRTCCloudDef.TRTCQuality qualityInfo: remoteQuality) {
                    activity.mVideoViewLayout.updateNetworkQuality(qualityInfo.userId, qualityInfo.quality);
                }
            }
        }
    }

    @Override
    public void onEnableRemoteVideo(final String userId, boolean enable) {
        if (enable) {
            final TXCloudVideoView renderView = mVideoViewLayout.getCloudVideoViewByUseId(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            if (renderView != null) {
                trtcCloud.setRemoteViewFillMode(userId, TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
                trtcCloud.startRemoteView(userId, renderView);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        renderView.setUserId(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                        mVideoViewLayout.freshToolbarLayoutOnMemberEnter(userId);
                    }
                });
            }
        }
        else {
            trtcCloud.stopRemoteView(userId);
        }
    }

    @Override
    public void onEnableRemoteAudio(String userId, boolean enable) {
        trtcCloud.muteRemoteAudio(userId, !enable);
    }

    @Override
    public void onChangeVideoFillMode(String userId, boolean adjustMode) {
        trtcCloud.setRemoteViewFillMode(userId, adjustMode ? TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT : TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL);
    }

    @Override
    public void onSwitchCamera(boolean bCameraFront){
        trtcCloud.switchCamera();
    }

    @Override
    public void onFillModeChange(boolean bFillMode){
        setVideoFillMode(bFillMode);
    }

    @Override
    public void onVideoRotationChange(boolean bVertical){
        setVideoRotation(bVertical);
    }

    @Override
    public void onEnableAudioCapture(boolean bEnable){
        enableAudioCapture(bEnable);
    }

    @Override
    public void onEnableAudioHandFree(boolean bEnable){
        enableAudioHandFree(bEnable);
    }

    @Override
    public void onMirrorLocalVideo(boolean bMirror){

    }

    @Override
    public void onMirrorRemoteVideo(boolean bMirror){

    }

    @Override
    public void onEnableGSensor(boolean bEnable){
        enableGSensor(bEnable);
    }

    @Override
    public void onEnableAudioVolumeEvaluation(boolean bEnable){
        enableAudioVolumeEvaluation(bEnable);
    }

    @Override
    public void onEnableCloudMixture(boolean bEnable){
        updateCloudMixtureParams();
    }

    @Override
    public void onClickButtonGetPlayUrl() {
        if (trtcParams == null) {
            return;
        }

        String strStreamID = "3891_" + stringToMd5("" + trtcParams.roomId + "_" + trtcParams.userId + "_main");
        String strPlayUrl = "http://3891.liveplay.myqcloud.com/live/" + strStreamID + ".flv";

//        ClipboardManager cm = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
//        ClipData clipData = ClipData.newPlainText("Label", strPlayUrl);
//        cm.setPrimaryClip(clipData);
//        Toast.makeText(getApplicationContext(), "播放地址已复制到系统剪贴板！", Toast.LENGTH_SHORT).show();

        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.putExtra(Intent.EXTRA_TEXT, strPlayUrl);
        intent.setType("text/plain");
        startActivity(Intent.createChooser(intent, "分享"));
    }

    @Override
    public void onClickButtonLinkMic() {
        if (beingLinkMic) {
            stopLinkMic();
        }
        else {
            showLinkMicLayout();
        }
    }

    private void setVideoFillMode(boolean bFillMode) {
        if (bFillMode) {
            trtcCloud.setLocalViewFillMode(TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL);
        }
        else {
            trtcCloud.setLocalViewFillMode(TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
        }
    }

    private void setVideoRotation(boolean bVertical) {
        if (bVertical) {
            trtcCloud.setLocalViewRotation(TRTCCloudDef.TRTC_VIDEO_ROTATION_0);
        }
        else {
            trtcCloud.setLocalViewRotation(TRTCCloudDef.TRTC_VIDEO_ROTATION_90);
        }
    }

    private void enableAudioCapture(boolean bEnable) {
        if (bEnable) {
            trtcCloud.startLocalAudio();
        }
        else {
            trtcCloud.stopLocalAudio();
        }
    }

    private void enableAudioHandFree(boolean bEnable) {
        if (bEnable) {
            trtcCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        }
        else {
            trtcCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
        }
    }

    private void enableGSensor(boolean bEnable) {
        if (bEnable) {
            trtcCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_UIFIXLAYOUT);
        }
        else {
            trtcCloud.setGSensorMode(TRTCCloudDef.TRTC_GSENSOR_MODE_DISABLE);
        }
    }

    private void enableAudioVolumeEvaluation(boolean bEnable) {
        if (bEnable) {
            trtcCloud.enableAudioVolumeEvaluation(200, 9);
        }
        else {
            trtcCloud.enableAudioVolumeEvaluation(0, 0);
            mVideoViewLayout.hideAudioVolumeProgressBar();
        }
    }

    private void enableCustomAudioCapture() {
        trtcCloud.enableCustomAudioCapture(mEnableCustomAudioCapture);
    }

    private void updateCloudMixtureParams() {
        // 背景大画面宽高
        int videoWidth  = 720;
        int videoHeight = 1280;

        // 小画面宽高
        int subWidth  = 180;
        int subHeight = 320;

        int offsetX = 5;
        int offsetY = 50;

        int bitrate = 200;

        int resolution = settingDlg.getResolution();
        switch (resolution) {

            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_160_160:
            {
                videoWidth  = 160;
                videoHeight = 160;
                subWidth    = 27;
                subHeight   = 48;
                offsetY     = 20;
                bitrate     = 200;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_180:
            {
                videoWidth  = 192;
                videoHeight = 336;
                subWidth    = 54;
                subHeight   = 96;
                offsetY     = 30;
                bitrate     = 400;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_240:
            {
                videoWidth  = 240;
                videoHeight = 320;
                subWidth    = 54;
                subHeight   = 96;
                bitrate     = 400;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_480:
            {
                videoWidth  = 480;
                videoHeight = 480;
                subWidth    = 72;
                subHeight   = 128;
                bitrate     = 600;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360:
            {
                videoWidth  = 368;
                videoHeight = 640;
                subWidth    = 90;
                subHeight   = 160;
                bitrate     = 800;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480:
            {
                videoWidth  = 480;
                videoHeight = 640;
                subWidth    = 90;
                subHeight   = 160;
                bitrate     = 800;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540:
            {
                videoWidth  = 544;
                videoHeight = 960;
                subWidth    = 171;
                subHeight   = 304;
                bitrate     = 1000;
                break;
            }
            case TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720:
            {
                videoWidth  = 720;
                videoHeight = 1280;
                subWidth    = 180;
                subHeight   = 320;
                bitrate     = 1500;
                break;
            }
        }

        TRTCCloudDef.TRTCTranscodingConfig config = new TRTCCloudDef.TRTCTranscodingConfig();
        config.appId = mSdkAppId;
        config.bizId = 3891;
        config.videoWidth = videoWidth;
        config.videoHeight = videoHeight;
        config.videoGOP = 3;
        config.videoFramerate = 15;
        config.videoBitrate = bitrate;
        config.audioSampleRate = 48000;
        config.audioBitrate = 64;
        config.audioChannels = 1;

        // 设置混流后主播的画面位置
        TRTCCloudDef.TRTCMixUser broadCaster = new TRTCCloudDef.TRTCMixUser();
        broadCaster.userId = trtcParams.userId; // 以主播uid为broadcaster为例
        broadCaster.zOrder = 0;
        broadCaster.x = 0;
        broadCaster.y = 0;
        broadCaster.width = videoWidth;
        broadCaster.height = videoHeight;

        config.mixUsers = new ArrayList<>();
        config.mixUsers.add(broadCaster);

        // 设置混流后各个小画面的位置
        if (moreDlg.isEnableCloudMixture()) {
            int index = 0;
            for (String userId : mRoomMembers) {
                TRTCCloudDef.TRTCMixUser audience = new TRTCCloudDef.TRTCMixUser();
                audience.userId = userId;
                audience.zOrder = 1 + index;
                if (index < 3) {
                    // 前三个小画面靠右从下往上铺
                    audience.x = videoWidth - offsetX - subWidth;
                    audience.y = videoHeight - offsetY - index * subHeight - subHeight;
                    audience.width = subWidth;
                    audience.height = subHeight;
                } else if (index < 6) {
                    // 后三个小画面靠左从下往上铺
                    audience.x = offsetX;
                    audience.y = videoHeight - offsetY - (index - 3) * subHeight - subHeight;
                    audience.width = subWidth;
                    audience.height = subHeight;
                } else {
                    // 最多只叠加六个小画面
                }

                config.mixUsers.add(audience);
                ++index;
            }
        }

        trtcCloud.setMixTranscodingConfig(config);
    }

    protected String stringToMd5(String string) {
        if (TextUtils.isEmpty(string)) {
            return "";
        }
        MessageDigest md5 = null;
        try {
            md5 = MessageDigest.getInstance("MD5");
            byte[] bytes = md5.digest(string.getBytes());
            String result = "";
            for (byte b : bytes) {
                String temp = Integer.toHexString(b & 0xff);
                if (temp.length() == 1) {
                    temp = "0" + temp;
                }
                result += temp;
            }
            return result;
        }
        catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return "";
    }

    private void showLinkMicLayout() {
        FrameLayout layout = (FrameLayout)findViewById(R.id.layout_linkmic);
        layout.setVisibility(View.VISIBLE);

        etRoomId.setText("");
        etUserId.setText("");
    }

    private void hideLinkMicLayout() {
        FrameLayout layout = (FrameLayout)findViewById(R.id.layout_linkmic);
        layout.setVisibility(View.GONE);
    }

    private void startLinkMicLoading() {
        FrameLayout layout = (FrameLayout) findViewById(R.id.layout_linkmic_loading);
        layout.setVisibility(View.VISIBLE);

        ImageView imageView = (ImageView)findViewById(R.id.imageview_linkmic_loading);
        imageView.setImageResource(R.drawable.trtc_linkmic_loading);
        AnimationDrawable animation = (AnimationDrawable)imageView.getDrawable();
        if (animation != null) {
            animation.start();
        }
    }

    private void stopLinkMicLoading() {
        FrameLayout layout = (FrameLayout) findViewById(R.id.layout_linkmic_loading);
        layout.setVisibility(View.GONE);

        ImageView imageView = (ImageView)findViewById(R.id.imageview_linkmic_loading);
        AnimationDrawable animation = (AnimationDrawable)imageView.getDrawable();
        if (animation != null) {
            animation.stop();
        }
    }

    private void startLinkMic() {
        String roomId = etRoomId.getText().toString();
        String userId = etUserId.getText().toString();
        if (roomId == null || roomId.isEmpty()) {
            Toast.makeText(getApplicationContext(), "请输入目标房间名", Toast.LENGTH_SHORT).show();
            return;
        }
        if (userId == null || userId.isEmpty()) {
            Toast.makeText(getApplicationContext(), "请输入目标用户ID", Toast.LENGTH_SHORT).show();
            return;
        }

        mUserIdBeingLink = userId;

        trtcCloud.ConnectOtherRoom(String.format("{\"roomId\":%s,\"userId\":\"%s\"}", roomId, userId));

        hideLinkMicLayout();
        startLinkMicLoading();
    }

    private void stopLinkMic() {
        trtcCloud.DisconnectOtherRoom();
    }

    private void startLocalVideo(boolean enable) {
        if(mEnableCustomVideoCapture) return;
        TXCloudVideoView localVideoView = mVideoViewLayout.getCloudVideoViewByUseId(trtcParams.userId);;
        localVideoView.setUserId(trtcParams.userId);
        localVideoView.setVisibility(View.VISIBLE);
        if (enable) {
            //启动SDK摄像头采集和渲染
            trtcCloud.startLocalPreview(moreDlg.isCameraFront(), localVideoView);
        } else {
            trtcCloud.stopLocalPreview();
        }

    }
}
