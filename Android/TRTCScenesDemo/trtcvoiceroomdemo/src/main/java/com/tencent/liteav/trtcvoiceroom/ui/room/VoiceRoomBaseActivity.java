package com.tencent.liteav.trtcvoiceroom.ui.room;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatImageButton;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.view.Display;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.blankj.utilcode.util.ToastUtils;
import com.squareup.picasso.Picasso;
import com.tencent.liteav.trtcvoiceroom.R;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoom;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomCallback;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomDef;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomDelegate;
import com.tencent.liteav.trtcvoiceroom.ui.base.MemberEntity;
import com.tencent.liteav.trtcvoiceroom.ui.base.VoiceRoomSeatEntity;
import com.tencent.liteav.trtcvoiceroom.ui.widget.AudioEffectPanel;
import com.tencent.liteav.trtcvoiceroom.ui.widget.ConfirmDialogFragment;
import com.tencent.liteav.trtcvoiceroom.ui.widget.InputTextMsgDialog;
import com.tencent.liteav.trtcvoiceroom.ui.widget.MoreActionDialog;
import com.tencent.liteav.trtcvoiceroom.ui.widget.SelectMemberView;
import com.tencent.liteav.trtcvoiceroom.ui.widget.msg.AudienceEntity;
import com.tencent.liteav.trtcvoiceroom.ui.widget.msg.MsgEntity;
import com.tencent.liteav.trtcvoiceroom.ui.widget.msg.MsgListAdapter;
import com.tencent.trtc.TRTCCloudDef;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import de.hdodenhof.circleimageview.CircleImageView;

import static com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomDef.SeatInfo.STATUS_CLOSE;
import static com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomDef.SeatInfo.STATUS_UNUSED;
import static com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomDef.SeatInfo.STATUS_USED;

public class VoiceRoomBaseActivity extends AppCompatActivity implements VoiceRoomSeatAdapter.OnItemClickListener, TRTCVoiceRoomDelegate, InputTextMsgDialog.OnTextSendListener, MsgListAdapter.OnItemClickListener {
    protected static final String TAG = VoiceRoomBaseActivity.class.getName();

    protected static final int    MAX_SEAT_SIZE           = 9;
    protected static final String VOICEROOM_ROOM_ID       = "room_id";
    protected static final String VOICEROOM_ROOM_NAME     = "room_name";
    protected static final String VOICEROOM_USER_NAME     = "user_name";
    protected static final String VOICEROOM_USER_ID       = "user_id";
    protected static final String VOICEROOM_USER_SIG      = "user_sig";
    protected static final String VOICEROOM_NEED_REQUEST  = "need_request";
    protected static final String VOICEROOM_SEAT_COUNT    = "seat_count";
    protected static final String VOICEROOM_AUDIO_QUALITY = "audio_quality";
    protected static final String VOICEROOM_USER_AVATAR   = "user_avatar";
    protected static final String VOICEROOM_ROOM_COVER    = "room_cover";

    private static final int MESSAGE_USERNAME_COLOR_ARR []       =  {
            R.color.trtcvoiceroom_color_msg_1,
            R.color.trtcvoiceroom_color_msg_2,
            R.color.trtcvoiceroom_color_msg_3,
            R.color.trtcvoiceroom_color_msg_4,
            R.color.trtcvoiceroom_color_msg_5,
            R.color.trtcvoiceroom_color_msg_6,
            R.color.trtcvoiceroom_color_msg_7,
    };

    /**
     *
     */
    protected String        mSelfUserId;     //进房用户ID
    protected int           mCurrentRole;    //用户当前角色
    protected Set<String>   mSeatUserSet; //在座位上的主播集合
    protected TRTCVoiceRoom mTRTCVoiceRoom;
    private boolean isInitSeat;

    protected List<VoiceRoomSeatEntity> mVoiceRoomSeatEntityList;
    protected Map<String, Boolean>      mSeatUserMuteMap;
    protected VoiceRoomSeatAdapter      mVoiceRoomSeatAdapter;
    protected AudienceListAdapter       mAudienceListAdapter;
    protected TextView                  mTvRoomName;
    protected TextView                  mTvRoomId;
    protected CircleImageView           mImgHead;
    protected CircleImageView           mIvAnchorHead;
    protected ImageView                 mIvManagerMute;
    protected ImageView                 mIvManagerTalk;
    protected TextView                  mTvName;
    protected RecyclerView              mRvSeat;
    protected RecyclerView              mRvAudience;
    protected RecyclerView              mRvImMsg;
    protected View                      mToolBarView;
    protected ImageView                 mRootBg;
    protected AppCompatImageButton      mBtnExitRoom;
    protected AppCompatImageButton      mBtnMsg;
    protected AppCompatImageButton      mBtnMic;
    protected AppCompatImageButton      mBtnEffect;
    protected AppCompatImageButton      mBtnLeaveSeat;
    protected AppCompatImageButton      mBtnMore;
    protected ImageView                 mIvAudienceMove;

    protected AudioEffectPanel          mAnchorAudioPanel;
    protected SelectMemberView          mViewSelectMember;
    protected InputTextMsgDialog        mInputTextMsgDialog;
    protected int                       mRoomId;
    protected String                    mRoomName;
    protected String                    mUserName;
    protected String                    mUserAvatar;
    protected String                    mRoomCover;
    protected String                    mMainSeatUserId;
    protected boolean                   mNeedRequest;
    protected int                       mAudioQuality;
    protected List<MsgEntity>           mMsgEntityList;
    protected LinkedList<AudienceEntity> mAudienceEntityList;
    protected MsgListAdapter            mMsgListAdapter;
    protected ConfirmDialogFragment     mConfirmDialogFragment;
    protected List<MemberEntity>        mMemberEntityList;
    protected Map<String, MemberEntity> mMemberEntityMap;

    private int mMessageColorIndex;
    private Context mContext;
    private int mRvAudienceScrollPosition;
    private boolean mIsMainSeatMute;
    private int mSelfSeatIndex = -1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.trtcvoiceroom_activity_main);
        initStatusBar();
        initView();
        initData();
        initListener();
        MsgEntity msgEntity = new MsgEntity();
        msgEntity.type = MsgEntity.TYPE_WELCOME;
        msgEntity.content = getString(R.string.trtcvoiceroom_welcome_visit);
        msgEntity.linkUrl = getString(R.string.trtcvoiceroom_welcome_visit_link);
        showImMsg(msgEntity);
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mAnchorAudioPanel != null) {
            mAnchorAudioPanel.unInit();
            mAnchorAudioPanel = null;
        }
    }

    private void updateMicButton() {
        if (checkButtonPermission()) {
            boolean currentMode = !mBtnMic.isSelected();
            if (currentMode) {
                if (!isSeatMute(mSelfSeatIndex)) {
                    updateMuteStatusView(mSelfUserId, false);
                    mTRTCVoiceRoom.muteLocalAudio(false);
                    ToastUtils.showLong(getString(R.string.trtcvoiceroom_toast_you_have_turned_on_the_microphone));
                } else {
                    ToastUtils.showLong(getString(R.string.trtcvoiceroom_seat_already_mute));
                }
            } else {
                mTRTCVoiceRoom.muteLocalAudio(true);
                updateMuteStatusView(mSelfUserId, true);
                ToastUtils.showLong(getString(R.string.trtcvoiceroom_toast_you_have_turned_off_the_microphone));
            }
        }
    }

    private boolean isSeatMute(int seatIndex) {
        VoiceRoomSeatEntity seatEntity = findSeatEntityFromUserId(seatIndex);
        if (seatEntity != null) {
            return  seatEntity.isSeatMute;
        }
        return false;
    }

    protected void initListener() {
        mBtnMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateMicButton();
            }
        });
        mBtnEffect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkButtonPermission()) {
                    if (mAnchorAudioPanel != null) {
                        mAnchorAudioPanel.show();
                    }
                }
            }
        });
        mBtnMsg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showInputMsgDialog();
            }
        });
        mBtnMore.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MoreActionDialog dialog = new MoreActionDialog(mContext);
                dialog.show();

            }
        });

        mRvAudience.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                mRvAudienceScrollPosition = dx;
            }
        });
        mIvAudienceMove.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRvAudienceScrollPosition < 0) {
                    mRvAudienceScrollPosition = 0;
                }
                int position = mRvAudienceScrollPosition + dp2px(mContext, 32);
                mRvAudience.smoothScrollBy(position, 0);
            }
        });
    }

    public static int dp2px(Context context, float dpVal) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                dpVal, context.getResources().getDisplayMetrics());
    }



    /**
     * 判断是否为主播，有操作按钮的权限
     *
     * @return 是否有权限
     */
    protected boolean checkButtonPermission() {
        boolean hasPermission = (mCurrentRole == TRTCCloudDef.TRTCRoleAnchor);
        if (!hasPermission) {
            ToastUtils.showLong(getString(R.string.trtcvoiceroom_toast_anchor_can_only_operate_it));
        }
        return hasPermission;
    }

    protected void initData() {
        Intent intent = getIntent();
        mRoomId = intent.getIntExtra(VOICEROOM_ROOM_ID, 0);
        mRoomName = intent.getStringExtra(VOICEROOM_ROOM_NAME);
        mUserName = intent.getStringExtra(VOICEROOM_USER_NAME);
        mSelfUserId = intent.getStringExtra(VOICEROOM_USER_ID);
        mNeedRequest = intent.getBooleanExtra(VOICEROOM_NEED_REQUEST, false);
        mUserAvatar = intent.getStringExtra(VOICEROOM_USER_AVATAR);
        mRoomCover = intent.getStringExtra(VOICEROOM_ROOM_COVER);
        mAudioQuality = intent.getIntExtra(VOICEROOM_AUDIO_QUALITY, TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);
        //        mSeatCount = intent.getIntExtra(VOICEROOM_SEAT_COUNT);
        mTRTCVoiceRoom = TRTCVoiceRoom.sharedInstance(this);
        mTRTCVoiceRoom.setDelegate(this);
        mAnchorAudioPanel = new AudioEffectPanel(this);
        mAnchorAudioPanel.setAudioEffectManager(mTRTCVoiceRoom.getAudioEffectManager());
        if (!TextUtils.isEmpty(mRoomCover)) {
            Picasso.get().load(mRoomCover).into(mRootBg);
        } else {
            mRootBg.setBackgroundResource(R.drawable.trtcvoiceroom_scene_bg);
        }
    }

    protected void initView() {
        mRootBg =  (ImageView) findViewById(R.id.root_bg);
        mTvRoomName = (TextView) findViewById(R.id.tv_room_name);
        mTvRoomId = (TextView) findViewById(R.id.tv_room_id);
        mImgHead = (CircleImageView) findViewById(R.id.img_head);
        mIvManagerMute = (ImageView) findViewById(R.id.iv_manager_mute);
        mIvManagerTalk = (ImageView) findViewById(R.id.iv_manager_talk);
        mIvAnchorHead = (CircleImageView) findViewById(R.id.iv_anchor_head);
        mTvName = (TextView) findViewById(R.id.tv_name);
        mRvSeat = (RecyclerView) findViewById(R.id.rv_seat);
        mRvAudience = (RecyclerView) findViewById(R.id.rv_audience);
        mRvImMsg = (RecyclerView) findViewById(R.id.rv_im_msg);
        mToolBarView = findViewById(R.id.tool_bar_view);
        mBtnExitRoom = (AppCompatImageButton) findViewById(R.id.exit_room);
        mBtnMsg = (AppCompatImageButton) findViewById(R.id.btn_msg);
        mBtnMic = (AppCompatImageButton) findViewById(R.id.btn_mic);
        mBtnEffect = (AppCompatImageButton) findViewById(R.id.btn_effect);
        mBtnLeaveSeat = (AppCompatImageButton) findViewById(R.id.btn_leave_seat);
        mBtnMore = (AppCompatImageButton) findViewById(R.id.btn_more);
        mIvAudienceMove = (ImageView) findViewById(R.id.iv_audience_move);
        mViewSelectMember = new SelectMemberView(this);
        mConfirmDialogFragment = new ConfirmDialogFragment();
        GridLayoutManager gridLayoutManager = new GridLayoutManager(this, 4);
        mInputTextMsgDialog = new InputTextMsgDialog(this, R.style.TRTCVoiceRoomInputDialog);
        mInputTextMsgDialog.setmOnTextSendListener(this);
        mMsgEntityList = new ArrayList<>();
        mMemberEntityList = new ArrayList<>();
        mMemberEntityMap = new HashMap<>();
        mBtnExitRoom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        mMsgListAdapter = new MsgListAdapter(this, mMsgEntityList, this);
        mRvImMsg.setLayoutManager(new LinearLayoutManager(this));
        mRvImMsg.setAdapter(mMsgListAdapter);
        mSeatUserMuteMap = new HashMap<>();
        mVoiceRoomSeatEntityList = new ArrayList<>();
        for (int i = 1; i < MAX_SEAT_SIZE; i++) {
            VoiceRoomSeatEntity seatEntity = new VoiceRoomSeatEntity();
            seatEntity.index = i;
            mVoiceRoomSeatEntityList.add(seatEntity);
        }
        mVoiceRoomSeatAdapter = new VoiceRoomSeatAdapter(this, mVoiceRoomSeatEntityList, this);
        mRvSeat.setLayoutManager(gridLayoutManager);
        mRvSeat.setAdapter(mVoiceRoomSeatAdapter);

        mAudienceEntityList = new LinkedList<>();
        mAudienceListAdapter = new AudienceListAdapter(this, mAudienceEntityList);
        LinearLayoutManager lm = new LinearLayoutManager(this);
        lm.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRvAudience.setLayoutManager(lm);
        mRvAudience.setAdapter(mAudienceListAdapter);
    }

    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      发送文本信息
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
        lp.width = display.getWidth(); //设置宽度
        mInputTextMsgDialog.getWindow().setAttributes(lp);
        mInputTextMsgDialog.setCancelable(true);
        mInputTextMsgDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        mInputTextMsgDialog.show();
    }

    @Override
    public void onTextSend(String msg) {
        if (msg.length() == 0) {
            return;
        }
        byte[] byte_num = msg.getBytes(StandardCharsets.UTF_8);
        if (byte_num.length > 160) {
            Toast.makeText(this, getString(R.string.trtcvoiceroom_toast_please_enter_content), Toast.LENGTH_SHORT).show();
            return;
        }

        //消息回显
        MsgEntity entity = new MsgEntity();
        entity.userName = getString(R.string.trtcvoiceroom_me);
        entity.content = msg;
        entity.isChat = true;
        entity.userId = mSelfUserId;
        entity.type = MsgEntity.TYPE_NORMAL;
        showImMsg(entity);

        mTRTCVoiceRoom.sendRoomTextMsg(msg, new TRTCVoiceRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    ToastUtils.showShort(getString(R.string.trtcvoiceroom_toast_sent_successfully));
                } else {
                    ToastUtils.showShort(getString(R.string.trtcvoiceroom_toast_sent_message_failure), code);
                }
            }
        });
    }

    public void resetSeatView() {
        mSeatUserSet.clear();
        for (VoiceRoomSeatEntity entity : mVoiceRoomSeatEntityList) {
            entity.isUsed = false;
        }
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    /**
     * 座位上点击按钮的反馈
     *
     * @param position
     */
    @Override
    public void onItemClick(int position) {
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
    public void onRoomInfoChange(TRTCVoiceRoomDef.RoomInfo roomInfo) {
        mNeedRequest = roomInfo.needRequest;
        mRoomName = roomInfo.roomName;
        mTvRoomName.setText(roomInfo.roomName);
        mTvRoomId.setText(getString(R.string.trtcvoiceroom_room_id, roomInfo.roomId));
        String roomCover = roomInfo.coverUrl;
        if (!TextUtils.isEmpty(roomCover)) {
            Picasso.get().load(roomCover).into(mRootBg);
        }
    }

    @Override
    public void onSeatListChange(final List<TRTCVoiceRoomDef.SeatInfo> seatInfoList) {
        //先刷一遍界面
        final List<String> userids = new ArrayList<>();
        for (int i = 0; i < seatInfoList.size(); i++) {
            TRTCVoiceRoomDef.SeatInfo newSeatInfo = seatInfoList.get(i);
            // 底层返回的第一个座位是主播哦！特殊处理一下
            if (i == 0) {
                if (mMainSeatUserId == null || !mMainSeatUserId.equals(newSeatInfo.userId)) {
                    //主播上线啦
                    mMainSeatUserId = newSeatInfo.userId;
                    userids.add(newSeatInfo.userId);
                    mTvName.setText(getString(R.string.trtcvoiceroom_tv_information_acquisition));
                }
                continue;
            }
            // 接下来是座位区域的列表
            VoiceRoomSeatEntity oldSeatEntity = mVoiceRoomSeatEntityList.get(i - 1);
            if (newSeatInfo.userId != null && !newSeatInfo.userId.equals(oldSeatEntity.userId)) {
                //userId相同，可以不用重新获取信息了
                //但是如果有新的userId进来，那么应该去拿一下主播的详细信息
                userids.add(newSeatInfo.userId);
            }
            oldSeatEntity.userId = newSeatInfo.userId;
            // 座位的状态更新一下
            switch (newSeatInfo.status) {
                case STATUS_UNUSED:
                    oldSeatEntity.isUsed = false;
                    oldSeatEntity.isClose = false;
                    break;
                case STATUS_CLOSE:
                    oldSeatEntity.isUsed = false;
                    oldSeatEntity.isClose = true;
                    break;
                case STATUS_USED:
                    oldSeatEntity.isUsed = true;
                    oldSeatEntity.isClose = false;
                    break;
                default:
                    break;
            }
            oldSeatEntity.isSeatMute = newSeatInfo.mute;
        }
        for (String userId : userids) {
            if (!mSeatUserMuteMap.containsKey(userId)) {
                mSeatUserMuteMap.put(userId, true);
            }
        }
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
        //所有的userId拿到手，开始去搜索详细信息了
        mTRTCVoiceRoom.getUserInfoList(userids, new TRTCVoiceRoomCallback.UserListCallback() {
            @Override
            public void onCallback(int code, String msg, List<TRTCVoiceRoomDef.UserInfo> list) {
                // 解析所有人的userinfo
                Map<String, TRTCVoiceRoomDef.UserInfo> map = new HashMap<>();
                for (TRTCVoiceRoomDef.UserInfo userInfo : list) {
                    map.put(userInfo.userId, userInfo);
                }
                for (int i = 0; i < seatInfoList.size(); i++) {
                    TRTCVoiceRoomDef.SeatInfo newSeatInfo = seatInfoList.get(i);
                    TRTCVoiceRoomDef.UserInfo userInfo    = map.get(newSeatInfo.userId);
                    if (userInfo == null) {
                        continue;
                    }
                    boolean isUserMute = mSeatUserMuteMap.get(userInfo.userId);
                    // 底层返回的第一个座位是房主哦！特殊处理一下
                    if (i == 0) {
                        if (newSeatInfo.status == STATUS_USED) {
                            //主播上线啦
                            if (!TextUtils.isEmpty(userInfo.userAvatar)) {
                                Picasso.get().load(userInfo.userAvatar).into(mImgHead);
                                Picasso.get().load(userInfo.userAvatar).into(mIvAnchorHead);
                            } else {
                                mImgHead.setImageResource(R.drawable.trtcvoiceroom_ic_head);
                                mIvAnchorHead.setImageResource(R.drawable.trtcvoiceroom_ic_head);
                            }
                            if (TextUtils.isEmpty(userInfo.userName)) {
                                mTvName.setText(userInfo.userId);
                            } else {
                                mTvName.setText(userInfo.userName);
                            }
                            updateMuteStatusView(userInfo.userId, isUserMute);
                        } else {
                            mTvName.setText(getString(R.string.trtcvoiceroom_tv_the_anchor_is_not_online));
                        }
                    } else {
                        // 接下来是座位区域的列表
                        VoiceRoomSeatEntity seatEntity = mVoiceRoomSeatEntityList.get(i - 1);
                        if (userInfo.userId.equals(seatEntity.userId)) {
                            seatEntity.userName = userInfo.userName;
                            seatEntity.userAvatar = userInfo.userAvatar;
                            seatEntity.isUserMute = isUserMute;
                        }
                    }
                }
                mVoiceRoomSeatAdapter.notifyDataSetChanged();
                if (!isInitSeat) {
                    getAudienceList();
                    isInitSeat = true;
                }
            }
        });
    }

    @Override
    public void onAnchorEnterSeat(int index, TRTCVoiceRoomDef.UserInfo user) {
        if (index != 0) {
            // 房主上麦就别提醒了
            Log.d(TAG, "onAnchorEnterSeat userInfo:"+user);
            MsgEntity msgEntity = new MsgEntity();
            msgEntity.type = MsgEntity.TYPE_NORMAL;
            msgEntity.userName = user.userName;
            msgEntity.content =  getString(R.string.trtcvoiceroom_tv_online_no_name, index);
            showImMsg(msgEntity);
            mAudienceListAdapter.removeMember(user.userId);
            if (user.userId.equals(mSelfUserId)) {
                mSelfSeatIndex = index;
            }
        }
    }

    @Override
    public void onAnchorLeaveSeat(int index, TRTCVoiceRoomDef.UserInfo user) {
        if (index != 0) {
            // 房主上麦就别提醒了
            Log.d(TAG, "onAnchorLeaveSeat userInfo:"+user);
            MsgEntity msgEntity = new MsgEntity();
            msgEntity.type = MsgEntity.TYPE_NORMAL;
            msgEntity.userName = user.userName;
            msgEntity.content =  getString(R.string.trtcvoiceroom_tv_offline_no_name, index);
            showImMsg(msgEntity);
            AudienceEntity entity = new AudienceEntity();
            entity.userId = user.userId;
            entity.userAvatar = user.userAvatar;
            mAudienceListAdapter.addMember(entity);
            if (user.userId.equals(mSelfUserId)) {
                mSelfSeatIndex = -1;
            }
        }
    }

    @Override
    public void onSeatMute(int index, boolean isMute) {
        MsgEntity msgEntity = new MsgEntity();
        msgEntity.type = MsgEntity.TYPE_NORMAL;
        if (isMute) {
            msgEntity.content =  getString(R.string.trtcvoiceroom_tv_the_position_has_muted, index);
        } else {
            msgEntity.content =  getString(R.string.trtcvoiceroom_tv_the_position_has_unmuted, index);
        }
        showImMsg(msgEntity);
        VoiceRoomSeatEntity seatEntity = findSeatEntityFromUserId(index);
        if (seatEntity == null) {
            return;
        }
        if (index == mSelfSeatIndex) {
            if (isMute) {
                mTRTCVoiceRoom.muteLocalAudio(true);
                updateMuteStatusView(mSelfUserId, true);
            } else if (!seatEntity.isUserMute) {
                mTRTCVoiceRoom.muteLocalAudio(false);
                updateMuteStatusView(mSelfUserId, false);
            }
        }
    }

    @Override
    public void onSeatClose(int index, boolean isClose) {
        MsgEntity msgEntity = new MsgEntity();
        msgEntity.type = MsgEntity.TYPE_NORMAL;
        msgEntity.content = isClose ? getString(R.string.trtcvoiceroom_tv_the_owner_ban_this_position, index) :
        getString(R.string.trtcvoiceroom_tv_the_owner_not_ban_this_position, index);
        showImMsg(msgEntity);
    }


    @Override
    public void onUserMicrophoneMute(String userId, boolean mute) {
        Log.d(TAG, "onUserMicrophoneMute userId:"+userId + " mute:"+mute);
        mSeatUserMuteMap.put(userId, mute);
        updateMuteStatusView(userId, mute);
    }

    private void updateMuteStatusView(String userId, boolean mute) {
        if (userId == null) {
            return;
        }
        if (userId.equals(mMainSeatUserId)) {
            mIvManagerMute.setVisibility(mute ? View.VISIBLE : View.GONE);
            if (mute) {
                mIvManagerTalk.setVisibility(View.GONE);
            }
            mIsMainSeatMute = mute;
        } else {
            VoiceRoomSeatEntity seatEntity = findSeatEntityFromUserId(userId);
            if (seatEntity != null) {
                if (!seatEntity.isSeatMute && mute != seatEntity.isUserMute) {
                    seatEntity.isUserMute = mute;
                    mVoiceRoomSeatAdapter.notifyDataSetChanged();
                }
            }
        }
        if (userId.equals(mSelfUserId)) {
            mBtnMic.setSelected(!mute);
        }
    }

    private VoiceRoomSeatEntity findSeatEntityFromUserId(String userId)  {
        if (mVoiceRoomSeatEntityList != null) {
            for (VoiceRoomSeatEntity seatEntity : mVoiceRoomSeatEntityList) {
                if (userId.equals(seatEntity.userId)) {
                    return seatEntity;
                }
            }
        }
        return null;
    }

    private VoiceRoomSeatEntity findSeatEntityFromUserId(int index)  {
        if (index == -1) {
            return null;
        }
        if (mVoiceRoomSeatEntityList != null) {
            for (VoiceRoomSeatEntity seatEntity : mVoiceRoomSeatEntityList) {
                if (index == seatEntity.index) {
                    return seatEntity;
                }
            }
        }
        return null;
    }

    @Override
    public void onAudienceEnter(TRTCVoiceRoomDef.UserInfo userInfo) {
        Log.d(TAG, "onAudienceEnter userInfo:"+userInfo);
        MsgEntity msgEntity = new MsgEntity();
        msgEntity.type = MsgEntity.TYPE_NORMAL;
        msgEntity.content = getString(R.string.trtcvoiceroom_tv_enter_room, "");
        msgEntity.userName = userInfo.userName;
        showImMsg(msgEntity);
        if (userInfo.userId.equals(mSelfUserId)) {
            return;
        }
        AudienceEntity entity = new AudienceEntity();
        entity.userId = userInfo.userId;
        entity.userAvatar = userInfo.userAvatar;
        mAudienceListAdapter.addMember(entity);
    }

    @Override
    public void onAudienceExit(TRTCVoiceRoomDef.UserInfo userInfo) {
        Log.d(TAG, "onAudienceExit userInfo:"+userInfo);
        MsgEntity msgEntity = new MsgEntity();
        msgEntity.type = MsgEntity.TYPE_NORMAL;
        msgEntity.userName = userInfo.userName;
        msgEntity.content = getString(R.string.trtcvoiceroom_tv_exit_room, "");
        showImMsg(msgEntity);
        mAudienceListAdapter.removeMember(userInfo.userId);
    }

    @Override
    public void onUserVolumeUpdate(List<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
        for (TRTCCloudDef.TRTCVolumeInfo info : userVolumes) {
            if (info != null) {
                int volume = info.volume;
                if (info.userId.equals(mMainSeatUserId)) {
                    mIvManagerTalk.setVisibility(mIsMainSeatMute ? View.GONE : volume > 20 ? View.VISIBLE: View.GONE);
                } else {
                    VoiceRoomSeatEntity entity = findSeatEntityFromUserId(info.userId);
                    if (entity != null) {
                        entity.isTalk = volume > 20 ? true : false;
                        mVoiceRoomSeatAdapter.notifyDataSetChanged();
                    }
                }
            }
        }
    }

    @Override
    public void onRecvRoomTextMsg(String message, TRTCVoiceRoomDef.UserInfo userInfo) {
        MsgEntity msgEntity = new MsgEntity();
        msgEntity.userId = userInfo.userId;
        msgEntity.userName = userInfo.userName;
        msgEntity.content = message;
        msgEntity.type = MsgEntity.TYPE_NORMAL;
        msgEntity.isChat = true;
        showImMsg(msgEntity);
    }

    @Override
    public void onRecvRoomCustomMsg(String cmd, String message, TRTCVoiceRoomDef.UserInfo userInfo) {

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
    public void onInvitationCancelled(String id, String invitee) {

    }

    @Override
    public void onAgreeClick(int position) {

    }

    protected void getAudienceList() {
        mTRTCVoiceRoom.getUserInfoList(null, new TRTCVoiceRoomCallback.UserListCallback() {
            @Override
            public void onCallback(int code, String msg, List<TRTCVoiceRoomDef.UserInfo> list) {
                if (code == 0) {
                    Log.d(TAG, "getAudienceList list size:"+list.size());
                    for (TRTCVoiceRoomDef.UserInfo userInfo : list) {
                        Log.d(TAG, "getAudienceList userInfo:"+userInfo);
                        if (!mSeatUserMuteMap.containsKey(userInfo.userId)) {
                            AudienceEntity audienceEntity = new AudienceEntity();
                            audienceEntity.userAvatar = userInfo.userAvatar;
                            audienceEntity.userId = userInfo.userId;
                            mAudienceListAdapter.addMember(audienceEntity);
                        }
                        if (userInfo.userId.equals(mSelfUserId)) {
                            continue;
                        }
                        MemberEntity memberEntity = new MemberEntity();
                        memberEntity.userId = userInfo.userId;
                        memberEntity.userAvatar = userInfo.userAvatar;
                        memberEntity.userName = userInfo.userName;
                        memberEntity.type = MemberEntity.TYPE_IDEL;
                        if (!mMemberEntityMap.containsKey(memberEntity.userId)) {
                            mMemberEntityMap.put(memberEntity.userId, memberEntity);
                            mMemberEntityList.add(memberEntity);
                        }
                    }
                }
            }
        });
    }

    protected int changeSeatIndexToModelIndex(int srcSeatIndex) {
        return srcSeatIndex + 1;
    }

    protected void showImMsg(final MsgEntity entity) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mMsgEntityList.size() > 1000) {
                    while (mMsgEntityList.size() > 900) {
                        mMsgEntityList.remove(0);
                    }
                }
                if (!TextUtils.isEmpty(entity.userName)) {
                    if (mMessageColorIndex >= MESSAGE_USERNAME_COLOR_ARR.length) {
                        mMessageColorIndex = 0;
                    }
                    int color = MESSAGE_USERNAME_COLOR_ARR[mMessageColorIndex];
                    entity.color = getResources().getColor(color);
                    mMessageColorIndex ++;
                }
                mMsgEntityList.add(entity);
                mMsgListAdapter.notifyDataSetChanged();
                mRvImMsg.smoothScrollToPosition(mMsgListAdapter.getItemCount());
            }
        });
    }

}