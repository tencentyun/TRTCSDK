package com.tencent.liteav.liveroom.ui.anchor;

import android.animation.ObjectAnimator;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintSet;
import android.support.constraint.Guideline;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.beauty.model.ItemInfo;
import com.tencent.liteav.demo.beauty.model.TabInfo;
import com.tencent.liteav.demo.beauty.view.BeautyPanel;
import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.ui.common.adapter.TCUserAvatarListAdapter;
import com.tencent.liteav.liveroom.ui.common.utils.TCUtils;
import com.tencent.liteav.liveroom.ui.widget.AudioEffectPanel;
import com.tencent.liteav.liveroom.ui.widget.video.TCVideoView;
import com.tencent.liteav.liveroom.ui.widget.video.TCVideoViewMgr;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Module:   TCBaseAnchorActivity
 * <p>
 * Function: 主播推流的页面
 * <p>
 */
public class TCCameraAnchorActivity extends TCBaseAnchorActivity implements View.OnClickListener {
    private static final String TAG = TCCameraAnchorActivity.class.getSimpleName();

    private TXCloudVideoView        mTXCloudVideoView;      // 主播本地预览的View
    private TXCloudVideoView        mVideoViewPKAnchor;     // PK主播的视频显示View
    private RecyclerView            mRecyclerUserAvatar;    // 显示观众头像的列表控件
    private ImageView               mImagesAnchorHead;      // 显示房间主播头像
    private ImageView               mImageRecordBall;       // 表明正在录制的红点球
    private TextView                mTextBroadcastTime;     // 显示已经开播的时间
    private TextView                mTextMemberCount;       // 显示当前房间的观众数量
    private Button                  mButtonPK;              // 发起PK请求的按钮
    private Guideline               mGuideLineVertical;     // ConstraintLayout的垂直参考线
    private Guideline               mGuideLineHorizontal;   // ConstraintLayout的水平参考线
    private AnchorPKSelectView      mViewPKAnchorList;      // 显示可PK主播的列表
    private AudioEffectPanel        mPanelAudioControl;     // 音效控制面板
    private BeautyPanel             mPanelBeautyControl;    // 美颜设置的控制类
    private RelativeLayout          mPKContainer;
    private RadioButton             mRbNormalQuality;
    private RadioButton             mRbMusicQuality;
    private ImageView               mImagePKLayer;
    private Button                  mButtonExit;            // 结束直播&退出PK
    private ObjectAnimator          mAnimatorRecordBall;    // 显示录制状态红点的闪烁动画
    private TCUserAvatarListAdapter mUserAvatarListAdapter; // mUserAvatarList的适配器
    private TCVideoViewMgr          mVideoViewMgr;          // 主播视频列表的View

    private boolean                 mShowLog;               // 表示是否显示Log面板
    private List<String>            mAnchorUserIdList  = new ArrayList<>();
    private int                     mCurrentStatus    = TRTCLiveRoomDef.ROOM_STATUS_NONE;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.TRTCLiveRoomBeautyTheme);
        super.onCreate(savedInstanceState);
        mPanelBeautyControl.setBeautyManager(mLiveRoom.getBeautyManager());
        startPreview();
    }

    @Override
    public int getLayoutId() {
        return R.layout.trtcliveroom_activity_anchor;
    }

    @Override
    protected void initView() {
        super.initView();
        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.video_view_anchor);
        mTXCloudVideoView.setLogMargin(10, 10, 45, 55);

        mPKContainer = (RelativeLayout) findViewById(R.id.pk_container);
        mImagePKLayer = (ImageView) findViewById(R.id.iv_pk_layer);

        mRecyclerUserAvatar = (RecyclerView) findViewById(R.id.rv_audience_avatar);
        mUserAvatarListAdapter = new TCUserAvatarListAdapter(this, mSelfUserId);
        mRecyclerUserAvatar.setAdapter(mUserAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRecyclerUserAvatar.setLayoutManager(linearLayoutManager);

        mTextBroadcastTime = (TextView) findViewById(R.id.tv_anchor_broadcasting_time);
        mTextBroadcastTime.setText(String.format(Locale.US, "%s", "00:00:00"));
        mImageRecordBall = (ImageView) findViewById(R.id.iv_anchor_record_ball);

        mButtonExit =  (Button) findViewById(R.id.btn_close);
        mImagesAnchorHead = (ImageView) findViewById(R.id.iv_anchor_head);
        showHeadIcon(mImagesAnchorHead, mSelfAvatar);

        mImagesAnchorHead.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLog();
            }
        });

        mTextMemberCount = (TextView) findViewById(R.id.tv_room_member_counts);
        mTextMemberCount.setText("0");
        mButtonPK = (Button) findViewById(R.id.btn_request_pk);
        //AudioEffectPanel
        mPanelAudioControl = new AudioEffectPanel(this);
        mPanelAudioControl.setAudioEffectManager(mLiveRoom.getAudioEffectManager());
        mPanelAudioControl.setDismissListener(new AudioEffectPanel.OnDismissListener() {
            @Override
            public void onDismiss() {
                mGroupLiveAfter.setVisibility(View.VISIBLE);
            }
        });
        mPanelBeautyControl = (BeautyPanel) findViewById(R.id.beauty_panel);
        mPanelBeautyControl.setOnBeautyListener(new BeautyPanel.OnBeautyListener() {
            @Override
            public void onTabChange(TabInfo tabInfo, int position) {

            }

            @Override
            public boolean onClose() {
                if (mIsEnterRoom) {
                    mGroupLiveAfter.setVisibility(View.VISIBLE);
                } else {
                    mGroupLiveBefore.setVisibility(View.VISIBLE);
                }
                return false;
            }

            @Override
            public boolean onClick(TabInfo tabInfo, int tabPosition, ItemInfo itemInfo, int itemPosition) {
                return false;
            }

            @Override
            public boolean onLevelChanged(TabInfo tabInfo, int tabPosition, ItemInfo itemInfo, int itemPosition, int beautyLevel) {
                return false;
            }
        });

        // 监听踢出的回调
        List<TCVideoView> videoViews = new ArrayList<>();
        videoViews.add((TCVideoView) findViewById(R.id.video_view_link_mic_1));
        videoViews.add((TCVideoView) findViewById(R.id.video_view_link_mic_2));
        videoViews.add((TCVideoView) findViewById(R.id.video_view_link_mic_3));
        mVideoViewMgr = new TCVideoViewMgr(videoViews, new TCVideoView.OnRoomViewListener() {
            @Override
            public void onKickUser(String userID) {
                if (userID != null) {
                    mLiveRoom.kickoutJoinAnchor(userID, new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {
                        }
                    });
                }
            }
        });

        mViewPKAnchorList = (AnchorPKSelectView) findViewById(R.id.anchor_pk_select_view);
        mViewPKAnchorList.setSelfRoomId(mRoomId);
        mViewPKAnchorList.setOnPKSelectedCallback(new AnchorPKSelectView.onPKSelectedCallback() {
            @Override
            public void onSelected(final TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo) {
                // 发起PK请求
                mViewPKAnchorList.setVisibility(View.GONE);
                mGroupLiveAfter.setVisibility(View.VISIBLE);
                mLiveRoom.requestRoomPK(roomInfo.roomId, roomInfo.ownerId, new TRTCLiveRoomCallback.ActionCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (code == 0) {
                            ToastUtils.showShort(getString(R.string.trtcliveroom_tips_accept_link_mic, roomInfo.ownerName));
                        } else {
                            ToastUtils.showShort(getString(R.string.trtcliveroom_tips_refuse_link_mic, roomInfo.ownerName));
                        }
                    }
                });
            }

            @Override
            public void onCancel() {
                mGroupLiveAfter.setVisibility(View.VISIBLE);
            }
        });
        mGuideLineVertical = (Guideline) findViewById(R.id.gl_vertical);
        mGuideLineHorizontal = (Guideline) findViewById(R.id.gl_horizontal);
        mRbNormalQuality = (RadioButton) findViewById(R.id.rb_live_room_quality_normal);
        mRbMusicQuality = (RadioButton) findViewById(R.id.rb_live_room_quality_music);
    }

    /**
     * 加载主播头像
     *
     * @param view   view
     * @param avatar 头像链接
     */
    private void showHeadIcon(ImageView view, String avatar) {
        TCUtils.showPicWithUrl(this, view, avatar, R.drawable.trtcliveroom_bg_cover);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mLiveRoom.showVideoDebugLog(false);
        if (mMainHandler != null) {
            mMainHandler.removeCallbacksAndMessages(null);
        }
        stopRecordAnimation();
        mVideoViewMgr.recycleVideoView();
        mVideoViewMgr = null;
        if (mPanelAudioControl != null) {
            mPanelAudioControl.reset();
            mPanelAudioControl.unInit();
            mPanelAudioControl = null;
        }
    }

    protected void startPreview() {
        // 打开本地预览，传入预览的 View
        mTXCloudVideoView.setVisibility(View.VISIBLE);
        mLiveRoom.startCameraPreview(true, mTXCloudVideoView, null);
    }

    /**
     * 开始和停止推流相关
     */

    @Override
    protected void enterRoom() {
        super.enterRoom();
    }

    @Override
    protected void exitRoom() {
        super.exitRoom();
    }

    @Override
    protected void onCreateRoomSuccess() {
        ProfileManager.getInstance().checkNeedShowSecurityTips(TCCameraAnchorActivity.this);
        startRecordAnimation();
        int audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
        if (mRbNormalQuality.isChecked()) {
            audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
        } else if (mRbMusicQuality.isChecked()) {
            audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC;
        }
        mLiveRoom.setAudioQuality(audioQuality);
        // 创建房间成功，开始推流
        mLiveRoom.startPublish(mSelfUserId + "_stream", new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    Log.d(TAG, "开播成功");
                } else {
                    Log.e(TAG, "开播失败" + msg);
                }
            }
        });
    }

    @Override
    protected void finishRoom() {
        mPanelBeautyControl.clear();
        mLiveRoom.stopCameraPreview();
        super.finishRoom();
    }

    private void setAnchorViewFull(boolean isFull) {
        if (isFull) {
            ConstraintSet set = new ConstraintSet();
            set.clone(mRootView);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.END, ConstraintSet.PARENT_ID, ConstraintSet.END);
            set.applyTo(mRootView);
        } else {
            ConstraintSet set = new ConstraintSet();
            set.clone(mRootView);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.TOP, mPKContainer.getId(), ConstraintSet.TOP);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.BOTTOM,  mPKContainer.getId(), ConstraintSet.BOTTOM);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.END, mGuideLineVertical.getId(), ConstraintSet.END);
            set.applyTo(mRootView);
        }
    }

    @Override
    public void onAnchorEnter(final String userId) {
        // 主播进房
        mAnchorUserIdList.add(userId);
        final TCVideoView view = mVideoViewMgr.applyVideoView(userId);
        if (mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK) {
            view.startLoading();
        }
        mLiveRoom.startPlay(userId, view.getPlayerVideo(), new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    Log.d(TAG, userId + "");
                    if (mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK) {
                        view.stopLoading(true);
                    }
                }
            }
        });
    }

    @Override
    public void onRoomInfoChange(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo) {
        Log.d(TAG, "onRoomInfoChange");
        super.onRoomInfoChange(roomInfo);
        int oldStatus = mCurrentStatus;
        mCurrentStatus = roomInfo.roomStatus;
        setAnchorViewFull(mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK);
        Log.d(TAG, "onRoomInfoChange: " + mCurrentStatus);
        if (oldStatus == TRTCLiveRoomDef.ROOM_STATUS_PK
                && mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK) {
            // 上一个状态是PK，需要将界面中的元素恢复
            mImagePKLayer.setVisibility(View.GONE);
            mButtonExit.setText(R.string.trtcliveroom_btn_stop_live);
            TCVideoView videoView = mVideoViewMgr.getPKUserView();
            mVideoViewPKAnchor = videoView.getPlayerVideo();
            if (mPKContainer.getChildCount() != 0) {
                mPKContainer.removeView(mVideoViewPKAnchor);
                videoView.addView(mVideoViewPKAnchor);
                mVideoViewMgr.clearPKView();
                mVideoViewPKAnchor = null;
            }
        } else if (mCurrentStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
            // 本次状态是PK，需要将一个PK的view挪到右上角
            mImagePKLayer.setVisibility(View.VISIBLE);
            mButtonExit.setText(R.string.trtcliveroom_btn_stop_pk);
            TCVideoView videoView = mVideoViewMgr.getPKUserView();
            videoView.showKickoutBtn(false);
            mVideoViewPKAnchor = videoView.getPlayerVideo();
            videoView.removeView(mVideoViewPKAnchor);
            mPKContainer.addView(mVideoViewPKAnchor);
        }
    }

    @Override
    public void onAnchorExit(String userId) {
        mAnchorUserIdList.remove(userId);
        mLiveRoom.stopPlay(userId, null);
        mVideoViewMgr.recycleVideoView(userId);
    }

    @Override
    public void onRequestRoomPK(final TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, final int timeout) {
        final ConfirmDialogFragment dialogFragment = new ConfirmDialogFragment();
        dialogFragment.setCancelable(false);
        dialogFragment.setMessage(getString(R.string.trtcliveroom_request_pk, userInfo.userName));
        if (dialogFragment.isAdded()) {
            dialogFragment.dismiss();
            return;
        }
        dialogFragment.setPositiveText(getString(R.string.trtcliveroom_accept));
        dialogFragment.setNegativeText(getString(R.string.trtcliveroom_refuse));
        dialogFragment.setPositiveClickListener(new ConfirmDialogFragment.PositiveClickListener() {
            @Override
            public void onClick() {
                dialogFragment.dismiss();
                mLiveRoom.responseRoomPK(userInfo.userId, true, "");
            }
        });

        dialogFragment.setNegativeClickListener(new ConfirmDialogFragment.NegativeClickListener() {
            @Override
            public void onClick() {
                dialogFragment.dismiss();
                mLiveRoom.responseRoomPK(userInfo.userId, false, getString(R.string.trtcliveroom_anchor_refuse_pk_request));
            }
        });
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                dialogFragment.show(getFragmentManager(), "ConfirmDialogFragment");
                mMainHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        dialogFragment.dismiss();
                    }
                }, timeout);
            }
        });
    }

    @Override
    public void onQuitRoomPK() {
        ToastUtils.showShort(R.string.trtcliveroom_tips_quit_pk);
    }

    @Override
    public void onRequestJoinAnchor(final TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String reason, final int timeout) {
        final ConfirmDialogFragment dialogFragment = new ConfirmDialogFragment();
        dialogFragment.setCancelable(false);
        dialogFragment.setMessage(getString(R.string.trtcliveroom_request_link_mic, userInfo.userName));
        if (dialogFragment.isAdded()) {
            dialogFragment.dismiss();
            return;
        }
        dialogFragment.setPositiveText(getString(R.string.trtcliveroom_accept));
        dialogFragment.setNegativeText(getString(R.string.trtcliveroom_refuse));
        dialogFragment.setPositiveClickListener(new ConfirmDialogFragment.PositiveClickListener() {
            @Override
            public void onClick() {
                dialogFragment.dismiss();
                mLiveRoom.responseJoinAnchor(userInfo.userId, true, "");
            }
        });

        dialogFragment.setNegativeClickListener(new ConfirmDialogFragment.NegativeClickListener() {
            @Override
            public void onClick() {
                dialogFragment.dismiss();
                mLiveRoom.responseJoinAnchor(userInfo.userId, false, getString(R.string.trtcliveroom_anchor_refuse_link_request));
            }
        });
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                dialogFragment.show(getFragmentManager(), "ConfirmDialogFragment");
                mMainHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        dialogFragment.dismiss();
                    }
                }, timeout);
            }
        });
    }


    /**
     * 成员进退房事件信息处理
     */
    @Override
    protected void handleMemberJoinMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        //更新头像列表 返回false表明已存在相同用户，将不会更新数据
        if (mUserAvatarListAdapter.addItem(userInfo))
            super.handleMemberJoinMsg(userInfo);
        mTextMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentMemberCount));
    }

    @Override
    protected void handleMemberQuitMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        mUserAvatarListAdapter.removeItem(userInfo.userId);
        super.handleMemberQuitMsg(userInfo);
        mTextMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentMemberCount));
    }


    /**
     * 音乐控制面板相关
     */

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (null != mViewPKAnchorList && mViewPKAnchorList.getVisibility() != View.GONE && ev.getRawY() < mViewPKAnchorList.getTop()) {
            mViewPKAnchorList.setVisibility(View.GONE);
            mGroupLiveAfter.setVisibility(View.VISIBLE);
        }

        if (null != mPanelBeautyControl && mPanelBeautyControl.getVisibility() != View.GONE && ev.getRawY() < mPanelBeautyControl.getTop()) {
            mPanelBeautyControl.setVisibility(View.GONE);
            if (mIsEnterRoom) {
                mGroupLiveAfter.setVisibility(View.VISIBLE);
            } else {
                mGroupLiveBefore.setVisibility(View.VISIBLE);
            }
        }
        return super.dispatchTouchEvent(ev);
    }

    /**
     * 开启红点与计时动画
     */
    private void startRecordAnimation() {
        mAnimatorRecordBall = ObjectAnimator.ofFloat(mImageRecordBall, "alpha", 1f, 0f, 1f);
        mAnimatorRecordBall.setDuration(1000);
        mAnimatorRecordBall.setRepeatCount(-1);
        mAnimatorRecordBall.start();
    }

    /**
     * 关闭红点与计时动画
     */
    private void stopRecordAnimation() {
        if (null != mAnimatorRecordBall)
            mAnimatorRecordBall.cancel();
    }

    @Override
    protected void onBroadcasterTimeUpdate(long second) {
        super.onBroadcasterTimeUpdate(second);
        mTextBroadcastTime.setText(TCUtils.formattedTime(second));
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_close) {
            if (!mIsEnterRoom) {
                //如果没有进房，直接退出就好了
                finishRoom();
                return;
            }
            if (mCurrentStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                stopPK();
                mButtonExit.setText(R.string.trtcliveroom_btn_stop_live);
                return;
            }
            showExitInfoDialog(getString(R.string.trtcliveroom_warning_anchor_exit_room), false);
        } else if (id == R.id.btn_switch_camera) {
            if (mLiveRoom != null) {
                mLiveRoom.switchCamera();
            }
        } else if (id == R.id.btn_request_pk) {
            if (mCurrentStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                return;
            }
            if (mViewPKAnchorList.isShown()) {
                mViewPKAnchorList.setVisibility(View.GONE);
            } else {
                mViewPKAnchorList.setVisibility(View.VISIBLE);
                mPanelBeautyControl.setVisibility(View.GONE);
                mPanelAudioControl.dismiss();
                mGroupLiveAfter.setVisibility(View.GONE);
            }
        } else if (id == R.id.beauty_btn) {
            if (mPanelBeautyControl.isShown()) {
                mPanelBeautyControl.setVisibility(View.GONE);
            } else {
                mPanelBeautyControl.setVisibility(View.VISIBLE);
                mPanelAudioControl.dismiss();
                mGroupLiveAfter.setVisibility(View.GONE);
            }
        } else if (id == R.id.btn_audio_ctrl) {
            if (mPanelAudioControl.isShowing()) {
                mPanelAudioControl.dismiss();
                mGroupLiveAfter.setVisibility(View.VISIBLE);
            } else {
                mPanelAudioControl.show();
                mGroupLiveAfter.setVisibility(View.GONE);
                mPanelBeautyControl.setVisibility(View.GONE);
                mViewPKAnchorList.setVisibility(View.GONE);
            }
        } else if (id == R.id.btn_switch_cam_before_live) {
            if (mLiveRoom != null) {
                mLiveRoom.switchCamera();
            }
        } else if (id == R.id.btn_beauty_before_live) {
            if (mPanelBeautyControl.isShown()) {
                mPanelBeautyControl.setVisibility(View.GONE);
            } else {
                mPanelBeautyControl.setVisibility(View.VISIBLE);
                mGroupLiveBefore.setVisibility(View.GONE);
            }
        } else {
            super.onClick(v);
        }
    }

    private void stopPK() {
        mLiveRoom.quitRoomPK(null);
    }


    @Override
    protected void showErrorAndQuit(int errorCode, String errorMsg) {
        stopRecordAnimation();
        super.showErrorAndQuit(errorCode, errorMsg);
    }

    private void showLog() {
        mShowLog = !mShowLog;
        mLiveRoom.showVideoDebugLog(mShowLog);
        if (mTXCloudVideoView != null) {
            mTXCloudVideoView.showLog(mShowLog);
        }
        if (mVideoViewPKAnchor != null) {
            mVideoViewPKAnchor.showLog(mShowLog);
        }

        mVideoViewMgr.showLog(mShowLog);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case 100:
                for (int ret : grantResults) {
                    if (ret != PackageManager.PERMISSION_GRANTED) {
                        showErrorAndQuit(-1314, getString(R.string.trtcliveroom_fail_request_permission));
                        return;
                    }
                }
                this.enterRoom();
                break;
            default:
                break;
        }
    }
}
