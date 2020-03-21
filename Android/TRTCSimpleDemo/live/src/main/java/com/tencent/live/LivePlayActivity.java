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
 * 观众视角下的RTC视频互动直播房间页面
 *
 * 包含如下简单功能：
 * - 进入/退出直播房间
 * - 显示房间内连麦用户的视频画面（当前示例最多可显示6个连麦用户的视频画面）
 * - 打开/关闭主播以及房间内其他连麦用户的声音和视频画面
 * - 发起/停止连麦
 * - 发起连麦之后，可以切换自己的前置/后置摄像头
 * - 发起连麦之后，可以控制打开/关闭自己的摄像头和麦克风
 */
public class LivePlayActivity extends LiveBaseActivity implements View.OnClickListener {

    private Button                            mLinkMicButton;                // 连麦按钮
    private LinearLayout                      mLicMicLayout;                 // 连麦按钮父布局

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
        mLinkMicButton = findViewById(R.id.live_iv_link_mic);
        mLicMicLayout = findViewById(R.id.live_ll_switch_role);

        mMuteVideoButton.setOnClickListener(this);
        mMuteAudioButton.setOnClickListener(this);
        mSwitchCameraButton.setOnClickListener(this);
        mLinkMicButton.setOnClickListener(this);

        mTRTCCloud.setListener(new TRTCCloudImplListener(LivePlayActivity.this));
        mLinkMicSelfPreviewView.setLiveSubViewListener(new LiveSubVideoView.LiveSubViewListener() {
            @Override
            public void onMuteRemoteAudioClicked(View view) {
                boolean isSelected = view.isSelected();
                if (!isSelected) {
                    mTRTCCloud.stopLocalAudio();
                    view.setBackground(getResources().getDrawable(R.mipmap.live_subview_sound_mute));
                } else {
                    mTRTCCloud.startLocalAudio();
                    view.setBackground(getResources().getDrawable(R.mipmap.live_subview_sound_unmute));
                }
                view.setSelected(!isSelected);
            }

            @Override
            public void onMuteRemoteVideoClicked(View view) {
                boolean isSelected = view.isSelected();
                if (!isSelected) {
                    mTRTCCloud.stopLocalPreview();
                    mLinkMicSelfPreviewView.getMuteVideoDefault().setVisibility(View.VISIBLE);
                    view.setBackground(getResources().getDrawable(R.mipmap.live_subview_video_mute));
                } else {
                    mTRTCCloud.startLocalPreview(mIsFrontCamera, mLinkMicSelfPreviewView.getVideoView());
                    mLinkMicSelfPreviewView.getMuteVideoDefault().setVisibility(View.GONE);
                    view.setBackground(getResources().getDrawable(R.mipmap.live_subview_video_unmute));
                }
                view.setSelected(!isSelected);
            }
        });

        for (int index = 0 ; index < mRemoteViewList.size(); index++) {
            mRemoteViewList.get(index).setLiveSubViewListener(new LiveSubViewListenerImpl(index));
        }
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
        mTRTCParams.role = mRoleType;
        // 普通观众可以切换角色，可以连麦成小主播
        mLicMicLayout.setVisibility(View.VISIBLE);
        // 普通观众无法切换摄像头，只能观看
        mSwitchCameraButton.setVisibility(View.GONE);
        // 进入直播间
        mTRTCCloud.enterRoom(mTRTCParams, TRTC_APP_SCENE_LIVE);
        /**
         * 设置默认美颜效果（美颜效果：自然，美颜级别：5, 美白级别：1）
         * BeautyStyle 美颜风格.三种美颜风格：0 ：光滑  1：自然  2：朦胧
         * 互动直播场景推荐使用“光滑”美颜效果
         */
        TXBeautyManager beautyManager = mTRTCCloud.getBeautyManager();
        beautyManager.setBeautyStyle(0);
        beautyManager.setBeautyLevel(5);
        beautyManager.setWhitenessLevel(1);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onClick(View view) {
        super.onClick(view);
        int id = view.getId();
        if (id == R.id.live_iv_link_mic) {
            linkMic();
        } else if (id == R.id.live_btn_mute_video) {
            muteVideo();
        } else if (id == R.id.live_btn_mute_audio) {
            muteAudio();
        } else if (id == R.id.live_btn_switch_camera) {
            switchCamera();
        }
    }

    private void linkMic() {
        boolean isSelected = mLinkMicButton.isSelected();
        if (isSelected) { // 停止连麦
            mLinkMicSelfPreviewView.setVisibility(View.GONE);
            mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.stopLocalPreview();
            mLinkMicButton.setBackgroundResource(R.mipmap.live_linkmic_stop);
            mSwitchCameraButton.setVisibility(View.GONE);
        } else { // 发起连麦
            mLinkMicSelfPreviewView.setVisibility(View.VISIBLE);
            mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
            mTRTCCloud.startLocalAudio();
            mTRTCCloud.startLocalPreview(mIsFrontCamera, mLinkMicSelfPreviewView.getVideoView());
            setVideoConfig();
            mLinkMicButton.setBackgroundResource(R.mipmap.live_linkmic_start);
            mSwitchCameraButton.setVisibility(View.VISIBLE);
        }
        mLinkMicButton.setSelected(!isSelected);
    }

    private void muteVideo() {
        boolean isSelected = mMuteAudioButton.isSelected();
        if (!isSelected) {
            if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
                mTRTCCloud.stopLocalPreview();
            } else {
                mTRTCCloud.stopRemoteView(mMainRoleAnchorId);
            }
            mMuteVideoButton.setBackgroundResource(R.mipmap.live_mute_video);
            mBigPreviewMuteVideoDefault.setVisibility(View.VISIBLE);
        } else {
            if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
                mTRTCCloud.startLocalPreview(mIsFrontCamera, mAnchorPreviewView);
            } else {
                mTRTCCloud.startRemoteView(mMainRoleAnchorId, mAnchorPreviewView);
            }
            mMuteVideoButton.setBackgroundResource(R.mipmap.live_unmute_video);
            mBigPreviewMuteVideoDefault.setVisibility(View.GONE);
        }
        mMuteAudioButton.setSelected(!isSelected);
    }

    private void muteAudio() {
        boolean isSelected = mMuteAudioButton.isSelected();
        if (!isSelected) {
            if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
                mTRTCCloud.stopLocalAudio();
            } else {
                mTRTCCloud.muteRemoteAudio(mMainRoleAnchorId, true);
            }
            mMuteAudioButton.setBackgroundResource(R.mipmap.live_mute_audio);
        } else {
            if (mTRTCParams.role == TRTCCloudDef.TRTCRoleAnchor) {
                mTRTCCloud.startLocalAudio();
            } else {
                mTRTCCloud.muteRemoteAudio(mMainRoleAnchorId, false);
            }
            mMuteAudioButton.setBackgroundResource(R.mipmap.live_unmute_audio);
        }
        mMuteAudioButton.setSelected(!isSelected);
    }

    private void setVideoConfig() {
        TRTCCloudDef.TRTCVideoEncParam encParam = new TRTCCloudDef.TRTCVideoEncParam();
        encParam.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270;
        encParam.videoFps = Constant.VIDEO_FPS;
        encParam.videoBitrate = Constant.LIVE_270_480_VIDEO_BITRATE;
        encParam.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
        mTRTCCloud.setVideoEncoderParam(encParam);
    }

}
