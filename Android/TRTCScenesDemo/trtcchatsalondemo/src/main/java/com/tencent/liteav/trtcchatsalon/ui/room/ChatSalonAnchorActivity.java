package com.tencent.liteav.trtcchatsalon.ui.room;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.login.model.RoomManager;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonCallback;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonDef;
import com.tencent.liteav.trtcchatsalon.ui.base.ChatSalonMemberEntity;
import com.tencent.liteav.trtcchatsalon.ui.list.TCConstants;
import com.tencent.liteav.trtcchatsalon.ui.widget.CommonBottomDialog;
import com.tencent.liteav.trtcchatsalon.ui.widget.ConfirmDialogFragment;
import com.tencent.liteav.trtcchatsalon.ui.widget.HandUpListDialog;
import com.tencent.trtc.TRTCCloudDef;

public class ChatSalonAnchorActivity extends ChatSalonBaseActivity {
    public static final int ERROR_ROOM_ID_EXIT = -1301;
    private boolean mIsEnterRoom;

    /**
     * 创建房间
     */
    public static void createRoom(Context context, String roomName, String userId,
                                  String userName, String userAvatar, String coverUrl, int audioQuality, boolean needRequest) {
        Intent intent = new Intent(context, ChatSalonAnchorActivity.class);
        intent.putExtra(VOICEROOM_ROOM_NAME, roomName);
        intent.putExtra(VOICEROOM_USER_ID, userId);
        intent.putExtra(VOICEROOM_USER_NAME, userName);
        intent.putExtra(VOICEROOM_USER_AVATAR, userAvatar);
        intent.putExtra(VOICEROOM_AUDIO_QUALITY, audioQuality);
        intent.putExtra(VOICEROOM_ROOM_COVER, coverUrl);
        intent.putExtra(VOICEROOM_NEED_REQUEST, needRequest);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initAnchor();
    }

    @Override
    public void onBackPressed() {
        if (mIsEnterRoom) {
            showExitRoom();
        } else {
            finish();
        }
    }

    private void showExitRoom() {
        if (mConfirmDialogFragment.isAdded()) {
            mConfirmDialogFragment.dismiss();
        }
        mConfirmDialogFragment.setMessage(mContext.getString(R.string.trtcchatsalon_anchor_leave_room));
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
                destroyRoom();
                finish();
            }
        });
        mConfirmDialogFragment.show(getFragmentManager(), "confirm_fragment");
    }

    private void destroyRoom() {
        RoomManager.getInstance().destroyRoom(mRoomId, TCConstants.TYPE_CHAT_SALON, new RoomManager.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "destroyRoom success");
            }

            @Override
            public void onFailed(int code, String msg) {
                Log.d(TAG, "destroyRoom failed[" + code);
            }
        });
        mTRTCChatSalon.destroyRoom(new TRTCChatSalonCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    Log.d(TAG, "IM destroyRoom success");
                } else {
                    Log.d(TAG, "IM destroyRoom failed:" + msg);
                }
            }
        });
        mTRTCChatSalon.setDelegate(null);
        mMemberEntityMap.clear();
    }

    /**
     * 主播的逻辑
     */
    private void initAnchor() {
        mRoomOwnerId = mSelfUserId;
        //刷新界面的按钮
        mBtnMic.setActivated(true);
        mBtnMic.setSelected(true);
        mBtnHandUpList.setVisibility(View.VISIBLE);
        mRoomId = getRoomId();
        mCurrentRole = TRTCCloudDef.TRTCRoleAnchor;
        //设置昵称、头像
        mTRTCChatSalon.setSelfProfile(mUserName, mUserAvatar, null);
        RoomManager.getInstance().createRoom(mRoomId, TCConstants.TYPE_CHAT_SALON, new RoomManager.ActionCallback() {
            @Override
            public void onSuccess() {
                internalCreateRoom();
            }

            @Override
            public void onFailed(int code, String msg) {
                if (code == ERROR_ROOM_ID_EXIT) {
                    onSuccess();
                } else {
                    ToastUtils.showLong(getString(R.string.trtcchatsalon_create_room_failed) + "[" + code + "]:" + msg);
                    finish();
                }
            }
        });
        mBtnHandUpList.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onHandUpListBtnClick();
            }
        });
        mHandleInvitation.findViewById(R.id.dismiss).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mStateTips.setVisibility(View.GONE);
            }
        });
        mHandleInvitation.findViewById(R.id.accept).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ChatSalonMemberEntity entity = (ChatSalonMemberEntity) mHandleInvitation.getTag();
                if (entity != null) {
                    onAgreeInvite(entity);
                }
                mStateTips.setVisibility(View.GONE);
            }
        });
    }

    private void onHandUpListBtnClick() {
        if (mHandUpListDialog == null) {
            mHandUpListDialog = new HandUpListDialog(mContext);
            mHandUpListDialog.setList(mRequestSpeakMembers);
            mHandUpListDialog.setOnSelectedCallback(new HandUpListDialog.onSelectedCallback() {
                @Override
                public void onSelected(ChatSalonMemberEntity memberEntity) {
                    onAgreeInvite(memberEntity);
                }
            });
        }
        mHandUpListDialog.notifyDataSetChanged();
        mHandUpListDialog.show();
    }

    private void onAgreeInvite(final ChatSalonMemberEntity memberEntity) {
        if (memberEntity != null) {
           final String inviteId = memberEntity.invitedId;
            if (inviteId == null) {
                ToastUtils.showLong(R.string.trtcchatsalon_request_expired);
                return;
            }
            mTRTCChatSalon.acceptInvitation(inviteId, new TRTCChatSalonCallback.ActionCallback() {
                @Override
                public void onCallback(int code, String msg) {
                    if (code != 0) {
                        ToastUtils.showShort(mContext.getString(R.string.trtcchatsalon_accept_failed) + code);
                    }
                    mRequestSpeakMap.remove(memberEntity.userId);
                    mRequestSpeakMembers.remove(memberEntity);
                    mRequestIdMap.remove(inviteId);
                    if (mHandUpListDialog != null) {
                        mHandUpListDialog.notifyDataSetChanged();
                    }
                    updateHandUpCountView();
                }
            });
        }
    }

    @Override
    protected void onAnchorItemClick(ChatSalonMemberEntity entity) {
        if (entity != null) {
            if (!entity.userId.equals(mSelfUserId)) {
                kickUser(entity.userId);
            }
        }
    }

    private void kickUser(final String userId) {
        final CommonBottomDialog dialog = new CommonBottomDialog(this);
        dialog.setButton(new CommonBottomDialog.OnButtonClickListener() {
            @Override
            public void onClick(int position, String text) {
                dialog.dismiss();
                mTRTCChatSalon.kickSeat(userId, new TRTCChatSalonCallback.ActionCallback() {
                    @Override
                    public void onCallback(int code, String msg) {

                    }
                });
            }
        }, mContext.getString(R.string.trtcchatsalon_request_leave_mic));
        dialog.show();
    }

    private void internalCreateRoom() {
        final TRTCChatSalonDef.RoomParam roomParam = new TRTCChatSalonDef.RoomParam();
        roomParam.roomName = mRoomName;
        roomParam.needRequest = true;
        roomParam.coverUrl = mRoomCover;
        //        roomParam.coverUrl = ;
        mTRTCChatSalon.createRoom(mRoomId, roomParam, new TRTCChatSalonCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    mIsEnterRoom = true;
                    mToolbarTitle.setText(getString(R.string.trtcchatsalon_main_title, roomParam.roomName, mRoomId));
                    mTRTCChatSalon.setAudioQuality(mAudioQuality);
                    getAudienceList();
                }
            }
        });
    }

    private int getRoomId() {
        // 这里我们用简单的 userId hashcode，然后取余
        // 您的room id应该是您后台生成的唯一值
        return (mSelfUserId + "_voice_room").hashCode() & 0x7FFFFFFF;
    }

    @Override
    public void onReceiveNewInvitation(String id, String inviter, String cmd, String content) {
        super.onReceiveNewInvitation(id, inviter, cmd, content);
        Log.d(TAG, "onReceiveNewInvitation id:"+id+" inviter：" + inviter + " cmd：" + " content:" + content);
        if (cmd.equals(TCConstants.CMD_REQUEST_TAKE_SEAT)) {
            receiveTakeSeat(id, inviter, content);
        }
    }

    private void receiveTakeSeat(String inviteId, String inviter, String content) {
        ChatSalonMemberEntity memberEntity = mMemberEntityMap.get(inviter);
        if (memberEntity != null) {
            ChatSalonMemberEntity entity = mRequestSpeakMap.get(inviter);
            if (entity != null) {
                entity.invitedId = inviteId;
                mRequestIdMap.put(inviteId, entity);
            } else {
                memberEntity.invitedId = inviteId;
                mRequestSpeakMembers.add(memberEntity);
                mRequestSpeakMap.put(inviter, memberEntity);
                mRequestIdMap.put(inviteId, memberEntity);
            }
            updateHandUpCountView();
        }
    }

    @Override
    public void onInvitationTimeout(String id) {
        ChatSalonMemberEntity entity = mRequestIdMap.get(id);
        if (entity != null) {
            mRequestSpeakMap.remove(entity.userId);
            mRequestSpeakMembers.remove(entity);
            mRequestIdMap.remove(id);
            if (mHandUpListDialog != null) {
                mHandUpListDialog.notifyDataSetChanged();
            }
        }
        updateHandUpCountView();
    }

    private void updateHandUpCountView() {
        int count = mRequestSpeakMembers.size();
        if (count > 0) {
            mTvHandUpCount.setText(String.valueOf(count));
            mTvHandUpCount.setVisibility(View.VISIBLE);
            ChatSalonMemberEntity entity = mRequestSpeakMembers.getLast();
            if (entity != null) {
                mStateTips.removeAllViews();
                mStateTips.addView(mHandleInvitation);
                mStateTips.setVisibility(View.VISIBLE);
                String showName = !TextUtils.isEmpty(entity.userName) ? entity.userName : entity.userId;
                mHandleInvitationTextView.setText(mContext.getString(R.string.trtcchatsalon_request_an, showName));
                mHandleInvitation.setTag(entity);
            }
        } else {
            mTvHandUpCount.setVisibility(View.GONE);
            mStateTips.setVisibility(View.GONE);
        }
    }
}