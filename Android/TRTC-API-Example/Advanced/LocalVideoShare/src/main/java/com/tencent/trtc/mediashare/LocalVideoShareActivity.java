package com.tencent.trtc.mediashare;

import android.app.Activity;
import android.content.Intent;
import android.media.MediaFormat;
import android.net.Uri;
import android.opengl.EGLContext;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
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
import com.tencent.trtc.debug.GenerateTestUserSig;
import com.tencent.trtc.mediashare.helper.CustomFrameRender;
import com.tencent.trtc.mediashare.helper.MediaFileSyncReader;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

/**
 * TRTC 视频文件分享的示例
 *
 * 本文件展示了如何使用TRTC SDK实现视频文件直播分享功能，主要流程如下：
 *  - 读取视频文件、对视频文件进行解封装 --> 解码；
 *  - 将解码后的音视频帧通过TRTC的自定义采集接口{@link com.tencent.trtc.TRTCCloud#sendCustomAudioData(com.tencent.trtc.TRTCCloudDef.TRTCAudioFrame)} 和{@link com.tencent.trtc.TRTCCloud#sendCustomVideoData(int, com.tencent.trtc.TRTCCloudDef.TRTCVideoFrame)}发送给TRTC SDK；
 *  - 通过{@link com.tencent.trtc.TRTCCloud#setLocalVideoRenderListener(int, int, com.tencent.trtc.TRTCCloudListener.TRTCVideoRenderListener)}获取处理后的本地视频帧并渲染到屏幕上；
 *  - 通过{@link com.tencent.trtc.TRTCCloud#setAudioFrameListener(com.tencent.trtc.TRTCCloudListener.TRTCAudioFrameListener)} )}获取处理后的音频帧并进行播放；
 *  - 如果有远端主播，可以通过{@link com.tencent.trtc.TRTCCloud#setRemoteVideoRenderListener(String, int, int, com.tencent.trtc.TRTCCloudListener.TRTCVideoRenderListener)} 获取远端主播的视频帧并渲染到屏幕上，远端主播的音频会在上一步自动混音后播放；
 *
 *  - 更多细节，详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html}
 */

/**
 * Video File Sharing
 *
 * This document shows how to share a video file during live streaming. The steps are detailed below:
 *  - Read and de-encapsulate the video file --> decode
 *  - Call the SDK’s custom audio and video capturing APIs {@link com.tencent.trtc.TRTCCloud#sendCustomAudioData(com.tencent.trtc.TRTCCloudDef.TRTCAudioFrame)} and {@link com.tencent.trtc.TRTCCloud#sendCustomVideoData(int, com.tencent.trtc.TRTCCloudDef.TRTCVideoFrame)} to send the decoded audio and video frames to the SDK.
 *  - Call {@link com.tencent.trtc.TRTCCloud#setLocalVideoRenderListener(int, int, com.tencent.trtc.TRTCCloudListener.TRTCVideoRenderListener)} to get the processed local video frames and render them to the screen.
 *  - Call {@link com.tencent.trtc.TRTCCloud#setAudioFrameListener(com.tencent.trtc.TRTCCloudListener.TRTCAudioFrameListener)} )} to get and play the processed audio frames.
 *  - If there is a remote anchor, call {@link com.tencent.trtc.TRTCCloud#setRemoteVideoRenderListener(String, int, int, com.tencent.trtc.TRTCCloudListener.TRTCVideoRenderListener)} to get the anchor’s video frames and render them to the screen. The audio of the anchor is automatically mixed and played in the previous step.
 *
 *  - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html}.
 */
@RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
public class LocalVideoShareActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String TAG = "LocalVideoShareActivity";

    private ImageView                          mImageBack;
    private TextView                           mTextTitle;
    private Button                             mButtonSelectFile;
    private Button                             mButtonStartPush;
    private EditText                           mEditRoomId;
    private EditText                           mEditVideoFilePath;
    private TXCloudVideoView                   mTXCloudPreviewView;
    private List<TXCloudVideoView>             mRemoteVideoList;

    private TRTCCloud                          mTRTCCloud;
    private MediaFileSyncReader                mMediaFileSyncReader;
    private CustomFrameRender                  mCustomFrameRender;

    private String                             mVideoFilePath;
    private List<String>                       mRemoteUserIdList;
    private boolean                            mStartPushFlag = false;
    private HashMap<String, CustomFrameRender> mCustomRemoteRenderMap;
    private String                             mUserId;


    private MediaFileSyncReader.AudioFrameReadListener mAudioFrameReadListener = new MediaFileSyncReader.AudioFrameReadListener() {
        @Override
        public void onFrameAvailable(byte[] data, int sampleRate, int channel, long timestamp) {
            TRTCCloudDef.TRTCAudioFrame trtcAudioFrame = new TRTCCloudDef.TRTCAudioFrame();
            trtcAudioFrame.data = data;
            trtcAudioFrame.sampleRate = sampleRate;
            trtcAudioFrame.channel = channel;
            trtcAudioFrame.timestamp = timestamp;

            mTRTCCloud.sendCustomAudioData(trtcAudioFrame);
        }
    };

    private MediaFileSyncReader.VideoFrameReadListener mVideoFrameReadListener = new MediaFileSyncReader.VideoFrameReadListener() {
        @Override
        public void onFrameAvailable(EGLContext eglContext, int textureId, int width, int height, long timestamp) {
            TRTCCloudDef.TRTCVideoFrame videoFrame = new TRTCCloudDef.TRTCVideoFrame();
            videoFrame.texture = new TRTCCloudDef.TRTCTexture();
            videoFrame.texture.textureId = textureId;
            videoFrame.texture.eglContext14 = eglContext;
            videoFrame.width = width;
            videoFrame.height = height;
            videoFrame.timestamp = timestamp;
            videoFrame.pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
            videoFrame.bufferType = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;

            mTRTCCloud.sendCustomVideoData(TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, videoFrame);
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.mediashare_activity_local_video_share);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }

        mRemoteUserIdList = new ArrayList<>();
    }

    private void initView() {
        mImageBack          = findViewById(R.id.iv_back);
        mTextTitle          = findViewById(R.id.tv_room_number);
        mButtonSelectFile   = findViewById(R.id.btn_file_select);
        mButtonStartPush    = findViewById(R.id.btn_start_push);
        mEditRoomId         = findViewById(R.id.et_room_id);
        mEditVideoFilePath  = findViewById(R.id.et_file_path);
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
        mButtonSelectFile.setOnClickListener(this);

        mUserId = new Random().nextInt(100000) + 1000000 + "";
        mTextTitle.setText(getString(R.string.mediashare_roomid) + ":" + mEditRoomId.getText().toString());
    }


    private void enterRoom(String roomId, String userId) {
        mMediaFileSyncReader = new MediaFileSyncReader(this, mVideoFilePath, true);
        mCustomFrameRender = new CustomFrameRender(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
        mCustomRemoteRenderMap = new HashMap<>();

        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(LocalVideoShareActivity.this));

        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = userId;
        mTRTCParams.roomId = Integer.parseInt(roomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);

        mTRTCCloud.enableCustomVideoCapture(TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, true);
        mTRTCCloud.enableCustomAudioCapture(true);
        mMediaFileSyncReader.start(mAudioFrameReadListener, mVideoFrameReadListener);

        mTRTCCloud.setLocalVideoRenderListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, mCustomFrameRender);
        final TextureView textureView = new TextureView(this);
        mTXCloudPreviewView.addVideoView(textureView);
        mCustomFrameRender.start(textureView);

        mTRTCCloud.setAudioFrameListener(mCustomFrameRender);
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

        if (mMediaFileSyncReader != null) {
            mMediaFileSyncReader.stop();
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
            if (TextUtils.isEmpty(mVideoFilePath)) {
                Toast.makeText(LocalVideoShareActivity.this, getString(R.string.mediashare_please_select_video_file), Toast.LENGTH_SHORT).show();
                return;
            }
            String roomId = mEditRoomId.getText().toString();
            if (!mStartPushFlag) {
                if (!TextUtils.isEmpty(roomId)) {
                    mButtonStartPush.setText(R.string.mediashare_stop_push);
                    enterRoom(roomId, mUserId);
                    mStartPushFlag = true;
                } else {
                    Toast.makeText(LocalVideoShareActivity.this, getString(R.string.mediashare_please_input_roomid_userid), Toast.LENGTH_SHORT).show();
                }
            } else {
                mButtonStartPush.setText(R.string.mediashare_start_push);
                exitRoom();
                mStartPushFlag = false;
            }

        } else if (view.getId() == R.id.btn_file_select) {
            if (mStartPushFlag) {
                return;
            }
            Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
            intent.setType("video/*");
            startActivityForResult(intent, 1);
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

        private WeakReference<LocalVideoShareActivity> mContext;

        public TRTCCloudImplListener(LocalVideoShareActivity activity) {
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
            LocalVideoShareActivity activity = mContext.get();
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
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            Uri uri = data.getData();
            if ("file".equalsIgnoreCase(uri.getScheme())) {
                mVideoFilePath = uri.getPath();
            } else {
                mVideoFilePath = Utils.getPathFromUri(this, uri);
            }

            try {
                MediaFormat mediaFormat = Utils.retrieveMediaFormat(mVideoFilePath, false);
                int sampleRate = mediaFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE);
                int channelCount = mediaFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
            } catch (Exception e) {
                Log.e(TAG, "Failed to open file " + mVideoFilePath);
                Toast.makeText(this, "打开文件失败!", Toast.LENGTH_LONG).show();
                mVideoFilePath = "";
                return;
            }
            mEditVideoFilePath.setText(mVideoFilePath);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }
}