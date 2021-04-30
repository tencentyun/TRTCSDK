package com.tencent.liteav.meeting.ui;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.constraint.Group;
import android.support.v4.app.DialogFragment;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatImageButton;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.ViewStub;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.beauty.BeautyParams;
import com.tencent.liteav.demo.beauty.view.BeautyPanel;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.meeting.model.TRTCMeeting;
import com.tencent.liteav.meeting.model.TRTCMeetingCallback;
import com.tencent.liteav.meeting.model.TRTCMeetingDef;
import com.tencent.liteav.meeting.model.TRTCMeetingDelegate;
import com.tencent.liteav.meeting.ui.remote.RemoteUserListView;
import com.tencent.liteav.meeting.ui.utils.StateBarUtils;
import com.tencent.liteav.meeting.ui.widget.base.ConfirmDialogFragment;
import com.tencent.liteav.meeting.ui.widget.feature.FeatureConfig;
import com.tencent.liteav.meeting.ui.widget.feature.FeatureSettingFragmentDialog;
import com.tencent.liteav.meeting.ui.widget.page.MeetingPageLayoutManager;
import com.tencent.liteav.meeting.ui.widget.page.PagerSnapHelper;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.tencent.liteav.meeting.ui.widget.page.MeetingPageLayoutManager.HORIZONTAL;

public class MeetingMainActivity extends AppCompatActivity implements TRTCMeetingDelegate, View.OnClickListener {
    private static final String TAG = MeetingMainActivity.class.getName();

    public static final String KEY_ROOM_ID       = "room_id";
    public static final String KEY_USER_ID       = "user_id";
    public static final String KEY_USER_NAME     = "user_name";
    public static final String KEY_USER_AVATAR   = "user_avatar";
    public static final String KEY_OPEN_CAMERA   = "open_camera";
    public static final String KEY_OPEN_AUDIO    = "open_audio";
    public static final String KEY_AUDIO_QUALITY = "audio_quality";
    public static final String KEY_VIDEO_QUALITY = "video_quality";
    //    public static final  String TYPE_CREATE     = "create";
    //    private static final String KEY_ENTER_TYPE  = "start_type";
    //    private static final String TYPE_ENTER      = "enter";

    private int                       mRoomId;
    private String                    mUserId;
    private String                    mUserAvatar;
    private boolean                   mOpenCamera;
    private boolean                   mOpenAudio;
    private int                       mAudioQuality;
    private int                       mVideoQuality;
    private String                    mUserName;
    private boolean                   isCreating            = false;
    private boolean                   mIsUserEnterMuteAudio = false; //后续人员进入都进入静音模式
    private boolean                   isFrontCamera         = true;
    private boolean                   isUseSpeaker          = true;
    private TRTCMeeting               mTRTCMeeting;
    private List<MemberEntity>        mMemberEntityList;
    private MemberListAdapter         mMemberListAdapter;
    private Map<String, MemberEntity> mStringMemberEntityMap;

    private RecyclerView                 mListRv;
    private MeetingVideoView             mViewVideo;
    private FrameLayout                  mContainerFl;
    private MeetingHeadBarView           mMeetingHeadBarView;
    private BeautyPanel                  mBeautyControl;
    private AppCompatImageButton         mAudioImg;
    private AppCompatImageButton         mVideoImg;
    private AppCompatImageButton         mBeautyImg;
    private AppCompatImageButton         mMemberImg;
    private AppCompatImageButton         mScreenShareImg;
    private AppCompatImageButton         mMoreImg;
    private ViewStub                     mStubRemoteUserView;
    private RemoteUserListView           mRemoteUserView;
    private FeatureSettingFragmentDialog mFeatureSettingFragmentDialog; //更多设置面板
    private View                        mScreenCaptureGroup;
    private Group                        mBottomToolBarGroup;
    private TextView                     mStopScreenCaptureTv;
    private View                         mFloatingWindow;
    private List<MemberEntity>           mVisibleVideoStreams;
    private String                       mShowUserId = "";
    private boolean                      isScreenCapture;
    private Handler                      mHandler    = new Handler();


    public static void enterRoom(Context context,
                                 int roomId,
                                 String userId,
                                 String userName,
                                 String userAvatar,
                                 boolean openCamera,
                                 boolean openAudio,
                                 int audioQuality,
                                 int videoQuality) {
        Intent starter = new Intent(context, MeetingMainActivity.class);
        starter.putExtra(KEY_ROOM_ID, roomId);
        starter.putExtra(KEY_USER_ID, userId);
        starter.putExtra(KEY_USER_NAME, userName);
        starter.putExtra(KEY_USER_AVATAR, userAvatar);
        starter.putExtra(KEY_OPEN_CAMERA, openCamera);
        starter.putExtra(KEY_OPEN_AUDIO, openAudio);
        starter.putExtra(KEY_AUDIO_QUALITY, audioQuality);
        starter.putExtra(KEY_VIDEO_QUALITY, videoQuality);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        StateBarUtils.setDarkStatusBar(this);
        setContentView(R.layout.activity_meeting_main);
        initData();
        initView();
        startCreateOrEnterMeeting();
        ProfileManager.getInstance().checkNeedShowSecurityTips(MeetingMainActivity.this);
    }

    @Override
    public void onBackPressed() {
        if (mRemoteUserView != null && mRemoteUserView.isShown()) {
            mRemoteUserView.setVisibility(View.GONE);
            StateBarUtils.setDarkStatusBar(MeetingMainActivity.this);
            return;
        }
        preExitMeeting();
    }

    @Override
    protected void onDestroy() {
        hideFloatingWindow();
        mBeautyControl.clear();
        mTRTCMeeting.setDelegate(null);
        mTRTCMeeting.stopScreenCapture();
        mTRTCMeeting.stopCameraPreview();
        super.onDestroy();
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (null != mBeautyControl && mBeautyControl.getVisibility() != View.GONE && ev.getRawY() < mBeautyControl.getTop()) {
            mBeautyControl.setVisibility(View.GONE);
        }
        return super.dispatchTouchEvent(ev);
    }

    private void preExitMeeting() {
        String notifyMsg = "";
        if (isCreating) {
            notifyMsg = getString(R.string.meeting_msg_exit_meeting);
        } else {
            notifyMsg = getString(R.string.meeting_msg_confirm_exit_meeting);
        }
        showExitInfoDialog(notifyMsg, false);
    }

    private void exitMeetingConfirm() {
        if (isCreating) {
            mTRTCMeeting.destroyMeeting(mRoomId, null);
        } else {
            mTRTCMeeting.leaveMeeting(null);
        }
    }

    private void createMeeting() {
        mTRTCMeeting.createMeeting(mRoomId, new TRTCMeetingCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    // 创建房间成功
                    isCreating = true;
                    ToastUtils.showLong(getString(R.string.meeting_toast_create_meeting_successfully));
                    mMeetingHeadBarView.setTitle(String.valueOf(mRoomId));
                    changeResolution();
                    return;
                }
                isCreating = false;
                // 会议创建不成功，进入会议
                mTRTCMeeting.enterMeeting(mRoomId, new TRTCMeetingCallback.ActionCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (code != 0) {
                            // 进房失败
                            ToastUtils.showShort(msg);
                            finish();
                        }
                        changeResolution();
                        mMeetingHeadBarView.setTitle(String.valueOf(mRoomId));
                    }
                });
            }
        });
    }

    private void startCreateOrEnterMeeting() {
        //设置默认状态
        FeatureConfig.getInstance().setRecording(false);
        FeatureConfig.getInstance().setAudioVolumeEvaluation(true);
        mTRTCMeeting.setDelegate(this);
        mTRTCMeeting.setSelfProfile(mUserName, mUserAvatar, null);
        mMeetingHeadBarView.setTitle(getString(R.string.meeting_title_entering));
        createMeeting();
        // 根据外面传入的设置，选择是否打开相应的功能
        mTRTCMeeting.setAudioQuality(mAudioQuality);
        if (mOpenAudio) {
            mTRTCMeeting.startMicrophone();
        } else {
            mTRTCMeeting.stopMicrophone();
        }
        if (mOpenCamera) {
            mTRTCMeeting.startCameraPreview(isFrontCamera, mViewVideo.getLocalPreviewView());
        }
        initBeauty();
        mTRTCMeeting.setSpeaker(isUseSpeaker);
        mMeetingHeadBarView.setHeadsetImg(isUseSpeaker);
        mTRTCMeeting.enableAudioEvaluation(FeatureConfig.getInstance().isAudioVolumeEvaluation());
    }

    private void initBeauty() {
        BeautyParams beautyParams = new BeautyParams();
        mTRTCMeeting.getBeautyManager().setBeautyStyle(beautyParams.mBeautyStyle);
        mTRTCMeeting.getBeautyManager().setBeautyLevel(beautyParams.mBeautyLevel);
        mTRTCMeeting.getBeautyManager().setWhitenessLevel(beautyParams.mWhiteLevel);
        mTRTCMeeting.getBeautyManager().setRuddyLevel(beautyParams.mRuddyLevel);
    }

    private void initData() {
        mTRTCMeeting = TRTCMeeting.sharedInstance(this);
        mStringMemberEntityMap = new HashMap<>();
        mMemberEntityList = new ArrayList<>();
        //从外界获取数据源
        Intent starter = getIntent();
        mRoomId = starter.getIntExtra(KEY_ROOM_ID, 0);
        mUserId = starter.getStringExtra(KEY_USER_ID);
        mUserName = starter.getStringExtra(KEY_USER_NAME);
        mUserAvatar = starter.getStringExtra(KEY_USER_AVATAR);
        mOpenCamera = starter.getBooleanExtra(KEY_OPEN_CAMERA, true);
        mOpenAudio = starter.getBooleanExtra(KEY_OPEN_AUDIO, true);
        mAudioQuality = starter.getIntExtra(KEY_AUDIO_QUALITY, TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mVideoQuality = starter.getIntExtra(KEY_VIDEO_QUALITY, CreateMeetingActivity.VIDEO_QUALITY_FAST);

        //创建自己的 MemberEntity
        MemberEntity     entity           = new MemberEntity();
        MeetingVideoView meetingVideoView = new MeetingVideoView(this);
        meetingVideoView.setSelfView(true);
        meetingVideoView.setMeetingUserId(mUserId);
        meetingVideoView.setListener(mMeetingViewClick);
        meetingVideoView.setNeedAttach(true);
        entity.setMeetingVideoView(meetingVideoView);
        entity.setShowAudioEvaluation(FeatureConfig.getInstance().isAudioVolumeEvaluation());
        entity.setAudioAvailable(mOpenAudio);
        entity.setVideoAvailable(mOpenCamera);
        entity.setMuteAudio(false);
        entity.setMuteVideo(false);
        entity.setUserId(mUserId);
        entity.setUserName(mUserName);
        entity.setUserAvatar(mUserAvatar);
        addMemberEntity(entity);
    }

    private void initView() {
        mListRv = (RecyclerView) findViewById(R.id.rv_list);
        mViewVideo = mMemberEntityList.get(0).getMeetingVideoView();
        mContainerFl = (FrameLayout) findViewById(R.id.fl_container);

        mMemberListAdapter = new MemberListAdapter(this, mTRTCMeeting, mMemberEntityList, new MemberListAdapter.ListCallback() {
            @Override
            public void onItemClick(int position) {

            }

            @Override
            public void onItemDoubleClick(final int position) {
            }
        });

        mListRv.setHasFixedSize(true);
        MeetingPageLayoutManager pageLayoutManager = new MeetingPageLayoutManager(2, 2, HORIZONTAL);
        pageLayoutManager.setAllowContinuousScroll(false);
        pageLayoutManager.setPageListener(new MeetingPageLayoutManager.PageListener() {
            @Override
            public void onPageSizeChanged(int pageSize) {

            }

            @Override
            public void onPageSelect(int pageIndex) {

            }

            @Override
            public void onItemVisible(int fromItem, int toItem) {
                Log.d(TAG, "onItemVisible: " + fromItem + " to " + toItem);
                if (fromItem == 0) {
                    //第0个是自己的video，分开处理
                    processSelfVideoPlay();
                    processVideoPlay(1, toItem);
                } else {
                    processVideoPlay(fromItem, toItem);
                }
            }
        });
        mListRv.setLayoutManager(pageLayoutManager);
        mListRv.setAdapter(mMemberListAdapter);
        mListRv.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                Log.d(TAG, "onScrollStateChanged: " + newState);
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {

                }
            }
        });
        PagerSnapHelper pagerSnapHelper = new PagerSnapHelper();
        pagerSnapHelper.attachToRecyclerView(mListRv);
        mMeetingHeadBarView = (MeetingHeadBarView) findViewById(R.id.view_meeting_head_bar);
        mAudioImg = (AppCompatImageButton) findViewById(R.id.img_audio);
        mAudioImg.setOnClickListener(this);
        mVideoImg = (AppCompatImageButton) findViewById(R.id.img_video);
        mVideoImg.setOnClickListener(this);
        mBeautyImg = (AppCompatImageButton) findViewById(R.id.img_beauty);
        mBeautyImg.setOnClickListener(this);
        mMemberImg = (AppCompatImageButton) findViewById(R.id.img_member);
        mMemberImg.setOnClickListener(this);
        mScreenShareImg = (AppCompatImageButton) findViewById(R.id.img_screen_share);
        mScreenShareImg.setOnClickListener(this);
        mMoreImg = (AppCompatImageButton) findViewById(R.id.img_more);
        mMoreImg.setOnClickListener(this);
        mBeautyControl = (BeautyPanel) findViewById(R.id.beauty_panel);
        mBeautyControl.setBeautyManager(mTRTCMeeting.getBeautyManager());
        mStubRemoteUserView = (ViewStub) findViewById(R.id.view_stub_remote_user);
        mFeatureSettingFragmentDialog = new FeatureSettingFragmentDialog();
        mFeatureSettingFragmentDialog.setTRTCMeeting(mTRTCMeeting);
        // 设置界面UI
        mVideoImg.setSelected(mOpenCamera);
        mAudioImg.setSelected(mOpenAudio);
        mMeetingHeadBarView.setTitle(String.valueOf(mRoomId));
        mMeetingHeadBarView.setHeadBarCallback(new MeetingHeadBarView.HeadBarCallback() {
            @Override
            public void onHeadSetClick() {
                isUseSpeaker = !isUseSpeaker;
                mTRTCMeeting.setSpeaker(isUseSpeaker);
                mMeetingHeadBarView.setHeadsetImg(isUseSpeaker);
            }

            @Override
            public void onSwitchCameraClick() {
                isFrontCamera = !isFrontCamera;
                mTRTCMeeting.switchCamera(isFrontCamera);
            }

            @Override
            public void onExitClick() {
                preExitMeeting();
            }
        });
        mScreenCaptureGroup = findViewById(R.id.group_screen_capture);
        mBottomToolBarGroup = (Group) findViewById(R.id.group_bottom_tool_bar);
        mStopScreenCaptureTv = (TextView) findViewById(R.id.tv_stop_screen_capture);

        // 注册本地变更的通知
        IntentFilter intentFilter = new IntentFilter(FeatureConfig.AUDIO_EVALUATION_CHANGED);
        LocalBroadcastManager.getInstance(this).registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                boolean isAudioVolumeEvaluationShow = FeatureConfig.getInstance().isAudioVolumeEvaluation();
                for (MemberEntity entity : mMemberEntityList) {
                    entity.setShowAudioEvaluation(isAudioVolumeEvaluationShow);
                }
                mMemberListAdapter.notifyItemRangeChanged(0, mMemberEntityList.size(), MemberListAdapter.VOLUME_SHOW);
            }
        }, intentFilter);
    }

    private void processSelfVideoPlay() {
        if (mMemberEntityList.get(0).isShowOutSide()) {
            return;
        }
        MeetingVideoView meetingVideoView = mMemberEntityList.get(0).getMeetingVideoView();
        meetingVideoView.refreshParent();
    }

    /**
     * 处理页面中需要展示的item
     * 如果滑动到新的页面，旧的页面所有item需要停止播放
     * 新的页面根据是否打开了video来判断需要播放页面
     *
     * @param fromItem
     * @param toItem
     */
    private void processVideoPlay(int fromItem, int toItem) {
        List<String>       oldUserIds       = new ArrayList<>();
        List<String>       newUserIds       = new ArrayList<>();
        List<String>       needStopIds      = new ArrayList<>();
        List<MemberEntity> newVisibleStream = new ArrayList<>();
        if (mVisibleVideoStreams == null) {
            mVisibleVideoStreams = new ArrayList<>();
        }
        for (int i = fromItem; i <= toItem; i++) {
            newUserIds.add(mMemberEntityList.get(i).getUserId());
            newVisibleStream.add(mMemberEntityList.get(i));
        }
        for (MemberEntity entity : mVisibleVideoStreams) {
            oldUserIds.add(entity.getUserId());
            if (!newUserIds.contains(entity.getUserId())) {
                needStopIds.add(entity.getUserId());
            }
        }
        for (MemberEntity entity : newVisibleStream) {
            if (entity.isShowOutSide()) {
                continue;
            }
            MeetingVideoView meetingVideoView = entity.getMeetingVideoView();
            meetingVideoView.refreshParent();
            if (entity.isNeedFresh()) {
                entity.setNeedFresh(false);
                if (!entity.isMuteVideo() && entity.isVideoAvailable()) {
                    meetingVideoView.setPlaying(true);
                    mTRTCMeeting.startRemoteView(entity.getUserId(), entity.getMeetingVideoView().getPlayVideoView(), null);
                } else {
                    if (meetingVideoView.isPlaying()) {
                        meetingVideoView.setPlaying(false);
                        mTRTCMeeting.stopRemoteView(entity.getUserId(), null);
                    }
                }
                continue;
            }
            if (!oldUserIds.contains(entity.getUserId())) {
                if (!entity.isMuteVideo() && entity.isVideoAvailable()) {
                    if (!meetingVideoView.isPlaying()) {
                        meetingVideoView.setPlaying(true);
                        mTRTCMeeting.startRemoteView(entity.getUserId(), entity.getMeetingVideoView().getPlayVideoView(), null);
                        meetingVideoView.refreshParent();
                    }
                } else {
                    if (meetingVideoView.isPlaying()) {
                        meetingVideoView.setPlaying(false);
                        mTRTCMeeting.stopRemoteView(entity.getUserId(), null);
                    }
                }
            } else {
                if (entity.isMuteVideo() || !entity.isVideoAvailable()) {
                    if (meetingVideoView.isPlaying()) {
                        meetingVideoView.setPlaying(false);
                        mTRTCMeeting.stopRemoteView(entity.getUserId(), null);
                    }
                }
            }
        }
        for (String id : needStopIds) {
            MemberEntity entity = mStringMemberEntityMap.get(id);
            if (entity != null) {
                entity.getMeetingVideoView().setPlayingWithoutSetVisible(false);
            }
            mTRTCMeeting.stopRemoteView(id, null);
        }
        mVisibleVideoStreams = newVisibleStream;
    }

    @Override
    public void onError(int code, String message) {
        if (code == -1308) {
            ToastUtils.showLong(getString(R.string.meeting_toast_start_screen_recording_failed));
            stopScreenCapture();
        } else {
            ToastUtils.showLong(getString(R.string.meeting_toast_error, code, message));
            finish();
        }
    }

    @Override
    public void onRoomDestroy(String roomId) {
        if (String.valueOf(mRoomId).equals(roomId)) {
            ToastUtils.showShort(getString(R.string.meeting_toast_end_meeting));
            finish();
        }
    }

    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, List<TRTCCloudDef.TRTCQuality> remoteQuality) {
        Log.d(TAG, "onNetworkQuality: ");
        matchQuality(localQuality, mStringMemberEntityMap.get(mUserId));
        for (TRTCCloudDef.TRTCQuality quality : remoteQuality) {
            matchQuality(quality, mStringMemberEntityMap.get(quality.userId));
        }
    }

    private void matchQuality(TRTCCloudDef.TRTCQuality trtcQuality, MemberEntity entity) {
        if (entity == null) {
            return;
        }
        int oldQulity = entity.getQuality();
        switch (trtcQuality.quality) {
            case TRTCCloudDef.TRTC_QUALITY_Excellent:
            case TRTCCloudDef.TRTC_QUALITY_Good:
                entity.setQuality(MemberEntity.QUALITY_GOOD);
                break;
            case TRTCCloudDef.TRTC_QUALITY_Poor:
            case TRTCCloudDef.TRTC_QUALITY_Bad:
                entity.setQuality(MemberEntity.QUALITY_NORMAL);
                break;
            case TRTCCloudDef.TRTC_QUALITY_Vbad:
            case TRTCCloudDef.TRTC_QUALITY_Down:
                entity.setQuality(MemberEntity.QUALITY_BAD);
                break;
            default:
                entity.setQuality(MemberEntity.QUALITY_NORMAL);
                break;
        }
        if (oldQulity != entity.getQuality()) {
            mMemberListAdapter.notifyItemChanged(mMemberEntityList.indexOf(entity), MemberListAdapter.QUALITY);
        }
    }

    @Override
    public void onUserVolumeUpdate(String userId, int volume) {
        if (!FeatureConfig.getInstance().isAudioVolumeEvaluation()) {
            return;
        }
        if (userId == null) {
            userId = mUserId;
        }
        MemberEntity memberEntity = mStringMemberEntityMap.get(userId);
        if (memberEntity != null) {
            memberEntity.setAudioVolume(volume);
            mMemberListAdapter.notifyItemChanged(mMemberEntityList.indexOf(memberEntity), MemberListAdapter.VOLUME);
        }
    }

    @Override
    public void onUserEnterRoom(final String userId) {
        final int              insertIndex      = mMemberEntityList.size();
        final MemberEntity     entity           = new MemberEntity();
        final MeetingVideoView meetingVideoView = new MeetingVideoView(this);
        meetingVideoView.setMeetingUserId(userId);
        meetingVideoView.setNeedAttach(false);
        meetingVideoView.setListener(mMeetingViewClick);
        entity.setUserId(userId);
        entity.setMeetingVideoView(meetingVideoView);
        entity.setMuteAudio(mIsUserEnterMuteAudio);
        entity.setMuteVideo(false);
        entity.setVideoAvailable(false);
        entity.setAudioAvailable(false);
        entity.setShowAudioEvaluation(FeatureConfig.getInstance().isAudioVolumeEvaluation());
        addMemberEntity(entity);
        changeResolution();
        mMemberListAdapter.notifyItemInserted(insertIndex);
        if (mRemoteUserView != null) {
            mRemoteUserView.notifyDataSetChanged();
        }
        mTRTCMeeting.muteRemoteAudio(userId, mIsUserEnterMuteAudio);
        mTRTCMeeting.getUserInfo(userId, new TRTCMeetingCallback.UserListCallback() {
            @Override
            public void onCallback(int code, String msg, List<TRTCMeetingDef.UserInfo> list) {
                if (code == 0 && list != null && list.size() != 0) {
                    entity.setUserName(list.get(0).userName);
                    entity.setUserAvatar(list.get(0).userAvatar);
                    mMemberListAdapter.notifyItemChanged(mMemberEntityList.indexOf(entity));
                }
            }
        });
    }

    private void changeResolution() {
        if (isScreenCapture) {
            return;
        }
        if (mVideoQuality == CreateMeetingActivity.VIDEO_QUALITY_HD) {
            TRTCCloudDef.TRTCNetworkQosParam qosParam = new TRTCCloudDef.TRTCNetworkQosParam();
            qosParam.preference = TRTCCloudDef.TRTC_VIDEO_QOS_PREFERENCE_CLEAR;
            mTRTCMeeting.setNetworkQosParam(qosParam);
            if (mMemberEntityList.size() <= 2) {
                mTRTCMeeting.setVideoResolution(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540);
                mTRTCMeeting.setVideoFps(15);
                mTRTCMeeting.setVideoBitrate(1300);
            } else if (mMemberEntityList.size() < 4) {
                mTRTCMeeting.setVideoResolution(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360);
                mTRTCMeeting.setVideoFps(15);
                mTRTCMeeting.setVideoBitrate(800);
            } else {
                mTRTCMeeting.setVideoResolution(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270);
                mTRTCMeeting.setVideoFps(15);
                mTRTCMeeting.setVideoBitrate(400);
            }
        } else {
            TRTCCloudDef.TRTCNetworkQosParam qosParam = new TRTCCloudDef.TRTCNetworkQosParam();
            qosParam.preference = TRTCCloudDef.TRTC_VIDEO_QOS_PREFERENCE_SMOOTH;
            mTRTCMeeting.setNetworkQosParam(qosParam);
            if (mMemberEntityList.size() < 5) {
                // 包括自己，一共四个人，选择360p分辨率
                mTRTCMeeting.setVideoResolution(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360);
                mTRTCMeeting.setVideoFps(15);
                mTRTCMeeting.setVideoBitrate(700);
            } else {
                mTRTCMeeting.setVideoResolution(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270);
                mTRTCMeeting.setVideoFps(15);
                mTRTCMeeting.setVideoBitrate(350);
            }
        }
    }

    @Override
    public void onUserLeaveRoom(String userId) {
        if (mShowUserId.equals(userId)) {
            mShowUserId = "";
            mContainerFl.removeAllViews();
            mContainerFl.setVisibility(View.GONE);
        }
        int index = removeMemberEntity(userId);
        changeResolution();
        if (index >= 0) {
            mMemberListAdapter.notifyItemRemoved(index);
        }
        if (mRemoteUserView != null) {
            mRemoteUserView.notifyDataSetChanged();
        }
    }


    @Override
    public void onUserVideoAvailable(String userId, boolean available) {
        MemberEntity entity = mStringMemberEntityMap.get(userId);
        if (!available && mShowUserId.equals(userId)) {
            mShowUserId = "";
            mContainerFl.removeAllViews();
            mContainerFl.setVisibility(View.GONE);
            entity.setShowOutSide(false);
        }
        if (entity != null) {
            entity.setNeedFresh(true);
            entity.setVideoAvailable(available);
            entity.getMeetingVideoView().setNeedAttach(available);
            mMemberListAdapter.notifyItemChanged(mMemberEntityList.indexOf(entity));
        }
    }

    @Override
    public void onUserAudioAvailable(String userId, boolean available) {
        MemberEntity entity = mStringMemberEntityMap.get(userId);
        if (entity != null) {
            entity.setAudioAvailable(available);
            //界面暂时没有变更
        }
    }

    @Override
    public void onRecvRoomTextMsg(String message, TRTCMeetingDef.UserInfo userInfo) {

    }

    @Override
    public void onRecvRoomCustomMsg(String cmd, String message, TRTCMeetingDef.UserInfo userInfo) {

    }

    @Override
    public void onScreenCaptureStarted() {
        isScreenCapture = true;
    }

    @Override
    public void onScreenCapturePaused() {

    }

    @Override
    public void onScreenCaptureResumed() {

    }

    @Override
    public void onScreenCaptureStopped(int reason) {
        isScreenCapture = false;
        changeResolution();
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.img_audio) {
            boolean isAudioOn = mOpenAudio;
            if (isAudioOn) {
                mTRTCMeeting.stopMicrophone();
            } else {
                mTRTCMeeting.startMicrophone();
            }
            mAudioImg.setSelected(!isAudioOn);
            mOpenAudio = !isAudioOn;
        } else if (id == R.id.img_video) {
            boolean      isVideoOn = mOpenCamera;
            MemberEntity entity    = mMemberEntityList.get(0);
            if (mShowUserId.equals(mUserId)) {
                mShowUserId = "";
                mStringMemberEntityMap.get(mUserId).setShowOutSide(false);
                mContainerFl.removeAllViews();
                mContainerFl.setVisibility(View.GONE);
            }
            if (isVideoOn) {
                mTRTCMeeting.stopCameraPreview();
            } else {
                MeetingVideoView videoView = entity.getMeetingVideoView();
                mTRTCMeeting.startCameraPreview(isFrontCamera, videoView.getLocalPreviewView());
            }
            entity.setVideoAvailable(!isVideoOn);
            mVideoImg.setSelected(!isVideoOn);
            mOpenCamera = !isVideoOn;
            mMemberListAdapter.notifyItemChanged(0);
        } else if (id == R.id.img_beauty) {
            if (mBeautyControl.isShown()) {
                mBeautyControl.setVisibility(View.GONE);
            } else {
                mBeautyControl.setVisibility(View.VISIBLE);
            }
        } else if (id == R.id.img_member) {
            handleMemberListView();
        } else if (id == R.id.img_screen_share) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!PermissionUtils.isGrantedDrawOverlays()) {
                    ToastUtils.showLong(getString(R.string.meeting_toast_need_floating_window_permission));
                    PermissionUtils.requestDrawOverlays(new PermissionUtils.SimpleCallback() {
                        @Override
                        public void onGranted() {
                            startScreenCapture();
                        }

                        @Override
                        public void onDenied() {
                            ToastUtils.showLong(getString(R.string.meeting_toast_need_floating_window_permission));
                        }
                    });
                } else {
                    startScreenCapture();
                }
            } else {
                startScreenCapture();
            }
        } else if (id == R.id.img_more) {
            showDialogFragment(mFeatureSettingFragmentDialog, "FeatureSettingFragmentDialog");
        }
    }

    private void startScreenCapture() {
        mListRv.setVisibility(View.GONE);
        mScreenCaptureGroup.setVisibility(View.VISIBLE);
        mBottomToolBarGroup.setVisibility(View.GONE);

        mStopScreenCaptureTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                stopScreenCapture();
            }
        });

        TRTCCloudDef.TRTCVideoEncParam encParams = new TRTCCloudDef.TRTCVideoEncParam();
        encParams.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
        encParams.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
        encParams.videoFps = 10;
        encParams.enableAdjustRes = false;
        encParams.videoBitrate = 1500;

        TRTCCloudDef.TRTCScreenShareParams params = new TRTCCloudDef.TRTCScreenShareParams();
        mTRTCMeeting.stopCameraPreview();
        mTRTCMeeting.startScreenCapture(encParams, params);

        if (mFloatingWindow == null) {
            LayoutInflater inflater = LayoutInflater.from(this);
            mFloatingWindow = inflater.inflate(R.layout.meeting_screen_capture_floating_window, null, false);
            mFloatingWindow.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d(TAG, "onClick: 悬浮窗");
                }
            });
        }
        showFloatingWindow();
    }

    private void stopScreenCapture() {
        hideFloatingWindow();
        mListRv.setVisibility(View.VISIBLE);
        mScreenCaptureGroup.setVisibility(View.GONE);
        mBottomToolBarGroup.setVisibility(View.VISIBLE);
        mTRTCMeeting.stopScreenCapture();
        if (mOpenCamera) {
            mTRTCMeeting.startCameraPreview(isFrontCamera, mViewVideo.getLocalPreviewView());
        }
    }

    private void showFloatingWindow() {
        if (mFloatingWindow == null) {
            return;
        }
        WindowManager windowManager = (WindowManager) mFloatingWindow.getContext().getSystemService(Context.WINDOW_SERVICE);
        if (windowManager == null) {
            return;
        }
        //TYPE_TOAST仅适用于4.4+系统，假如要支持更低版本使用TYPE_SYSTEM_ALERT(需要在manifest中声明权限)
        //7.1（包含）及以上系统对TYPE_TOAST做了限制
        int type = WindowManager.LayoutParams.TYPE_TOAST;
        if (Build.VERSION.SDK_INT >= 26) {
            type = 2038; // WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N) {
            type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams(type);
        layoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        layoutParams.flags |= WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH;
        layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.format = PixelFormat.TRANSLUCENT;
        layoutParams.gravity = Gravity.RIGHT;
        windowManager.addView(mFloatingWindow, layoutParams);
    }

    private void hideFloatingWindow() {
        if (mFloatingWindow == null) {
            return;
        }
        WindowManager windowManager = (WindowManager) mFloatingWindow.getContext().getSystemService(Context.WINDOW_SERVICE);
        if (windowManager != null) {
            windowManager.removeViewImmediate(mFloatingWindow);
        }
        mFloatingWindow = null;
    }

    /**
     * 展示dialog界面
     */
    private void showDialogFragment(DialogFragment dialogFragment, String tag) {
        if (dialogFragment != null) {
            if (dialogFragment.isVisible()) {
                try {
                    dialogFragment.dismissAllowingStateLoss();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            } else {
                if (!dialogFragment.isAdded()) {
                    dialogFragment.show(getSupportFragmentManager(), tag);
                }
            }
        }
    }

    /**
     * 处理成员列表
     */
    private void handleMemberListView() {
        if (mRemoteUserView == null) {
            mStubRemoteUserView.inflate();
            mRemoteUserView = (RemoteUserListView) findViewById(R.id.view_remote_user);
            // 监听成员列表的变化
            mRemoteUserView.setRemoteUserListCallback(new RemoteUserListView.RemoteUserListCallback() {
                @Override
                public void onFinishClick() {
                    mRemoteUserView.setVisibility(View.GONE);
                    StateBarUtils.setDarkStatusBar(MeetingMainActivity.this);
                }

                @Override
                public void onMuteAllAudioClick() {
                    ToastUtils.showShort(getString(R.string.meeting_toast_mute_all_audio));
                    mIsUserEnterMuteAudio = true;
                    for (int i = 1; i < mMemberEntityList.size(); i++) {
                        MemberEntity entity = mMemberEntityList.get(i);
                        entity.setMuteAudio(true);
                        mTRTCMeeting.muteRemoteAudio(entity.getUserId(), true);
                    }
                    mRemoteUserView.notifyDataSetChanged();
                }

                @Override
                public void onMuteAllAudioOffClick() {
                    ToastUtils.showShort(getString(R.string.meeting_toast_not_mute_all_audio));
                    mIsUserEnterMuteAudio = false;
                    for (int i = 1; i < mMemberEntityList.size(); i++) {
                        MemberEntity entity = mMemberEntityList.get(i);
                        entity.setMuteAudio(false);
                        mTRTCMeeting.muteRemoteAudio(entity.getUserId(), false);
                    }
                    mRemoteUserView.notifyDataSetChanged();
                }

                @Override
                public void onMuteAllVideoClick() {
                    ToastUtils.showShort(getString(R.string.meeting_toast_mute_all_video));
                    for (int i = 1; i < mMemberEntityList.size(); i++) {
                        MemberEntity entity = mMemberEntityList.get(i);
                        entity.setMuteVideo(true);
                        entity.setNeedFresh(true);
                        entity.getMeetingVideoView().setNeedAttach(false);
                    }
                    mMemberListAdapter.notifyDataSetChanged();
                    mRemoteUserView.notifyDataSetChanged();
                }

                @Override
                public void onMuteAudioClick(int position) {
                    MemberEntity entity = mMemberEntityList.get(position);
                    if (entity != null) {
                        boolean isMuteAudio = !entity.isMuteAudio();
                        entity.setMuteAudio(isMuteAudio);
                        mTRTCMeeting.muteRemoteAudio(entity.getUserId(), isMuteAudio);
                        mRemoteUserView.notifyDataSetChanged();
                    }
                }

                @Override
                public void onMuteVideoClick(int position) {
                    MemberEntity entity = mMemberEntityList.get(position);
                    if (entity != null) {
                        boolean isMuteVideo = !entity.isMuteVideo();
                        entity.setMuteVideo(isMuteVideo);
                        entity.setNeedFresh(true);
                        entity.getMeetingVideoView().setNeedAttach(!isMuteVideo);
                        mMemberListAdapter.notifyItemChanged(position);
                        mRemoteUserView.notifyDataSetChanged();
                    }
                }
            });
            mRemoteUserView.setRemoteUser(mMemberEntityList);
            mRemoteUserView.notifyDataSetChanged();
            StateBarUtils.setLightStatusBar(MeetingMainActivity.this);
        } else {
            if (mRemoteUserView.isShown()) {
                mRemoteUserView.setVisibility(View.GONE);
                StateBarUtils.setDarkStatusBar(MeetingMainActivity.this);
            } else {
                mRemoteUserView.setVisibility(View.VISIBLE);
                StateBarUtils.setLightStatusBar(MeetingMainActivity.this);
            }
        }
    }

    private void addMemberEntity(MemberEntity entity) {
        mMemberEntityList.add(entity);
        mStringMemberEntityMap.put(entity.getUserId(), entity);
    }

    private int removeMemberEntity(String userId) {
        MemberEntity entity = mStringMemberEntityMap.remove(userId);
        if (entity != null) {
            int i = mMemberEntityList.indexOf(entity);
            mMemberEntityList.remove(entity);
            return i;
        }
        return -1;
    }

    /**
     * 显示确认消息
     *
     * @param msg     消息内容
     * @param isError true错误消息（必须退出） false提示消息（可选择是否退出）
     */
    public void showExitInfoDialog(String msg, Boolean isError) {
        final ConfirmDialogFragment dialogFragment = new ConfirmDialogFragment();
        dialogFragment.setCancelable(true);
        dialogFragment.setMessage(msg);
        if (dialogFragment.isAdded()) {
            dialogFragment.dismiss();
            return;
        }
        if (!isError) {
            dialogFragment.setPositiveText(getString(R.string.meeting_dialog_ok));
            dialogFragment.setNegativeText(getString(R.string.meeting_dialog_cancel));
            dialogFragment.setPositiveClickListener(new ConfirmDialogFragment.PositiveClickListener() {
                @Override
                public void onClick() {
                    dialogFragment.dismiss();
                    exitMeetingConfirm();
                    finish();            }
            });

            dialogFragment.setNegativeClickListener(new ConfirmDialogFragment.NegativeClickListener() {
                @Override
                public void onClick() {
                    dialogFragment.dismiss();
                }
            });
        } else {
            //当情况为错误的时候，直接停止推流
            dialogFragment.setPositiveText(getString(R.string.meeting_dialog_ok));
            dialogFragment.setPositiveClickListener(new ConfirmDialogFragment.PositiveClickListener() {
                @Override
                public void onClick() {
                    dialogFragment.dismiss();
                }
            });
        }
        dialogFragment.show(getFragmentManager(), "ConfirmDialogFragment");
    }

    private MeetingVideoView.Listener mMeetingViewClick = new MeetingVideoView.Listener() {
        @Override
        public void onSingleClick(View view) {

        }

        @Override
        public void onDoubleClick(View view) {
            final MeetingVideoView videoView = (MeetingVideoView) view;
            MemberEntity           entity    = mStringMemberEntityMap.get(videoView.getMeetingUserId());
            final ViewParent       viewGroup = videoView.getViewParent();
            if (viewGroup == mContainerFl) {
                entity.setShowOutSide(false);
                mContainerFl.removeView(videoView);
                mContainerFl.setVisibility(View.GONE);
                mShowUserId = "";
                videoView.refreshParent();
            } else if (viewGroup instanceof ViewGroup) {
                entity.setShowOutSide(true);
                mShowUserId = entity.getUserId();
                videoView.detach();
                mContainerFl.setVisibility(View.VISIBLE);
                videoView.addViewToViewGroup(mContainerFl);
            }
        }
    };
}
