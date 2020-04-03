package com.tencent.liteav.liveroom.model.impl.room.impl;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
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
import com.tencent.imsdk.TIMGroupEventListener;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMGroupMemberInfo;
import com.tencent.imsdk.TIMGroupSystemElem;
import com.tencent.imsdk.TIMGroupSystemElemType;
import com.tencent.imsdk.TIMGroupTipsElem;
import com.tencent.imsdk.TIMGroupTipsType;
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
import com.tencent.imsdk.ext.group.TIMGroupDetailInfo;
import com.tencent.imsdk.ext.group.TIMGroupDetailInfoResult;
import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.model.impl.base.TRTCLogger;
import com.tencent.liteav.liveroom.model.impl.base.TXCallback;
import com.tencent.liteav.liveroom.model.impl.base.TXRoomInfo;
import com.tencent.liteav.liveroom.model.impl.base.TXRoomInfoListCallback;
import com.tencent.liteav.liveroom.model.impl.base.TXUserInfo;
import com.tencent.liteav.liveroom.model.impl.base.TXUserListCallback;
import com.tencent.liteav.liveroom.model.impl.room.ITXRoomService;
import com.tencent.liteav.liveroom.model.impl.room.ITXRoomServiceDelegate;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

public class TXRoomService implements ITXRoomService, TIMMessageListener, TIMUserStatusListener, TIMConnListener, TIMGroupEventListener {
    private static final String TAG = "TXRoomService";

    private static final int CODE_ERROR                = -1;
    private static final int CODE_TIMEOUT              = -2;
    // 发送消息的超时时间
    private static final int SEND_MSG_TIMEOUT          = 15000;
    // 处理消息的超时时间
    private static final int HANDLE_MSG_TIMEOUT        = 10000;
    // 等待主播进房的超时时间
    private static final int WAIT_ANCHOR_ENTER_TIMEOUT = 3000;

    private static final int STATUS_NONE           = 0;
    private static final int STATUS_REQUEST        = 1;
    private static final int STATUS_RECEIVED       = 2;
    private static final int STATUS_WAITING_ANCHOR = 3;

    private static TXRoomService          sInstance;
    private        Context                mContext;
    private        ITXRoomServiceDelegate mDelegate;
    private        boolean                mIsInitIMSDK;
    private        boolean                mIsLogin;
    private        boolean                mIsEnterRoom;
    private        List<IMAnchorInfo>     mAnchorList;

    private String       mRoomId;
    private IMAnchorInfo mMySelfIMInfo;
    private IMAnchorInfo mOwnerIMInfo;
    // 房间外部状态，见 TRTCLiveRoomDef
    private int          mCurrentRoomStatus;
    private TXRoomInfo   mTXRoomInfo;

    private String                   mPKingRoomId;
    private IMAnchorInfo             mPKingIMAnchorInfo;
    private Pair<String, TXCallback> mLinkMicReqPair;
    private Pair<String, TXCallback> mPKReqPair;

    /// 房间内部状态，消息发送流程
    /// 1. 观众主动请求，观众状态变更 STATUS_REQUEST，并且等待 SEND_MSG_TIMEOUT 超时
    /// 2. 主播收到消息，主播状态变更 STATUS_RECEIVED，并且等待 HANDLE_MSG_TIMEOUT 超时
    /// 3. 主播主动回复接受，主播状态变更 STATUS_WAITING_ANCHOR，并且等待 WAIT_ANCHOR_ENTER_TIMEOUT 超时
    /// 4. 观众收到接受回复，观众状态变更 STATUS_NONE，主动上麦
    /// 5. 观众收到对应的上麦消息，恢复 STATUS_NONE
    private int mInternalStatus = STATUS_NONE;

    private Handler                mTimeoutHandler;
    private Pair<String, Runnable> mTimeoutRunnablePair;

    public static synchronized TXRoomService getInstance() {
        if (sInstance == null) {
            sInstance = new TXRoomService();
        }
        return sInstance;
    }

    private TXRoomService() {
        mTimeoutRunnablePair = new Pair<>(null, null);
        mAnchorList = new ArrayList<>();
        mMySelfIMInfo = new IMAnchorInfo();
        mOwnerIMInfo = new IMAnchorInfo();
        mRoomId = "";
        mCurrentRoomStatus = TRTCLiveRoomDef.ROOM_STATUS_NONE;
        mTimeoutHandler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void init(Context context) {
        mContext = context;

    }

    public void destroy() {
        mTimeoutHandler.removeCallbacksAndMessages(null);
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
            userConfig.setGroupEventListener(this);
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
            mMySelfIMInfo.userId = userId;
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
                mMySelfIMInfo.userId = userId;
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
                mMySelfIMInfo.clean();
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
                mMySelfIMInfo.name = userName;
                //                mMySelfIMInfo.avatar = avatarURL;
                if (isOwner()) {
                    mOwnerIMInfo.name = userName;
                    //                    mOwnerIMInfo.avatar = avatarURL;
                }
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
            TRTCLogger.e(TAG, "not log yet, create room fail.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "not log yet, create room fail.");
            }
            return;
        }
        TIMGroupManager.CreateGroupParam param = new TIMGroupManager.CreateGroupParam("AVChatRoom", roomId);
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
                mCurrentRoomStatus = TRTCLiveRoomDef.ROOM_STATUS_SINGLE;

                mRoomId = roomId;

                mOwnerIMInfo.userId = mMySelfIMInfo.userId;
                mOwnerIMInfo.streamId = mMySelfIMInfo.streamId;
                //                mOwnerIMInfo.avatar = mMySelfIMInfo.avatar;
                mOwnerIMInfo.name = mMySelfIMInfo.name;
                // 组装 RoomInfo 抛给上层
                mTXRoomInfo.roomStatus = mCurrentRoomStatus;
                mTXRoomInfo.roomId = roomId;
                mTXRoomInfo.roomName = roomName;
                mTXRoomInfo.ownerId = mMySelfIMInfo.userId;
                mTXRoomInfo.coverUrl = coverUrl;
                mTXRoomInfo.ownerName = mMySelfIMInfo.name;
                mTXRoomInfo.streamUrl = mMySelfIMInfo.streamId;
                mTXRoomInfo.memberCount = 1;

                // 主播自己更新到主播列表中
                mAnchorList.add(mMySelfIMInfo);
                // 更新群资料以及发送广播
                updateHostAnchorInfo();
                TRTCLogger.i(TAG, "create room success.");
                if (callback != null) {
                    callback.onCallback(0, "create room success.");
                }
                if (mDelegate != null) {
                    mDelegate.onRoomInfoChange(mTXRoomInfo);
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
        if (isEnterRoom()) {
            TRTCLogger.e(TAG, "you have been in room:" + mRoomId + ", can't enter another room:" + roomId);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "you have been in room:" + mRoomId + ", can't enter another room:" + roomId);
            }
            return;
        }
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
                boolean isSuccess = false;
                if (timGroupDetailInfoResults != null && timGroupDetailInfoResults.size() == 1) {
                    final TIMGroupDetailInfoResult result = timGroupDetailInfoResults.get(0);
                    if (result != null) {
                        final String introduction = result.getGroupIntroduction();
                        TRTCLogger.i(TAG, "get group info success, info:" + introduction);
                        if (introduction != null) {
                            isSuccess = true;
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

                                    mTXRoomInfo.roomId = roomId;
                                    mTXRoomInfo.roomName = result.getGroupName();
                                    mTXRoomInfo.coverUrl = result.getFaceUrl();
                                    mTXRoomInfo.memberCount = (int) result.getMemberNum();

                                    // 获取群资料，解析群简介，获取成员列表和当前房间类型
                                    Pair<Integer, List<IMAnchorInfo>> pair = IMProtocol.parseGroupInfo(introduction);
                                    if (pair != null) {
                                        TRTCLogger.i(TAG, "parse room info success, type:" + pair.first + " list:" + pair.second.toString());
                                        mCurrentRoomStatus = pair.first;
                                        mTXRoomInfo.roomStatus = mCurrentRoomStatus;
                                        if (pair.second.size() > 0) {
                                            // 添加到主播列表
                                            mAnchorList.clear();
                                            mAnchorList.addAll(pair.second);

                                            // 主播列表的第一个认为是群组的owner
                                            IMAnchorInfo ownerInfo = pair.second.get(0);
                                            mOwnerIMInfo.userId = ownerInfo.userId;
                                            mOwnerIMInfo.streamId = ownerInfo.streamId;
                                            // mOwnerIMInfo.avatar = ownerInfo.avatar
                                            mOwnerIMInfo.name = ownerInfo.name;
                                            // 组装房间的info信息
                                            mTXRoomInfo.ownerName = ownerInfo.name;
                                            mTXRoomInfo.ownerId = ownerInfo.userId;
                                            mTXRoomInfo.streamUrl = ownerInfo.streamId;

                                            ITXRoomServiceDelegate delegate = mDelegate;
                                            if (delegate != null) {
                                                // 回调当前房间信息状态变更
                                                delegate.onRoomInfoChange(mTXRoomInfo);
                                                // 回调当前的主播列表、流列表
                                                for (IMAnchorInfo info : pair.second) {
                                                    delegate.onRoomAnchorEnter(info.userId);
                                                    // 如果 streamId 不为空，说明当前可以播放
                                                    if (!TextUtils.isEmpty(info.streamId)) {
                                                        delegate.onRoomStreamAvailable(info.userId);
                                                    }
                                                }
                                            }
                                        }
                                        if (callback != null) {
                                            callback.onCallback(0, "enter room success");
                                        }
                                    } else {
                                        TRTCLogger.e(TAG, "parse room info error, maybe something error.");
                                    }
                                }
                            });
                        } else {
                            isSuccess = false;
                        }

                    } else {
                        isSuccess = false;
                    }
                }
                if (!isSuccess) {
                    onError(-1, "get info fail.");
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

    @Override
    public void getRoomInfos(final List<String> roomIds, final TXRoomInfoListCallback callback) {
        final List<TXRoomInfo> roomInfos = new ArrayList<>();
        TIMGroupManager.getInstance().getGroupInfo(roomIds, new TIMValueCallBack<List<TIMGroupDetailInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                if (callback != null) {
                    callback.onCallback(i, s, null);
                }
            }

            @Override
            public void onSuccess(List<TIMGroupDetailInfoResult> timGroupDetailInfoResults) {
                for (String id : roomIds) {
                    TIMGroupDetailInfo timGroupDetailInfo = TIMGroupManager.getInstance().queryGroupInfo(id);
                    if (timGroupDetailInfo == null) {
                        continue;
                    }
                    TXRoomInfo txRoomInfo = new TXRoomInfo();
                    txRoomInfo.roomId = timGroupDetailInfo.getGroupId();
                    txRoomInfo.ownerId = timGroupDetailInfo.getGroupOwner();
                    txRoomInfo.memberCount = (int) timGroupDetailInfo.getMemberNum();
                    txRoomInfo.coverUrl = timGroupDetailInfo.getFaceUrl();
                    txRoomInfo.roomName = timGroupDetailInfo.getGroupName();
                    Pair<Integer, List<IMAnchorInfo>> pair =
                            IMProtocol.parseGroupInfo(timGroupDetailInfo.getGroupIntroduction());
                    if (pair != null) {
                        List<IMAnchorInfo> list = pair.second;
                        for (IMAnchorInfo anchor : list) {
                            if (anchor.userId.equals(txRoomInfo.ownerId)) {
                                txRoomInfo.streamUrl = anchor.streamId;
                                txRoomInfo.ownerName = anchor.name;
                                break;
                            }
                        }
                    }
                    roomInfos.add(txRoomInfo);
                }
                if (callback != null) {
                    callback.onCallback(0, "get room info success", roomInfos);
                }
            }


        });
    }

    @Override
    public void updateStreamId(String streamId, TXCallback callback) {
        mMySelfIMInfo.streamId = streamId;
        if (isOwner()) {
            mOwnerIMInfo.streamId = streamId;
            mTXRoomInfo.streamUrl = streamId;
            updateHostAnchorInfo();
        }
        if (callback != null) {
            callback.onCallback(0, "update stream id success.");
        }
    }

    public void handleAnchorEnter(String userId) {
        // 有主播真的进来了
        TRTCLogger.i(TAG, "handleAnchorEnter roomStatus " + mInternalStatus + " " + userId + " pk " + mPKingIMAnchorInfo);
        if (mInternalStatus == STATUS_WAITING_ANCHOR) {
            if (mTimeoutRunnablePair.second != null) {
                mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
            }
            changeRoomStatus(STATUS_NONE);
            // 状态为PK
            if (mPKingIMAnchorInfo != null && userId.equals(mPKingIMAnchorInfo.userId)) {
                updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_PK);
            } else {
                updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_LINK_MIC);
            }
        }
    }

    public void handleAnchorExit(String userId) {
        // 有主播退出了
        TRTCLogger.i(TAG, "handleAnchorExit roomStatus " + mInternalStatus + " " + userId + " pk " + mPKingIMAnchorInfo);
        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK
                && mPKingIMAnchorInfo != null && userId.equals(mPKingIMAnchorInfo.userId)) {
            // 处理主播退出
            clearPkStatus();
        }
    }

    @Override
    public void getAudienceList(final TXUserListCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "get audience info list fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "get user info list fail, not enter room yet.", new ArrayList<TXUserInfo>());
            }
            return;
        }
        final List<String> memberIds = new ArrayList<>();
        TIMGroupManager.getInstance().getGroupMembers(mRoomId, new TIMValueCallBack<List<TIMGroupMemberInfo>>() {
            @Override
            public void onError(int i, String s) {
            }

            @Override
            public void onSuccess(List<TIMGroupMemberInfo> timGroupMemberInfos) {
                for (TIMGroupMemberInfo info : timGroupMemberInfos) {
                    memberIds.add(info.getUser());
                }
                TIMFriendshipManager.getInstance().getUsersProfile(memberIds, false, new TIMValueCallBack<List<TIMUserProfile>>() {
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
        });

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
    public void requestJoinAnchor(String reason, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "request join anchor fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "request join anchor fail, not enter room yet.");
            }
            return;
        }

        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
            TRTCLogger.e(TAG, "response join anchor fail, mCurrentRoomStatus " + mCurrentRoomStatus);
            if (callback != null) {
                callback.onCallback(-1, "当前房间正在PK中");
            }
            return;
        }
        if (mInternalStatus != STATUS_NONE) {
            TRTCLogger.e(TAG, "request join anchor fail, status :" + mInternalStatus);
            if (callback != null) {
                callback.onCallback(-1, "request join anchor fail, status :" + mInternalStatus);
            }
            return;
        }
        if (isOwner()) {
            TRTCLogger.e(TAG, "request join anchor fail, you are the owner of current room, id:" + mRoomId);
            if (callback != null) {
                callback.onCallback(-1, "request join anchor fail, you are the owner of current room, id:" + mRoomId);
            }
            return;
        }
        if (!TextUtils.isEmpty(mOwnerIMInfo.userId)) {
            mLinkMicReqPair = new Pair<>(mOwnerIMInfo.userId, callback);

            TIMCustomElem customElem = new TIMCustomElem();
            customElem.setData(IMProtocol.getJoinReqJsonStr(reason).getBytes());
            TIMMessage timMessage = new TIMMessage();
            timMessage.addElement(customElem);
            sendC2CMessage(mOwnerIMInfo.userId, timMessage, null);
            changeRoomStatus(STATUS_REQUEST);
            Runnable runnable = new Runnable() {
                @Override
                public void run() {
                    TRTCLogger.e(TAG, "request join anchor fail timeout");
                    changeRoomStatus(STATUS_NONE);
                    callback.onCallback(CODE_TIMEOUT, "主播超时未处理");
                }
            };
            mTimeoutRunnablePair = new Pair<>(mOwnerIMInfo.userId, runnable);
            mTimeoutHandler.postDelayed(runnable, SEND_MSG_TIMEOUT);
        } else {
            TRTCLogger.e(TAG, "request join anchor fail, can't find host anchor user id.");
            if (callback != null) {
                callback.onCallback(-1, "request join anchor fail, can't find host anchor user id.");
            }
        }
    }

    @Override
    public void responseJoinAnchor(String userId, boolean agree, String reason) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "response join anchor fail, not enter room yet.");
            return;
        }
        if (mInternalStatus != STATUS_NONE
                && mInternalStatus != STATUS_RECEIVED) {
            TRTCLogger.e(TAG, "response join anchor fail, roomStatus " + mInternalStatus);
            return;
        }
        if (isOwner()) {
            if (mTimeoutRunnablePair.second != null) {
                mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
            }
            if (agree) {
                changeRoomStatus(STATUS_WAITING_ANCHOR);
                Runnable runnable = new Runnable() {
                    @Override
                    public void run() {
                        TRTCLogger.e(TAG, "check link mic timeout ");
                        changeRoomStatus(STATUS_NONE);
                    }
                };
                mTimeoutRunnablePair = new Pair<>(userId, runnable);
                mTimeoutHandler.postDelayed(mTimeoutRunnablePair.second, WAIT_ANCHOR_ENTER_TIMEOUT);

            } else {
                changeRoomStatus(STATUS_NONE);
            }
            TIMCustomElem elem = new TIMCustomElem();
            elem.setData(IMProtocol.getJoinRspJsonStr(agree, reason).getBytes());
            TIMMessage timMessage = new TIMMessage();
            timMessage.addElement(elem);
            sendC2CMessage(userId, timMessage, null);
        } else {
            TRTCLogger.e(TAG, "send join anchor fail, not the room owner, room id:" + mRoomId + " my id:" + mMySelfIMInfo.userId);
        }
    }

    @Override
    public void kickoutJoinAnchor(String userId, TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "kickout join anchor fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "kickout join anchor fail, not enter room yet.");
            }
            return;
        }
        if (isOwner()) {
            if (mMySelfIMInfo.userId.equals(userId)) {
                TRTCLogger.e(TAG, "kick out join anchor fail, you can't kick out yourself.");
                if (callback != null) {
                    callback.onCallback(-1, "kick out join anchor fail, you can't kick out yourself.");
                }
                return;
            }

            TIMCustomElem elem = new TIMCustomElem();
            elem.setData(IMProtocol.getKickOutJoinJsonStr().getBytes());

            TIMMessage timMessage = new TIMMessage();
            timMessage.addElement(elem);

            sendC2CMessage(userId, timMessage, null);
        } else {
            TRTCLogger.e(TAG, "kick out anchor fail, not the room owner, room id:" + mRoomId + " my id:" + mMySelfIMInfo.userId);
            if (callback != null) {
                callback.onCallback(-1, "kick out anchor fail, not the room owner, room id:" + mRoomId + " my id:" + mMySelfIMInfo.userId);
            }
        }
    }

    @Override
    public void requestRoomPK(String roomId, final String userId, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "request room pk fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "request room pk fail, not enter room yet.");
            }
            return;
        }

        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_LINK_MIC) {
            TRTCLogger.e(TAG, "request room pk fail, room status is " + mInternalStatus);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "正在连麦中");
            }
            return;
        }

        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
            TRTCLogger.e(TAG, "request room pk fail, room status is " + mInternalStatus);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "已经处于PK状态");
            }
            return;
        }

        if (mInternalStatus != STATUS_NONE) {
            TRTCLogger.e(TAG, "request room pk fail, room status is " + mInternalStatus);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "正在请求中, 等待主播处理结果");
            }
            return;
        }
        if (isOwner()) {
            mPKingRoomId = roomId;
            mPKingIMAnchorInfo = new IMAnchorInfo();
            mPKingIMAnchorInfo.userId = userId;
            mPKReqPair = new Pair<>(userId, callback);
            TIMCustomElem customElem = new TIMCustomElem();
            customElem.setData(IMProtocol.getPKReqJsonStr(mRoomId, mMySelfIMInfo.userId).getBytes());
            TIMMessage timMessage = new TIMMessage();
            timMessage.addElement(customElem);
            sendC2CMessage(userId, timMessage, null);
            // 将房间状态置为请求pk中
            changeRoomStatus(STATUS_REQUEST);
            if (mTimeoutRunnablePair.second != null) {
                mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
            }
            // 超时未处理
            Runnable runnable = new Runnable() {
                @Override
                public void run() {
                    TRTCLogger.e(TAG, "requestRoomPK timeout");
                    if (isOwner()) {
                        if (callback != null) {
                            callback.onCallback(CODE_TIMEOUT, "主播超时未处理");
                        }
                        changeRoomStatus(STATUS_NONE);
                    }
                }
            };
            mTimeoutRunnablePair = new Pair<>(userId, runnable);
            mTimeoutHandler.postDelayed(runnable, SEND_MSG_TIMEOUT);
        } else {
            TRTCLogger.e(TAG, "request room pk fail, not the owner of current room, room id:" + mRoomId);
            if (callback != null) {
                callback.onCallback(-1, "request room pk fail, not the owner of current room, room id:" + mRoomId);
            }
        }
    }

    @Override
    public void responseRoomPK(String userId, boolean agree, String reason) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "response room pk fail, not enter room yet.");
            return;
        }
        // 上一个状态不是接受到PK消息
        if (mInternalStatus != STATUS_RECEIVED) {
            TRTCLogger.e(TAG, "response room pk fail, roomStatus is " + mInternalStatus);
            return;
        }
        if (isOwner()) {
            if (mTimeoutRunnablePair.second != null) {
                mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
            }
            if (agree) {
                changeRoomStatus(STATUS_WAITING_ANCHOR);
                //增加超时监测，如果PK主播没过来，就清空状态
                mTimeoutHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        if (isOwner() && mCurrentRoomStatus != TRTCLiveRoomDef.ROOM_STATUS_PK) {
                            clearPkStatus();
                        }
                    }
                }, WAIT_ANCHOR_ENTER_TIMEOUT);
            } else {
                mPKingIMAnchorInfo = null;
                mPKingRoomId = null;
                changeRoomStatus(STATUS_NONE);
            }
            TIMCustomElem customElem = new TIMCustomElem();
            customElem.setData(IMProtocol.getPKRspJsonStr(agree, reason, mMySelfIMInfo.streamId).getBytes());
            TIMMessage timMessage = new TIMMessage();
            timMessage.addElement(customElem);
            sendC2CMessage(userId, timMessage, null);
        } else {
            TRTCLogger.e(TAG, "response room pk fail, not the owner of this room, room id:" + mRoomId);
        }
    }

    private void clearPkStatus() {
        if (mPKingIMAnchorInfo == null || mPKingRoomId == null) {
            return;
        }
        changeRoomStatus(STATUS_NONE);
        mPKingIMAnchorInfo = null;
        mPKingRoomId = null;
        if (mTimeoutRunnablePair.second != null) {
            mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
        }
        updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_SINGLE);
        final ITXRoomServiceDelegate delegate = mDelegate;
        if (delegate != null) {
            delegate.onRoomQuitRoomPk();
        }
    }

    private void changeRoomStatus(int status) {
        TRTCLogger.e(TAG, "changeRoomStatus " + status);
        mInternalStatus = status;
        if (mInternalStatus == STATUS_NONE) {
            // 一旦重新将状态置回, 清空超时逻辑
            mTimeoutHandler.removeCallbacksAndMessages(null);
        }
    }

    private void rejectRoomPk(String userId, String msg) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "response room pk fail, not enter room yet.");
            return;
        }
        if (isOwner()) {
            TIMCustomElem customElem = new TIMCustomElem();
            customElem.setData(IMProtocol.getPKRspJsonStr(false, msg, mMySelfIMInfo.streamId).getBytes());
            TIMMessage timMessage = new TIMMessage();
            timMessage.addElement(customElem);
            sendC2CMessage(userId, timMessage, null);
        }
    }

    private void rejectLinkMic(String userId, String msg) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "response room pk fail, not enter room yet.");
            return;
        }
        if (isOwner()) {
            TIMCustomElem customElem = new TIMCustomElem();
            customElem.setData(IMProtocol.getJoinRspJsonStr(false, msg).getBytes());
            TIMMessage timMessage = new TIMMessage();
            timMessage.addElement(customElem);
            sendC2CMessage(userId, timMessage, null);
        }
    }

    public void quitLinkMic() {
        // 观众退出连麦
        changeRoomStatus(STATUS_NONE);
    }

    @Override
    public void resetRoomStatus() {
        if (isOwner()) {
            changeRoomStatus(STATUS_NONE);
            updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_SINGLE);
        }
    }

    @Override
    public void quitRoomPK(TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "quit room pk fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "quit room pk fail, not enter room yet.");
            }
            return;
        }
        if (isOwner()) {
            IMAnchorInfo pkingAnchorInfo = mPKingIMAnchorInfo;
            String       pkingRoomId     = mPKingRoomId;
            changeRoomStatus(STATUS_NONE);
            if (pkingAnchorInfo != null && !TextUtils.isEmpty(pkingAnchorInfo.userId) && !TextUtils.isEmpty(pkingRoomId)) {
                mPKingIMAnchorInfo = null;
                mPKingRoomId = null;
                if (mTimeoutRunnablePair.second != null) {
                    mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
                }
                updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_SINGLE);
                TIMCustomElem customElem = new TIMCustomElem();
                customElem.setData(IMProtocol.getQuitPKJsonStr().getBytes());
                TIMMessage timMessage = new TIMMessage();
                timMessage.addElement(customElem);
                sendC2CMessage(pkingAnchorInfo.userId, timMessage, null);
            } else {
                TRTCLogger.e(TAG, "quit room pk fail, not in pking, pk room id:" + pkingRoomId + " pk user:" + pkingAnchorInfo);
                if (callback != null) {
                    callback.onCallback(-1, "quit room pk fail, not in pk.");
                }
            }
        } else {
            TRTCLogger.e(TAG, "quit room pk fail, not the owner of this room, room id:" + mRoomId);
            if (callback != null) {
                callback.onCallback(-1, "quit room pk fail, not the owner of this room, room id:" + mRoomId);
            }
        }
    }

    @Override
    public String exchangeStreamId(String userId) {
        for (IMAnchorInfo info : mAnchorList) {
            if (info != null && info.userId != null && info.userId.equals(userId)) {
                return info.streamId;
            }
        }
        return null;
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
        return mOwnerIMInfo != null ? mOwnerIMInfo.userId : null;
    }

    @Override
    public boolean isOwner() {
        return mMySelfIMInfo.equals(mOwnerIMInfo);
    }

    @Override
    public boolean isPKing() {
        return !TextUtils.isEmpty(mPKingRoomId) && mPKingIMAnchorInfo != null && !TextUtils.isEmpty(mPKingIMAnchorInfo.userId);
    }

    @Override
    public String getPKRoomId() {
        return mPKingRoomId;
    }

    @Override
    public String getPKUserId() {
        return mPKingIMAnchorInfo != null ? mPKingIMAnchorInfo.userId : null;
    }

    private void cleanStatus() {
        mCurrentRoomStatus = TRTCLiveRoomDef.ROOM_STATUS_NONE;

        mTXRoomInfo = new TXRoomInfo();

        mIsEnterRoom = false;

        mRoomId = "";
        mAnchorList.clear();
        // 个人信息不需要清除，但是流需要
        mMySelfIMInfo.streamId = "";
        mOwnerIMInfo.clean();

        mPKingIMAnchorInfo = null;
        mPKingRoomId = null;

        mPKReqPair = new Pair<>(null, null);
        mLinkMicReqPair = new Pair<>(null, null);

        mInternalStatus = STATUS_NONE;
        mTimeoutHandler.removeCallbacksAndMessages(null);
    }

    private void updateRoomType(int type) {
        int oldType = mCurrentRoomStatus;
        mCurrentRoomStatus = type;
        updateHostAnchorInfo();
        ITXRoomServiceDelegate delegate = mDelegate;
        mTXRoomInfo.roomStatus = type;
        if (delegate != null && mCurrentRoomStatus != oldType) {
            delegate.onRoomInfoChange(mTXRoomInfo);
        }
    }

    private void updateHostAnchorInfo() {
        if (!isOwner()) {
            return;
        }
        TRTCLogger.i(TAG, "start update anchor info, type:" + mCurrentRoomStatus + " list:" + mAnchorList.toString());
        // 更新群简介
        TIMGroupManager.ModifyGroupInfoParam groupInfoParam = new TIMGroupManager.ModifyGroupInfoParam(mRoomId);
        groupInfoParam.setIntroduction(IMProtocol.getGroupInfoJsonStr(mCurrentRoomStatus, new ArrayList<>(mAnchorList)));
        TIMGroupManager.getInstance().modifyGroupInfo(groupInfoParam, new TIMCallBack() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "room owner update anchor list into group introduction fail, code: " + i + " msg:" + s);
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "room owner update anchor list into group introduction success");
            }
        });

        // 发出全员公告
        String        json       = IMProtocol.getUpdateGroupInfoJsonStr(mCurrentRoomStatus, new ArrayList<>(mAnchorList));
        TIMMessage    timMessage = new TIMMessage();
        TIMCustomElem customElem = new TIMCustomElem();
        customElem.setData(json.getBytes());
        timMessage.addElement(customElem);
        timMessage.setPriority(TIMMessagePriority.High);
        sendGroupMessage(timMessage, null);

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

    private void onRecvGroupMemberMessage(TIMGroupTipsElem timGroupTipsElem) {
        if (!isEnterRoom()) {
            return;
        }
        final ITXRoomServiceDelegate delegate       = mDelegate;
        TIMUserProfile               timUserProfile = timGroupTipsElem.getOpUserInfo();
        TXUserInfo                   userInfo       = new TXUserInfo();
        userInfo.userName = timUserProfile.getNickName();
        userInfo.userId = timUserProfile.getIdentifier();
        userInfo.avatarURL = timUserProfile.getFaceUrl();
        String userId = userInfo.userId;
        if (userId == null || userId.equals(mMySelfIMInfo.userId)) {
            return;
        }
        if (timGroupTipsElem.getTipsType() == TIMGroupTipsType.Join) {
            // 有成员加入
            if (delegate != null) {
                delegate.onRoomAudienceEnter(userInfo);
            }
        } else if (timGroupTipsElem.getTipsType() == TIMGroupTipsType.Quit) {
            // 有成员退出
            if (delegate != null) {
                delegate.onRoomAudienceExit(userInfo);
            }
        }
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
                            cleanStatus();
                            ITXRoomServiceDelegate delegate = mDelegate;
                            if (delegate != null) {
                                String roomId = mRoomId;
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
                    case IMProtocol.Define.CODE_REQUEST_JOIN_ANCHOR:
                        // 收到请求连麦的消息：
                        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                            TRTCLogger.e(TAG, "recv join anchor mCurrentRoomStatus " + mCurrentRoomStatus);
                            rejectLinkMic(txUserInfo.userId, "主播正在PK中");
                            return;
                        }
                        if (mInternalStatus != STATUS_NONE) {
                            TRTCLogger.e(TAG, "recv join anchor status " + mInternalStatus);
                            rejectLinkMic(txUserInfo.userId, "主播正在处理其他消息");
                            return;
                        }
                        changeRoomStatus(STATUS_RECEIVED);
                        if (mTimeoutRunnablePair.second != null) {
                            mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
                        }
                        Runnable runnable = new Runnable() {
                            @Override
                            public void run() {
                                TRTCLogger.e(TAG, "request join anchor timeout:" + mCurrentRoomStatus);
                                rejectLinkMic(txUserInfo.userId, "主播超时未响应");
                                changeRoomStatus(STATUS_NONE);
                            }
                        };
                        mTimeoutRunnablePair = new Pair<>(txUserInfo.userId, runnable);
                        mTimeoutHandler.postDelayed(runnable, HANDLE_MSG_TIMEOUT);
                        String reqReason = IMProtocol.parseJoinReqReason(jsonObject);
                        if (delegate != null) {
                            delegate.onRoomRequestJoinAnchor(txUserInfo, reqReason, HANDLE_MSG_TIMEOUT);
                        }
                        break;
                    case IMProtocol.Define.CODE_RESPONSE_JOIN_ANCHOR:
                        if (mInternalStatus != STATUS_REQUEST) {
                            TRTCLogger.e(TAG, "recv link mic response status " + mInternalStatus);
                            return;
                        }
                        // 收到连麦回包的消息：
                        Pair<Boolean, String> joinRspPair = IMProtocol.parseJoinRspResult(jsonObject);
                        if (joinRspPair != null) {
                            boolean                  agree       = joinRspPair.first;
                            String                   rspReason   = joinRspPair.second;
                            Pair<String, TXCallback> linkMicPair = mLinkMicReqPair;
                            if (linkMicPair != null) {
                                String     ownerId  = linkMicPair.first;
                                TXCallback callback = linkMicPair.second;
                                if (!TextUtils.isEmpty(ownerId) && callback != null) {
                                    if (ownerId.equals(timMessage.getSender())) {
                                        mLinkMicReqPair = null;
                                        // 连麦的时候主播已经在线了，所以不需要等待主播上线，直接将状态置为STATUS_NONE
                                        changeRoomStatus(STATUS_NONE);
                                        if (mTimeoutRunnablePair.second != null) {
                                            mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
                                        }
                                        callback.onCallback(agree ? 0 : -1, agree ? "anchor agree to link mic" : rspReason);
                                    } else {
                                        TRTCLogger.e(TAG, "recv join rsp, but link mic owner id:" + ownerId + " recv im id:" + timMessage.getSender());
                                    }
                                } else {
                                    TRTCLogger.e(TAG, "recv join rsp, but link mic pair params is invalid, ownerId:" + ownerId + " callback:" + callback);
                                }
                            } else {
                                TRTCLogger.e(TAG, "recv join rsp, but link mic pair is null.");
                            }
                        } else {
                            TRTCLogger.e(TAG, "recv join rsp, but parse pair is null, maybe something error.");
                        }
                        break;
                    case IMProtocol.Define.CODE_KICK_OUT_JOIN_ANCHOR:
                        // 收到被踢出的消息：
                        if (delegate != null) {
                            delegate.onRoomKickoutJoinAnchor();
                        }
                        break;
                    case IMProtocol.Define.CODE_NOTIFY_JOIN_ANCHOR_STREAM:
                        // 收到连麦者流id更新的消息：
                        // 当前ignore
                        break;
                    case IMProtocol.Define.CODE_REQUEST_ROOM_PK:
                        // 收到请求跨房PK的消息：
                        // 首先检查状态，如果状态不对，立即回复拒绝
                        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_LINK_MIC) {
                            TRTCLogger.e(TAG, "received pk msg, but mCurrentRoomStatus is" + mCurrentRoomStatus);
                            rejectRoomPk(timMessage.getSender(), "主播正在连麦中");
                            return;
                        }
                        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                            TRTCLogger.e(TAG, "received pk msg, but mCurrentRoomStatus is" + mCurrentRoomStatus);
                            rejectRoomPk(timMessage.getSender(), "主播正在PK中");
                            return;
                        }
                        if (mInternalStatus != STATUS_NONE) {
                            TRTCLogger.e(TAG, "received pk msg, but roomStatus is" + mInternalStatus);
                            rejectRoomPk(timMessage.getSender(), "主播正在处理其他消息");
                            return;
                        }
                        Pair<String, String> pkReqPair = IMProtocol.parsePKReq(jsonObject);
                        if (pkReqPair != null) {
                            String fromRoomId   = pkReqPair.first;
                            String fromStreamId = pkReqPair.second;


                            if (!TextUtils.isEmpty(fromRoomId) && !TextUtils.isEmpty(fromStreamId)) {
                                mPKingRoomId = fromRoomId;
                                mPKingIMAnchorInfo = new IMAnchorInfo();
                                mPKingIMAnchorInfo.name = timMessage.getSenderNickname();
                                mPKingIMAnchorInfo.streamId = fromStreamId;
                                mPKingIMAnchorInfo.userId = timMessage.getSender();
                                // 改变房间状态
                                changeRoomStatus(STATUS_RECEIVED);
                                // 同时增加超时处理
                                if (mTimeoutRunnablePair.second != null) {
                                    mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
                                }
                                Runnable runnable1 = new Runnable() {
                                    @Override
                                    public void run() {
                                        TRTCLogger.e(TAG, "received pk msg handle timeout");
                                        if (isOwner()) {
                                            rejectRoomPk(mPKingIMAnchorInfo.userId, "主播超时未响应");
                                            mPKingRoomId = null;
                                            mPKingIMAnchorInfo = null;
                                            changeRoomStatus(STATUS_NONE);
                                        }
                                    }
                                };
                                mTimeoutRunnablePair = new Pair<>(timMessage.getSender(), runnable1);
                                mTimeoutHandler.postDelayed(runnable1, HANDLE_MSG_TIMEOUT);
                                if (delegate != null) {
                                    // 回调到上层
                                    delegate.onRoomRequestRoomPK(txUserInfo, HANDLE_MSG_TIMEOUT);
                                }
                            } else {
                                TRTCLogger.e(TAG, "recv pk req, room id:" + fromRoomId + " or stream id:" + fromStreamId + " is invalid.");
                            }
                        } else {
                            TRTCLogger.e(TAG, "recv pk req, but parse pair is null, maybe something error.");
                        }
                        break;
                    case IMProtocol.Define.CODE_RESPONSE_PK:
                        if (mInternalStatus != STATUS_REQUEST) {
                            TRTCLogger.e(TAG, "recv pk response status " + mInternalStatus);
                            return;
                        }
                        // 收到跨房PK响应消息：
                        Pair<Boolean, Pair<String, String>> pkRspPair = IMProtocol.parsePKRsp(jsonObject);
                        if (pkRspPair != null) {
                            //accept、reason、streamId
                            boolean agree    = pkRspPair.first;
                            String  reason   = pkRspPair.second.first;
                            String  streamId = pkRspPair.second.second;

                            Pair<String, TXCallback> pkPair = mPKReqPair;
                            if (pkPair != null) {
                                String     userId   = pkPair.first;
                                TXCallback callback = pkPair.second;
                                if (!TextUtils.isEmpty(userId)) {
                                    if (timMessage.getSender().equals(userId)) {
                                        mPKReqPair = null;
                                        if (agree) {
                                            changeRoomStatus(STATUS_WAITING_ANCHOR);
                                            mPKingIMAnchorInfo.streamId = streamId;
                                            if (delegate != null) {
                                                delegate.onRoomResponseRoomPK(mPKingRoomId, streamId, txUserInfo);
                                            }
                                        } else {
                                            mPKingRoomId = null;
                                            mPKingIMAnchorInfo = null;
                                            changeRoomStatus(STATUS_NONE);
                                        }
                                        //收到回应，需要清除超时回调
                                        if (mTimeoutRunnablePair != null) {
                                            mTimeoutHandler.removeCallbacks(mTimeoutRunnablePair.second);
                                        }
                                        if (callback != null) {
                                            callback.onCallback(agree ? 0 : -1, agree ? "agree to pk" : reason);
                                        }
                                    } else {
                                        TRTCLogger.e(TAG, "recv pk rsp, but pk id:" + userId + " im id:" + timMessage.getSender());
                                    }
                                } else {
                                    TRTCLogger.e(TAG, "recv pk rsp, but pk pair params is invalid.");
                                }
                            } else {
                                TRTCLogger.e(TAG, "recv pk rsp, but pk pair is null.");
                            }
                        } else {
                            TRTCLogger.e(TAG, "recv pk rsp, but parse pair is null, maybe something error.");
                        }
                        break;
                    case IMProtocol.Define.CODE_QUIT_ROOM_PK:
                        if (mPKingIMAnchorInfo != null && !timMessage.getSender().equals(mPKingIMAnchorInfo.userId)) {
                            return;
                        }
                        clearPkStatus();
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
                    case IMProtocol.Define.CODE_UPDATE_GROUP_INFO:
                        Pair<Integer, List<IMAnchorInfo>> roomPair = IMProtocol.parseGroupInfo(jsonObject.toString());
                        if (roomPair != null) {
                            int newRoomStatus = roomPair.first;
                            if (mCurrentRoomStatus != newRoomStatus) {
                                mCurrentRoomStatus = newRoomStatus;
                                mTXRoomInfo.roomStatus = mCurrentRoomStatus;
                                if (delegate != null) {
                                    delegate.onRoomInfoChange(mTXRoomInfo);
                                }
                            }

                            List<IMAnchorInfo> copyList = new ArrayList<>(mAnchorList);
                            mAnchorList.clear();
                            mAnchorList.addAll(roomPair.second);

                            if (delegate != null) {
                                // 回调主播列表变更通知
                                List<IMAnchorInfo> anchorLeaveList = new ArrayList<>(copyList);
                                List<IMAnchorInfo> anchorEnterList = new ArrayList<>(roomPair.second);

                                Iterator<IMAnchorInfo> leaveIterator = anchorLeaveList.iterator();
                                while (leaveIterator.hasNext()) {
                                    IMAnchorInfo           info          = leaveIterator.next();
                                    Iterator<IMAnchorInfo> enterIterator = anchorEnterList.iterator();
                                    while (enterIterator.hasNext()) {
                                        IMAnchorInfo info2 = enterIterator.next();
                                        if (info.equals(info2)) {
                                            // 两个都有，说明个主播，前后都存在，移除出列表。
                                            leaveIterator.remove();
                                            enterIterator.remove();
                                            break;
                                        }
                                    }
                                }

                                for (IMAnchorInfo info : anchorLeaveList) {
                                    delegate.onRoomAnchorExit(info.userId);
                                }
                                for (IMAnchorInfo info : anchorEnterList) {
                                    delegate.onRoomAnchorEnter(info.streamId);
                                }
                                // 回调流变更通知
                                List<IMAnchorInfo> oldAnchorList = new ArrayList<>(copyList);
                                List<IMAnchorInfo> newAnchorList = new ArrayList<>(roomPair.second);
                                for (IMAnchorInfo oldInfo : oldAnchorList) {
                                    for (IMAnchorInfo newInfo : newAnchorList) {
                                        if (oldInfo.equals(newInfo)) {
                                            if (TextUtils.isEmpty(oldInfo.streamId) && !TextUtils.isEmpty(newInfo.streamId)) {
                                                // 流新增
                                                delegate.onRoomStreamAvailable(newInfo.userId);
                                            } else if (!TextUtils.isEmpty(oldInfo.streamId) && TextUtils.isEmpty(newInfo.streamId)) {
                                                // 流移除
                                                delegate.onRoomStreamUnavailable(newInfo.userId);
                                            }
                                        }
                                    }
                                }
                            }

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

    @Override
    public void onGroupTipsEvent(TIMGroupTipsElem timGroupTipsElem) {
        // 收到了系统通知
        TRTCLogger.i(TAG, "get tips:type:" + timGroupTipsElem.getType() + " op:" + timGroupTipsElem.getOpUser() + " list:" + timGroupTipsElem.getUserList());
        onRecvGroupMemberMessage(timGroupTipsElem);
    }

}
