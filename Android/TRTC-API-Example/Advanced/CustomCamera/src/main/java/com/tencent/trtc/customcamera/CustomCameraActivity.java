package com.tencent.trtc.customcamera;

import android.opengl.EGLContext;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.TextureView;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.RequiresApi;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.customcamera.helper.CustomCameraCapture;
import com.tencent.trtc.customcamera.helper.CustomFrameRender;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

/**
 * TRTC 自定义相机采集&渲染的示例
 *
 * 本文件展示了如何使用TRTC SDK 实现相机的自定义采集&渲染功能，主要流程如下：
 * - 调用{@link com.tencent.trtc.customcamera.helper.CustomCameraCapture#startInternal(com.tencent.trtc.customcamera.helper.CustomCameraCapture.VideoFrameReadListener)}，启动Camera采集，并传入一个VideoFrameReadListener；
 * - 将{@link com.tencent.trtc.customcamera.helper.CustomCameraCapture.VideoFrameReadListener}返回的视频帧通过TRTC的自定义视频采集接口 {@link com.tencent.trtc.TRTCCloud#sendCustomVideoData(int, com.tencent.trtc.TRTCCloudDef.TRTCVideoFrame)}; 发送给TRTC SDK；
 * - 通过{@link com.tencent.trtc.TRTCCloud#setLocalVideoRenderListener(int, int, com.tencent.trtc.TRTCCloudListener.TRTCVideoRenderListener)}获取处理后的本地视频帧并渲染到屏幕上；
 * - 如果有远端主播，可以通过{@link com.tencent.trtc.TRTCCloud#setRemoteVideoRenderListener(String, int, int, com.tencent.trtc.TRTCCloudListener.TRTCVideoRenderListener)} 获取远端主播的视频帧并渲染到屏幕上；
 *
 * - 更多细节，详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html}
 */

/**
 * Custom Video Capturing & Rendering
 *
 * This document shows how to enable custom video capturing and rendering in the TRTC SDK.
 * - Call {@link com.tencent.trtc.customcamera.helper.CustomCameraCapture#startInternal(com.tencent.trtc.customcamera.helper.CustomCameraCapture.VideoFrameReadListener)} to start video capturing by the camera, with `VideoFrameReadListener` passed in.
 * - Call the custom video capturing API {@link com.tencent.trtc.TRTCCloud#sendCustomVideoData(int, com.tencent.trtc.TRTCCloudDef.TRTCVideoFrame)}; to send the video frames returned by `{@link com.tencent.trtc.customcamera.helper.CustomCameraCapture.VideoFrameReadListener}` to the SDK.
 * - Get the processed local video data using {@link com.tencent.trtc.TRTCCloud#setLocalVideoRenderListener(int, int, com.tencent.trtc.TRTCCloudListener.TRTCVideoRenderListener)} and render it to the screen.
 * - If there is a remote anchor, call {@link com.tencent.trtc.TRTCCloud#setRemoteVideoRenderListener(String, int, int, com.tencent.trtc.TRTCCloudListener.TRTCVideoRenderListener)} to get the anchor’s video frames and render them to the screen.
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html}.
 */
@RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
public class CustomCameraActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String TAG = "CustomCameraActivity";

    private ImageView                           mImageBack;
    private TextView                            mTextTitle;
    private Button                              mButtonStartPush;
    private EditText                            mEditRoomId;
    private EditText                            mEditUserId;
    private TXCloudVideoView                    mTXCloudPreviewView;
    private List<TXCloudVideoView>              mRemoteVideoList;

    private TRTCCloud                           mTRTCCloud;
    private CustomCameraCapture                 mCustomCameraCapture;
    private CustomFrameRender                   mCustomFrameRender;

    private List<String>                        mRemoteUserIdList;
    private boolean                             mStartPushFlag = false;
    private HashMap<String, CustomFrameRender>  mCustomRemoteRenderMap;

    private CustomCameraCapture.VideoFrameReadListener mVideoFrameReadListener = new CustomCameraCapture.VideoFrameReadListener() {
        @Override
        public void onFrameAvailable(EGLContext eglContext, int textureId, int width, int height) {
            TRTCCloudDef.TRTCVideoFrame videoFrame = new TRTCCloudDef.TRTCVideoFrame();
            videoFrame.texture = new TRTCCloudDef.TRTCTexture();
            videoFrame.texture.textureId = textureId;
            videoFrame.texture.eglContext14 = eglContext;
            videoFrame.width = width;
            videoFrame.height = height;
            videoFrame.pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
            videoFrame.bufferType = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;

            mTRTCCloud.sendCustomVideoData(TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG ,videoFrame);
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.customcamera_activity_custom_camera);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }

        mRemoteUserIdList = new ArrayList<>();
    }

    private void initView() {
        mImageBack          = findViewById(R.id.iv_back);
        mTextTitle          = findViewById(R.id.tv_room_number);
        mButtonStartPush    = findViewById(R.id.btn_start_push);
        mEditRoomId         = findViewById(R.id.et_room_id);
        mEditUserId         = findViewById(R.id.et_user_id);
        mTXCloudPreviewView = findViewById(R.id.txcvv_main_local);
        mRemoteVideoList = new ArrayList<>();

        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote1));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote2));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote3));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote4));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote5));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote6));

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);

        mEditUserId.setText(new Random().nextInt(100000) + 1000000 + "");
        mTextTitle.setText(getString(R.string.customcamera_roomid) + ":" + mEditRoomId.getText().toString());
    }


    private void enterRoom(String roomId, String userId) {
        mCustomCameraCapture = new CustomCameraCapture();
        mCustomFrameRender = new CustomFrameRender(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        mCustomRemoteRenderMap = new HashMap<>();

        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(CustomCameraActivity.this));

        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = userId;
        mTRTCParams.roomId = Integer.parseInt(roomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);

        mTRTCCloud.enableCustomVideoCapture(TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,true);

        mCustomCameraCapture.startInternal(mVideoFrameReadListener);

        mTRTCCloud.setLocalVideoRenderListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, mCustomFrameRender);
        final TextureView textureView = new TextureView(this);
        mTXCloudPreviewView.addVideoView(textureView);
        mCustomFrameRender.start(textureView);
    }

    private void hideRemoteView() {
        mRemoteUserIdList.clear();
        for (TXCloudVideoView videoView : mRemoteVideoList) {
            videoView.setVisibility(View.GONE);
        }
    }

    private void exitRoom() {
        if (mCustomRemoteRenderMap != null) {
            for (CustomFrameRender render : mCustomRemoteRenderMap.values()) {
                if (render != null) {
                    render.stop();
                }
            }
            mCustomRemoteRenderMap.clear();
        }
        if (mCustomCameraCapture != null) {
            mCustomCameraCapture.stop();
        }
        if (mCustomFrameRender != null) {
            mCustomFrameRender.stop();
        }
        hideRemoteView();
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAllRemoteView();
            mTRTCCloud.exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }


    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.iv_back) {
            finish();
        } else if (view.getId() == R.id.btn_start_push) {
            String roomId = mEditRoomId.getText().toString();
            String userId = mEditUserId.getText().toString();
            if (!mStartPushFlag) {
                if (!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)) {
                    mButtonStartPush.setText(R.string.customcamera_stop_push);
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                } else {
                    Toast.makeText(CustomCameraActivity.this, getString(R.string.customcamera_please_input_roomid_userid), Toast.LENGTH_SHORT).show();
                }
            } else {
                mButtonStartPush.setText(R.string.customcamera_start_push);
                exitRoom();
                mStartPushFlag = false;
            }

        }
    }

    private void startRemoteCustomRender(String userId, TXCloudVideoView renderView) {
        CustomFrameRender customRender = new CustomFrameRender(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        TextureView textureView = new TextureView(renderView.getContext());
        renderView.addVideoView(textureView);
        mTRTCCloud.setRemoteVideoRenderListener(userId, TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_I420, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY, customRender);
        customRender.start(textureView);
        mCustomRemoteRenderMap.put(userId, customRender);
        mTRTCCloud.startRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,null);
    }


    private void stopRemoteCustomRender(String userId) {
        CustomFrameRender render = mCustomRemoteRenderMap.remove(userId);
        if (render != null) {
            render.stop();
        }
        mTRTCCloud.stopRemoteView(userId);
    }


    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<CustomCameraActivity> mContext;

        public TRTCCloudImplListener(CustomCameraActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            int index = mRemoteUserIdList.indexOf(userId);
            if (available) {
                if (index != -1) {
                    return;
                }
                mRemoteUserIdList.add(userId);
            } else {
                if (index == -1) {
                    return;
                }
                stopRemoteCustomRender(userId);
                mRemoteUserIdList.remove(index);
            }
            refreshRemoteVideo();

        }

        private void refreshRemoteVideo() {
            if (mRemoteUserIdList.size() > 0) {
                for (int i = 0; i < mRemoteUserIdList.size() || i < 6; i++) {
                    if (i < mRemoteUserIdList.size() && !TextUtils.isEmpty(mRemoteUserIdList.get(i))) {
                        mRemoteVideoList.get(i).setVisibility(View.VISIBLE);
                        startRemoteCustomRender(mRemoteUserIdList.get(i), mRemoteVideoList.get(i));
                    } else {
                        mRemoteVideoList.get(i).setVisibility(View.GONE);
                    }
                }
            } else {
                for (int i = 0; i < 6; i++) {
                    mRemoteVideoList.get(i).setVisibility(View.GONE);
                }
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            CustomCameraActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode + "]", Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

    @Override
    protected void onPermissionGranted() {
        initView();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }
}