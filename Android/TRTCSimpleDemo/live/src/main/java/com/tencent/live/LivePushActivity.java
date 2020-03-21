package com.tencent.live;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.debug.Constant;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.trtc.TRTCCloudDef;

import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_LIVE;

/**
 * 主播视角下的RTC视频互动直播房间页面
 *
 * 包含如下简单功能：
 * - 进入/退出直播房间
 * - 切换前置/后置摄像头
 * - 打开/关闭摄像头
 * - 打开/关闭麦克风
 * - 切换视频直播的画质（标清、高清、超清）
 * - 显示房间内连麦用户的视频画面（当前示例最多可显示6个连麦用户的视频画面）
 * - 打开/关闭连麦用户的声音和视频画面
 */
public class LivePushActivity extends LiveBaseActivity implements View.OnClickListener {

    private LinearLayout                    mSelectResolutionLayout;
    private Button                          mSelectResolution;          // 大主播独有，切换分辨率

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 先检查权限再加入通话
        if (checkPermission()) {
            initView();
            enterRoom();
        }
    }

    @Override
    protected void initView() {
        super.initView();
        mTRTCCloud.setListener(new TRTCCloudImplListener(LivePushActivity.this));
        for (int index = 0 ; index < mRemoteViewList.size(); index++) {
            mRemoteViewList.get(index).setLiveSubViewListener(new LiveSubViewListenerImpl(index));
        }
        mMuteVideoButton.setOnClickListener(this);
        mMuteAudioButton.setOnClickListener(this);
        mSwitchCameraButton.setOnClickListener(this);
        // 【按钮】切换分辨率（大主播时才有）
        mSelectResolution = findViewById(R.id.live_btn_select_resolution);
        mSelectResolutionLayout = findViewById(R.id.live_ll_select_resolution);
        mSelectResolution.setOnClickListener(this);
    }

    @Override
    protected void enterRoom() {
        // 初始化配置
        mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = mUserId;
        mTRTCParams.roomId = Integer.parseInt(mRoomId);
        /// userSig是进入房间的用户签名，相当于密码（这里生成的是测试签名，正确做法需要业务服务器来生成，然后下发给客户端）
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        // 开启本地声音采集并上行
        mTRTCCloud.startLocalAudio();
        // 开启本地画面采集并上行
        mTRTCCloud.startLocalPreview(mIsFrontCamera, mAnchorPreviewView);
        // 显示切换摄像头
        mSwitchCameraButton.setVisibility(View.VISIBLE);
        // 显示分辨率
        mSelectResolutionLayout.setVisibility(View.VISIBLE);
        // 进入直播间
        mTRTCCloud.enterRoom(mTRTCParams, TRTC_APP_SCENE_LIVE);
        /**
         * 设置默认美颜效果（美颜效果：自然，美颜级别：5, 美白级别：1）
         * BeautyStyle 美颜风格.三种美颜风格：0 ：光滑  1：自然  2：朦胧
         * 互动直播场景推荐使用“光滑”美颜效果
         */
        TXBeautyManager beautyManager = mTRTCCloud.getBeautyManager();
        beautyManager.setBeautyStyle(Constant.BEAUTY_STYLE_SMOOTH);
        beautyManager.setBeautyLevel(5);
        beautyManager.setWhitenessLevel(1);

        // 设置默认分辨率, 码率
        setVideoConfig(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540, Constant.LIVE_540_960_VIDEO_BITRATE);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onClick(View view) {
        super.onClick(view);
        int id = view.getId();
        if (id == R.id.live_btn_mute_video) {
            muteVideo();
        } else if (id == R.id.live_btn_mute_audio) {
            muteAudio();
        } else if (id == R.id.live_btn_switch_camera) {
            switchCamera();
        } else if (id == R.id.live_btn_select_resolution) {
            selectResolution();
        }
    }

    private void muteVideo() {
        boolean isSelected = mMuteAudioButton.isSelected();
        if (!isSelected) {
            mTRTCCloud.stopLocalPreview();
            mMuteVideoButton.setBackgroundResource(R.mipmap.live_mute_video);
            mBigPreviewMuteVideoDefault.setVisibility(View.VISIBLE);
        } else {
            mTRTCCloud.startLocalPreview(mIsFrontCamera, mAnchorPreviewView);
            mMuteVideoButton.setBackgroundResource(R.mipmap.live_unmute_video);
            mBigPreviewMuteVideoDefault.setVisibility(View.GONE);
        }
        mMuteAudioButton.setSelected(!isSelected);
    }

    private void muteAudio() {
        boolean isSelected = mMuteAudioButton.isSelected();
        if (!isSelected) {
            mTRTCCloud.stopLocalAudio();
            mMuteAudioButton.setBackgroundResource(R.mipmap.live_mute_audio);
        } else {
            mTRTCCloud.startLocalAudio();
            mMuteAudioButton.setBackgroundResource(R.mipmap.live_unmute_audio);
        }
        mMuteAudioButton.setSelected(!isSelected);
    }

    public void setVideoConfig(int resolution, int bitRate) {
        // 画面的编码器参数设置
        // 设置视频编码参数，包括分辨率、帧率、码率等等
        // 注意（1）：不要在码率很低的情况下设置很高的分辨率，会出现较大的马赛克
        // 注意（2）：不要设置超过25FPS以上的帧率，因为电影才使用24FPS，我们一般推荐15FPS，这样能将更多的码率分配给画质
        TRTCCloudDef.TRTCVideoEncParam encParam = new TRTCCloudDef.TRTCVideoEncParam();
        encParam.videoResolution = resolution;
        encParam.videoFps = Constant.VIDEO_FPS;
        encParam.videoBitrate = bitRate;
        encParam.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
        mTRTCCloud.setVideoEncoderParam(encParam);
    }

    private int parseResolution(int position) {
        int videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
        switch (position) {
            case 0:
                videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
                break;
            case 1:
                videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
                break;
            case 2:
                videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
                break;
            default:
                break;
        }
        return videoResolution;
    }

    private void selectResolution() {
        new LiveBottomDialog(LivePushActivity.this)
                .builder()
                .setTitle("分辨率")
                .setCancelable(true)
                .setCanceledOnTouchOutside(true)
                .addDialogItem("标清：360*640", LiveBottomDialog.DialogItemColor.Blue
                        , new LiveBottomDialog.OnDialogItemClickListener() {
                            @Override
                            public void onClick(int position) {
                                mSelectResolution.setText("标");
                                setVideoConfig(parseResolution(0), Constant.LIVE_360_640_VIDEO_BITRATE);
                            }
                        })
                .addDialogItem("高清：540*960", LiveBottomDialog.DialogItemColor.Blue
                        , new LiveBottomDialog.OnDialogItemClickListener() {
                            @Override
                            public void onClick(int position) {
                                mSelectResolution.setText("高");
                                setVideoConfig(parseResolution(1), Constant.LIVE_540_960_VIDEO_BITRATE);
                            }
                        })
                .addDialogItem("超清：720*1280", LiveBottomDialog.DialogItemColor.Blue
                        , new LiveBottomDialog.OnDialogItemClickListener() {
                            @Override
                            public void onClick(int position) {
                                mSelectResolution.setText("超");
                                setVideoConfig(parseResolution(2), Constant.LIVE_720_1280_VIDEO_BITRATE);
                            }
                        }).show();
    }

}
