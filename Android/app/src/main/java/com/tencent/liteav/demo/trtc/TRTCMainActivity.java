package com.tencent.liteav.demo.trtc;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.TXLiteAVCode;
import com.tencent.liteav.demo.R;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.lang.ref.WeakReference;


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
public class TRTCMainActivity extends Activity implements View.OnClickListener, TRTCSettingDialog.ISettingListener {
    private final static String TAG = TRTCMainActivity.class.getSimpleName();

    private boolean bFrontCamera = true, bBeautyEnable = true, bMicEnable = true;
    private int iDebugLevel = 0;

    private TextView tvRoomId;
    private ImageView ivShowMode, ivSwitch, ivBeauty, ivMic, ivLog;
    private TRTCSettingDialog settingDlg;
    private TRTCVideoViewLayout mVideoViewLayout;

    private TRTCCloudDef.TRTCParams trtcParams; /// TRTC SDK 视频通话房间进入所必须的参数
    private TRTCCloud trtcCloud;                /// TRTC SDK 实例对象
    private TRTCCloudListener trtcListener;     /// TRTC SDK 回调监听

    @Override
    protected void onCreate( Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //应用运行时，保持屏幕高亮，不锁屏
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN , WindowManager.LayoutParams.FLAG_FULLSCREEN);

        //获取前一个页面得到的进房参数
        Intent intent       = getIntent();
        int sdkAppId        = intent.getIntExtra("sdkAppId", 0);
        int roomId          = intent.getIntExtra("roomId", 0);
        String selfUserId   = intent.getStringExtra("userId");
        String userSig      = intent.getStringExtra("userSig");

        trtcParams = new TRTCCloudDef.TRTCParams(sdkAppId, selfUserId, userSig, roomId, "", "");

        //初始化 UI 控件
        initView();

        //获取 TRTC SDK 单例
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
        if (trtcCloud != null) {
            //取消SDK回调
            trtcCloud.setListener(null);
        }
    }

    @Override
    public void onBackPressed() {
        exitRoom();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_show_mode) {
            onChangeMode();
        } else if (v.getId() == R.id.ll_switch) {
            onSwitchCamera();
        } else if (v.getId() == R.id.ll_voice) {
            onMuteAudio();
        } else if (v.getId() == R.id.ll_log) {
            onChangeLogStatus();
        } else if (v.getId() == R.id.ll_beauty) {
            onChangeBeauty();
        } else if (v.getId() == R.id.ll_role) {
            onShowSettingDlg();
        }
    }

    private void finishActivity() {
        finish();
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
        encParam.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
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

        // 开启视频采集预览
        TXCloudVideoView localVideoView = mVideoViewLayout.getCloudVideoViewByIndex(0);
        localVideoView.setUserId(trtcParams.userId);
        localVideoView.setVisibility(View.VISIBLE);
        trtcCloud.setLocalViewFillMode(TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL);
        trtcCloud.startLocalPreview(true, localVideoView);
        trtcCloud.startLocalAudio();

        //进房
        trtcCloud.enterRoom(trtcParams, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);

        Toast.makeText(this, "开始进房", Toast.LENGTH_SHORT).show();
    }

    /**
     * 退出视频房间
     */
    private void exitRoom() {
        if (trtcCloud != null) {
            trtcCloud.exitRoom();
        }
    }

    /**
     * 初始化界面控件，包括主要的视频显示View，以及底部的一排功能按钮
     */
    private void initView() {
        setContentView(R.layout.main_activity);
        tvRoomId = (TextView) findViewById(R.id.tv_room_id);
        initClickableLayout(R.id.ll_switch);
        initClickableLayout(R.id.ll_beauty);
        initClickableLayout(R.id.ll_voice);
        initClickableLayout(R.id.ll_log);
        initClickableLayout(R.id.ll_role);

        mVideoViewLayout = (TRTCVideoViewLayout) findViewById(R.id.ll_mainview);
        mVideoViewLayout.setUserId(trtcParams.userId);
        ivShowMode = (ImageView) findViewById(R.id.iv_show_mode);
        ivShowMode.setOnClickListener(this);
        ivSwitch = (ImageView) findViewById(R.id.iv_switch);
        ivBeauty = (ImageView) findViewById(R.id.iv_beauty);
        ivMic = (ImageView) findViewById(R.id.iv_mic);
        ivLog = (ImageView) findViewById(R.id.iv_log);

        tvRoomId.setText("" + trtcParams.roomId);

        settingDlg = new TRTCSettingDialog(this, this);
        findViewById(R.id.rtc_double_room_back_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                exitRoom();
            }
        });
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
     * 在前后堆叠模式下，响应手指触控事件，用来切换视频画面的布局
     */
    private void onChangeMode() {
        int mode = mVideoViewLayout.changeMode();
        ivShowMode.setImageResource(mode == TRTCVideoViewLayout.MODE_FLOAT ? R.mipmap.ic_float : R.mipmap.ic_gird);
    }

    /**
     * 点击切换前后置摄像头
     */
    private void onSwitchCamera() {
        bFrontCamera = !bFrontCamera;
        trtcCloud.switchCamera();
        ivSwitch.setImageResource(bFrontCamera ? R.mipmap.camera : R.mipmap.camera2);
    }

    /**
     * 点击关闭或者打开本地的麦克风采集
     */
    private void onMuteAudio() {
        bMicEnable = !bMicEnable;
        trtcCloud.muteLocalAudio(!bMicEnable);
        ivMic.setImageResource(bMicEnable ? R.mipmap.mic : R.mipmap.mic2);
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
     * 打开编码参数设置面板，用于调整画质
     */
    private void onShowSettingDlg() {
        settingDlg.show();
    }

    @Override
    public void onComplete() {
        setTRTCCloudParam();
    }

    /**
     * SDK内部状态回调
     */
    static class TRTCCloudListenerImpl extends TRTCCloudListener {
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
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "加入房间成功", Toast.LENGTH_SHORT).show();
                activity.mVideoViewLayout.onRoomEnter();
            }
        }

        /**
         * 离开房间
         */
        @Override
        public void onExitRoom(int reason) {
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                activity.finishActivity();
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

        }

        /**
         * 有用户离开了当前视频房间
         */
        @Override
        public void onUserExit(String userId, int reason) {
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                activity.trtcCloud.stopRemoteView(userId);
                activity.mVideoViewLayout.onMemberLeave(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);

                activity.trtcCloud.stopRemoteSubStreamView(userId);
                activity.mVideoViewLayout.onMemberLeave(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
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
                        activity.trtcCloud.showDebugView(activity.iDebugLevel);
                        activity.trtcCloud.setDebugViewMargin(userId, new TRTCCloud.TRTCViewMargin(0.0f, 0.0f, 0.1f, 0.0f));
                        activity.trtcCloud.startRemoteView(userId, renderView);
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                renderView.setUserId(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                            }
                        });
                    }
                } else {
                    activity.trtcCloud.stopRemoteView(userId);
                    activity.mVideoViewLayout.onMemberLeave(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                }
            }
        }
        /**
         * 有用户屏蔽了声音
         */
        @Override
        public void onUserAudioAvailable(String userId, boolean available){
            Log.d(TAG, "sdk callback onUserAudioAvailable " +available);
        }

        public void onUserSubStreamAvailable(final String userId, boolean available){
            TRTCMainActivity activity = mContext.get();
            if (activity != null) {
                if (available) {
                    final TXCloudVideoView renderView = activity.mVideoViewLayout.onMemberEnter(userId+TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
                    if (renderView != null) {
                        // 启动远程画面的解码和显示逻辑，FillMode 可以设置是否显示黑边
                        activity.trtcCloud.setRemoteViewFillMode(userId, TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
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
    }
}
