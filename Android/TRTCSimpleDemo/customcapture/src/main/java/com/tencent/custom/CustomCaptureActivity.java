package com.tencent.custom;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.tencent.custom.customcapture.AudioFrameReader;
import com.tencent.custom.customcapture.TestRenderVideoFrame;
import com.tencent.custom.customcapture.TestSendCustomData;
import com.tencent.custom.customcapture.VideoFrameReader;
import com.tencent.custom.customcapture.structs.TextureFrame;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.liteav.debug.Constant;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.tencent.trtc.TRTCCloudDef.TRTCRoleAnchor;
import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_LIVE;

/**
 * 自定义视频采集的主页面
 * <p>
 * 包含如下简单功能：
 * - 展示自定义采集的视频音频并推送
 * - 显示房间内其他用户的视频画面（当前示例最多可显示6个其他用户的视频画面）
 */
public class CustomCaptureActivity extends AppCompatActivity implements View.OnClickListener {

    private static final String TAG                 = "CustomCaptureActivity";
    private static final int    REQ_PERMISSION_CODE = 0x1000;

    private TextView         mTitleText;                 //【控件】页面Title
    private TXCloudVideoView mLocalPreviewView;          //【控件】本地画面View
    private ImageView        mBackButton;                //【控件】返回上一级页面

    private TRTCCloud              mTRTCCloud;                 // SDK 核心类
    private List<String>           mRemoteUidList;             // 远端用户Id列表
    private List<TXCloudVideoView> mRemoteViewList;            // 远端画面列表
    private int                    mGrantedCount = 0;          // 权限个数计数，获取Android系统权限
    private int                    mUserCount    = 0;             // 房间通话人数个数
    private int                    mLogLevel     = 0;              // 日志等级
    private String                 mRoomId;                    // 房间Id
    private String                 mUserId;                    // 用户Id

    private String                                mVideoFilePath;             // 视频文件路径
    private TestSendCustomData                    mCustomCapture;             // 外部采集
    private TestRenderVideoFrame                  mCustomRender;              // 外部渲染
    private HashMap<String, TestRenderVideoFrame> mCustomRemoteRenderMap;         // 自定义渲染远端的主播 Map

    private AudioFrameReader.AudioFrameReadListener mAudioFrameReadListener = new AudioFrameReader.AudioFrameReadListener() {
        @Override
        public void onFrameAvailable(byte[] data, int sampleRate, int channel, long timestamp) {
            TRTCCloudDef.TRTCAudioFrame trtcAudioFrame = new TRTCCloudDef.TRTCAudioFrame();
            trtcAudioFrame.data = data;
            trtcAudioFrame.sampleRate = sampleRate;
            trtcAudioFrame.channel = channel;
            // 模拟不带时间戳
            // trtcAudioFrame.timestamp = mLastEndTime;

            mTRTCCloud.sendCustomAudioData(trtcAudioFrame);
        }
    };

    private VideoFrameReader.VideoFrameReadListener mVideoFrameReadListener = new VideoFrameReader.VideoFrameReadListener() {
        @Override
        public void onFrameAvailable(TextureFrame frame) {
            // 将视频帧通过纹理方式塞给SDK
            TRTCCloudDef.TRTCVideoFrame videoFrame = new TRTCCloudDef.TRTCVideoFrame();
            videoFrame.texture = new TRTCCloudDef.TRTCTexture();
            videoFrame.texture.textureId = frame.textureId;
            videoFrame.texture.eglContext14 = frame.eglContext;
            videoFrame.width = frame.width;
            videoFrame.height = frame.height;
            videoFrame.pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
            videoFrame.bufferType = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;

            mTRTCCloud.sendCustomVideoData(videoFrame);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_customcaputure);
        getSupportActionBar().hide();
        handleIntent();
        // 先检查权限再加入通话
        if (checkPermission()) {
            initView();
            initCustomCapture();
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
        mTitleText = findViewById(R.id.trtc_tv_room_number);
        mBackButton = findViewById(R.id.trtc_ic_back);
        mLocalPreviewView = findViewById(R.id.trtc_tc_cloud_view_main);

        if (!TextUtils.isEmpty(mRoomId)) {
            mTitleText.setText(mRoomId);
        }
        mBackButton.setOnClickListener(this);

        mRemoteUidList = new ArrayList<>();
        mRemoteViewList = new ArrayList<>();
        mRemoteViewList.add((TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view_1));
        mRemoteViewList.add((TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view_2));
        mRemoteViewList.add((TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view_3));
        mRemoteViewList.add((TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view_4));
        mRemoteViewList.add((TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view_5));
        mRemoteViewList.add((TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view_6));
    }


    private void initCustomCapture() {
        mVideoFilePath = getIntent().getStringExtra(Constant.CUSTOM_VIDEO);
        mCustomCapture = new TestSendCustomData(this, mVideoFilePath, true);
        mCustomRender = new TestRenderVideoFrame(mUserId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        mCustomRemoteRenderMap = new HashMap<>();
    }

    private void enterRoom() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(CustomCaptureActivity.this));

        // 初始化配置 SDK 参数
        TRTCCloudDef.TRTCParams trtcParams = new TRTCCloudDef.TRTCParams();
        trtcParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        trtcParams.userId = mUserId;
        trtcParams.roomId = Integer.parseInt(mRoomId);
        // userSig是进入房间的用户签名，相当于密码（这里生成的是测试签名，正确做法需要业务服务器来生成，然后下发给客户端）
        trtcParams.userSig = GenerateTestUserSig.genTestUserSig(trtcParams.userId);
        trtcParams.role = TRTCRoleAnchor;

        // 进入通话
        mTRTCCloud.enterRoom(trtcParams, TRTC_APP_SCENE_LIVE);

        // 打开自定义采集
        mTRTCCloud.enableCustomVideoCapture(true);
        mTRTCCloud.enableCustomAudioCapture(true);
        mCustomCapture.start(mAudioFrameReadListener, mVideoFrameReadListener);

        mTRTCCloud.setLocalVideoRenderListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, mCustomRender);
        TextureView textureView = new TextureView(this);
        mLocalPreviewView.addVideoView(textureView);
        mCustomRender.start(textureView);

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
        if (mCustomRemoteRenderMap != null) {
            for (TestRenderVideoFrame render : mCustomRemoteRenderMap.values()) {
                if (render != null) {
                    render.stop();
                }
            }
            mCustomRemoteRenderMap.clear();
        }
        mCustomCapture.stop();
        mCustomRender.stop();
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
                ActivityCompat.requestPermissions(CustomCaptureActivity.this,
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
                Toast.makeText(this, getString(R.string.custom_permisson_error_tip), Toast.LENGTH_SHORT).show();
            }
            mGrantedCount = 0;
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.trtc_ic_back) {
            finish();
        }
    }

    /**
     * 开始自定义渲染
     *
     * @param userId
     * @param renderView
     */
    private void startCustomRender(String userId, TXCloudVideoView renderView) {
        // 创建自定义渲染类
        TestRenderVideoFrame customRender = new TestRenderVideoFrame(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        // 创建渲染的View
        TextureView textureView = new TextureView(renderView.getContext());
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
    }

    /**
     * 停止自定义渲染
     *
     * @param userId
     */
    private void stopCustomRender(String userId) {
        // 停止自定义渲染
        TestRenderVideoFrame render = mCustomRemoteRenderMap.remove(userId);
        if (render != null) {
            render.stop();
        }
        // 移除自定义渲染的 View
        mTRTCCloud.stopRemoteSubStreamView(userId);
    }

    private class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<CustomCaptureActivity> mContext;

        public TRTCCloudImplListener(CustomCaptureActivity activity) {
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
                stopCustomRender(userId);
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
                    startCustomRender(remoteUid, mRemoteViewList.get(i));
                } else {
                    mRemoteViewList.get(i).setVisibility(View.GONE);
                }
            }
        }

        // 错误通知监听，错误通知意味着 SDK 不能继续运行
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            CustomCaptureActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode + "]", Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

}
