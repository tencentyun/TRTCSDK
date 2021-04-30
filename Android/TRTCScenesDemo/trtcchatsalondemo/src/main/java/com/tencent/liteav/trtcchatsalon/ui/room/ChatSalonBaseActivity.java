package com.tencent.liteav.trtcchatsalon.ui.room;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatImageButton;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalon;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonCallback;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonDef;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonDelegate;
import com.tencent.liteav.trtcchatsalon.ui.utils.StatusBarUtils;
import com.tencent.liteav.trtcchatsalon.ui.base.ChatSalonMemberEntity;
import com.tencent.liteav.trtcchatsalon.ui.widget.ConfirmDialogFragment;
import com.tencent.liteav.trtcchatsalon.ui.widget.HandUpListDialog;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class ChatSalonBaseActivity extends AppCompatActivity implements ChatSalonAnchorAdapter.OnItemClickListener, TRTCChatSalonDelegate {
    protected static final String TAG = "ChatSalonBaseActivity";

    protected static final String VOICEROOM_ROOM_ID = "room_id";
    protected static final String VOICEROOM_ROOM_NAME = "room_name";
    protected static final String VOICEROOM_USER_NAME = "user_name";
    protected static final String VOICEROOM_USER_ID = "user_id";
    protected static final String VOICEROOM_NEED_REQUEST = "need_request";
    protected static final String VOICEROOM_AUDIO_QUALITY = "audio_quality";
    protected static final String VOICEROOM_USER_AVATAR = "user_avatar";
    protected static final String VOICEROOM_ROOM_COVER = "room_cover";

    protected int    mRoomId;
    protected String mRoomOwnerId;
    protected String mRoomName;
    protected String mUserName;
    protected String mUserAvatar;
    protected String mRoomCover;
    protected int    mAudioQuality;
    protected String mSelfUserId;     //进房用户ID
    protected int    mCurrentRole;    //用户当前角色
    protected TRTCChatSalon mTRTCChatSalon;
    protected Context mContext;

    protected List<ChatSalonMemberEntity>        mAnchorEntityList;
    protected List<ChatSalonMemberEntity>        mAudienceEntityList;
    protected Map<String, ChatSalonMemberEntity> mMemberEntityMap;
    protected LinkedList<ChatSalonMemberEntity>  mRequestSpeakMembers;
    protected Map<String, ChatSalonMemberEntity> mRequestSpeakMap;
    protected Map<String, ChatSalonMemberEntity> mRequestIdMap;

    protected ChatSalonAnchorAdapter   mAnchorAdapter;
    protected ChatSalonAudienceAdapter mAudienceAdapter;
    protected Toolbar      mToolbar;
    protected TextView     mToolbarTitle;
    protected RecyclerView mRvAnchor;
    protected RecyclerView mRvAudience;
    protected View         mToolBarView;
    protected View         mBtnLeave;
    protected View         mHandUpTipsView;
    protected AppCompatImageButton mBtnMic;
    protected AppCompatImageButton mBtnHandUpList;
    protected AppCompatImageButton mBtnLeaveMic;
    protected AppCompatImageButton mBtnHandUp;
    protected View      mHandleInvitation;
    protected TextView  mHandleInvitationTextView;
    protected TextView  mTvHandUpCount;
    protected ViewGroup mStateTips;
    protected HandUpListDialog      mHandUpListDialog;
    protected ConfirmDialogFragment mConfirmDialogFragment;


    private Runnable  mGetAudienceRunnable;
    protected Handler mHandler = new Handler(Looper.getMainLooper());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.trtcchatsalon_activity_main);
        StatusBarUtils.initStatusBar(this);
        initView();
        initData();
        initListener();
    }

    protected void initListener() {
        mBtnMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkButtonPermission()) {
                    boolean currentMode = !mBtnMic.isSelected();
                    mBtnMic.setSelected(currentMode);
                    if (currentMode) {
                        mTRTCChatSalon.muteLocalAudio(false);
                        ToastUtils.showLong(R.string.trtcchatsalon_already_open_mic);
                    } else {
                        mTRTCChatSalon.muteLocalAudio(true);
                        ToastUtils.showLong(R.string.trtcchatsalon_already_close_mic);
                    }
                }
            }
        });
    }


    /**
     * 判断是否为主播，有操作按钮的权限
     *
     * @return 是否有权限
     */
    protected boolean checkButtonPermission() {
        boolean hasPermission = (mCurrentRole == TRTCCloudDef.TRTCRoleAnchor);
        if (!hasPermission) {
            ToastUtils.showLong(R.string.trtcchatsalon_anchor_permission);
        }
        return hasPermission;
    }

    protected void initData() {
        Intent intent  = getIntent();
        mRoomId        = intent.getIntExtra(VOICEROOM_ROOM_ID, 0);
        mRoomName      = intent.getStringExtra(VOICEROOM_ROOM_NAME);
        mUserName      = intent.getStringExtra(VOICEROOM_USER_NAME);
        mSelfUserId    = intent.getStringExtra(VOICEROOM_USER_ID);
        mUserAvatar    = intent.getStringExtra(VOICEROOM_USER_AVATAR);
        mRoomCover     = intent.getStringExtra(VOICEROOM_ROOM_COVER);
        mAudioQuality  = intent.getIntExtra(VOICEROOM_AUDIO_QUALITY, TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCChatSalon = TRTCChatSalon.sharedInstance(this);
        mTRTCChatSalon.setDelegate(this);
        mGetAudienceRunnable = new Runnable() {
            @Override
            public void run() {
                getAudienceList();
            }
        };
    }

    protected void initView() {
        mToolbar          = (Toolbar) findViewById(R.id.toolbar);
        mToolbarTitle     = (TextView) findViewById(R.id.toolbar_title);
        mRvAnchor         = (RecyclerView) findViewById(R.id.rv_anchor);
        mRvAudience       = (RecyclerView) findViewById(R.id.rv_audience);
        mToolBarView      = findViewById(R.id.tool_bar_view);
        mBtnLeave         = findViewById(R.id.btn_leave);
        mStateTips        = findViewById(R.id.state_tips);
        mBtnMic           = (AppCompatImageButton) findViewById(R.id.btn_mic);
        mBtnHandUpList    = (AppCompatImageButton) findViewById(R.id.btn_hand_up_list);
        mBtnLeaveMic      = (AppCompatImageButton) findViewById(R.id.btn_leave_mic);
        mBtnHandUp        = (AppCompatImageButton) findViewById(R.id.btn_hand_up);
        mTvHandUpCount    = (TextView) findViewById(R.id.tv_hand_up_count);
        mHandleInvitation = View.inflate(this, R.layout.trtcchatsalon_layout_handle_invitation, null);
        mHandleInvitationTextView = mHandleInvitation.findViewById(R.id.state_tips_text);
        mConfirmDialogFragment = new ConfirmDialogFragment();
        mRequestSpeakMembers = new LinkedList<>();
        mRequestSpeakMap = new HashMap<>();
        mMemberEntityMap = new HashMap<>();
        mRequestIdMap = new HashMap<>();
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        mBtnLeave.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

        mAnchorEntityList = new ArrayList<>();
        mAnchorAdapter = new ChatSalonAnchorAdapter(this, mAnchorEntityList, new ChatSalonAnchorAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                if (mAnchorEntityList != null && !mAnchorEntityList.isEmpty()) {
                    ChatSalonMemberEntity entity = mAnchorEntityList.get(position);
                    if (entity != null) {
                        onAnchorItemClick(entity);
                    }
                }
            }
        });
        GridLayoutManager anchorLayoutManager = new GridLayoutManager(this, 3);
        mRvAnchor.setLayoutManager(anchorLayoutManager);
        mRvAnchor.setAdapter(mAnchorAdapter);

        mAudienceEntityList = new ArrayList<>();
        mAudienceAdapter = new ChatSalonAudienceAdapter(this, mAudienceEntityList, new ChatSalonAudienceAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(int position) {

            }
        });
        GridLayoutManager audienceLayoutManager = new GridLayoutManager(this, 4);
        mRvAudience.setLayoutManager(audienceLayoutManager);
        mRvAudience.setAdapter(mAudienceAdapter);

    }

    protected void onAnchorItemClick(ChatSalonMemberEntity entity) {

    }


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
    public void onRoomDestroy(String roomId) {

    }

    @Override
    public void onRoomInfoChange(TRTCChatSalonDef.RoomInfo roomInfo) {
        Log.d(TAG, "onRoomInfoChange userInfo: "+roomInfo);
        mRoomName = roomInfo.roomName;
        mRoomOwnerId = roomInfo.ownerId;
        mToolbarTitle.setText(getString(R.string.trtcchatsalon_main_title, roomInfo.roomName, roomInfo.roomId));
    }

    protected void getAudienceList() {
        mTRTCChatSalon.getUserInfoList(null, new TRTCChatSalonCallback.UserListCallback() {
            @Override
            public void onCallback(int code, String msg, List<TRTCChatSalonDef.UserInfo> list) {
                if (code == 0) {
                    final List<ChatSalonMemberEntity> audienceEntityList = new ArrayList<>();
                    HashMap<String, ChatSalonMemberEntity> anchorMap = mAnchorAdapter.getChatSalonMap();
                    for (TRTCChatSalonDef.UserInfo userInfo : list) {
                        Log.d(TAG, "getAudienceList userInfo: "+userInfo);
                        if (userInfo != null) {
                            if (anchorMap.containsKey(userInfo.userId)) {
                                continue;
                            }
                            ChatSalonMemberEntity entity = new ChatSalonMemberEntity();
                            entity.userId = userInfo.userId;
                            entity.userName = userInfo.userName;
                            entity.userAvatar = userInfo.userAvatar;
                            audienceEntityList.add(entity);
                            mMemberEntityMap.put(entity.userId, entity);
                        }
                    }
                    mAudienceAdapter.addMembers(audienceEntityList);
                } else {
                    mHandler.postDelayed(mGetAudienceRunnable, 2000);
                }
            }
        });
    }

    @Override
    public void onAnchorEnterSeat(TRTCChatSalonDef.UserInfo user) {
        Log.d(TAG,  "onAnchorEnterSeat user info:"+  user);
        if (user == null) {
            return;
        }
        ChatSalonMemberEntity entity = new ChatSalonMemberEntity();
        if (user.userId.equals(mRoomOwnerId)) {
            entity.isManager = true;
        }
        entity.userId = user.userId;
        entity.userName = user.userName;
        entity.userAvatar = user.userAvatar;
        entity.enterTime = System.currentTimeMillis();
        mMemberEntityMap.put(user.userId, entity);
        mAnchorAdapter.addMember(entity);
        mAudienceAdapter.removeMember(user.userId);
    }

    @Override
    public void onAnchorLeaveSeat(TRTCChatSalonDef.UserInfo user) {
        Log.d(TAG, "onAnchorLeaveSeat user:" + user);
        if (user == null) {
            return;
        }
        String userId = user.userId;
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        ChatSalonMemberEntity entity = mMemberEntityMap.get(userId);
        if (entity != null) {
            mAudienceAdapter.addMember(entity);
            mAnchorAdapter.removeMember(user.userId);
        }
    }

    @Override
    public void onSeatMute(String seatUserId, boolean isMute) {
        Log.d(TAG, "onSeatMute:" + seatUserId +" isMute:" + isMute);
        ChatSalonMemberEntity entity = mMemberEntityMap.get(seatUserId);
        if (entity != null) {
            entity.isMute = isMute;
            mAnchorAdapter.notifyDataSetChanged();
        }
    }

    @Override
    public void onAudienceEnter(TRTCChatSalonDef.UserInfo userInfo) {
        Log.d(TAG, "onAudienceEnter " + userInfo);
        if (userInfo == null) {
            return;
        }
        HashMap<String, ChatSalonMemberEntity> anchorMap = mAnchorAdapter.getChatSalonMap();
        if (anchorMap.containsKey(userInfo.userId)) {
            return;
        }
        ChatSalonMemberEntity entity = mMemberEntityMap.get(userInfo.userId);
        if (entity == null) {
            entity = new ChatSalonMemberEntity();
        }
        entity.userId = userInfo.userId;
        entity.userName = userInfo.userName;
        entity.userAvatar = userInfo.userAvatar;
        mMemberEntityMap.put(entity.userId, entity);
        mAudienceAdapter.addMember(entity);
    }

    @Override
    public void onAudienceExit(TRTCChatSalonDef.UserInfo userInfo) {
        Log.d(TAG, "onAudienceExit " + userInfo);
        if (userInfo == null) {
            return;
        }
        mAudienceAdapter.removeMember(userInfo.userId);
    }

    @Override
    public void onUserVolumeUpdate(List<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
        for (TRTCCloudDef.TRTCVolumeInfo info : userVolumes) {
            if (info != null) {
                ChatSalonMemberEntity entity = mMemberEntityMap.get(info.userId);
                if (entity != null) {
                    int volume = info.volume;
                    if (volume > 20) {
                        entity.isTalk = true;
                    } else {
                        entity.isTalk = false;
                    }
                }
            }
        }
        mAnchorAdapter.notifyDataSetChanged();
    }

    @Override
    public void onRecvRoomTextMsg(String message, TRTCChatSalonDef.UserInfo userInfo) {

    }

    @Override
    public void onRecvRoomCustomMsg(String cmd, String message, TRTCChatSalonDef.UserInfo userInfo) {

    }

    @Override
    public void onReceiveNewInvitation(String id, String inviter, String cmd, String content) {

    }

    @Override
    public void onInviteeAccepted(String id, String invitee) {

    }

    @Override
    public void onInviteeRejected(String id, String invitee) {

    }

    @Override
    public void onInvitationCancelled(String id, String inviter) {

    }

    @Override
    public void onInvitationTimeout(String id) {

    }

    @Override
    public void onItemClick(int position) {

    }
}