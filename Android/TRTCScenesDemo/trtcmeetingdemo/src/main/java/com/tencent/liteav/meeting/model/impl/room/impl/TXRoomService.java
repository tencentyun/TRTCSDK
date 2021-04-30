package com.tencent.liteav.meeting.model.impl.room.impl;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMSimpleMsgListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.meeting.model.impl.base.TRTCLogger;
import com.tencent.liteav.meeting.model.impl.base.TXCallback;
import com.tencent.liteav.meeting.model.impl.base.TXUserInfo;
import com.tencent.liteav.meeting.model.impl.base.TXUserListCallback;
import com.tencent.liteav.meeting.model.impl.room.ITXRoomService;
import com.tencent.liteav.meeting.model.impl.room.ITXRoomServiceDelegate;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class TXRoomService implements ITXRoomService {
    private static final String TAG = "TXMeetingRoomService";

    private static final int CODE_ERROR = -1;

    private static TXRoomService        sInstance;
    private Context                     mContext;
    private ITXRoomServiceDelegate      mDelegate;
    private LiveRoomSimpleMsgListener   mSimpleListener;
    private LiveRoomGroupListener       mGroupListener;
    private boolean                     mIsInitIMSDK;
    private boolean                     mIsLogin;
    private boolean                     mIsEnterRoom;
    private String                      mRoomId;
    private String                      mSelfUserId;
    private String                      mOwnerUserId;

    public static synchronized TXRoomService getInstance() {
        if (sInstance == null) {
            sInstance = new TXRoomService();
        }
        return sInstance;
    }

    private TXRoomService() {
        mSelfUserId = "";
        mOwnerUserId = "";
        mRoomId = "";
        mSimpleListener = new LiveRoomSimpleMsgListener();
        mGroupListener = new LiveRoomGroupListener();
    }

    @Override
    public void init(Context context) {
        mContext = context;

    }

    @Override
    public void setDelegate(ITXRoomServiceDelegate delegate) {
        mDelegate = delegate;
    }

    @Override
    public void login(int sdkAppId, final String userId, String userSign, final TXCallback callback) {
        // 未初始化 IM 先初始化 IM
        if (!mIsInitIMSDK) {
            V2TIMSDKConfig config = new V2TIMSDKConfig();
            config.setLogLevel(V2TIMSDKConfig.V2TIM_LOG_DEBUG);
            mIsInitIMSDK = V2TIMManager.getInstance().initSDK(mContext, sdkAppId, config, new V2TIMSDKListener() {
                @Override
                public void onConnecting() {
                }

                @Override
                public void onConnectSuccess() {
                }

                @Override
                public void onConnectFailed(int code, String error) {
                    TRTCLogger.e(TAG, "init im sdk error.");
                }
            });

            if (!mIsInitIMSDK) {
                TRTCLogger.e(TAG, "init im sdk error.");
                if (callback != null) {
                    callback.onCallback(CODE_ERROR, "init im sdk error.");
                }
                return;
            }
        }
        // 登陆到 IM
        String loginedUserId = V2TIMManager.getInstance().getLoginUser();
        if (loginedUserId != null && loginedUserId.equals(userId)) {
            // 已经登录过了
            mIsLogin = true;
            mSelfUserId = userId;
            TRTCLogger.i(TAG, "login im success.");
            if (callback != null) {
                callback.onCallback(0, "login im success.");
            }
            return;
        }
        if (isLogin()) {
            TRTCLogger.e(TAG, "start login fail, you have been login, can't login twice.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "start login fail, you have been login, can't login twice.");
            }
            return;
        }
        V2TIMManager.getInstance().login(userId, userSign, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "login im fail, code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                mIsLogin = true;
                mSelfUserId = userId;
                TRTCLogger.i(TAG, "login im success.");
                if (callback != null) {
                    callback.onCallback(0, "login im success.");
                }
            }
        });
    }

    @Override
    public void logout(final TXCallback callback) {
        if (!isLogin()) {
            TRTCLogger.e(TAG, "start logout fail, not login yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "start logout fail, not login yet.");
            }
            return;
        }
        if (isEnterRoom()) {
            TRTCLogger.e(TAG, "start logout fail, you are in room:" + mRoomId + ", please exit room before logout.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "start logout fail, you are in room:" + mRoomId + ", please exit room before logout.");
            }
            return;
        }

        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "logout fail, code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                mIsLogin = false;
                mSelfUserId = "";
                TRTCLogger.i(TAG, "logout im success.");
                if (callback != null) {
                    callback.onCallback(0, "login im success.");
                }
            }
        });
    }

    @Override
    public void setSelfProfile(final String userName, final String avatarURL, final TXCallback callback) {
        if (!isLogin()) {
            TRTCLogger.e(TAG, "set profile fail, not login yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "set profile fail, not login yet.");
            }
            return;
        }

        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
        v2TIMUserFullInfo.setNickname(userName);
        v2TIMUserFullInfo.setFaceUrl(avatarURL);
        V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TRTCLogger.e(TAG, "set profile code:" + code + " msg:" + desc);
                if (callback != null) {
                    callback.onCallback(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "set profile success.");
                if (callback != null) {
                    callback.onCallback(0, "set profile success.");
                }
            }
        });
    }

    @Override
    public void createRoom(final String roomId, final String roomName, final String coverUrl, final TXCallback callback) {
        // 如果已经在一个房间了，则不允许再次进入
        if (isEnterRoom()) {
            TRTCLogger.e(TAG, "you have been in room:" + mRoomId + " can't create another room:" + roomId);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "you have been in room:" + mRoomId + " can't create another room:" + roomId);
            }
            return;
        }
        if (!isLogin()) {
            TRTCLogger.e(TAG, "im not login yet, create room fail.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "im not login yet, create room fail.");
            }
            return;
        }

        final V2TIMManager imManager = V2TIMManager.getInstance();
        imManager.createGroup(V2TIMManager.GROUP_TYPE_MEETING, roomId, roomName, new V2TIMValueCallback<String>() {
            @Override
            public void onError(int code, String s) {
                String msg = s;
                if (code == 10036) {
                    msg = mContext.getString(R.string.meeting_create_room_limit);
                }
                if (code == 10037) {
                    msg = mContext.getString(R.string.meeting_create_or_join_group_limit);
                }
                if (code == 10038) {
                    msg = mContext.getString(R.string.meeting_group_member_limit);
                }
                if (code == 10025) {
                    // 10025 表明群主是自己，那么认为创建房间成功
                    onSuccess("success");
                } else {
                    TRTCLogger.e(TAG, "create room fail, code:" + code + " msg:" + msg);
                    if (callback != null) {
                        callback.onCallback(code, msg);
                    }
                }
            }

            @Override
            public void onSuccess(String s) {
                cleanStatus();
                V2TIMManager.getInstance().addSimpleMsgListener(mSimpleListener);
                V2TIMManager.getInstance().setGroupListener(mGroupListener);

                mIsEnterRoom = true;

                mRoomId = roomId;

                mOwnerUserId = mSelfUserId;

                TRTCLogger.i(TAG, "create room success.");
                if (callback != null) {
                    callback.onCallback(0, "create room success.");
                }
            }
        });
    }

    @Override
    public void destroyRoom(final TXCallback callback) {
        // Todo: 此处存疑，待解答：摧毁房间的时候，需要优先清空群简介，否者有可能开同样的房，观众会有异常。
        List<String> groupList = new ArrayList<>(Arrays.asList(mRoomId));
        V2TIMManager.getGroupManager().getGroupsInfo(groupList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "room owner get group info fail, code: " + i + " msg:" + s);
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                if (v2TIMGroupInfoResults != null && v2TIMGroupInfoResults.size() == 1) {
                    V2TIMGroupInfoResult v2TIMGroupInfoResult = v2TIMGroupInfoResults.get(0);
                    V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
                    v2TIMGroupInfo.setGroupID(v2TIMGroupInfoResult.getGroupInfo().getGroupID());
                    v2TIMGroupInfo.setGroupName(v2TIMGroupInfoResult.getGroupInfo().getGroupName());
                    v2TIMGroupInfo.setFaceUrl(v2TIMGroupInfoResult.getGroupInfo().getFaceUrl());
                    v2TIMGroupInfo.setGroupType(v2TIMGroupInfoResult.getGroupInfo().getGroupType());
                    v2TIMGroupInfo.setIntroduction("");

                    V2TIMManager.getGroupManager().setGroupInfo(v2TIMGroupInfo, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TRTCLogger.e(TAG, "destroyRoom room owner update anchor list into group introduction fail, code: " + code + " msg:" + desc);
                            if (callback != null) {
                                callback.onCallback(code, desc);
                            }
                        }

                        @Override
                        public void onSuccess() {
                            TRTCLogger.i(TAG, "room owner update anchor list into group introduction success");
                            V2TIMManager.getInstance().dismissGroup(mRoomId, new V2TIMCallback() {
                                @Override
                                public void onError(int i, String s) {
                                    TRTCLogger.e(TAG, "destroy room fail, code:" + i + " msg:" + s);
                                    if (callback != null) {
                                        callback.onCallback(i, s);
                                    }
                                }

                                @Override
                                public void onSuccess() {
                                    TRTCLogger.d(TAG, "destroyRoom remove GroupListener roomId: " + mRoomId + " mGroupListener: " + mGroupListener.hashCode());
                                    V2TIMManager.getInstance().removeSimpleMsgListener(mSimpleListener);
                                    V2TIMManager.getInstance().setGroupListener(null);

                                    cleanStatus();

                                    TRTCLogger.i(TAG, "destroy room success.");
                                    if (callback != null) {
                                        callback.onCallback(0, "destroy room success.");
                                    }
                                }
                            });
                        }
                    });
                }
            }
        });
    }

    @Override
    public void enterRoom(final String roomId, final TXCallback callback) {
        List<String> groupList = new ArrayList<>(Arrays.asList(roomId));
        V2TIMManager.getGroupManager().getGroupsInfo(groupList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "get group info error, enter room fail. code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(-1, "get group info error, enter room fail. code:" + i + " msg:" + s);
                }
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                TRTCLogger.i(TAG, "get group info success.");
                if (v2TIMGroupInfoResults != null && v2TIMGroupInfoResults.size() == 1) {
                    final V2TIMGroupInfoResult v2TIMGroupInfoResult = v2TIMGroupInfoResults.get(0);
                    if (v2TIMGroupInfoResult != null) {
                        final String ownerUserId = v2TIMGroupInfoResult.getGroupInfo().getOwner();
                        V2TIMManager.getInstance().joinGroup(roomId, "", new V2TIMCallback() {
                            @Override
                            public void onError(int i, String s) {
                                // 已经是群成员了，可以继续操作
                                if (i == 10013) {
                                    onSuccess();
                                } else {
                                    TRTCLogger.e(TAG, "enter room fail, code:" + i + " msg:" + s);
                                    if (callback != null) {
                                        callback.onCallback(i, s);
                                    }
                                }
                            }

                            @Override
                            public void onSuccess() {
                                V2TIMManager.getInstance().addSimpleMsgListener(mSimpleListener);
                                V2TIMManager.getInstance().setGroupListener(mGroupListener);
                                cleanStatus();

                                TRTCLogger.i(TAG, "enter room success.");
                                mRoomId = roomId;
                                mIsEnterRoom = true;
                                mOwnerUserId = ownerUserId;
                                if (callback != null) {
                                    callback.onCallback(0, "enter room success.");
                                }
                            }
                        });
                    } else {
                        if (callback != null) {
                            callback.onCallback(-1, "");
                        }
                    }
                }
            }
        });
    }

    @Override
    public void exitRoom(final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "not enter room yet, can't exit room.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "not enter room yet, can't exit room.");
            }
            return;
        }
        V2TIMManager.getInstance().quitGroup(mRoomId, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "exit room fail, code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "exit room success.");
                V2TIMManager.getInstance().removeSimpleMsgListener(mSimpleListener);
                V2TIMManager.getInstance().setGroupListener(null);
                cleanStatus();

                if (callback != null) {
                    callback.onCallback(0, "exit room success.");
                }
            }
        });
    }

    public void handleAnchorEnter(String userId) {
    }

    public void handleAnchorExit(String userId) {
    }

    @Override
    public void getUserInfo(final List<String> userList, final TXUserListCallback callback) {
        if (userList == null || userList.size() == 0) {
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "get user info list fail, user list is empty.", new ArrayList<TXUserInfo>());
            }
            return;
        }

        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "get user info list fail, code:" + i);
                if (callback != null) {
                    callback.onCallback(i, s, new ArrayList<TXUserInfo>());
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                TRTCLogger.i(TAG, "get user info list success, code:" + v2TIMUserFullInfos.size());
                List<TXUserInfo> list = new ArrayList<>();
                if (v2TIMUserFullInfos != null && v2TIMUserFullInfos.size() != 0) {
                    for (int i = 0; i < v2TIMUserFullInfos.size(); i++) {
                        TXUserInfo userInfo = new TXUserInfo();
                        userInfo.userName = v2TIMUserFullInfos.get(i).getNickName();
                        userInfo.userId = v2TIMUserFullInfos.get(i).getUserID();
                        userInfo.avatarURL = v2TIMUserFullInfos.get(i).getFaceUrl();
                        list.add(userInfo);
                    }
                }
                if (callback != null) {
                    callback.onCallback(0, "success", list);
                }
            }
        });
    }

    @Override
    public void sendRoomTextMsg(String msg, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room text fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room text fail, not enter room yet.");
            }
            return;
        }

        V2TIMManager.getInstance().sendGroupTextMessage(msg, mRoomId, V2TIMMessage.V2TIM_PRIORITY_LOW, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "message send fail, code: " + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                if (callback != null) {
                    callback.onCallback(0, "send group message success.");
                }
            }
        });
    }

    @Override
    public void sendRoomCustomMsg(String cmd, String message, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room custom msg fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room custom msg fail, not enter room yet.");
            }
            return;
        }

        String data = IMProtocol.getCusMsgJsonStr(cmd, message);

        V2TIMManager.getInstance().sendGroupCustomMessage(data.getBytes(), mRoomId, V2TIMMessage.V2TIM_PRIORITY_LOW, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                if (callback != null) {
                    callback.onCallback(0, "send group message success.");
                }
            }
        });
    }

    @Override
    public boolean isLogin() {
        return mIsLogin;
    }

    @Override
    public boolean isEnterRoom() {
        return mIsLogin && mIsEnterRoom;
    }

    @Override
    public String getOwnerUserId() {
        return mOwnerUserId;
    }

    @Override
    public boolean isOwner() {
        return mSelfUserId.equals(mOwnerUserId);
    }

    private void cleanStatus() {
        mIsEnterRoom = false;
        mRoomId = "";
        mOwnerUserId = "";
    }

    private void onRecvC2COrGroupMessage(final TXUserInfo txUserInfo, byte[] customData) {
        final ITXRoomServiceDelegate delegate = mDelegate;
        String customStr = new String(customData);

        TRTCLogger.i(TAG, "im msg dump, sender id:" + txUserInfo.userId + " customStr:" + customStr);
        if (!TextUtils.isEmpty(customStr)) {
            // 一定会有自定义消息的头
            try {
                JSONObject jsonObject = new JSONObject(customStr);
                String version = jsonObject.getString(IMProtocol.Define.KEY_VERSION);
                if (!version.equals(IMProtocol.Define.VALUE_PROTOCOL_VERSION)) {
                    TRTCLogger.e(TAG, "protocol version is not match, ignore msg.");
                }
                int action = jsonObject.getInt(IMProtocol.Define.KEY_ACTION);

                switch (action) {
                    case IMProtocol.Define.CODE_UNKNOWN:
                        // ignore
                        break;
                    case IMProtocol.Define.CODE_ROOM_CUSTOM_MSG:
                        Pair<String, String> cusPair = IMProtocol.parseCusMsg(jsonObject);
                        if (delegate != null && cusPair != null) {
                            delegate.onRoomRecvRoomCustomMsg(mRoomId, cusPair.first, cusPair.second, txUserInfo);
                        }
                        break;
                    default:
                        break;
                }
            } catch (JSONException e) {
                // ignore 无需关注的消息
            }
        }
    }

    private class LiveRoomSimpleMsgListener extends V2TIMSimpleMsgListener {

        @Override
        public void onRecvC2CTextMessage(String msgID, V2TIMUserInfo sender, String text) {
        }

        @Override
        public void onRecvC2CCustomMessage(String msgID, V2TIMUserInfo sender, byte[] customData) {
            TXUserInfo txUserInfo = new TXUserInfo();
            txUserInfo.userId = sender.getUserID();
            txUserInfo.userName = sender.getNickName();
            txUserInfo.avatarURL = sender.getFaceUrl();
            onRecvC2COrGroupMessage(txUserInfo, customData);
        }

        @Override
        public void onRecvGroupTextMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, String text) {
            final TXUserInfo txUserInfo = new TXUserInfo();
            txUserInfo.userId = sender.getUserID();
            txUserInfo.userName = sender.getNickName();
            txUserInfo.avatarURL = sender.getFaceUrl();

            if (mDelegate != null) {
                mDelegate.onRoomRecvRoomTextMsg(groupID, text, txUserInfo);
            }
        }

        @Override
        public void onRecvGroupCustomMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData) {
            TXUserInfo txUserInfo = new TXUserInfo();
            txUserInfo.userId = sender.getUserID();
            txUserInfo.userName = sender.getNickName();
            txUserInfo.avatarURL = sender.getFaceUrl();
            onRecvC2COrGroupMessage(txUserInfo, customData);
        }
    }

    private class LiveRoomGroupListener extends V2TIMGroupListener {
        @Override
        public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
        }

        @Override
        public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
        }

        @Override
        public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
            TXCLog.i(TAG, "recv room destroy msg");
            // 这里房主 IM 也会收到消息，但是由于我在 destroyGroup 成功的时候，把消息监听移除了，所以房主是不会走到这里的
            // 因此不需要做逻辑拦截。

            // 如果发现房间已经解散，那么内部退一次房间
            exitRoom(new TXCallback() {
                @Override
                public void onCallback(int code, String msg) {
                    TRTCLogger.i(TAG, "recv room destroy msg, exit room inner, code:" + code + " msg:" + msg);
                    // 无论结果是否成功，都清空状态，并且回调出去
                    String roomId = mRoomId;
                    cleanStatus();
                    ITXRoomServiceDelegate delegate = mDelegate;
                    if (delegate != null) {
                        delegate.onRoomDestroy(roomId);
                    }
                }
            });
        }

        @Override
        public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
            super.onGroupInfoChanged(groupID, changeInfos);
        }
    }

}
