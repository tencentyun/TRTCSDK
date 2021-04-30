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
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.beauty.view.BeautyPanel;
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
import com.tencent.liteav.liveroom.ui.widget.danmaku.TCDanmuMgr;
import com.tencent.liteav.liveroom.ui.widget.like.TCHeartLayout;
import com.tencent.liteav.liveroom.ui.widget.video.TCVideoView;
import com.tencent.liteav.liveroom.ui.widget.video.TCVideoViewMgr;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.model.UserModel;
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

    private static final long   LINK_MIC_INTERVAL = 3 * 1000;    //连麦间隔控制

    private Handler mHandler = new Handler(Looper.getMainLooper());

    private ConstraintLayout            mRootView;              // 当前Windows的Root View
    private TXCloudVideoView            mVideoViewAnchor;       // 显示大主播视频的View
    private TXCloudVideoView            mVideoViewPKAnchor;     // 显示PK主播视频的View
    private Guideline                   mGuideLineVertical;     // ConstraintLayout的垂直参考线
    private Guideline                   mGuideLineHorizontal;   // ConstraintLayout的水平参考线
    private TextView                    mTextAnchorLeave;       // 主播不在线时的提示文本
    private ImageView                   mImageBackground;       // 主播不在线时的背景显示
    private InputTextMsgDialog          mInputTextMsgDialog;    // 消息输入框
    private ListView                    mListIMMessage;         // 显示所有消息的列表控件
    private TCHeartLayout               mHeartLayout;           // 点赞后心形显示心形图案的布局&控制类
    private Button                      mButtonLinkMic;         // 连麦按钮
    private Button                      mButtonSwitchCamera;    // 切换摄像头按钮
    private ImageView                   mImageAnchorAvatar;     // 显示房间主播头像
    private TextView                    mTextAnchorName;        // 显示房间主播昵称
    private TextView                    mMemberCount;           // 显示当前观众数量控件
    private RecyclerView                mRecyclerUserAvatar;    // 显示观众头像的列表控件
    private AlertDialog                 mDialogError;           // 错误提示的Dialog
    private IDanmakuView                mDanmuView;             // 负责弹幕的显示
    private TCDanmuMgr                  mDanmuMgr;              // 弹幕的管理类
    private TCVideoViewMgr              mVideoViewMgr;          // 连麦时观众的视频窗口管理类
    private BeautyPanel                 mBeautyControl;         // 美颜的控制面板
    private RelativeLayout              mPKContainer;
    private Toast                       mToastNotice;
    private Timer                       mNoticeTimer;
    private TCChatMsgListAdapter        mChatMsgListAdapter;    // mListIMMessage的适配器
    private TCUserAvatarListAdapter     mUserAvatarListAdapter; // mUserAvatarList的适配器
    private TRTCLiveRoom                mLiveRoom;              // MLVB 组件
    private TCLikeFrequencyControl      mLikeFrequencyControl;  //点赞频率的控制类
    private ArrayList<TCChatEntity>     mArrayListChatEntity = new ArrayList<>();   // 消息列表集合

    private boolean     mShowLog;
    private long        mLastLinkMicTime;            // 上次发起连麦的时间，用于频率控制
    private long        mCurrentAudienceCount;       // 当前观众数量
    private boolean     isEnterRoom      = false;    // 表示当前是否已经进房成功
    private boolean     isUseCDNPlay     = false;    // 表示当前是否是CDN模式
    private boolean     mIsAnchorEnter   = false;    // 表示主播是否已经进房
    private boolean     mIsBeingLinkMic  = false;    // 表示当前是否在连麦状态
    private int         mRoomId          = 0;
    private int         mCurrentStatus = TRTCLiveRoomDef.ROOM_STATUS_NONE;
    private String      mAnchorAvatarURL;            // 主播头像连接地址
    private String      mAnchorNickname;             // 主播昵称
    private String      mAnchorId;                   // 主播id
    private String      mSelfUserId      = "";       // 我的id
    private String      mSelfNickname    = "";       // 我的昵称
    private String      mSelfAvatar      = "";       // 我的头像
    private String      mCoverUrl        = "";       // 房间的背景图的URL
    private Runnable    mGetAudienceRunnable;

    //如果一定时间内主播没出现
    private Runnable mShowAnchorLeave = new Runnable() {
        @Override
        public void run() {
            if (mTextAnchorLeave != null) {
                mTextAnchorLeave.setVisibility(mIsAnchorEnter ? View.GONE : View.VISIBLE);
                mImageBackground.setVisibility(mIsAnchorEnter ? View.GONE : View.VISIBLE);
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
            if (isUseCDNPlay) {
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
                mVideoViewPKAnchor = videoView.getPlayerVideo();
                if (mPKContainer.getChildCount() != 0) {
                    mPKContainer.removeView(mVideoViewPKAnchor);
                    videoView.addView(mVideoViewPKAnchor);
                    mVideoViewMgr.clearPKView();
                    mVideoViewPKAnchor = null;
                }
            } else if (mCurrentStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                TCVideoView videoView = mVideoViewMgr.getPKUserView();
                mVideoViewPKAnchor = videoView.getPlayerVideo();
                videoView.removeView(mVideoViewPKAnchor);
                mPKContainer.addView(mVideoViewPKAnchor);
            }
        }

        @Override
        public void onRoomDestroy(String roomId) {
            showErrorAndQuit(0, getString(R.string.trtcliveroom_warning_room_disband));
        }

        @Override
        public void onAnchorEnter(final String userId) {
            if (userId.equals(mAnchorId)) {
                // 如果是大主播的画面
                mIsAnchorEnter = true;
                mTextAnchorLeave.setVisibility(View.GONE);
                mVideoViewAnchor.setVisibility(View.VISIBLE);
                mImageBackground.setVisibility(View.GONE);
                mLiveRoom.startPlay(userId, mVideoViewAnchor, new TRTCLiveRoomCallback.ActionCallback() {
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
            if (userId.equals(mAnchorId)) {
                mVideoViewAnchor.setVisibility(View.GONE);
                mImageBackground.setVisibility(View.VISIBLE);
                mTextAnchorLeave.setVisibility(View.VISIBLE);
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
            ToastUtils.showLong(R.string.trtcliveroom_warning_kick_out_by_anchor);
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
        if (mDialogError == null) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this, R.style.TRTCLiveRoomDialogTheme)
                    .setTitle(R.string.trtcliveroom_error)
                    .setMessage(errorMsg)
                    .setNegativeButton(R.string.trtcliveroom_ok, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            mDialogError.dismiss();
                            exitRoom();
                            finish();
                        }
                    });

            mDialogError = builder.create();
        }
        if (mDialogError.isShowing()) {
            mDialogError.dismiss();
        }
        mDialogError.show();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(R.style.TRTCLiveRoomBeautyTheme);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.trtcliveroom_activity_audience);

        Intent intent = getIntent();
        isUseCDNPlay = intent.getBooleanExtra(TCConstants.USE_CDN_PLAY, false);
        mRoomId = intent.getIntExtra(TCConstants.GROUP_ID, 0);
        mAnchorId = intent.getStringExtra(TCConstants.PUSHER_ID);
        mAnchorNickname = intent.getStringExtra(TCConstants.PUSHER_NAME);
        mCoverUrl = intent.getStringExtra(TCConstants.COVER_PIC);
        mAnchorAvatarURL = intent.getStringExtra(TCConstants.PUSHER_AVATAR);

        UserModel userModel = ProfileManager.getInstance().getUserModel();
        mSelfNickname = userModel.userName;
        mSelfUserId = userModel.userId;
        mSelfAvatar = userModel.userAvatar;

        List<TCVideoView> videoViewList = new ArrayList<>();
        videoViewList.add((TCVideoView) findViewById(R.id.video_view_link_mic_1));
        videoViewList.add((TCVideoView) findViewById(R.id.video_view_link_mic_2));
        videoViewList.add((TCVideoView) findViewById(R.id.video_view_link_mic_3));
        mVideoViewMgr = new TCVideoViewMgr(videoViewList, null);

        // 初始化 liveRoom 组件
        mLiveRoom = TRTCLiveRoom.sharedInstance(this);
        mLiveRoom.setDelegate(mTRTCLiveRoomDelegate);

        initView();
        enterRoom();
        mHandler.postDelayed(mShowAnchorLeave, 3000);
    }


    private void initView() {
        mVideoViewAnchor = (TXCloudVideoView) findViewById(R.id.video_view_anchor);
        mVideoViewAnchor.setLogMargin(10, 10, 45, 55);
        mListIMMessage = (ListView) findViewById(R.id.lv_im_msg);
        mListIMMessage.setVisibility(View.VISIBLE);
        mHeartLayout = (TCHeartLayout) findViewById(R.id.heart_layout);
        mTextAnchorName = (TextView) findViewById(R.id.tv_anchor_broadcasting_time);
        mTextAnchorName.setText(TCUtils.getLimitString(mAnchorNickname, 10));

        findViewById(R.id.iv_anchor_record_ball).setVisibility(View.GONE);

        mRecyclerUserAvatar = (RecyclerView) findViewById(R.id.rv_audience_avatar);
        mRecyclerUserAvatar.setVisibility(View.VISIBLE);
        mUserAvatarListAdapter = new TCUserAvatarListAdapter(this, mAnchorId);
        mRecyclerUserAvatar.setAdapter(mUserAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRecyclerUserAvatar.setLayoutManager(linearLayoutManager);

        mInputTextMsgDialog = new InputTextMsgDialog(this, R.style.TRTCLiveRoomInputDialog);
        mInputTextMsgDialog.setmOnTextSendListener(this);

        mImageAnchorAvatar = (ImageView) findViewById(R.id.iv_anchor_head);

        mImageAnchorAvatar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLog();
            }
        });

        mMemberCount = (TextView) findViewById(R.id.tv_room_member_counts);

        mCurrentAudienceCount++;
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentAudienceCount));
        mChatMsgListAdapter = new TCChatMsgListAdapter(this, mListIMMessage, mArrayListChatEntity);
        mListIMMessage.setAdapter(mChatMsgListAdapter);

        mDanmuView = (IDanmakuView) findViewById(R.id.anchor_danmaku_view);
        mDanmuView.setVisibility(View.VISIBLE);
        mDanmuMgr = new TCDanmuMgr(this);
        mDanmuMgr.setDanmakuView(mDanmuView);

        mImageBackground = (ImageView) findViewById(R.id.audience_background);
        mImageBackground.setScaleType(ImageView.ScaleType.CENTER_CROP);
        TCUtils.showPicWithUrl(TCAudienceActivity.this
                , mImageBackground, mCoverUrl, R.drawable.trtcliveroom_bg_cover);

        mButtonLinkMic = (Button) findViewById(R.id.audience_btn_linkmic);
        mButtonLinkMic.setVisibility(View.VISIBLE);
        mButtonLinkMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!mIsBeingLinkMic) {
                    long curTime = System.currentTimeMillis();
                    if (curTime < mLastLinkMicTime + LINK_MIC_INTERVAL) {
                        Toast.makeText(getApplicationContext(), R.string.trtcliveroom_tips_rest, Toast.LENGTH_SHORT).show();
                    } else {
                        mLastLinkMicTime = curTime;
                        startLinkMic();
                    }
                } else {
                    stopLinkMic();
                }
            }
        });

        mButtonSwitchCamera = (Button) findViewById(R.id.audience_btn_switch_cam);
        mButtonSwitchCamera.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsBeingLinkMic) {
                    mLiveRoom.switchCamera();
                }
            }
        });

        //美颜功能
        mBeautyControl = (BeautyPanel) findViewById(R.id.beauty_panel);
        mBeautyControl.setBeautyManager(mLiveRoom.getBeautyManager());

        mGuideLineVertical = (Guideline) findViewById(R.id.gl_vertical);
        mGuideLineHorizontal = (Guideline) findViewById(R.id.gl_horizontal);
        mPKContainer = (RelativeLayout) findViewById(R.id.pk_container);
        mRootView = (ConstraintLayout) findViewById(R.id.root);
        TCUtils.showPicWithUrl(TCAudienceActivity.this, mImageAnchorAvatar, mAnchorAvatarURL, R.drawable.trtcliveroom_bg_cover);
        mTextAnchorLeave = (TextView) findViewById(R.id.tv_anchor_leave);
    }

    private void setAnchorViewFull(boolean isFull) {
        if (isFull) {
            ConstraintSet set = new ConstraintSet();
            set.clone(mRootView);
            set.connect(mVideoViewAnchor.getId(), ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP);
            set.connect(mVideoViewAnchor.getId(), ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START);
            set.connect(mVideoViewAnchor.getId(), ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM);
            set.connect(mVideoViewAnchor.getId(), ConstraintSet.END, ConstraintSet.PARENT_ID, ConstraintSet.END);
            set.applyTo(mRootView);
        } else {
            ConstraintSet set = new ConstraintSet();
            set.clone(mRootView);
            set.connect(mVideoViewAnchor.getId(), ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP);
            set.connect(mVideoViewAnchor.getId(), ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START);
            set.connect(mVideoViewAnchor.getId(), ConstraintSet.BOTTOM, mGuideLineHorizontal.getId(), ConstraintSet.BOTTOM);
            set.connect(mVideoViewAnchor.getId(), ConstraintSet.END, mGuideLineVertical.getId(), ConstraintSet.END);
            set.applyTo(mRootView);
        }
    }

    /**
     * 生命周期相关
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
        mLiveRoom.showVideoDebugLog(false);
        mHandler.removeCallbacks(mGetAudienceRunnable);
        mHandler.removeCallbacks(mShowAnchorLeave);
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
     * 生命周期相关
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
                    ToastUtils.showShort(R.string.trtcliveroom_tips_enter_room_success);
                    isEnterRoom = true;
                    getAudienceList();
                } else {
                    ToastUtils.showLong(getString(R.string.trtcliveroom_tips_enter_room_fail, code));
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
                                mUserAvatarListAdapter.addItem(info);
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
     * 生命周期相关
     */
    private void startLinkMic() {
        if (!TCUtils.checkRecordPermission(TCAudienceActivity.this)) {
            showNoticeToast(getString(R.string.trtcliveroom_tips_start_camera_audio));
            return;
        }

        mButtonLinkMic.setEnabled(false);
        mButtonLinkMic.setBackgroundResource(R.drawable.trtcliveroom_linkmic_off);

        showNoticeToast(getString(R.string.trtcliveroom_wait_anchor_accept));

        mLiveRoom.requestJoinAnchor(getString(R.string.trtcliveroom_request_link_mic_anchor, mSelfUserId), new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    // 接受请求
                    hideNoticeToast();
                    ToastUtils.showShort(getString(R.string.trtcliveroom_anchor_accept_link_mic));
                    joinPusher();
                    return;
                }
                if (code == -1) {
                    // 拒绝请求
                    ToastUtils.showShort(msg);
                } else {
                    //出现错误
                    ToastUtils.showShort(getString(R.string.trtcliveroom_error_request_link_mic, msg));
                }
                mButtonLinkMic.setEnabled(true);
                hideNoticeToast();
                mIsBeingLinkMic = false;
                mButtonLinkMic.setBackgroundResource(R.drawable.trtcliveroom_linkmic_on);
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
                                mButtonLinkMic.setEnabled(true);
                                mIsBeingLinkMic = true;
                                if (mButtonSwitchCamera != null) {
                                    mButtonSwitchCamera.setVisibility(View.VISIBLE);
                                }
                            } else {
                                stopLinkMic();
                                mButtonLinkMic.setEnabled(true);
                                mButtonLinkMic.setBackgroundResource(R.drawable.trtcliveroom_linkmic_on);
                                Toast.makeText(TCAudienceActivity.this, getString(R.string.trtcliveroom_fail_link_mic, msg), Toast.LENGTH_SHORT).show();
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
        if (mButtonLinkMic != null) {
            mButtonLinkMic.setEnabled(true);
            mButtonLinkMic.setBackgroundResource(R.drawable.trtcliveroom_linkmic_on);
        }
        //隐藏切换摄像头Button
        if (mButtonSwitchCamera != null) {
            mButtonSwitchCamera.setVisibility(View.INVISIBLE);
        }
        // 停止
        mLiveRoom.stopCameraPreview();
        mLiveRoom.stopPublish(null);
        if (mVideoViewMgr != null) {
            mVideoViewMgr.recycleVideoView(mSelfUserId);
        }
    }

    /**
     * 观众进房消息
     *
     * @param userInfo
     */
    public void handleAudienceJoinMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        //更新头像列表 返回false表明已存在相同用户，将不会更新数据
        if (!mUserAvatarListAdapter.addItem(userInfo)) {
            return;
        }

        mCurrentAudienceCount++;
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentAudienceCount));
        //左下角显示用户加入消息
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName(getString(R.string.trtcliveroom_notification));
        if (TextUtils.isEmpty(userInfo.userName)) {
            entity.setContent(getString(R.string.trtcliveroom_user_join_live, userInfo.userId));
        } else {
            entity.setContent(getString(R.string.trtcliveroom_user_join_live, userInfo.userName));
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

        mUserAvatarListAdapter.removeItem(userInfo.userId);

        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName(getString(R.string.trtcliveroom_notification));
        if (TextUtils.isEmpty(userInfo.userName)) {
            entity.setContent(getString(R.string.trtcliveroom_user_quit_live, userInfo.userId));
        } else {
            entity.setContent(getString(R.string.trtcliveroom_user_quit_live, userInfo.userName));
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

        entity.setSenderName(getString(R.string.trtcliveroom_notification));
        if (TextUtils.isEmpty(userInfo.userName)) {
            entity.setContent(getString(R.string.trtcliveroom_user_click_like, userInfo.userId));
        } else {
            entity.setContent(getString(R.string.trtcliveroom_user_click_like, userInfo.userName));
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
     * 点击事件
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
            if (mLikeFrequencyControl == null) {
                mLikeFrequencyControl = new TCLikeFrequencyControl();
                mLikeFrequencyControl.init(2, 1);
            }
            if (mLikeFrequencyControl.canTrigger()) {
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
        if (mVideoViewAnchor != null) {
            mVideoViewAnchor.showLog(mShowLog);
        }
        if (mVideoViewPKAnchor != null) {
            mVideoViewPKAnchor.showLog(mShowLog);
        }

        mVideoViewMgr.showLog(mShowLog);
    }


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
            Toast.makeText(this, R.string.trtcliveroom_tips_input_content, Toast.LENGTH_SHORT).show();
            return;
        }

        //消息回显
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName(getString(R.string.trtcliveroom_me));
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
                        ToastUtils.showShort(R.string.trtcliveroom_message_send_success);
                    } else {
                        ToastUtils.showShort(getString(R.string.trtcliveroom_message_send_fail, code, msg));
                    }
                }
            });
        }
    }


    private void showNoticeToast(String text) {
        if (mToastNotice == null) {
            mToastNotice = Toast.makeText(getApplicationContext(), text, Toast.LENGTH_LONG);
        }

        if (mNoticeTimer == null) {
            mNoticeTimer = new Timer();
        }

        mToastNotice.setText(text);
        mNoticeTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                mToastNotice.show();
            }
        }, 0, 3000);
    }

    private void hideNoticeToast() {
        if (mToastNotice != null) {
            mToastNotice.cancel();
            mToastNotice = null;
        }
        if (mNoticeTimer != null) {
            mNoticeTimer.cancel();
            mNoticeTimer = null;
        }
    }

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
