package com.tencent.liteav.trtcchatsalon.model.impl.room.impl;

import android.content.Context;
import android.text.TextUtils;
import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMSignalingListener;
import com.tencent.imsdk.v2.V2TIMSimpleMsgListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXCallback;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXInviteData;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXRoomInfo;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXRoomInfoListCallback;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXUserInfo;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXUserListCallback;
import com.tencent.liteav.trtcchatsalon.model.impl.room.ITXRoomServiceDelegate;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TXRoomService extends V2TIMSDKListener {
    private static final String TAG = "TXRoomService";

    private static final int CODE_ERROR = -1;
    private static final int MAX_INVITATION_TIME_OUT = 20; //邀请超时时间10s

    private static TXRoomService          sInstance;
    private        Context                mContext;
    private        ITXRoomServiceDelegate mDelegate;
    private        boolean                mIsInitIMSDK;
    private        boolean                mIsLogin;
    private        boolean                mIsEnterRoom;

    private String                  mRoomId;
    private String                  mSelfUserId;
    private String                  mOwnerUserId;
    private TXRoomInfo              mTXRoomInfo;
    private VoiceRoomSimpleListener mSimpleListener;
    private String                  mSelfUserName;
    private VoiceRoomGroupListener  mGroupListener;
    private VoiceRoomSignalListener mSignalListener;

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
        mTXRoomInfo = null;
        mSimpleListener = new VoiceRoomSimpleListener();
        mGroupListener = new VoiceRoomGroupListener();
        mSignalListener = new VoiceRoomSignalListener();
    }

    public void init(Context context) {
        mContext = context;
    }

    public void setDelegate(ITXRoomServiceDelegate delegate) {
        mDelegate = delegate;
    }

    public void login(int sdkAppId, final String userId, String userSig, final TXCallback callback) {
        // 未初始化 IM 先初始化 IM
        if (!mIsInitIMSDK) {
            V2TIMSDKConfig config = new V2TIMSDKConfig();
            mIsInitIMSDK = V2TIMManager.getInstance().initSDK(mContext, sdkAppId, config, this);
            if (!mIsInitIMSDK) {
                TRTCLogger.e(TAG, "init im sdk error.");
                if (callback != null) {
                    callback.onCallback(CODE_ERROR, "init im sdk error.");
                }
                return;
            }
        }
        mIsInitIMSDK = true;
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
        V2TIMManager.getInstance().login(userId, userSig, new V2TIMCallback() {
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
                getSelfInfo();
                if (callback != null) {
                    callback.onCallback(0, "login im success.");
                }
            }
        });
    }

    private void initIMListener() {
        V2TIMManager.getInstance().setGroupListener(mGroupListener);
        V2TIMManager.getSignalingManager().addSignalingListener(mSignalListener);
        V2TIMManager.getInstance().addSimpleMsgListener(mSimpleListener);
    }

    private void unInitImListener() {
        V2TIMManager.getInstance().setGroupListener(null);
        V2TIMManager.getSignalingManager().removeSignalingListener(mSignalListener);
        V2TIMManager.getInstance().removeSimpleMsgListener(mSimpleListener);
    }

    private void getSelfInfo() {
        List<String> userIds = new ArrayList<>();
        userIds.add(mSelfUserId);
        V2TIMManager.getInstance().getUsersInfo(userIds, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int i, String s) {

            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                mSelfUserName = v2TIMUserFullInfos.get(0).getNickName();
            }
        });
    }

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

    public void setSelfProfile(final String userName, final String avatarUrl, final TXCallback callback) {
        if (!isLogin()) {
            TRTCLogger.e(TAG, "set profile fail, not login yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "set profile fail, not login yet.");
            }
            return;
        }
        mSelfUserName = userName;
        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
        v2TIMUserFullInfo.setNickname(userName);
        v2TIMUserFullInfo.setFaceUrl(avatarUrl);
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

    public void createRoom(final String roomId, final String roomName, final String coverUrl, boolean needRequest, final TXCallback callback) {
        if (!isLogin()) {
            TRTCLogger.e(TAG, "im not login yet, create room fail.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "im not login yet, create room fail.");
            }
            return;
        }
        final V2TIMManager manager = V2TIMManager.getInstance();
        mRoomId = roomId;
        mOwnerUserId = mSelfUserId;
        mTXRoomInfo = new TXRoomInfo();
        mTXRoomInfo.ownerId = mSelfUserId;
        mTXRoomInfo.ownerName = mSelfUserName;
        mTXRoomInfo.roomName = roomName;
        mTXRoomInfo.cover = coverUrl;
        mTXRoomInfo.needRequest = needRequest ? 1 : 0;
        manager.createGroup(V2TIMManager.GROUP_TYPE_AVCHATROOM, roomId, roomName, new V2TIMValueCallback<String>() {
            @Override
            public void onError(final int code, String s) {
                TRTCLogger.e(TAG, "createRoom error " + code);
                String msg = s;
                // 通用提示
                if (code == 10036) {
                    msg = mContext.getString(R.string.trtcchatsalon_create_room_limit);
                }
                if (code == 10037) {
                    msg = mContext.getString(R.string.trtcchatsalon_create_or_join_group_limit);
                }
                if (code == 10038) {
                    msg = mContext.getString(R.string.trtcchatsalon_group_member_limit);
                }
                //特殊处理
                if (code == 10025 || code == 10021) {
                    // 10025 表明群主是自己，那么认为创建房间成功
                    // 群组 ID 已被其他人使用，此时走进房逻辑
                    setGroupInfo(roomId, roomName, coverUrl, mSelfUserName);
                    manager.joinGroup(roomId, "", new V2TIMCallback() {
                        @Override
                        public void onError(int code, String msg) {
                            TRTCLogger.e(TAG, "group has been created.join group failed, code:" + code + " msg:" + msg);
                            if (callback != null) {
                                callback.onCallback(code, msg);
                            }
                        }

                        @Override
                        public void onSuccess() {
                            TRTCLogger.i(TAG, "group has been created.join group success.");
                            onCreateSuccess(callback);
                        }
                    });
                } else {
                    TRTCLogger.e(TAG, "create room fail, code:" + code + " msg:" + msg);
                    if (callback != null) {
                        callback.onCallback(code, msg);
                    }
                }
            }

            @Override
            public void onSuccess(String s) {
                setGroupInfo(roomId, roomName, coverUrl, mSelfUserName);
                onCreateSuccess(callback);
            }
        });
    }

    /**
     * 将一些基本信息写到IM里面方便列表的读取
     *
     * @param roomId
     * @param roomName
     * @param coverUrl
     * @param userName
     */
    private void setGroupInfo(String roomId, String roomName, String coverUrl, String userName) {
        V2TIMGroupInfo groupInfo = new V2TIMGroupInfo();
        groupInfo.setGroupID(roomId);
        groupInfo.setGroupName(roomName);
        groupInfo.setFaceUrl(coverUrl);
        groupInfo.setIntroduction(userName);
        V2TIMManager.getGroupManager().setGroupInfo(groupInfo, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.w(TAG, "set group info error:" + i + " msg:" + s);
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "set group info success");
            }
        });
    }

    private void onCreateSuccess(final TXCallback callback) {
        // 创建房间成功
        initIMListener();
//        // 创建房间需要初始化座位
        V2TIMManager.getGroupManager().initGroupAttributes(mRoomId, IMProtocol.getInitRoomMap(mTXRoomInfo), new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.i(TAG, "init room info and seat failed. code:" + i);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                mIsEnterRoom = true;
                TRTCLogger.i(TAG, "create room success.");
                if (callback != null) {
                    callback.onCallback(0, "init room info and seat success");
                }
            }
        });
    }

    public void destroyRoom(final TXCallback callback) {
        if (!isOwner()) {
            TRTCLogger.e(TAG, "only owner could destroy room");
            if (callback != null) {
                callback.onCallback(-1, "only owner could destroy room");
            }
            return;
        }
        V2TIMManager.getInstance().dismissGroup(mRoomId, new V2TIMCallback() {
            @Override
            public void onError(int code, String msg) {
                if (code == 10007) {
                    //权限不足
                    TRTCLogger.i(TAG, "you're not real owner, start logic destroy.");
                    //清空群属性
                    cleanGroupAttr();
                    sendGroupMsg(IMProtocol.getRoomDestroyMsg(), callback);
                    unInitImListener();
                    cleanStatus();
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "you're real owner, destroy success.");
                unInitImListener();
                cleanStatus();
                if (callback != null) {
                    callback.onCallback(0, "destroy success.");
                }
            }
        });
    }

    private void cleanGroupAttr() {
        V2TIMManager.getGroupManager().deleteGroupAttributes(mRoomId, null, null);
    }

    public void enterRoom(final String roomId, final TXCallback callback) {
        cleanStatus();
        mRoomId = roomId;
        V2TIMManager.getInstance().joinGroup(roomId, "", new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                if (i == 10013) {
                    onSuccess();
                } else {
                    TRTCLogger.e(TAG, "join group error, enter room fail. code:" + i + " msg:" + s);
                    if (callback != null) {
                        callback.onCallback(-1, "join group error, enter room fail. code:" + i + " msg:" + s);
                    }
                }
            }

            @Override
            public void onSuccess() {
                V2TIMManager.getGroupManager().getGroupAttributes(roomId, null, new V2TIMValueCallback<Map<String, String>>() {
                    @Override
                    public void onError(int i, String s) {
                        TRTCLogger.e(TAG, "get group attrs error, enter room fail. code:" + i + " msg:" + s);
                        if (callback != null) {
                            callback.onCallback(-1, "get group attrs error, enter room fail. code:" + i + " msg:" + s);
                        }
                    }

                    @Override
                    public void onSuccess(Map<String, String> attrMap) {
                        initIMListener();
                        //开始解析room info
                        mTXRoomInfo = IMProtocol.getRoomInfoFromAttr(attrMap);
                        if (mTXRoomInfo == null) {
                            TRTCLogger.e(TAG, "group room info is empty, enter room fail.");
                            if (callback != null) {
                                callback.onCallback(-1, "group room info is empty, enter room fail.");
                            }
                            return;
                        }
                        mTXRoomInfo.roomId = roomId;
                        TRTCLogger.i(TAG, "enter room success: " + mRoomId);
                        mIsEnterRoom = true;
                        mOwnerUserId = mTXRoomInfo.ownerId;
                        // 回调给上层
                        if (mDelegate != null) {
                            mDelegate.onRoomInfoChange(mTXRoomInfo);
                        }
                        if (callback != null) {
                            callback.onCallback(0, "enter room success.");
                        }
                    }
                });
            }
        });
    }

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
                unInitImListener();
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "exit room success.");
                unInitImListener();
                cleanStatus();

                if (callback != null) {
                    callback.onCallback(0, "exit room success.");
                }
            }
        });
    }

    public void getUserInfo(final List<String> userList, final TXUserListCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "get user info list fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "get user info list fail, not enter room yet.", new ArrayList<TXUserInfo>());
            }
            return;
        }
        if (userList == null || userList.size() == 0) {
            TRTCLogger.e(TAG, "get user info list fail, user list is empty.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "get user info list fail, user list is empty.", new ArrayList<TXUserInfo>());
            }
            return;
        }
        TRTCLogger.i(TAG, "get user info list " + userList);
        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "get user info list fail, code:" + i);
                if (callback != null) {
                    callback.onCallback(i, s, null);
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
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

    public void sendRoomTextMsg(final String msg, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room text fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room text fail, not enter room yet.");
            }
            return;
        }

        V2TIMManager.getInstance().sendGroupTextMessage(msg, mRoomId, V2TIMMessage.V2TIM_PRIORITY_NORMAL, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "sendGroupTextMessage error " + i + " msg:" + msg);
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

    public void sendRoomCustomMsg(String cmd, String message, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room custom msg fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room custom msg fail, not enter room yet.");
            }
            return;
        }
        sendGroupMsg(IMProtocol.getCusMsgJsonStr(cmd, message), callback);
    }

    public void sendKickMsg(String userId, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room kick msg fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room kick msg fail, not enter room yet.");
            }
            return;
        }
        sendC2CMsg(IMProtocol.getKickMsgJsonStr(userId), userId, callback);
    }

    public void sendPickMsg(String userId, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room pick msg fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room pick msg fail, not enter room yet.");
            }
            return;
        }
        sendC2CMsg(IMProtocol.getPickMsgJsonStr(userId), userId, callback);
    }


    public void sendGroupMsg(String data, final TXCallback callback) {
        V2TIMManager.getInstance().sendGroupCustomMessage(data.getBytes(), mRoomId, V2TIMMessage.V2TIM_PRIORITY_NORMAL, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "sendGroupMsg error " + i + " msg:" + s);
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

    public void sendC2CMsg(String data, String userId, final TXCallback callback) {
        V2TIMManager.getInstance().sendC2CCustomMessage(data.getBytes(), userId, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "sendC2CMsg error " + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                if (callback != null) {
                    callback.onCallback(0, "send c2c message success.");
                }
            }
        });
    }

    public boolean isLogin() {
        return mIsLogin;
    }

    public boolean isEnterRoom() {
        return mIsLogin && mIsEnterRoom;
    }

    public String getOwnerUserId() {
        return mOwnerUserId;
    }

    public boolean isOwner() {
        return mSelfUserId.equals(mOwnerUserId);
    }

    private void cleanStatus() {
        mIsEnterRoom = false;
        mRoomId = "";
        mOwnerUserId = "";
    }

    public void onSeatTake(final String user) {
        TRTCLogger.i(TAG, "onSeatTake " + " userInfo:" + user);
        List<String> userIdList = new ArrayList<>();
        userIdList.add(user);
        getUserInfo(userIdList, new TXUserListCallback() {
            @Override
            public void onCallback(int code, String msg, List<TXUserInfo> list) {
                if (code == 0) {
                    if (mDelegate != null) {
                        mDelegate.onSeatTake(list.get(0));
                    }
                } else {
                    // 获取失败了
                    TRTCLogger.e(TAG, "onSeatTake get user info error!");
                    if (mDelegate != null) {
                        TXUserInfo userInfo = new TXUserInfo();
                        userInfo.userId = user;
                        mDelegate.onSeatTake(userInfo);
                    }
                }
            }
        });
    }

    public void onSeatLeave(final String user) {
        TRTCLogger.i(TAG, "onSeatLeave " + " userInfo:" + user);
        List<String> userIdList = new ArrayList<>();
        userIdList.add(user);
        getUserInfo(userIdList, new TXUserListCallback() {
            @Override
            public void onCallback(int code, String msg, List<TXUserInfo> list) {
                if (code == 0) {
                    if (mDelegate != null) {
                        mDelegate.onSeatLeave(list.get(0));
                    }
                } else {
                    // 获取失败了
                    TRTCLogger.e(TAG, "onSeatTake get user info error!");
                    if (mDelegate != null) {
                        TXUserInfo userInfo = new TXUserInfo();
                        userInfo.userId = user;
                        mDelegate.onSeatLeave(userInfo);
                    }
                }
            }
        });
    }

    public void onSeatMute(String userId, boolean mute) {
        TRTCLogger.i(TAG, "onSeatMute " + userId + " mute:" + mute);
        if (mDelegate != null) {
            mDelegate.onSeatMute(userId, mute);
        }
    }

    public void destroy() {

    }

    public String sendInvitation(String cmd, String userId, String content, final TXCallback callback) {
        String json = IMProtocol.getInvitationMsg(mRoomId, cmd, content);
        TRTCLogger.i(TAG, "send " + userId + " json:" + json);
        return V2TIMManager.getSignalingManager().invite(userId, json, MAX_INVITATION_TIME_OUT, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "sendInvitation error " + i);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "sendInvitation success ");
                if (callback != null) {
                    callback.onCallback(0, "send invitation success");
                }
            }
        });
    }

    public void acceptInvitation(String id, final TXCallback callback) {
        TRTCLogger.i(TAG, "acceptInvitation " + id);
        V2TIMManager.getSignalingManager().accept(id, null, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "acceptInvitation error " + i);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "acceptInvitation success ");
                if (callback != null) {
                    callback.onCallback(0, "send invitation success");
                }
            }
        });
    }

    public void rejectInvitation(String id, final TXCallback callback) {
        TRTCLogger.i(TAG, "rejectInvitation " + id);
        V2TIMManager.getSignalingManager().reject(id, null, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "rejectInvitation error " + i);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onCallback(0, "send invitation success");
                }
            }
        });
    }

    public void cancelInvitation(String id, final TXCallback callback) {
        TRTCLogger.i(TAG, "cancelInvitation " + id);
        V2TIMManager.getSignalingManager().cancel(id, null, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "cancelInvitation error " + i);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "cancelInvitation success ");
                if (callback != null) {
                    callback.onCallback(0, "send invitation success");
                }
            }
        });
    }

    public void getAudienceList(final TXUserListCallback txUserListCallback) {
        V2TIMManager.getGroupManager().getGroupMemberList(mRoomId, V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_COMMON, 0, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onError(int i, String s) {
                if (txUserListCallback != null) {
                    txUserListCallback.onCallback(i, s, new ArrayList<TXUserInfo>());
                }
            }

            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                List<TXUserInfo> userInfos = new ArrayList<>();
                if (v2TIMGroupMemberInfoResult.getMemberInfoList() != null) {
                    for (V2TIMGroupMemberFullInfo info : v2TIMGroupMemberInfoResult.getMemberInfoList()) {
                        TXUserInfo userInfo = new TXUserInfo();
                        userInfo.userId = info.getUserID();
                        userInfo.userName = info.getNickName();
                        userInfo.avatarURL = info.getFaceUrl();
                        userInfos.add(userInfo);
                    }
                }
                if (txUserListCallback != null) {
                    txUserListCallback.onCallback(0, "", userInfos);
                }
            }
        });
    }

    public void getRoomInfoList(final List<String> roomIds, final TXRoomInfoListCallback callback) {
        // TODO: 2020-06-10 由于IM的问题，所以这里只能从groupInfo里面查找
        V2TIMManager.getGroupManager().getGroupsInfo(roomIds, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                if (callback != null) {
                    callback.onCallback(i, s, new ArrayList<TXRoomInfo>());
                }
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                List<TXRoomInfo>            txRoomInfos        = new ArrayList<>();
                Map<String, V2TIMGroupInfo> groupInfoResultMap = new HashMap<>();
                // 注意 IM 返回的顺序可能不对，所以需要重新排序
                if (v2TIMGroupInfoResults != null) {
                    for (V2TIMGroupInfoResult result : v2TIMGroupInfoResults) {
                        V2TIMGroupInfo groupInfo = result.getGroupInfo();
                        // 防止为空
                        if (groupInfo == null) {
                            continue;
                        }
                        groupInfoResultMap.put(groupInfo.getGroupID(), groupInfo);
                    }
                    for (String roomId : roomIds) {
                        V2TIMGroupInfo groupInfo = groupInfoResultMap.get(roomId);
                        if (groupInfo == null) {
                            continue;
                        }
                        TXRoomInfo txRoomInfo = new TXRoomInfo();
                        txRoomInfo.roomId = groupInfo.getGroupID();
                        txRoomInfo.cover = groupInfo.getFaceUrl();
                        txRoomInfo.memberCount = groupInfo.getMemberCount();
                        txRoomInfo.ownerId = groupInfo.getOwner();
                        txRoomInfo.roomName = groupInfo.getGroupName();
                        txRoomInfo.ownerName = groupInfo.getIntroduction();
                        txRoomInfos.add(txRoomInfo);
                    }
                }
                if (callback != null) {
                    callback.onCallback(0, "", txRoomInfos);
                }
            }

        });
    }

    private class VoiceRoomSimpleListener extends V2TIMSimpleMsgListener {
        @Override
        public void onRecvGroupTextMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, String text) {
            TRTCLogger.i(TAG, "im get text msg group:" + groupID + " userid :" + sender.getUserID() + " text:" + text);
            if (!groupID.equals(mRoomId)) {
                return;
            }
            TXUserInfo userInfo = new TXUserInfo();
            userInfo.userId = sender.getUserID();
            userInfo.avatarURL = sender.getFaceUrl();
            userInfo.userName = sender.getNickName();
            if (mDelegate != null) {
                mDelegate.onRoomRecvRoomTextMsg(mRoomId, text, userInfo);
            }
        }

        @Override
        public void onRecvGroupCustomMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData) {
            if (!groupID.equals(mRoomId)) {
                return;
            }
            String customStr = new String(customData);
            if (!TextUtils.isEmpty(customStr)) {
                // 一定会有自定义消息的头
                try {
                    JSONObject jsonObject = new JSONObject(customStr);
                    String     version    = jsonObject.getString(IMProtocol.Define.KEY_ATTR_VERSION);
                    if (!version.equals(IMProtocol.Define.VALUE_ATTR_VERSION)) {
                        TRTCLogger.e(TAG, "protocol version is not match, ignore msg.");
                    }
                    int action = jsonObject.getInt(IMProtocol.Define.KEY_CMD_ACTION);

                    switch (action) {
                        case IMProtocol.Define.CODE_UNKNOWN:
                            // ignore
                            break;
                        case IMProtocol.Define.CODE_ROOM_CUSTOM_MSG:
                            Pair<String, String> cusPair = IMProtocol.parseCusMsg(jsonObject);
                            TXUserInfo userInfo = new TXUserInfo();
                            userInfo.userId = sender.getUserID();
                            userInfo.avatarURL = sender.getFaceUrl();
                            userInfo.userName = sender.getNickName();
                            if (mDelegate != null && cusPair != null) {
                                mDelegate.onRoomRecvRoomCustomMsg(mRoomId, cusPair.first, cusPair.second, userInfo);
                            }
                            break;
                        case IMProtocol.Define.CODE_ROOM_DESTROY:
                            exitRoom(null);
                            cleanStatus();
                            if (mDelegate != null) {
                                mDelegate.onRoomDestroy(mRoomId);
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

        @Override
        public void onRecvC2CCustomMessage(String msgID, V2TIMUserInfo sender, byte[] customData) {
            String customStr = new String(customData);
            if (!TextUtils.isEmpty(customStr)) {
                try {
                    JSONObject jsonObject = new JSONObject(customStr);
                    String version = jsonObject.getString(IMProtocol.Define.KEY_ATTR_VERSION);
                    if (!version.equals(IMProtocol.Define.VALUE_ATTR_VERSION)) {
                        TRTCLogger.e(TAG, "protocol version is not match, ignore msg.");
                    }
                    int action = jsonObject.getInt(IMProtocol.Define.KEY_CMD_ACTION);
                    switch (action) {
                        case IMProtocol.Define.CODE_ROOM_KICK_SEAT_MSG:
                            String kickUserId = jsonObject.getString("userId");
                            onSeatLeave(kickUserId);
                            break;
                        case IMProtocol.Define.CODE_ROOM_PICK_SEAT_MSG:
                            String pickUserId = jsonObject.getString("userId");
                            onSeatTake(pickUserId);
                            break;
                        default:
                            break;
                    }
                } catch (JSONException e) {
                }
            }
        }
    }

    private class VoiceRoomGroupListener extends V2TIMGroupListener {
        @Override
        public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
            if (!groupID.equals(mRoomId)) {
                return;
            }
            if (mDelegate != null && memberList != null) {
                for (V2TIMGroupMemberInfo member : memberList) {
                    TXUserInfo userInfo = new TXUserInfo();
                    userInfo.userId = member.getUserID();
                    userInfo.userName = member.getNickName();
                    userInfo.avatarURL = member.getFaceUrl();
                    mDelegate.onRoomAudienceEnter(userInfo);
                }
            }
        }

        @Override
        public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
            if (!groupID.equals(mRoomId)) {
                return;
            }
            if (mDelegate != null) {
                TXUserInfo userInfo = new TXUserInfo();
                userInfo.userId = member.getUserID();
                userInfo.userName = member.getNickName();
                userInfo.avatarURL = member.getFaceUrl();
                mDelegate.onRoomAudienceLeave(userInfo);
            }
        }

        @Override
        public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
            // 解散逻辑
            if (!groupID.equals(mRoomId)) {
                return;
            }
            cleanStatus();
            if (mDelegate != null) {
                mDelegate.onRoomDestroy(mRoomId);
            }
        }
    }

    private class VoiceRoomSignalListener extends V2TIMSignalingListener {
        @Override
        public void onReceiveNewInvitation(String inviteID, String inviter, String groupId, List<String> inviteeList, String data) {
            TRTCLogger.i(TAG, "recv new invitation: " + inviteID + " from " + inviter);
            if (mDelegate != null) {
                TXInviteData txInviteData = IMProtocol.parseInvitationMsg(data);
                if (txInviteData == null) {
                    TRTCLogger.e(TAG, "parse data error");
                    return;
                }
                if (!mRoomId.equals(txInviteData.roomId)) {
                    TRTCLogger.e(TAG, "roomId is not right");
                    return;
                }
                mDelegate.onReceiveNewInvitation(inviteID, inviter, txInviteData.command, txInviteData.message);
            }
        }

        @Override
        public void onInviteeAccepted(String inviteID, String invitee, String data) {
            TRTCLogger.i(TAG, "recv accept invitation: " + inviteID + " from " + invitee);
            if (mDelegate != null) {
                mDelegate.onInviteeAccepted(inviteID, invitee);
            }
        }

        @Override
        public void onInviteeRejected(String inviteID, String invitee, String data) {
            TRTCLogger.i(TAG, "recv reject invitation: " + inviteID + " from " + invitee);
            if (mDelegate != null) {
                mDelegate.onInviteeRejected(inviteID, invitee);
            }
        }

        @Override
        public void onInvitationCancelled(String inviteID, String inviter, String data) {
            TRTCLogger.i(TAG, "recv cancel invitation: " + inviteID + " from " + inviter);
            if (mDelegate != null) {
                mDelegate.onInvitationCancelled(inviteID, inviter);
            }
        }

        @Override
        public void onInvitationTimeout(String inviteID, List<String> inviteeList) {
            TRTCLogger.i(TAG, "recv invitation timeout: " + inviteID + " from " + inviteeList);
            if (mDelegate != null) {
                mDelegate.onInvitationTimeout(inviteID, inviteeList);
            }
        }
    }
}
