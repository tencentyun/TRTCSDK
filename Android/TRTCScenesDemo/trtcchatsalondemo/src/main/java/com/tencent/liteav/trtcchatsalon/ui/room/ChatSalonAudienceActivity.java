package com.tencent.liteav.trtcchatsalon.ui.room;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonCallback;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonDef;
import com.tencent.liteav.trtcchatsalon.ui.list.TCConstants;
import com.tencent.liteav.trtcchatsalon.ui.widget.ConfirmDialogFragment;
import com.tencent.trtc.TRTCCloudDef;

/**
 * 观众界面
 */
public class ChatSalonAudienceActivity extends ChatSalonBaseActivity {
    private String mOwnerId;
    private Runnable mTimeoutRunnable;

    public static void enterRoom(Context context, int roomId, String userId, int audioQuality) {
        Intent starter = new Intent(context, ChatSalonAudienceActivity.class);
        starter.putExtra(VOICEROOM_ROOM_ID, roomId);
        starter.putExtra(VOICEROOM_USER_ID, userId);
        starter.putExtra(VOICEROOM_AUDIO_QUALITY, audioQuality);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initAudience();
    }

    private void initAudience() {
        mBtnHandUp.setVisibility(View.VISIBLE);
        enterRoom();
        refreshView();
        mBtnHandUp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!TextUtils.isEmpty(mSelfUserId)) {
                    startTakeSeat(mSelfUserId);
                }
            }
        });
        mHandUpTipsView = View.inflate(this, R.layout.trtcchatsalon_layout_hand_up_tips, null);
        mBtnLeaveMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCChatSalon.leaveSeat(null);
            }
        });
    }

    private void refreshView() {
        if (mCurrentRole == TRTCCloudDef.TRTCRoleAnchor) {
            mBtnMic.setActivated(true);
            mBtnMic.setSelected(true);
            mBtnLeaveMic.setVisibility(View.VISIBLE);
            mBtnMic.setVisibility(View.VISIBLE);
            mBtnHandUp.setVisibility(View.GONE);
            updateHandUpIcon(false);
        } else {
            mBtnMic.setActivated(false);
            mBtnLeaveMic.setVisibility(View.GONE);
            mBtnMic.setVisibility(View.GONE);
            mBtnHandUp.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onBackPressed() {
        showExitRoom();
    }

    private void exitRoom() {
        mTRTCChatSalon.exitRoom(new TRTCChatSalonCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                ToastUtils.showShort(R.string.trtcchatsalon_exit_room_success);
            }
        });
        mMemberEntityMap.clear();
    }

    private void showExitRoom() {
        if (mConfirmDialogFragment.isAdded()) {
            mConfirmDialogFragment.dismiss();
        }
        mConfirmDialogFragment.setMessage(mContext.getString(R.string.trtcchatsalon_audience_leave_room));
        mConfirmDialogFragment.setNegativeClickListener(new ConfirmDialogFragment.NegativeClickListener() {
            @Override
            public void onClick() {
                mConfirmDialogFragment.dismiss();
            }
        });
        mConfirmDialogFragment.setPositiveClickListener(new ConfirmDialogFragment.PositiveClickListener() {
            @Override
            public void onClick() {
                mConfirmDialogFragment.dismiss();
                exitRoom();
                finish();
            }
        });
        mConfirmDialogFragment.show(getFragmentManager(), "confirm_fragment");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void enterRoom() {
        mCurrentRole = TRTCCloudDef.TRTCRoleAudience;
        mTRTCChatSalon.enterRoom(mRoomId, new TRTCChatSalonCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    //进房成功
                    ToastUtils.showShort(R.string.trtcchatsalon_enter_room_success);
                    mTRTCChatSalon.setAudioQuality(mAudioQuality);
                    getAudienceList();
                } else {
                    ToastUtils.showShort(getString(R.string.trtcchatsalon_enter_room_failed) + "[" + code + "]:" + msg);
                    finish();
                }
            }
        });
    }

    private void startTakeSeat(String userId) {
        if (mCurrentRole == TRTCCloudDef.TRTCRoleAnchor) {
            ToastUtils.showShort(R.string.trtcchatsalon_already_anchor);
            return;
        }
        //需要申请上麦
        if (mOwnerId == null) {
            ToastUtils.showShort(R.string.trtcchatsalon_room_not_ready);
            return;
        }
        mTRTCChatSalon.sendInvitation(TCConstants.CMD_REQUEST_TAKE_SEAT, mOwnerId, userId, new TRTCChatSalonCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    mStateTips.removeAllViews();
                    mStateTips.addView(mHandUpTipsView);
                    mStateTips.setVisibility(View.VISIBLE);
                    updateHandUpIcon(true);
                } else if(code == TRTCChatSalonDef.INVITATION_REQUEST_LIMIT) {
                    ToastUtils.showShort(getString(R.string.trtcchatsalon_invitation_limit));
                } else {
                    ToastUtils.showShort(getString(R.string.trtcchatsalon_request_failed) + ":" + msg);
                    updateHandUpIcon(false);
                    mStateTips.setVisibility(View.GONE);
                }
            }
        });
    }

    private void updateHandUpIcon(boolean open) {
        if (open) {
            mBtnHandUp.setActivated(true);
            mBtnHandUp.setSelected(true);
            mBtnHandUp.setEnabled(false);
        } else {
            mBtnHandUp.setActivated(false);
            mBtnHandUp.setEnabled(true);
        }
        mHandler.removeCallbacks(mTimeoutRunnable);
        mTimeoutRunnable = new Runnable() {
            @Override
            public void run() {
                mBtnHandUp.setActivated(false);
                mBtnHandUp.setEnabled(true);
                mStateTips.setVisibility(View.GONE);
            }
        };
        mHandler.postDelayed(mTimeoutRunnable, 3000);
    }



    @Override
    public void onRoomInfoChange(TRTCChatSalonDef.RoomInfo roomInfo) {
        super.onRoomInfoChange(roomInfo);
        mOwnerId = roomInfo.ownerId;
    }

    @Override
    public void onReceiveNewInvitation(final String id, String inviter, String cmd, final String content) {
        super.onReceiveNewInvitation(id, inviter, cmd, content);
    }

    @Override
    public void onInviteeAccepted(String id, String invitee) {
        super.onInviteeAccepted(id, invitee);
        Log.d(TAG, "onInviteeAccepted id:" + id + " invitee:" + invitee + " userId:" + mSelfUserId);
        mStateTips.setVisibility(View.GONE);
        mTRTCChatSalon.enterSeat(new TRTCChatSalonCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
            }
        });
    }

    @Override
    public void onSeatMute(String seatUserId, boolean isMute) {
        super.onSeatMute(seatUserId, isMute);
    }

    @Override
    public void onAnchorEnterSeat(TRTCChatSalonDef.UserInfo user) {
        super.onAnchorEnterSeat(user);
        String userId = user.userId;
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        if (user.userId.equals(mSelfUserId)) {
            mCurrentRole = TRTCCloudDef.TRTCRoleAnchor;
            refreshView();
        }
    }

    @Override
    public void onAnchorLeaveSeat(TRTCChatSalonDef.UserInfo user) {
        super.onAnchorLeaveSeat(user);
        String userId = user.userId;
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        if (user.userId.equals(mSelfUserId)) {
            mCurrentRole = TRTCCloudDef.TRTCRoleAudience;
            refreshView();
        }
    }

    @Override
    public void onRoomDestroy(String roomId) {
        super.onRoomDestroy(roomId);
        ToastUtils.showLong(R.string.trtcchatsalon_room_destroy);
        mTRTCChatSalon.exitRoom(null);
        finish();
    }
}