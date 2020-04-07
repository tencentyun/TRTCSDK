package com.tencent.liteav.liveroom.ui.anchor;

import android.animation.ObjectAnimator;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.constraint.ConstraintSet;
import android.support.constraint.Guideline;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.beauty.BeautyPanel;
import com.tencent.liteav.demo.beauty.BeautyParams;
import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.ui.anchor.music.TCAudioControl;
import com.tencent.liteav.liveroom.ui.common.adapter.TCUserAvatarListAdapter;
import com.tencent.liteav.liveroom.ui.common.utils.TCUtils;
import com.tencent.liteav.liveroom.ui.widget.beauty.LiveRoomBeautyKit;
import com.tencent.liteav.liveroom.ui.widget.video.TCVideoView;
import com.tencent.liteav.liveroom.ui.widget.video.TCVideoViewMgr;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import static com.tencent.liteav.liveroom.ui.anchor.music.TCAudioControl.REQUESTCODE;

/**
 * Module:   TCBaseAnchorActivity
 * <p>
 * Function: 主播推流的页面
 * <p>
 */
public class TCCameraAnchorActivity extends TCBaseAnchorActivity implements View.OnClickListener {
    private static final String TAG = TCCameraAnchorActivity.class.getSimpleName();

    private TXCloudVideoView mTXCloudVideoView;      // 主播本地预览的 View

    // 观众头像列表控件
    private RecyclerView            mUserAvatarList;        // 用户头像的列表控件
    private TCUserAvatarListAdapter mAvatarListAdapter;     // 头像列表的 Adapter

    // 主播信息
    private ImageView mHeadIcon;              // 主播头像
    private ImageView mRecordBall;            // 表明正在录制的红点球
    private TextView  mBroadcastTime;         // 已经开播的时间
    private TextView  mMemberCount;           // 观众数量

    //UI
    private Button           mPKButton;
    private ObjectAnimator   mObjAnim;               // 动画
    private TXCloudVideoView mPKVideoView;
    private RelativeLayout   mPKContainer;
    private Guideline        mVGuideLine;
    private Guideline        mHGuideLine;

    private TCAudioControl     mAudioCtrl;             // 音效控制面板
    private AnchorPKSelectView mAnchorPKSelectView; //PK选择

    private BeautyPanel mBeautyControl;          // 美颜设置的控制类

    // log相关
    private boolean mShowLog;               // 是否打开 log 面板

    private TCVideoViewMgr mVideoViewMgr;   // 主播视频列表的View
    private List<String>   mAnchorUserIdList = new ArrayList<>(); // 麦上主播对应的String(除了自己)
    private int            mCurrentStatus    = TRTCLiveRoomDef.ROOM_STATUS_NONE;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.BeautyTheme);
        super.onCreate(savedInstanceState);
        LiveRoomBeautyKit manager = new LiveRoomBeautyKit(mLiveRoom);
        mBeautyControl.setProxy(manager);
        // 清空上次的美颜参数
        mBeautyControl.clear();
        startPreview();
    }

    @Override
    public int getLayoutId() {
        return R.layout.liveroom_activity_anchor;
    }

    @Override
    protected void initView() {
        super.initView();
        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.anchor_video_view);
        mTXCloudVideoView.setLogMargin(10, 10, 45, 55);

        mPKContainer = (RelativeLayout) findViewById(R.id.pk_container);

        mUserAvatarList = (RecyclerView) findViewById(R.id.anchor_rv_avatar);
        mAvatarListAdapter = new TCUserAvatarListAdapter(this, mSelfUserId);
        mUserAvatarList.setAdapter(mAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mUserAvatarList.setLayoutManager(linearLayoutManager);

        mBroadcastTime = (TextView) findViewById(R.id.anchor_tv_broadcasting_time);
        mBroadcastTime.setText(String.format(Locale.US, "%s", "00:00:00"));
        mRecordBall = (ImageView) findViewById(R.id.anchor_iv_record_ball);

        mHeadIcon = (ImageView) findViewById(R.id.anchor_iv_head_icon);
        showHeadIcon(mHeadIcon, mSelfAvatar);

        mHeadIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLog();
            }
        });

        mMemberCount = (TextView) findViewById(R.id.anchor_tv_member_counts);
        mMemberCount.setText("0");
        mPKButton = (Button) findViewById(R.id.btn_request_pk);
        //AudioControl
        mAudioCtrl = (TCAudioControl) findViewById(R.id.anchor_audio_control);

        mBeautyControl = (BeautyPanel) findViewById(R.id.beauty_panel);

        // 监听踢出的回调
        List<TCVideoView> videoViews = new ArrayList<>();
        videoViews.add((TCVideoView) findViewById(R.id.tcvideoview_1));
        videoViews.add((TCVideoView) findViewById(R.id.tcvideoview_2));
        videoViews.add((TCVideoView) findViewById(R.id.tcvideoview_3));
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

        mAnchorPKSelectView = (AnchorPKSelectView) findViewById(R.id.anchor_pk_select_view);
        mAnchorPKSelectView.setSelfRoomId(mRoomId);
        mAnchorPKSelectView.setOnPKSelectedCallback(new AnchorPKSelectView.onPKSelectedCallback() {
            @Override
            public void onSelected(final TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo) {
                // 发起PK请求
                mAnchorPKSelectView.setVisibility(View.GONE);
                mLiveRoom.requestRoomPK(roomInfo.roomId, roomInfo.ownerId, new TRTCLiveRoomCallback.ActionCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (code == 0) {
                            ToastUtils.showShort("用户接受");
                        } else {
                            ToastUtils.showShort("用户拒绝:" + msg);
                        }
                    }
                });
            }
        });
        mVGuideLine = (Guideline) findViewById(R.id.gl_v);
        mHGuideLine = (Guideline) findViewById(R.id.gl_h);
        mAudioCtrl.setPusher(mLiveRoom);
    }

    /**
     * 加载主播头像
     *
     * @param view   view
     * @param avatar 头像链接
     */
    private void showHeadIcon(ImageView view, String avatar) {
        TCUtils.showPicWithUrl(this, view, avatar, R.drawable.bg_cover);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mMainHandler != null) {
            mMainHandler.removeCallbacksAndMessages(null);
        }
        stopRecordAnimation();
        mVideoViewMgr.recycleVideoView();
        mVideoViewMgr = null;
        if (mAudioCtrl != null) {
            mAudioCtrl.unInit();
            mAudioCtrl.setPusher(null);
            mAudioCtrl = null;
        }
    }

    protected void startPreview() {
        // 打开本地预览，传入预览的 View
        mTXCloudVideoView.setVisibility(View.VISIBLE);
        mLiveRoom.startCameraPreview(true, mTXCloudVideoView, null);
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      开始和停止推流相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
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
        startRecordAnimation();
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
        mBeautyControl.clear();
        mLiveRoom.stopCameraPreview();
        super.finishRoom();
    }

    private void setAnchorViewFull(boolean isFull) {
        if (isFull) {
            ConstraintSet set = new ConstraintSet();
            set.clone(mConstraintLayout);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.END, ConstraintSet.PARENT_ID, ConstraintSet.END);
            set.applyTo(mConstraintLayout);
        } else {
            ConstraintSet set = new ConstraintSet();
            set.clone(mConstraintLayout);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.BOTTOM, mHGuideLine.getId(), ConstraintSet.BOTTOM);
            set.connect(mTXCloudVideoView.getId(), ConstraintSet.END, mVGuideLine.getId(), ConstraintSet.END);
            set.applyTo(mConstraintLayout);
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
        super.onRoomInfoChange(roomInfo);
        int oldStatus = mCurrentStatus;
        mCurrentStatus = roomInfo.roomStatus;
        setAnchorViewFull(mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK);
        Log.d(TAG, "onRoomInfoChange: " + mCurrentStatus);
        if (oldStatus == TRTCLiveRoomDef.ROOM_STATUS_PK
                && mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK) {
            // 上一个状态是PK，需要将界面中的元素恢复
            mPKButton.setBackgroundResource(R.drawable.pk_start);
            TCVideoView videoView = mVideoViewMgr.getPKUserView();
            mPKVideoView = videoView.getPlayerVideo();
            if (mPKContainer.getChildCount() != 0) {
                mPKContainer.removeView(mPKVideoView);
                videoView.addView(mPKVideoView);
                mVideoViewMgr.clearPKView();
                mPKVideoView = null;
            }
        } else if (mCurrentStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
            // 本次状态是PK，需要将一个PK的view挪到右上角
            mPKButton.setBackgroundResource(R.drawable.pk_stop);
            TCVideoView videoView = mVideoViewMgr.getPKUserView();
            videoView.showKickoutBtn(false);
            mPKVideoView = videoView.getPlayerVideo();
            videoView.removeView(mPKVideoView);
            mPKContainer.addView(mPKVideoView);
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
        final AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setCancelable(true)
                .setTitle("提示")
                .setMessage(userInfo.userName + "向您发起PK请求")
                .setPositiveButton("接受", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        mLiveRoom.responseRoomPK(userInfo.userId, true, "");
                    }
                })
                .setNegativeButton("拒绝", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        mLiveRoom.responseRoomPK(userInfo.userId, false, "主播拒绝了您的PK请求");
                    }
                });

        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                final AlertDialog alertDialog = builder.create();
                alertDialog.setCancelable(false);
                alertDialog.setCanceledOnTouchOutside(false);
                alertDialog.show();

                mMainHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        alertDialog.dismiss();
                    }
                }, timeout);
            }
        });
    }

    @Override
    public void onQuitRoomPK() {
        ToastUtils.showShort("onQuitRoomPK:");
    }

    @Override
    public void onRequestJoinAnchor(final TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String reason, final int timeout) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setCancelable(true)
                .setTitle("提示")
                .setMessage(userInfo.userName + "向您发起连麦请求")
                .setPositiveButton("接受", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        mLiveRoom.responseJoinAnchor(userInfo.userId, true, "");
                    }
                })
                .setNegativeButton("拒绝", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mLiveRoom.responseJoinAnchor(userInfo.userId, false, "主播拒绝了您的连麦请求");
                        dialog.dismiss();
                    }
                });

        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mAnchorUserIdList.size() >= 3) {
                    mLiveRoom.responseJoinAnchor(userInfo.userId, false, "主播端连麦人数超过最大限制");
                    return;
                }

                final AlertDialog alertDialog = builder.create();
                alertDialog.setCancelable(false);
                alertDialog.setCanceledOnTouchOutside(false);
                alertDialog.show();

                mMainHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        alertDialog.dismiss();
                    }
                }, timeout);
            }
        });
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      成员进退房事件信息处理
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    protected void handleMemberJoinMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        //更新头像列表 返回false表明已存在相同用户，将不会更新数据
        if (mAvatarListAdapter.addItem(userInfo))
            super.handleMemberJoinMsg(userInfo);
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentMemberCount));
    }

    @Override
    protected void handleMemberQuitMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        mAvatarListAdapter.removeItem(userInfo.userId);
        super.handleMemberQuitMsg(userInfo);
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentMemberCount));
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      音乐控制面板相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (null != mAudioCtrl && mAudioCtrl.getVisibility() != View.GONE && ev.getRawY() < mAudioCtrl.getTop()) {
            mAudioCtrl.setVisibility(View.GONE);
        }
        return super.dispatchTouchEvent(ev);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        /** attention to this below ,must add this**/
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK) {//是否选择，没选择就不会继续
            if (requestCode == REQUESTCODE) {
                if (data == null) {
                    Log.e(TAG, "null data");
                } else {
                    Uri uri = data.getData();//得到uri，后面就是将uri转化成file的过程。
                    if (mAudioCtrl != null) {
                        mAudioCtrl.processActivityResult(uri);
                    } else {
                        Log.e(TAG, "NULL Pointer! Get Music Failed");
                    }
                }
            }
        }
    }


    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      界面动画与时长统计
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */
    /**
     * 开启红点与计时动画
     */
    private void startRecordAnimation() {
        mObjAnim = ObjectAnimator.ofFloat(mRecordBall, "alpha", 1f, 0f, 1f);
        mObjAnim.setDuration(1000);
        mObjAnim.setRepeatCount(-1);
        mObjAnim.start();
    }

    /**
     * 关闭红点与计时动画
     */
    private void stopRecordAnimation() {
        if (null != mObjAnim)
            mObjAnim.cancel();
    }

    @Override
    protected void onBroadcasterTimeUpdate(long second) {
        super.onBroadcasterTimeUpdate(second);
        mBroadcastTime.setText(TCUtils.formattedTime(second));
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      点击事件与调用函数相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.switch_cam) {
            if (mLiveRoom != null) {
                mLiveRoom.switchCamera();
            }
        } else if (id == R.id.btn_request_pk) {
            if (mCurrentStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                mPKButton.setBackgroundResource(R.drawable.pk_start);
                stopPK();
                return;
            }
            if (mAnchorPKSelectView.isShown()) {
                mAnchorPKSelectView.setVisibility(View.GONE);
            } else {
                mAnchorPKSelectView.setVisibility(View.VISIBLE);
                mBeautyControl.setVisibility(View.GONE);
                mAudioCtrl.setVisibility(View.GONE);
            }
        } else if (id == R.id.beauty_btn) {
            if (mBeautyControl.isShown()) {
                mBeautyControl.setVisibility(View.GONE);
            } else {
                mBeautyControl.setVisibility(View.VISIBLE);
                mAnchorPKSelectView.setVisibility(View.GONE);
                mAudioCtrl.setVisibility(View.GONE);
            }
        } else if (id == R.id.btn_audio_ctrl) {
            if (mAudioCtrl.isShown()) {
                mAudioCtrl.setVisibility(View.GONE);
            } else {
                mAudioCtrl.setVisibility(View.VISIBLE);
                mBeautyControl.setVisibility(View.GONE);
                mAnchorPKSelectView.setVisibility(View.GONE);
            }
        } else if (id == R.id.btn_switch_cam_before_live) {
            if (mLiveRoom != null) {
                mLiveRoom.switchCamera();
            }
        } else if (id == R.id.btn_beauty_before_live) {
            if (mBeautyControl.isShown()) {
                mBeautyControl.setVisibility(View.GONE);
            } else {
                mBeautyControl.setVisibility(View.VISIBLE);
                mAnchorPKSelectView.setVisibility(View.GONE);
                mAudioCtrl.setVisibility(View.GONE);
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
        if (mPKVideoView != null) {
            mPKVideoView.showLog(mShowLog);
        }

        mVideoViewMgr.showLog(mShowLog);
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      权限相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case 100:
                for (int ret : grantResults) {
                    if (ret != PackageManager.PERMISSION_GRANTED) {
                        showErrorAndQuit(-1314, "获取权限失败");
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
