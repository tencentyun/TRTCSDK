package com.tencent.liteav.trtcaudiocalldemo.model;

import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMCustomElem;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMLogLevel;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMMessageListener;
import com.tencent.imsdk.TIMSdkConfig;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.session.SessionWrapper;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.io.Serializable;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.UUID;

/**
 * 语音通话实现
 * 本功能使用腾讯云实时音视频 / 腾讯云即时通信IM 组合实现
 * 1. 为了方便您接入，在login中调用了initIM进行IM系统的初始化，如果您的项目中已经使用了IM，可以删除这里的初始化
 */
public class TRTCAudioCallImpl implements ITRTCAudioCall {
    private static final String TAG            = "TRTCAudioCallImpl";
    private static final long   TIME_OUT_COUNT = 30000;

    private static ITRTCAudioCall             sITRTCAudioCall;
    private final  Context                    mContext;
    /**
     * 底层SDK调用实例
     */
    private        TRTCCloud                  mTRTCCloud;
    private        TIMManager                 mTIMManager;
    private        TIMMessageListener         mTIMMessageListener = new TIMMessageListener() {
        @Override
        public boolean onNewMessages(List<TIMMessage> list) {
            if (isCollectionEmpty(list)) {
                return false;
            }
            Log.d(TAG, "onNewMessages: " + list.size());
            // 收到新消息，取最新的一条进行判断
            TIMMessage msg       = list.get(0);
            CallModel  callModel = convert2VideoCallData(msg);
            if (callModel != null && callModel.version
                    == CallModel.JSON_VERSION_4_ANDROID_IOS_TRTC
                    && CallModel.CALL_TYPE_AUDIO == callModel.callType) {
                // 主动拨打电话，开始监听trtc的消息
                mTRTCCloud.setListener(mTRTCCloudListener);
                // 如果这条消息已经超时，则不再处理
                if (!checkCallTimeout(msg)) {
                    handleCallModel(callModel, msg);
                }
                return true;
            }
            return false;
        }
    };
    /**
     * 当前IM登录用户名
     */
    private        String                     mCurUserId          = "";
    private        int                        mSdkAppId;
    private        String                     mCurUserSig;
    /**
     * 是否首次邀请
     */
    private        boolean                    isOnCalling         = false;
    private        String                     mCurCallID          = "";
    private        int                        mCurRoomID          = 0;
    /**
     * 当前是否在TRTC房间中
     */
    private        boolean                    mIsInRoom           = false;
    /**
     * 当前邀请列表
     * C2C通话时会记录自己邀请的用户
     * IM群组通话时会同步群组内邀请的用户
     * 当用户接听、拒绝、忙线、超时会从列表中移除该用户
     */
    private        List<String>               mCurInvitedList     = new ArrayList<>();
    /**
     * 当前语音通话中的用户
     */
    private        Set<String>                mCurRoomUserSet     = new HashSet<>();
    /**
     * 用于记录邀请用户无回应超时处理
     * 每个邀请用户对应一个超时处理函数
     * 当被邀请用户有回应时，接听、拒绝、忙线会移除对应的超时处理函数
     */
    private        Map<String, Runnable>      mTimeoutMap         = new HashMap<>();
    /**
     * C2C通话的邀请人
     * 例如A邀请B，B存储的mCurSponsorForMe为A
     */
    private        String                     mCurSponsorForMe    = "";
    /**
     * C2C通话是否回复过邀请人
     * 例如A邀请B，B回复接受/拒绝/忙线都置为true
     */
    private        boolean                    mIsRespSponsor      = false;
    /**
     * 当前通话的类型
     */
    private        int                        mCurCallType        = TYPE_UNKNOWN;
    /**
     * 当前群组通话的群组ID
     */
    private        String                     mCurGroupId         = "";
    /**
     * 最近使用的通话信令，用于快速处理
     */
    private        CallModel                  mLastCallModel      = new CallModel();
    /**
     * 上层传入回调
     */
    private        TRTCInteralListenerManager mTRTCInteralListenerManager;
    /**
     * 用于超时处理
     */
    private        HandlerThread              mTimeoutThread;
    private        Handler                    mTimeoutHandler;
    private        boolean                    mIsUseFrontCamera;

    // 初始化TRTC的监听器
    private TRTCCloudListener mTRTCCloudListener = new TRTCCloudListener() {
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            stopCall();
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onError(errCode, errMsg);
            }
            Log.e(TAG, "onError: " + errCode + " " + errMsg);
        }

        @Override
        public void onEnterRoom(long result) {
            if (result < 0) {
                stopCall();
            } else {
                mIsInRoom = true;
            }
        }

        @Override
        public void onExitRoom(int reason) {
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
            mCurRoomUserSet.add(userId);
            // 远端用户进入房间，认为对方接受了请求，需要将邀请列表、超时处理移除
            mCurInvitedList.remove(userId);
            removeInvitedTimeoutCallBack(userId);
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onUserEnter(userId);
            }
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
            mCurRoomUserSet.remove(userId);
            mCurInvitedList.remove(userId);
            // 远端用户退出房间，需要判断本次通话是否结束
            preExitRoom();
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onUserLeave(userId);
            }
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean available) {
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onUserAudioAvailable(userId, available);
            }
        }

        @Override
        public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
            Map<String, Integer> volumeMaps = new HashMap<>();
            for (TRTCCloudDef.TRTCVolumeInfo info : userVolumes) {
                String userId = "";
                if (info.userId == null) {
                    userId = mCurUserId;
                } else {
                    userId = info.userId;
                }
                volumeMaps.put(userId, info.volume);
            }
            mTRTCInteralListenerManager.onUserVoiceVolume(volumeMaps);
        }
    };

    /**
     * 用于获取单例
     *
     * @param context
     * @return 单例
     */
    public static ITRTCAudioCall sharedInstance(Context context) {
        synchronized (TRTCAudioCallImpl.class) {
            if (sITRTCAudioCall == null) {
                sITRTCAudioCall = new TRTCAudioCallImpl(context);
            }
            return sITRTCAudioCall;
        }
    }

    /**
     * 销毁单例
     */
    public static void destroySharedInstance() {
        synchronized (TRTCAudioCallImpl.class) {
            if (sITRTCAudioCall != null) {
                sITRTCAudioCall.destroy();
                sITRTCAudioCall = null;
            }
        }
    }

    public TRTCAudioCallImpl(Context context) {
        mContext = context;
        mTIMManager = TIMManager.getInstance();
        mTRTCCloud = TRTCCloud.sharedInstance(context);
        mTRTCInteralListenerManager = new TRTCInteralListenerManager();
        mTimeoutThread = new HandlerThread("timeoutThread");
        mTimeoutThread.start();
        mTimeoutHandler = new Handler(mTimeoutThread.getLooper());
    }

    private void startCall() {
        isOnCalling = true;
    }

    /**
     * 停止此次通话，把所有的变量都会重置
     */
    private void stopCall() {
        isOnCalling = false;
        mIsInRoom = false;
        mCurCallID = "";
        mCurRoomID = 0;
        mCurInvitedList.clear();
        mCurRoomUserSet.clear();
        mCurSponsorForMe = "";
        mLastCallModel = new CallModel();
        mIsRespSponsor = false;
        mCurGroupId = "";
        mCurCallType = TYPE_UNKNOWN;
        mTimeoutHandler.removeCallbacksAndMessages(null);
    }

    /**
     * 这里会初始化IM，如果您的项目中已经使用了腾讯云IM，可以删除，不需要再次初始化
     */
    private void initIM() {
        if (SessionWrapper.isMainProcess(mContext.getApplicationContext())) {
            TIMSdkConfig config = new TIMSdkConfig(mSdkAppId)
                    .enableLogPrint(true)
                    .setLogLevel(TIMLogLevel.DEBUG)
                    .setLogPath(Environment.getExternalStorageDirectory().getPath() + "/justfortest/");
            //初始化 SDK
            TIMManager.getInstance().init(mContext.getApplicationContext(), config);
        }
    }

    @Override
    public void init() {
        if (!mTimeoutThread.isAlive()) {
            mTimeoutThread.start();
        }
    }

    private void handleDialing(CallModel callModel, String user, long timeoutTime) {
        // 与对方处在同一个聊天室中，此时收到了别人的邀请列表
        if (mCurCallID.equals(callModel.callId)
                && mCurGroupId.equals(callModel.groupId)) {
            mCurInvitedList = callModel.invitedList;
            for (final String id : mCurInvitedList) {
                if (!mTimeoutMap.containsKey(id)) {
                    Log.d(TAG, "同步列表:" + id);
                    addInviteTimeoutCallback(id, mCurCallID, mCurGroupId, timeoutTime);
                }
            }
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onGroupCallInviteeListUpdate(mCurInvitedList);
            }
            return;
        }
        // 不和对方处于同一个聊天室中，此时收到了一个邀请我的通话请求,需要告诉对方忙线
        if (isOnCalling && callModel.invitedList.contains(mCurUserId)) {
            sendModel(user, CallModel.VIDEO_CALL_ACTION_LINE_BUSY, callModel);
            return;
        }
        // 虽然是群组聊天，但是对方并没有邀请我，我不做处理
        if (!TextUtils.isEmpty(callModel.groupId) && !callModel.invitedList.contains(mCurUserId)) {
            return;
        }
        // 开始接通电话
        startCall();
        mCurCallID = callModel.callId;
        mCurRoomID = callModel.roomId;
        mCurCallType = callModel.callType;
        mCurSponsorForMe = user;
        mCurGroupId = callModel.groupId;
        final String cid = mCurCallID;
        // 邀请列表中需要移除掉自己
        callModel.invitedList.remove(mCurUserId);
        List<String> onInvitedUserListParam = callModel.invitedList;
        // 为群组聊天邀请列表中的人增加超时定时器
        if (!TextUtils.isEmpty(mCurGroupId)) {
            mCurInvitedList.addAll(callModel.invitedList);
            for (String id : mCurInvitedList) {
                addInviteTimeoutCallback(id, mCurCallID, mCurGroupId, TIME_OUT_COUNT);
            }
        }
        if (mTRTCInteralListenerManager != null) {
            mTRTCInteralListenerManager.onInvited(user, onInvitedUserListParam, !TextUtils.isEmpty(mCurGroupId), mCurCallType);
        }
        // 开始超时处理
        mTimeoutHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (cid.equals(mCurCallID) && !mIsRespSponsor) {
                    stopCall();
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onCallingTimeout();
                    }
                }
            }
        }, timeoutTime);
    }

    private void handleCallModel(CallModel callModel, TIMMessage msg) {
        String user     = msg.getSender();
        long   leftTime = TIME_OUT_COUNT - (System.currentTimeMillis() / 1000 - msg.timestamp());
        Log.d(TAG, "handleCallModel: " + callModel + " mCurCallID:" + mCurCallID + " sender:" + msg.getSender());
        switch (callModel.action) {
            case CallModel.VIDEO_CALL_ACTION_DIALING:
                handleDialing(callModel, user, leftTime);
                break;
            case CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL:
                if (mCurCallID.equals(callModel.callId)) {
                    stopCall();
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onCallingCancel();
                    }
                }
                break;

            case CallModel.VIDEO_CALL_ACTION_SPONSOR_TIMEOUT:
                if (mCurCallID.equals(callModel.callId)) {
                    stopCall();
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onCallingTimeout();
                    }
                }
                break;
            case CallModel.VIDEO_CALL_ACTION_HANGUP:
                if (mCurCallID.equals(callModel.callId)) {
                    stopCall();
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onCallEnd();
                    }
                }
                break;
            case CallModel.VIDEO_CALL_ACTION_REJECT:
                if (mCurCallID.equals(callModel.callId)) {
                    mCurInvitedList.remove(user);
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onReject(user);
                    }
                    preExitRoom();
                }
                break;
            case CallModel.VIDEO_CALL_ACTION_LINE_BUSY:
                if (mCurCallID.equals(callModel.callId)) {
                    mCurInvitedList.remove(user);
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onLineBusy(user);
                    }
                    preExitRoom();
                }
                break;
            default:
                break;
        }

        if (mCurCallID.equals(callModel.callId)) {
            mLastCallModel = (CallModel) callModel.clone();
            if (callModel.action != CallModel.VIDEO_CALL_ACTION_DIALING) {
                removeInvitedTimeoutCallBack(user);
            }
        }
    }

    private boolean checkCallTimeout(TIMMessage msg) {
        long timeInterval = (System.currentTimeMillis() / 1000 - msg.timestamp()) * 1000;
        return timeInterval > TIME_OUT_COUNT;
    }

    /**
     * 为邀请的用户增加一个超时处理函数
     *
     * @param userId  邀请的用户
     * @param callId  当前call id
     * @param groupId 当前group id
     * @param timeOut 超时时间
     */
    private void addInviteTimeoutCallback(final String userId, final String callId, final String groupId, final long timeOut) {
        final Runnable runnable = new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "timeout runnable:" + userId + " callid:" + callId);
                if (mCurCallID != null && mCurCallID.equals(callId)) {
                    if (TextUtils.isEmpty(groupId)) {
                        //C2C模式下需要给对方发送一个超时消息
                        sendModel(userId, CallModel.VIDEO_CALL_ACTION_SPONSOR_TIMEOUT);
                    }
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onNoResp(userId);
                    }
                    Log.d(TAG, userId + " no response");
                    // 移除计时器
                    mCurInvitedList.remove(userId);
                    removeInvitedTimeoutCallBack(userId);
                    // 每次超时都需要判断当前是否需要结束通话
                    preExitRoom();
                }
            }
        };
        mTimeoutMap.put(userId, runnable);
        mTimeoutHandler.postDelayed(runnable, timeOut);
    }

    /**
     * 清除对应userid超时的定时器
     *
     * @param userId 清除对象
     */
    private void removeInvitedTimeoutCallBack(String userId) {
        Runnable runnable = mTimeoutMap.remove(userId);
        if (runnable != null) {
            mTimeoutHandler.removeCallbacks(runnable);
        }
    }

    @Override
    public void destroy() {
        //必要的清楚逻辑
        mTIMManager.removeMessageListener(mTIMMessageListener);
        mTimeoutHandler.removeCallbacks(null);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            mTimeoutThread.quitSafely();
        } else {
            mTimeoutThread.quit();
        }
        mTRTCCloud.stopLocalPreview();
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.exitRoom();
    }

    @Override
    public void addListener(TRTCAudioCallListener listener) {
        mTRTCInteralListenerManager.addListenter(listener);
    }

    @Override
    public void removeListener(TRTCAudioCallListener listener) {
        mTRTCInteralListenerManager.removeListenter(listener);
    }

    @Override
    public void login(int sdkAppId, final String userId, final String userSign, final ITRTCAudioCall.ActionCallBack callback) {
        Log.i(TAG, "start login, sdkAppId:" + sdkAppId + " userId:" + userId + " sign is empty:" + TextUtils.isEmpty(userSign));
        if (sdkAppId == 0 || TextUtils.isEmpty(userId) || TextUtils.isEmpty(userSign)) {
            Log.e(TAG, "start login fail. params invalid.");
            if (callback != null) {
                callback.onError(-1, "login fail, params is invalid.");
            }
            return;
        }
        mSdkAppId = sdkAppId;
        //1. 未初始化 IM 先初始化 IM
        if (!TIMManager.getInstance().isInited()) {
            initIM();
        }
        //2. 需要将监听器添加到IM上
        mTIMManager.addMessageListener(mTIMMessageListener);

        String loginUser = mTIMManager.getLoginUser();
        if (loginUser != null && loginUser.equals(userId)) {
            Log.d(TAG, "IM已经登录过了：" + loginUser);
            mCurUserId = loginUser;
            mCurUserSig = userSign;
            if (callback != null) {
                callback.onSuccess();
            }
            return;
        }

        mTIMManager.login(userId, userSign, new TIMCallBack() {
            @Override
            public void onError(int i, String s) {
                if (callback != null) {
                    callback.onError(i, s);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onSuccess();
                }
                mCurUserId = userId;
                mCurUserSig = userSign;
            }
        });
    }

    @Override
    public void logout(final ITRTCAudioCall.ActionCallBack callBack) {
        mTIMManager.logout(new TIMCallBack() {
            @Override
            public void onError(int i, String s) {
                if (callBack != null) {
                    callBack.onError(i, s);
                }
            }

            @Override
            public void onSuccess() {
                if (callBack != null) {
                    callBack.onSuccess();
                }
            }
        });
        stopCall();
        exitRoom();
    }

    @Override
    public void call(final String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        List<String> list = new ArrayList<>();
        list.add(userId);
        internalCall(list, ITRTCAudioCall.TYPE_VOICE_CALL, "");
    }

    @Override
    public void groupCall(final List<String> userIdList, String groupId) {
        if (isCollectionEmpty(userIdList)) {
            return;
        }
        internalCall(userIdList, ITRTCAudioCall.TYPE_VOICE_CALL, groupId);
    }

    /**
     * 统一的拨打逻辑
     *
     * @param userIdList 需要邀请的用户列表
     * @param type       邀请类型
     * @param groupId    群组通话的group id，如果是C2C需要传 ""
     */
    private void internalCall(final List<String> userIdList, int type, String groupId) {
        // 主动拨打电话，开始监听trtc的消息
        mTRTCCloud.setListener(mTRTCCloudListener);
        final boolean isGroupCall = !TextUtils.isEmpty(groupId);
        if (!isOnCalling) {
            // 首次拨打电话，生成id，并进入trtc房间
            mCurCallID = generateCallID();
            mCurRoomID = generateRoomID();
            mCurGroupId = groupId;
            mCurCallType = type;
            enterTRTCRoom();
            startCall();
        }
        // 非首次拨打，不能发起新的groupId通话
        if (!mCurGroupId.equals(groupId)) {
            return;
        }

        // 过滤已经邀请的用户id
        List<String> filterInvitedList = new ArrayList<>();
        for (String id : userIdList) {
            if (!mCurInvitedList.contains(id)) {
                filterInvitedList.add(id);
            }
        }
        // 如果当前没有需要邀请的id则返回
        if (isCollectionEmpty(filterInvitedList)) {
            return;
        }

        mCurInvitedList.addAll(filterInvitedList);
        Log.d(TAG, "groupCall: filter:" + filterInvitedList + " all:" + mCurInvitedList);
        // 填充通话信令的model
        mLastCallModel.action = CallModel.VIDEO_CALL_ACTION_DIALING;
        mLastCallModel.invitedList = mCurInvitedList;
        mLastCallModel.callId = mCurCallID;
        mLastCallModel.roomId = mCurRoomID;
        mLastCallModel.groupId = mCurGroupId;
        mLastCallModel.callType = mCurCallType;

        if (!TextUtils.isEmpty(mCurGroupId)) {
            // 群聊发送群消息
            sendModel("", CallModel.VIDEO_CALL_ACTION_DIALING);
        } else {
            // 单聊发送C2C消息
            for (final String userId : filterInvitedList) {
                sendModel(userId, CallModel.VIDEO_CALL_ACTION_DIALING);
            }
        }
        // 为邀请的id增加超时计时器
        for (final String userId : filterInvitedList) {
            addInviteTimeoutCallback(userId, mCurCallID, mCurGroupId, TIME_OUT_COUNT);
        }
    }

    /**
     * 重要：用于判断是否需要结束本次通话
     * 在用户超时、拒绝、忙线需要进行判断
     */
    private void preExitRoom() {
        Log.d(TAG, "preExitRoom: " + mCurRoomUserSet + " " + mCurInvitedList);
        if (mCurRoomUserSet.isEmpty() && mCurInvitedList.isEmpty() && mIsInRoom) {
            exitRoom();
            stopCall();
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onCallEnd();
            }
        }
    }

    /**
     * trtc 退房
     */
    private void exitRoom() {
        mTRTCCloud.stopLocalPreview();
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.exitRoom();
    }

    @Override
    public void accept() {
        mIsRespSponsor = true;
        enterTRTCRoom();
    }

    /**
     * trtc 进房
     */
    private void enterTRTCRoom() {
        Log.d(TAG, "enterTRTCRoom: " + mCurUserId + " room:" + mCurRoomID);
        TRTCCloudDef.TRTCParams TRTCParams = new TRTCCloudDef.TRTCParams(mSdkAppId, mCurUserId, mCurUserSig, mCurRoomID, "", "");
        TRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;
        mTRTCCloud.enableAudioVolumeEvaluation(300);
        mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        mTRTCCloud.startLocalAudio();
        mTRTCCloud.enterRoom(TRTCParams, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
    }

    @Override
    public void reject() {
        mIsRespSponsor = true;
        sendModel(mCurSponsorForMe, CallModel.VIDEO_CALL_ACTION_REJECT);
        stopCall();
    }

    @Override
    public void hangup() {
        //1. 如果还没有在通话中，说明还没有接通，所以直接拒绝了
        if (!isOnCalling) {
            reject();
            return;
        }
        boolean fromGroup = (!TextUtils.isEmpty(mCurGroupId));
        if (fromGroup) {
            groupHangup();
        } else {
            singleHangup();
        }
    }

    private void groupHangup() {
        if (isCollectionEmpty(mCurRoomUserSet)) {
            //当前以及没有人在通话了，直接向群里发送一个取消消息
            // TODO: 2019-12-27 这里可能会有逻辑问题，待查验
            sendModel("", CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL);
        }
        stopCall();
        exitRoom();
    }

    private void singleHangup() {
        for (String id : mCurInvitedList) {
            sendModel(id, CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL);
        }
        stopCall();
        exitRoom();
    }

    @Override
    public void setMicMute(boolean isMute) {
        mTRTCCloud.muteLocalAudio(isMute);
    }

    @Override
    public void setHandsFree(boolean isHandsFree) {
        if (isHandsFree) {
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        } else {
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
        }
    }

    private void sendModel(final String user, int action) {
        sendModel(user, action, null);
    }

    /**
     * 信令发送函数，当CallModel 存在groupId时会向群组发送信令
     *
     * @param user
     * @param action
     * @param model
     */
    private void sendModel(final String user, int action, CallModel model) {
        CallModel realCallModel;
        if (model != null) {
            realCallModel = (CallModel) model.clone();
            realCallModel.action = action;
        } else {
            realCallModel = generateModel(action);
        }

        final String json = CallModel2Json(realCallModel);
        if (json == null) {
            return;
        }

        TIMMessage    message = new TIMMessage();
        TIMCustomElem elem    = new TIMCustomElem();
        elem.setData(json.getBytes());
        message.addElement(elem);
        boolean         isGroup = (!TextUtils.isEmpty(realCallModel.groupId));
        TIMConversation conversation;
        if (isGroup) {
            conversation = mTIMManager.getConversation(TIMConversationType.Group, realCallModel.groupId);
        } else {
            conversation = mTIMManager.getConversation(TIMConversationType.C2C, user);
        }
        if (conversation != null) {
            // 设置IM离线消息推送，您可以根据自己的需求进行修改

            //设置当前消息的离线推送配置
            //            TIMMessageOfflinePushSettings settings = new TIMMessageOfflinePushSettings();
            //            settings.setEnabled(true);
            //            settings.setDescr("您收到语音电话");
            //            //设置离线推送扩展信息
            //            JSONObject object = new JSONObject();
            //            try {
            //                object.put("level", 15);
            //                object.put("task", "TASK15");
            //                settings.setExt(object.toString().getBytes("utf-8"));
            //            } catch (JSONException e) {
            //                e.printStackTrace();
            //            } catch (UnsupportedEncodingException e) {
            //                e.printStackTrace();
            //            }
            //            //
            //            TIMMessageOfflinePushSettings.AndroidSettings androidSettings = new TIMMessageOfflinePushSettings.AndroidSettings();
            //            androidSettings.setTitle("收到语音通话");
            //            //推送自定义通知栏消息，接收方收到消息后单击通知栏消息会给应用回调（针对小米、华为离线推送）
            //            androidSettings.setNotifyMode(TIMMessageOfflinePushSettings.NotifyMode.Normal);
            //            //设置 Android 设备收到消息时的提示音，声音文件需要放置到 raw 文件夹
            //            androidSettings.setSound(Uri.parse("android.resource://" + getPackageName() + "/" +R.raw.hualala));
            //            settings.setAndroidSettings(androidSettings);
            //            //设置在 iOS 设备上收到消息时的离线配置
            //            TIMMessageOfflinePushSettings.IOSSettings iosSettings = new TIMMessageOfflinePushSettings.IOSSettings();
            //            //开启 Badge 计数
            //            iosSettings.setBadgeEnabled(true);
            //            //设置 iOS 设备收到离线消息时的提示音
            //            iosSettings.setSound("/path/to/sound/file");
            //
            //            message.setOfflinePushSettings(settings);

            conversation.sendMessage(message, new TIMValueCallBack<TIMMessage>() {
                @Override
                public void onError(int i, String s) {
                    Log.e(TAG, "send error: " + s);
                }

                @Override
                public void onSuccess(TIMMessage timMessage) {
                    Log.d(TAG, "send success:" + user + " " + json);
                }
            });
        }

        // 最后需要重新赋值
        if (realCallModel.action != CallModel.VIDEO_CALL_ACTION_REJECT &&
                realCallModel.action != CallModel.VIDEO_CALL_ACTION_HANGUP &&
                realCallModel.action != CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL &&
                model == null) {
            mLastCallModel = (CallModel) realCallModel.clone();
        }
    }

    private CallModel generateModel(int action) {
        CallModel callModel = (CallModel) mLastCallModel.clone();
        callModel.action = action;
        return callModel;
    }

    private static CallModel convert2VideoCallData(TIMMessage msg) {
        if (msg != null) {
            TIMElem elem = msg.getElement(0);
            if (elem instanceof TIMCustomElem) {
                CallModel data = null;
                try {
                    String json = new String(((TIMCustomElem) elem).getData());
                    Log.d(TAG, "convert2VideoCallData: " + json);
                    data = new Gson().fromJson(json, CallModel.class);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return data;
            }
        }
        return null;
    }

    private static boolean isCollectionEmpty(Collection coll) {
        return coll == null || coll.size() == 0;
    }

    private static String CallModel2Json(CallModel callModel) {
        if (callModel == null) {
            return null;
        }
        return new Gson().toJson(callModel);
    }

    private static String generateCallID() {
        return UUID.randomUUID().toString();
    }

    private static int generateRoomID() {
        Random random = new Random();
        return random.nextInt(Integer.MAX_VALUE);
    }

    /**
     * 自定义消息的bean实体，用来与json的相互转化
     */
    public static class CallModel implements Cloneable, Serializable {
        /**
         * 系统错误
         */
        public static final int VIDEO_CALL_ACTION_ERROR           = -1;
        /**
         * 未知信令
         */
        public static final int VIDEO_CALL_ACTION_UNKNOWN         = 0;
        /**
         * 正在呼叫
         */
        public static final int VIDEO_CALL_ACTION_DIALING         = 1;
        /**
         * 发起人取消
         */
        public static final int VIDEO_CALL_ACTION_SPONSOR_CANCEL  = 2;
        /**
         * 拒接电话
         */
        public static final int VIDEO_CALL_ACTION_REJECT          = 3;
        /**
         * 无人接听
         */
        public static final int VIDEO_CALL_ACTION_SPONSOR_TIMEOUT = 4;
        /**
         * 挂断
         */
        public static final int VIDEO_CALL_ACTION_HANGUP          = 5;
        /**
         * 电话占线
         */
        public static final int VIDEO_CALL_ACTION_LINE_BUSY       = 6;

        /**
         * 通话类型
         */
        public static final int CALL_TYPE_UNKNOWN = 0;
        public static final int CALL_TYPE_AUDIO   = 1;
        public static final int CALL_TYPE_VIDEO   = 2;


        public static final int JSON_VERSION_4_ANDROID_IOS_TRTC = 4;

        /**
         * 1: 仅仅是一个带链接的文本消息
         * 2: iOS支持的视频通话版本，后续已经不兼容
         * 3: Android/iOS/Web互通的视频通话版本
         */
        @SerializedName("version")
        public int    version = JSON_VERSION_4_ANDROID_IOS_TRTC;
        /**
         * 表示一次通话的唯一ID
         */
        @SerializedName("call_id")
        public String callId;
        /**
         * TRTC的房间号
         */
        @SerializedName("room_id")
        public int    roomId  = 0;
        /**
         * IM的群组id，在群组内发起通话时使用
         */
        @SerializedName("group_id")
        public String groupId = "";
        /**
         * 信令动作
         */
        @SerializedName("action")
        public int    action  = VIDEO_CALL_ACTION_UNKNOWN;

        /**
         * 通话类型
         * 0-未知
         * 1-语音通话
         * 2-视频通话
         */
        @SerializedName("call_type")
        public int          callType = CALL_TYPE_UNKNOWN;
        /**
         * 正在邀请的列表
         */
        @SerializedName("invited_list")
        public List<String> invitedList;
        @SerializedName("duration")
        public int          duration = 0;
        @SerializedName("code")
        public int          code     = 0;

        @Override
        public Object clone() {
            CallModel callModel = null;
            try {
                callModel = (CallModel) super.clone();
                if (invitedList != null) {
                    callModel.invitedList = new ArrayList<>(invitedList);
                }
            } catch (CloneNotSupportedException e) {
                e.printStackTrace();
            }
            return callModel;
        }

        @Override
        public String toString() {
            return "CallModel{" +
                    "version=" + version +
                    ", callId='" + callId + '\'' +
                    ", roomId=" + roomId +
                    ", groupId='" + groupId + '\'' +
                    ", action=" + action +
                    ", callType=" + callType +
                    ", invitedList=" + invitedList +
                    ", duration=" + duration +
                    ", code=" + code +
                    '}';
        }
    }

    private class TRTCInteralListenerManager implements TRTCAudioCallListener {
        private List<WeakReference<TRTCAudioCallListener>> mWeakReferenceList;

        public TRTCInteralListenerManager() {
            mWeakReferenceList = new ArrayList<>();
        }

        public void addListenter(TRTCAudioCallListener listener) {
            WeakReference<TRTCAudioCallListener> listenerWeakReference = new WeakReference<>(listener);
            mWeakReferenceList.add(listenerWeakReference);
        }

        public void removeListenter(TRTCAudioCallListener listener) {
            Iterator iterator = mWeakReferenceList.iterator();
            while (iterator.hasNext()) {
                WeakReference<TRTCAudioCallListener> reference = (WeakReference<TRTCAudioCallListener>) iterator.next();
                if (reference.get() == null) {
                    iterator.remove();
                    continue;
                }
                if (reference.get() == listener) {
                    iterator.remove();
                }
            }
        }

        @Override
        public void onError(int code, String msg) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onError(code, msg);
                }
            }
        }

        @Override
        public void onInvited(String sponsor, List<String> userIdList, boolean isFromGroup, int callType) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onInvited(sponsor, userIdList, isFromGroup, callType);
                }
            }
        }

        @Override
        public void onGroupCallInviteeListUpdate(List<String> userIdList) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onGroupCallInviteeListUpdate(userIdList);
                }
            }
        }

        @Override
        public void onUserEnter(String userId) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserEnter(userId);
                }
            }
        }

        @Override
        public void onUserLeave(String userId) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserLeave(userId);
                }
            }
        }

        @Override
        public void onReject(String userId) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onReject(userId);
                }
            }
        }

        @Override
        public void onNoResp(String userId) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onNoResp(userId);
                }
            }
        }

        @Override
        public void onLineBusy(String userId) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onLineBusy(userId);
                }
            }
        }

        @Override
        public void onCallingCancel() {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onCallingCancel();
                }
            }
        }

        @Override
        public void onCallingTimeout() {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onCallingTimeout();
                }
            }
        }

        @Override
        public void onCallEnd() {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onCallEnd();
                }
            }
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserAudioAvailable(userId, isVideoAvailable);
                }
            }
        }

        @Override
        public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
            for (WeakReference<TRTCAudioCallListener> reference : mWeakReferenceList) {
                TRTCAudioCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserVoiceVolume(volumeMap);
                }
            }
        }
    }
}
