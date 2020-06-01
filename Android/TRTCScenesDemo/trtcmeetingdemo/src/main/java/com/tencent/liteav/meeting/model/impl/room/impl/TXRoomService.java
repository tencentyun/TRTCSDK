package com.tencent.liteav.meeting.model.impl.room.impl;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConnListener;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMCustomElem;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMElemType;
import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMGroupSystemElem;
import com.tencent.imsdk.TIMGroupSystemElemType;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMMessageListener;
import com.tencent.imsdk.TIMMessagePriority;
import com.tencent.imsdk.TIMSdkConfig;
import com.tencent.imsdk.TIMTextElem;
import com.tencent.imsdk.TIMUserConfig;
import com.tencent.imsdk.TIMUserProfile;
import com.tencent.imsdk.TIMUserStatusListener;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.ext.group.TIMGroupDetailInfoResult;
import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.meeting.model.impl.base.TRTCLogger;
import com.tencent.liteav.meeting.model.impl.base.TXCallback;
import com.tencent.liteav.meeting.model.impl.base.TXUserInfo;
import com.tencent.liteav.meeting.model.impl.base.TXUserListCallback;
import com.tencent.liteav.meeting.model.impl.room.ITXRoomService;
import com.tencent.liteav.meeting.model.impl.room.ITXRoomServiceDelegate;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class TXRoomService implements ITXRoomService, TIMMessageListener, TIMUserStatusListener, TIMConnListener {
    private static final String TAG = "TXMeetingRoomService";

    private static final int CODE_ERROR                = -1;

    private static TXRoomService          sInstance;
    private        Context                mContext;
    private        ITXRoomServiceDelegate mDelegate;
    private        boolean                mIsInitIMSDK;
    private        boolean                mIsLogin;
    private        boolean                mIsEnterRoom;

    private String mRoomId;
    private String mSelfUserId;
    private String mOwnerUserId;


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
            TIMUserConfig userConfig = new TIMUserConfig();
            userConfig.setConnectionListener(this);
            userConfig.setUserStatusListener(this);
            TIMManager.getInstance().setUserConfig(userConfig);

            TIMSdkConfig config = new TIMSdkConfig(sdkAppId);
            mIsInitIMSDK = TIMManager.getInstance().init(mContext, config);
            if (!mIsInitIMSDK) {
                TRTCLogger.e(TAG, "init im sdk error.");
                if (callback != null) {
                    callback.onCallback(CODE_ERROR, "init im sdk error.");
                }
                return;
            }
        }
        // 登陆到 IM
        String loginedUserId = TIMManager.getInstance().getLoginUser();
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
        TIMManager.getInstance().login(userId, userSign, new TIMCallBack() {
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

        TIMManager.getInstance().logout(new TIMCallBack() {
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
        HashMap<String, Object> profileMap = new HashMap<>();
        profileMap.put(TIMUserProfile.TIM_PROFILE_TYPE_KEY_NICK, userName);
        profileMap.put(TIMUserProfile.TIM_PROFILE_TYPE_KEY_FACEURL, avatarURL);
        TIMFriendshipManager.getInstance().modifySelfProfile(profileMap, new TIMCallBack() {
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
        TIMGroupManager.CreateGroupParam param = new TIMGroupManager.CreateGroupParam("ChatRoom", roomId);
        param.setGroupId(roomId);
        param.setGroupName(roomName);
        param.setFaceUrl(coverUrl);
        TIMGroupManager.getInstance().createGroup(param, new TIMValueCallBack<String>() {
            @Override
            public void onError(int code, String s) {
                String msg = s;
                if (code == 10036) {
                    msg = "您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】，地址：https://cloud.tencent.com/document/product/269/11673";
                }
                if (code == 10037) {
                    msg = "单个用户可创建和加入的群组数量超过了限制，请购买相关套餐,价格地址：https://cloud.tencent.com/document/product/269/11673";
                }
                if (code == 10038) {
                    msg = "群成员数量超过限制，请参考，请购买相关套餐，价格地址：https://cloud.tencent.com/document/product/269/11673";
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
                TIMManager.getInstance().addMessageListener(TXRoomService.this);
                cleanStatus();

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
        // 摧毁房间的时候，需要优先清空群简介，否者有可能开同样的房，观众会有异常。
        TIMGroupManager.ModifyGroupInfoParam groupInfoParam = new TIMGroupManager.ModifyGroupInfoParam(mRoomId);
        groupInfoParam.setIntroduction("");
        TIMGroupManager.getInstance().modifyGroupInfo(groupInfoParam, new TIMCallBack() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "room owner update anchor list into group introduction fail, code: " + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "room owner update anchor list into group introduction success");
                TIMGroupManager.getInstance().deleteGroup(mRoomId, new TIMCallBack() {
                    @Override
                    public void onError(int i, String s) {
                        TRTCLogger.e(TAG, "destroy room fail, code:" + i + " msg:" + s);
                        if (callback != null) {
                            callback.onCallback(i, s);
                        }
                    }

                    @Override
                    public void onSuccess() {
                        TIMManager.getInstance().removeMessageListener(TXRoomService.this);

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

    @Override
    public void enterRoom(final String roomId, final TXCallback callback) {
        // 如果已经在一个房间了，则不允许再次进入
//        if (isEnterRoom()) {
//            TRTCLogger.e(TAG, "you have been in room:" + mRoomId + ", can't enter another room:" + roomId);
//            if (callback != null) {
//                callback.onCallback(CODE_ERROR, "you have been in room:" + mRoomId + ", can't enter another room:" + roomId);
//            }
//            return;
//        }
        List<String> groupList = new ArrayList<>();
        groupList.add(roomId);

        TIMGroupManager.getInstance().getGroupInfo(groupList, new TIMValueCallBack<List<TIMGroupDetailInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "get group info error, enter room fail. code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(-1, "get group info error, enter room fail. code:" + i + " msg:" + s);
                }
            }

            @Override
            public void onSuccess(List<TIMGroupDetailInfoResult> timGroupDetailInfoResults) {
                TRTCLogger.i(TAG, "get group info success.");
                if (timGroupDetailInfoResults != null && timGroupDetailInfoResults.size() == 1) {
                    final TIMGroupDetailInfoResult result = timGroupDetailInfoResults.get(0);
                    if (result != null) {
                        final String ownerUserId = result.getGroupOwner();
                        TIMGroupManager.getInstance().applyJoinGroup(roomId, "", new TIMCallBack() {
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
                                TIMManager.getInstance().addMessageListener(TXRoomService.this);
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
        TIMGroupManager.getInstance().quitGroup(mRoomId, new TIMCallBack() {
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
                TIMManager.getInstance().removeMessageListener(TXRoomService.this);
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
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "get user info list fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "get user info list fail, not enter room yet.", new ArrayList<TXUserInfo>());
            }
            return;
        }
        if (userList == null || userList.size() == 0) {
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "get user info list fail, user list is empty.", new ArrayList<TXUserInfo>());
            }
            return;
        }
        TIMFriendshipManager.getInstance().getUsersProfile(userList, true, new TIMValueCallBack<List<TIMUserProfile>>() {
            @Override
            public void onError(int i, String s) {
                if (callback != null) {
                    callback.onCallback(i, s, new ArrayList<TXUserInfo>());
                }
            }

            @Override
            public void onSuccess(List<TIMUserProfile> timUserProfiles) {
                List<TXUserInfo> list = new ArrayList<>();

                if (timUserProfiles != null && timUserProfiles.size() != 0) {
                    for (int i = 0; i < timUserProfiles.size(); i++) {
                        TXUserInfo userInfo = new TXUserInfo();
                        userInfo.userName = timUserProfiles.get(i).getNickName();
                        userInfo.userId = timUserProfiles.get(i).getIdentifier();
                        userInfo.avatarURL = timUserProfiles.get(i).getFaceUrl();
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
    public void sendRoomTextMsg(String msg, TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room text fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room text fail, not enter room yet.");
            }
            return;
        }

        TIMCustomElem customElem = new TIMCustomElem();
        customElem.setData(IMProtocol.getRoomTextMsgHeadJsonStr().getBytes());

        TIMTextElem textElem = new TIMTextElem();
        textElem.setText(msg);

        TIMMessage timMessage = new TIMMessage();
        timMessage.addElement(customElem);
        timMessage.addElement(textElem);
        timMessage.setPriority(TIMMessagePriority.Lowest);
        sendGroupMessage(timMessage, callback);
    }

    @Override
    public void sendRoomCustomMsg(String cmd, String message, TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room custom msg fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room custom msg fail, not enter room yet.");
            }
            return;
        }
        TIMCustomElem customElem = new TIMCustomElem();
        customElem.setData(IMProtocol.getCusMsgJsonStr(cmd, message).getBytes());

        TIMMessage timMessage = new TIMMessage();
        timMessage.addElement(customElem);
        timMessage.setPriority(TIMMessagePriority.Lowest);
        sendGroupMessage(timMessage, callback);
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

    private void sendGroupMessage(TIMMessage message, final TXCallback callback) {
        if (!isEnterRoom()) {
            return;
        }
        TIMConversation conversation = TIMManager.getInstance().getConversation(TIMConversationType.Group, mRoomId);
        conversation.sendMessage(message, new TIMValueCallBack<TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                Log.e(TAG, "send group message fail, code: " + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess(TIMMessage timMessage) {
                Log.i(TAG, "send group message success");
                if (callback != null) {
                    callback.onCallback(0, "send group message success.");
                }
            }
        });
    }

    private void sendC2CMessage(String userId, TIMMessage message, final TXCallback callback) {
        if (!isEnterRoom()) {
            return;
        }
        TIMConversation conversation = TIMManager.getInstance().getConversation(TIMConversationType.C2C, userId);
        conversation.sendMessage(message, new TIMValueCallBack<TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "send c2c msg fail, code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess(TIMMessage message) {
                TRTCLogger.i(TAG, "send c2c msg success.");
                if (callback != null) {
                    callback.onCallback(0, "send c2c msg success.");
                }
            }
        });
    }


    // -------------- im callback -----------------
    @Override
    public boolean onNewMessages(List<TIMMessage> list) {
        for (final TIMMessage timMessage : list) {
            final TIMConversation conversation = timMessage.getConversation();
            timMessage.getSenderProfile(new TIMValueCallBack<TIMUserProfile>() {
                @Override
                public void onError(int i, String s) {
                    if (conversation.getType() == TIMConversationType.C2C || conversation.getType() == TIMConversationType.Group) {
                        onRecvC2COrGroupMessage(timMessage, null);
                    } else if (conversation.getType() == TIMConversationType.System) {
                        onRecvSysMessage(timMessage, null);
                    }
                }

                @Override
                public void onSuccess(TIMUserProfile timUserProfile) {
                    if (conversation.getType() == TIMConversationType.C2C || conversation.getType() == TIMConversationType.Group) {
                        onRecvC2COrGroupMessage(timMessage, timUserProfile);
                    } else if (conversation.getType() == TIMConversationType.System) {
                        onRecvSysMessage(timMessage, timUserProfile);
                    }
                }
            });
        }
        return false;
    }

    private void onRecvSysMessage(TIMMessage timMessage, TIMUserProfile timUserProfile) {
        if (timMessage.getElementCount() > 0) {
            TIMElem     ele     = timMessage.getElement(0);
            TIMElemType eleType = ele.getType();
            if (eleType == TIMElemType.GroupSystem) {
                TIMGroupSystemElem groupSysEle = (TIMGroupSystemElem) ele;
                if (groupSysEle.getSubtype() == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE) {
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
            }
        }
    }

    private void onRecvC2COrGroupMessage(final TIMMessage timMessage, TIMUserProfile timUserProfile) {
        final ITXRoomServiceDelegate delegate   = mDelegate;
        String                       customStr  = "";
        String                       textStr    = "";
        final TXUserInfo             txUserInfo = new TXUserInfo();
        txUserInfo.userId = timMessage.getSender();
        txUserInfo.userName = timMessage.getSenderNickname();
        if (timUserProfile != null) {
            txUserInfo.avatarURL = timUserProfile.getFaceUrl();
        } else {
            txUserInfo.avatarURL = "";
        }
        for (int i = 0; i < timMessage.getElementCount(); i++) {
            TIMElem timElem = timMessage.getElement(i);
            if (timElem.getType() == TIMElemType.Custom) {
                customStr = new String(((TIMCustomElem) timElem).getData());
            } else if (timElem.getType() == TIMElemType.Text) {
                textStr = ((TIMTextElem) timElem).getText();
            }
        }
        TRTCLogger.i(TAG, "im msg dump, sender id:" + timMessage.getSender() + " custom:" + customStr + " text:" + textStr);
        if (!TextUtils.isEmpty(customStr)) {
            // 一定会有自定义消息的头
            try {
                JSONObject jsonObject = new JSONObject(customStr);
                String     version    = jsonObject.getString(IMProtocol.Define.KEY_VERSION);
                if (!version.equals(IMProtocol.Define.VALUE_PROTOCOL_VERSION)) {
                    TRTCLogger.e(TAG, "protocol version is not match, ignore msg.");
                }
                int action = jsonObject.getInt(IMProtocol.Define.KEY_ACTION);

                switch (action) {
                    case IMProtocol.Define.CODE_UNKNOWN:
                        // ignore
                        break;
                    case IMProtocol.Define.CODE_ROOM_TEXT_MSG:
                        if (delegate != null) {
                            delegate.onRoomRecvRoomTextMsg(mRoomId, textStr, txUserInfo);
                        }
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

    @Override
    public void onForceOffline() {
        TRTCLogger.e(TAG, "im force offline");
    }

    @Override
    public void onUserSigExpired() {
        TRTCLogger.e(TAG, "im user sign is expired");
    }

    @Override
    public void onConnected() {
        TRTCLogger.i(TAG, "im connected");
    }

    @Override
    public void onDisconnected(int i, String s) {
        TRTCLogger.e(TAG, "im disconnected code:" + i + " msg:" + s);
    }

    @Override
    public void onWifiNeedAuth(String s) {

    }
}
