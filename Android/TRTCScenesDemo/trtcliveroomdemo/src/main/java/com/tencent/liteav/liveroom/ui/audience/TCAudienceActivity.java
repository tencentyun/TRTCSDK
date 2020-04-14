package com.tencent.liteav.liveroom.ui.audience;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.constraint.ConstraintSet;
import android.support.constraint.Guideline;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.beauty.BeautyPanel;
import com.tencent.liteav.demo.beauty.BeautyParams;
import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.model.TRTCLiveRoom;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDelegate;
import com.tencent.liteav.liveroom.ui.common.adapter.TCUserAvatarListAdapter;
import com.tencent.liteav.liveroom.ui.common.msg.TCChatEntity;
import com.tencent.liteav.liveroom.ui.common.msg.TCChatMsgListAdapter;
import com.tencent.liteav.liveroom.ui.common.utils.TCConstants;
import com.tencent.liteav.liveroom.ui.common.utils.TCUtils;
import com.tencent.liteav.liveroom.ui.widget.InputTextMsgDialog;
import com.tencent.liteav.liveroom.ui.widget.beauty.LiveRoomBeautyKit;
import com.tencent.liteav.liveroom.ui.widget.danmaku.TCDanmuMgr;
import com.tencent.liteav.liveroom.ui.widget.like.TCHeartLayout;
import com.tencent.liteav.liveroom.ui.widget.video.TCVideoView;
import com.tencent.liteav.liveroom.ui.widget.video.TCVideoViewMgr;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.UserModel;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

import master.flame.danmaku.controller.IDanmakuView;

/**
 * Module:   TCAudienceActivity
 * <p>
 * Function: 观众观看界面
 * <p>
 * <p>
 * 1. MLVB 观众开始和停止观看主播：{@link TCAudienceActivity#enterRoom()} 和 {@link TCAudienceActivity#exitRoom()}
 * <p>
 * 2. MLVB 观众开始连麦和停止连麦：{@link TCAudienceActivity#startLinkMic()} 和 {@link TCAudienceActivity#stopLinkMic()}
 * <p>
 * 3. 房间消息、弹幕、点赞处理
 **/
public class TCAudienceActivity extends AppCompatActivity implements View.OnClickListener, InputTextMsgDialog.OnTextSendListener {
    private static final String TAG               = TCAudienceActivity.class.getSimpleName();
    //连麦间隔控制
    private static final long   LINK_MIC_INTERVAL = 3 * 1000;

    private Handler mHandler = new Handler(Looper.getMainLooper());


    private TXCloudVideoView mTXCloudVideoView;      // 观看大主播的 View
    private TRTCLiveRoom     mLiveRoom;              // MLVB 组件
    private ImageView        mBgImageView;

    // 消息相关
    private InputTextMsgDialog      mInputTextMsgDialog;    // 消息输入框
    private ListView                mListViewMsg;           // 消息列表控件
    private ArrayList<TCChatEntity> mArrayListChatEntity = new ArrayList<>(); // 消息列表集合
    private TCChatMsgListAdapter    mChatMsgListAdapter;    // 消息列表的Adapter

    //点赞动画
    private TCHeartLayout mHeartLayout;

    private ImageButton mBtnLinkMic;            // 连麦按钮
    private ImageButton mBtnSwitchCamera;       // 切换摄像头按钮
    private ImageView   mIvAvatar;              // 主播头像控件
    private TextView    mTvPusherName;          // 主播昵称控件
    private TextView    mMemberCount;           // 当前观众数量控件

    private String mPusherAvatar;          // 主播头像连接地址
    private long   mCurrentAudienceCount;  // 当前观众数量

    private boolean isEnterRoom  = false;       // 是否正在播放
    private boolean isUseCdnPlay = false;

    private String  mPusherNickname;        // 主播昵称
    private String  mPusherId;              // 主播id
    private boolean mIsPusherEnter = false; // 主播以及进房了
    private int     mRoomId        = 0;          // 房间id
    private String  mSelfUserId    = "";           // 我的id
    private String  mSelfNickname  = "";         // 我的昵称
    private String  mSelfAvatar    = "";           // 我的头像

    //头像列表控件
    private RecyclerView            mUserAvatarList;
    private TCUserAvatarListAdapter mAvatarListAdapter;

    //点赞频率控制
    private TCFrequeControl mLikeFrequeControl;

    //弹幕
    private TCDanmuMgr   mDanmuMgr;
    private IDanmakuView mDanmuView;

    //分享相关
    private String mCoverUrl = "";
    private String mTitle    = ""; //标题

    //log相关
    private boolean mShowLog;
    private boolean mIsBeingLinkMic = false;                    // 当前是否正在与主播连麦

    // 麦上主播相关
    private TCVideoViewMgr mVideoViewMgr;                      // 主播对应的视频View管理类

    //美颜
    private BeautyPanel mBeautyControl;

    private long mLastLinkMicTime;   // 上次发起连麦的时间，用于频率控制

    private AlertDialog mErrorDialog;

    private Guideline        mVGuideLine;
    private Guideline        mHGuideLine;
    private TXCloudVideoView mPKVideoView;
    private RelativeLayout   mPKContainer;
    private ConstraintLayout mConstraintLayout;
    private TextView         mAnchorLeaveTv;
    private int              mCurrentStatus = TRTCLiveRoomDef.ROOM_STATUS_NONE;
    private Runnable         mGetAudienceRunnable;

    //如果一定时间内主播没出现
    private Runnable mShowPusherLeave = new Runnable() {
        @Override
        public void run() {
            if (mAnchorLeaveTv != null) {
                mAnchorLeaveTv.setVisibility(mIsPusherEnter ? View.GONE : View.VISIBLE);
                mBgImageView.setVisibility(mIsPusherEnter ? View.GONE : View.VISIBLE);
            }
        }
    };

    // trtclive 监听
    private TRTCLiveRoomDelegate mTRTCLiveRoomDelegate = new TRTCLiveRoomDelegate() {
        @Override
        public void onError(int code, String message) {

        }

        @Override
        public void onWarning(int code, String message) {

        }

        @Override
        public void onDebugLog(String message) {

        }

        @Override
        public void onRoomInfoChange(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo) {
            int oldStatus = mCurrentStatus;
            mCurrentStatus = roomInfo.roomStatus;
            // 由于CDN模式下是只播放一路画面，所以不需要做画面的设置
            if (isUseCdnPlay) {
                return;
            }
            // 将PK的界面设置成左右两边
            // 将PK以外的界面设置成大画面
            setAnchorViewFull(mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK);
            Log.d(TAG, "onRoomInfoChange: " + mCurrentStatus);
            if (oldStatus == TRTCLiveRoomDef.ROOM_STATUS_PK
                    && mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK) {
                // 上一个状态是PK，需要将界面中的元素恢复
                TCVideoView videoView = mVideoViewMgr.getPKUserView();
                mPKVideoView = videoView.getPlayerVideo();
                if (mPKContainer.getChildCount() != 0) {
                    mPKContainer.removeView(mPKVideoView);
                    videoView.addView(mPKVideoView);
                    mVideoViewMgr.clearPKView();
                    mPKVideoView = null;
                }
            } else if (mCurrentStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                TCVideoView videoView = mVideoViewMgr.getPKUserView();
                mPKVideoView = videoView.getPlayerVideo();
                videoView.removeView(mPKVideoView);
                mPKContainer.addView(mPKVideoView);
            }
        }

        @Override
        public void onRoomDestroy(String roomId) {
            showErrorAndQuit(0, "房间已解散");
        }

        @Override
        public void onAnchorEnter(final String userId) {
            if (userId.equals(mPusherId)) {
                // 如果是大主播的画面
                mIsPusherEnter = true;
                mAnchorLeaveTv.setVisibility(View.GONE);
                mTXCloudVideoView.setVisibility(View.VISIBLE);
                mBgImageView.setVisibility(View.GONE);
                mLiveRoom.startPlay(userId, mTXCloudVideoView, new TRTCLiveRoomCallback.ActionCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (code != 0) {
                            onAnchorExit(userId);
                        }
                    }
                });
            } else {
                TCVideoView view = mVideoViewMgr.applyVideoView(userId);
                view.showKickoutBtn(false);
                mLiveRoom.startPlay(userId, view.getPlayerVideo(), null);
            }
        }

        @Override
        public void onAnchorExit(String userId) {
            if (userId.equals(mPusherId)) {
                mTXCloudVideoView.setVisibility(View.GONE);
                mBgImageView.setVisibility(View.VISIBLE);
                mAnchorLeaveTv.setVisibility(View.VISIBLE);
                mLiveRoom.stopPlay(userId, null);
            } else {
                // 这里PK也会回收，但是没关系，因为我们有保护
                mVideoViewMgr.recycleVideoView(userId);
                mLiveRoom.stopPlay(userId, null);
            }
        }

        @Override
        public void onAudienceEnter(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
            Log.d(TAG, "onAudienceEnter: " + userInfo);
            handleAudienceJoinMsg(userInfo);
        }

        @Override
        public void onAudienceExit(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
            Log.d(TAG, "onAudienceExit: " + userInfo);
            handleAudienceQuitMsg(userInfo);
        }

        @Override
        public void onRequestJoinAnchor(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String reason, int timeout) {

        }

        @Override
        public void onKickoutJoinAnchor() {
            ToastUtils.showLong("不好意思，您被主播踢开");
            stopLinkMic();
        }

        @Override
        public void onRequestRoomPK(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, int timeout) {

        }

        @Override
        public void onQuitRoomPK() {

        }

        @Override
        public void onRecvRoomTextMsg(String message, TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
            handleTextMsg(userInfo, message);
        }

        @Override
        public void onRecvRoomCustomMsg(String cmd, String message, TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
            int type = Integer.valueOf(cmd);
            switch (type) {
                case TCConstants.IMCMD_PRAISE:
                    handlePraiseMsg(userInfo);
                    break;
                case TCConstants.IMCMD_DANMU:
                    handleDanmuMsg(userInfo, message);
                    break;
                default:
                    break;
            }
        }
    };

    /**
     * 显示错误并且退出直播
     *
     * @param errorCode
     * @param errorMsg
     */
    protected void showErrorAndQuit(int errorCode, String errorMsg) {
        if (mErrorDialog == null) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this, R.style.LiveRoomDialogTheme)
                    .setTitle("错误")
                    .setMessage(errorMsg)
                    .setNegativeButton("知道了", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            mErrorDialog.dismiss();
                            exitRoom();
                            finish();
                        }
                    });

            mErrorDialog = builder.create();
        }
        if (mErrorDialog.isShowing()) {
            mErrorDialog.dismiss();
        }
        mErrorDialog.show();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(R.style.BeautyTheme);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.liveroom_activity_audience);

        Intent intent = getIntent();
        isUseCdnPlay = intent.getBooleanExtra(TCConstants.USE_CDN_PLAY, false);
        mRoomId = intent.getIntExtra(TCConstants.GROUP_ID, 0);
        mPusherId = intent.getStringExtra(TCConstants.PUSHER_ID);
        mPusherNickname = intent.getStringExtra(TCConstants.PUSHER_NAME);
        mCoverUrl = intent.getStringExtra(TCConstants.COVER_PIC);
        mPusherAvatar = intent.getStringExtra(TCConstants.PUSHER_AVATAR);

        UserModel userModel = ProfileManager.getInstance().getUserModel();
        mSelfNickname = userModel.userName;
        mSelfUserId = userModel.userId;
        mSelfAvatar = userModel.userAvatar;

        List<TCVideoView> videoViewList = new ArrayList<>();
        videoViewList.add((TCVideoView) findViewById(R.id.tcvideoview_1));
        videoViewList.add((TCVideoView) findViewById(R.id.tcvideoview_2));
        videoViewList.add((TCVideoView) findViewById(R.id.tcvideoview_3));
        mVideoViewMgr = new TCVideoViewMgr(videoViewList, null);

        // 初始化 liveRoom 组件
        mLiveRoom = TRTCLiveRoom.sharedInstance(this);
        mLiveRoom.setDelegate(mTRTCLiveRoomDelegate);

        initView();
        enterRoom();
        mHandler.postDelayed(mShowPusherLeave, 3000);
    }


    private void initView() {
        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.anchor_video_view);
        mTXCloudVideoView.setLogMargin(10, 10, 45, 55);
        mListViewMsg = (ListView) findViewById(R.id.im_msg_listview);
        mListViewMsg.setVisibility(View.VISIBLE);
        mHeartLayout = (TCHeartLayout) findViewById(R.id.heart_layout);
        mTvPusherName = (TextView) findViewById(R.id.anchor_tv_broadcasting_time);
        mTvPusherName.setText(TCUtils.getLimitString(mPusherNickname, 10));

        findViewById(R.id.anchor_iv_record_ball).setVisibility(View.GONE);

        mUserAvatarList = (RecyclerView) findViewById(R.id.anchor_rv_avatar);
        mUserAvatarList.setVisibility(View.VISIBLE);
        mAvatarListAdapter = new TCUserAvatarListAdapter(this, mPusherId);
        mUserAvatarList.setAdapter(mAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mUserAvatarList.setLayoutManager(linearLayoutManager);

        mInputTextMsgDialog = new InputTextMsgDialog(this, R.style.InputDialog);
        mInputTextMsgDialog.setmOnTextSendListener(this);

        mIvAvatar = (ImageView) findViewById(R.id.anchor_iv_head_icon);

        mIvAvatar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLog();
            }
        });

        mMemberCount = (TextView) findViewById(R.id.anchor_tv_member_counts);

        mCurrentAudienceCount++;
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentAudienceCount));
        mChatMsgListAdapter = new TCChatMsgListAdapter(this, mListViewMsg, mArrayListChatEntity);
        mListViewMsg.setAdapter(mChatMsgListAdapter);

        mDanmuView = (IDanmakuView) findViewById(R.id.anchor_danmaku_view);
        mDanmuView.setVisibility(View.VISIBLE);
        mDanmuMgr = new TCDanmuMgr(this);
        mDanmuMgr.setDanmakuView(mDanmuView);

        mBgImageView = (ImageView) findViewById(R.id.audience_background);
        mBgImageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
        TCUtils.showPicWithUrl(TCAudienceActivity.this
                , mBgImageView, mCoverUrl, R.drawable.bg_cover);

        mBtnLinkMic = (ImageButton) findViewById(R.id.audience_btn_linkmic);
        mBtnLinkMic.setVisibility(View.VISIBLE);
        mBtnLinkMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!mIsBeingLinkMic) {
                    long curTime = System.currentTimeMillis();
                    if (curTime < mLastLinkMicTime + LINK_MIC_INTERVAL) {
                        Toast.makeText(getApplicationContext(), "太频繁啦，休息一下！", Toast.LENGTH_SHORT).show();
                    } else {
                        mLastLinkMicTime = curTime;
                        startLinkMic();
                    }
                } else {
                    stopLinkMic();
                }
            }
        });

        mBtnSwitchCamera = (ImageButton) findViewById(R.id.audience_btn_switch_cam);
        mBtnSwitchCamera.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsBeingLinkMic) {
                    mLiveRoom.switchCamera();
                }
            }
        });

        //美颜功能
        mBeautyControl = (BeautyPanel) findViewById(R.id.beauty_panel);
        LiveRoomBeautyKit manager = new LiveRoomBeautyKit(mLiveRoom);
        mBeautyControl.setProxy(manager);

        mVGuideLine = (Guideline) findViewById(R.id.gl_v);
        mHGuideLine = (Guideline) findViewById(R.id.gl_h);
        mPKContainer = (RelativeLayout) findViewById(R.id.pk_container);
        mConstraintLayout = (ConstraintLayout) findViewById(R.id.cl_audience);
        TCUtils.showPicWithUrl(TCAudienceActivity.this, mIvAvatar, mPusherAvatar, R.drawable.bg_cover);
        mAnchorLeaveTv = (TextView) findViewById(R.id.tv_anchor_leave);
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

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      生命周期相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    protected void onResume() {
        super.onResume();
        if (mDanmuMgr != null) {
            mDanmuMgr.resume();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mDanmuMgr != null) {
            mDanmuMgr.pause();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mHandler.removeCallbacks(mGetAudienceRunnable);
        mHandler.removeCallbacks(mShowPusherLeave);
        if (mDanmuMgr != null) {
            mDanmuMgr.destroy();
            mDanmuMgr = null;
        }
        exitRoom();
        mVideoViewMgr.recycleVideoView();
        mVideoViewMgr = null;
        stopLinkMic();
        hideNoticeToast();
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      开始和停止播放相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    private void enterRoom() {
        if (isEnterRoom) {
            return;
        }
        mLiveRoom.enterRoom(mRoomId, new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    //进房成功
                    ToastUtils.showShort("进房成功");
                    isEnterRoom = true;
                    getAudienceList();
                } else {
                    ToastUtils.showLong("进房失败:" + code);
                    exitRoom();
                    finish();
                }
            }
        });
    }

    private void getAudienceList() {
        mGetAudienceRunnable = new Runnable() {
            @Override
            public void run() {
                mLiveRoom.getAudienceList(new TRTCLiveRoomCallback.UserListCallback() {
                    @Override
                    public void onCallback(int code, String msg, List<TRTCLiveRoomDef.TRTCLiveUserInfo> list) {
                        if (code == 0) {
                            for (TRTCLiveRoomDef.TRTCLiveUserInfo info : list) {
                                mAvatarListAdapter.addItem(info);
                            }
                            mCurrentAudienceCount += list.size();
                            mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentAudienceCount));
                        } else {
                            mHandler.postDelayed(mGetAudienceRunnable, 2000);
                        }
                    }
                });
            }
        };
        // 为了防止进房后立即获取列表不全，所以增加了一个延迟
        mHandler.postDelayed(mGetAudienceRunnable, 2000);
    }

    private void exitRoom() {
        if (isEnterRoom && mLiveRoom != null) {
            mLiveRoom.exitRoom(null);
            isEnterRoom = false;
        }
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      发起和结束连麦
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    private void startLinkMic() {
        if (!TCUtils.checkRecordPermission(TCAudienceActivity.this)) {
            showNoticeToast("请先打开摄像头与麦克风权限");
            return;
        }

        mBtnLinkMic.setEnabled(false);
        mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_off);

        showNoticeToast("等待主播接受......");


        mLiveRoom.requestJoinAnchor(mSelfUserId + "请求和您连麦", new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    // 接受请求
                    hideNoticeToast();
                    ToastUtils.showShort("主播接受了您的连麦请求，开始连麦");
                    joinPusher();
                    return;
                }
                if (code == -1) {
                    // 拒绝请求
                    ToastUtils.showShort(msg);
                } else {
                    //出现错误
                    ToastUtils.showShort("连麦请求发生错误，" + msg);
                }
                mBtnLinkMic.setEnabled(true);
                hideNoticeToast();
                mIsBeingLinkMic = false;
                mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_on);
            }
        });
    }

    private void joinPusher() {
        TCVideoView videoView = mVideoViewMgr.applyVideoView(mSelfUserId);

        BeautyParams beautyParams = new BeautyParams();
        mLiveRoom.getBeautyManager().setBeautyStyle(beautyParams.mBeautyStyle);
        mLiveRoom.getBeautyManager().setBeautyLevel(beautyParams.mBeautyLevel);
        mLiveRoom.getBeautyManager().setWhitenessLevel(beautyParams.mWhiteLevel);
        mLiveRoom.getBeautyManager().setRuddyLevel(beautyParams.mRuddyLevel);
        mLiveRoom.startCameraPreview(true, videoView.getPlayerVideo(), new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    mLiveRoom.startPublish(mSelfUserId + "_stream", new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {
                            if (code == 0) {
                                mBtnLinkMic.setEnabled(true);
                                mIsBeingLinkMic = true;
                                if (mBtnSwitchCamera != null) {
                                    mBtnSwitchCamera.setVisibility(View.VISIBLE);
                                }
                            } else {
                                stopLinkMic();
                                mBtnLinkMic.setEnabled(true);
                                mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_on);
                                Toast.makeText(TCAudienceActivity.this, "连麦失败：" + msg, Toast.LENGTH_SHORT).show();
                            }
                        }
                    });
                }
            }
        });
    }

    private void stopLinkMic() {
        mIsBeingLinkMic = false;
        //启用连麦Button
        if (mBtnLinkMic != null) {
            mBtnLinkMic.setEnabled(true);
            mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_on);
        }
        //隐藏切换摄像头Button
        if (mBtnSwitchCamera != null) {
            mBtnSwitchCamera.setVisibility(View.INVISIBLE);
        }
        // 停止
        mLiveRoom.stopCameraPreview();
        mLiveRoom.stopPublish(null);
        if (mVideoViewMgr != null) {
            mVideoViewMgr.recycleVideoView(mSelfUserId);
        }
    }

    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      接收到各类的消息的处理
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */

    /**
     * 观众进房消息
     *
     * @param userInfo
     */
    public void handleAudienceJoinMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        //更新头像列表 返回false表明已存在相同用户，将不会更新数据
        if (!mAvatarListAdapter.addItem(userInfo)) {
            return;
        }

        mCurrentAudienceCount++;
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentAudienceCount));
        //左下角显示用户加入消息
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.userName)) {
            entity.setContent(userInfo.userId + "加入直播");
        } else {
            entity.setContent(userInfo.userName + "加入直播");
        }
        entity.setType(TCConstants.MEMBER_ENTER);
        notifyMsg(entity);
    }

    /**
     * 观众退房消息
     *
     * @param userInfo
     */
    public void handleAudienceQuitMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        if (mCurrentAudienceCount > 0) {
            mCurrentAudienceCount--;
        } else {
            Log.d(TAG, "接受多次退出请求，目前人数为负数");
        }

        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentAudienceCount));

        mAvatarListAdapter.removeItem(userInfo.userId);

        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.userName)) {
            entity.setContent(userInfo.userId + "退出直播");
        } else {
            entity.setContent(userInfo.userName + "退出直播");
        }
        entity.setType(TCConstants.MEMBER_EXIT);
        notifyMsg(entity);
    }

    /**
     * 收到点赞消息
     *
     * @param userInfo
     */
    public void handlePraiseMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        TCChatEntity entity = new TCChatEntity();

        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.userName)) {
            entity.setContent(userInfo.userId + "点了个赞");
        } else {
            entity.setContent(userInfo.userName + "点了个赞");
        }
        if (mHeartLayout != null) {
            mHeartLayout.addFavor();
        }
        entity.setType(TCConstants.MEMBER_ENTER);
        notifyMsg(entity);
    }

    /**
     * 说到弹幕消息
     *
     * @param userInfo
     * @param text
     */
    public void handleDanmuMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String text) {
        handleTextMsg(userInfo, text);
        if (mDanmuMgr != null) {
            //这里暂时没有头像，所以用默认的一个头像链接代替
            mDanmuMgr.addDanmu(userInfo.userAvatar, userInfo.userName, text);
        }
    }

    /**
     * 收到文本消息
     *
     * @param userInfo
     * @param text
     */
    public void handleTextMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String text) {
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName(userInfo.userName);
        entity.setContent(text);
        entity.setType(TCConstants.TEXT_TYPE);
        notifyMsg(entity);
    }

    /**
     * 更新消息列表控件
     *
     * @param entity
     */
    private void notifyMsg(final TCChatEntity entity) {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mArrayListChatEntity.size() > 1000) {
                    while (mArrayListChatEntity.size() > 900) {
                        mArrayListChatEntity.remove(0);
                    }
                }

                mArrayListChatEntity.add(entity);
                mChatMsgListAdapter.notifyDataSetChanged();
            }
        });
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                       点击事件
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_close) {
            exitRoom();
            finish();
        } else if (id == R.id.btn_like) {
            if (mHeartLayout != null) {
                mHeartLayout.addFavor();
            }

            //点赞发送请求限制
            if (mLikeFrequeControl == null) {
                mLikeFrequeControl = new TCFrequeControl();
                mLikeFrequeControl.init(2, 1);
            }
            if (mLikeFrequeControl.canTrigger()) {
                //向ChatRoom发送点赞消息
                mLiveRoom.sendRoomCustomMsg(String.valueOf(TCConstants.IMCMD_PRAISE), "", null);
            }
        } else if (id == R.id.btn_message_input) {
            showInputMsgDialog();
        }
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
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                       消息输入与发送相关
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */

    /**
     * 发消息弹出框
     */
    private void showInputMsgDialog() {
        WindowManager              windowManager = getWindowManager();
        Display                    display       = windowManager.getDefaultDisplay();
        WindowManager.LayoutParams lp            = mInputTextMsgDialog.getWindow().getAttributes();

        lp.width = (display.getWidth()); //设置宽度
        mInputTextMsgDialog.getWindow().setAttributes(lp);
        mInputTextMsgDialog.setCancelable(true);
        mInputTextMsgDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        mInputTextMsgDialog.show();
    }

    /**
     * TextInputDialog发送回调
     *
     * @param msg       文本信息
     * @param danmuOpen 是否打开弹幕
     */
    @Override
    public void onTextSend(String msg, boolean danmuOpen) {
        if (msg.length() == 0) {
            return;
        }
        byte[] byte_num = msg.getBytes(StandardCharsets.UTF_8);
        if (byte_num.length > 160) {
            Toast.makeText(this, "请输入内容", Toast.LENGTH_SHORT).show();
            return;
        }

        //消息回显
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("我:");
        entity.setContent(msg);
        entity.setType(TCConstants.TEXT_TYPE);
        notifyMsg(entity);

        if (danmuOpen) {
            if (mDanmuMgr != null) {
                mDanmuMgr.addDanmu(mSelfAvatar, mSelfNickname, msg);
            }

            mLiveRoom.sendRoomCustomMsg(String.valueOf(TCConstants.IMCMD_DANMU), msg, new TRTCLiveRoomCallback.ActionCallback() {
                @Override
                public void onCallback(int code, String msg) {

                }
            });
        } else {
            mLiveRoom.sendRoomTextMsg(msg, new TRTCLiveRoomCallback.ActionCallback() {
                @Override
                public void onCallback(int code, String msg) {
                    if (code == 0) {
                        ToastUtils.showShort("发送成功");
                    } else {
                        ToastUtils.showShort("发送消息失败[" + code + "]" + msg);
                    }
                }
            });
        }
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      弹窗消息
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    private Toast mNoticeToast;
    private Timer mNoticeTimer;

    private void showNoticeToast(String text) {
        if (mNoticeToast == null) {
            mNoticeToast = Toast.makeText(getApplicationContext(), text, Toast.LENGTH_LONG);
        }

        if (mNoticeTimer == null) {
            mNoticeTimer = new Timer();
        }

        mNoticeToast.setText(text);
        mNoticeTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                mNoticeToast.show();
            }
        }, 0, 3000);
    }

    private void hideNoticeToast() {
        if (mNoticeToast != null) {
            mNoticeToast.cancel();
            mNoticeToast = null;
        }
        if (mNoticeTimer != null) {
            mNoticeTimer.cancel();
            mNoticeTimer = null;
        }
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      权限管理
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
                        return;
                    }
                }
                joinPusher();
                break;
            default:
                break;
        }
    }
}
