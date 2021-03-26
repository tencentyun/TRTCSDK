package com.tencent.liteav.trtcchatsalon.model.impl;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalon;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonCallback;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonDef;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonDelegate;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXCallback;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXRoomInfo;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXRoomInfoListCallback;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXUserInfo;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXUserListCallback;
import com.tencent.liteav.trtcchatsalon.model.impl.room.ITXRoomServiceDelegate;
import com.tencent.liteav.trtcchatsalon.model.impl.room.impl.TXRoomService;
import com.tencent.liteav.trtcchatsalon.model.impl.trtc.ChatSalonTRTCService;
import com.tencent.liteav.trtcchatsalon.model.impl.trtc.ChatSalonTRTCServiceDelegate;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class TRTCChatSalonImpl extends TRTCChatSalon implements ITXRoomServiceDelegate, ChatSalonTRTCServiceDelegate {
    private static final String TAG = TRTCChatSalonImpl.class.getName();

    private static TRTCChatSalonImpl sInstance;
    private final  Context           mContext;
    private TRTCChatSalonDelegate    mDelegate;
    // 所有调用都切到主线程使用，保证内部多线程安全问题
    private        Handler               mMainHandler;
    // 外部可指定的回调线程
    private        Handler               mDelegateHandler;
    private        int                   mSdkAppId;
    private        String                mUserId;
    private        String                mUserSig;
    private        String                mRoomId;

    // 主播列表
    private Set<String>                          mAnchorList;
    // 已抛出的观众列表
    private Set<String>                          mAudienceList;
    private HashMap<String, Boolean>             mMuteMap;
    private HashMap<String, String>              mInvitationMap;
    private TRTCChatSalonCallback.ActionCallback mEnterSeatCallback;
    private TRTCChatSalonCallback.ActionCallback mLeaveSeatCallback;
    private TRTCChatSalonCallback.ActionCallback mPickSeatCallback;
    private TRTCChatSalonCallback.ActionCallback mKickSeatCallback;

    public static synchronized TRTCChatSalon sharedInstance(Context context) {
        if (sInstance == null) {
            sInstance = new TRTCChatSalonImpl(context.getApplicationContext());
        }
        return sInstance;
    }

    public static synchronized void destroySharedInstance() {
        if (sInstance != null) {
            sInstance.destroy();
            sInstance = null;
        }
    }

    private void destroy() {
        TXRoomService.getInstance().destroy();
    }

    private TRTCChatSalonImpl(Context context) {
        mContext = context;
        mMainHandler = new Handler(Looper.getMainLooper());
        mDelegateHandler = new Handler(Looper.getMainLooper());
        mAnchorList = new HashSet<>();
        mAudienceList = new HashSet<>();
        mMuteMap = new HashMap<>();
        mInvitationMap = new HashMap<>();
        ChatSalonTRTCService.getInstance().setDelegate(this);
        ChatSalonTRTCService.getInstance().init(context);
        TXRoomService.getInstance().init(context);
        TXRoomService.getInstance().setDelegate(this);
    }

    private void clearList() {
        mAnchorList.clear();
        mAudienceList.clear();
        mMuteMap.clear();
        mInvitationMap.clear();
    }

    private void runOnMainThread(Runnable runnable) {
        Handler handler = mMainHandler;
        if (handler != null) {
            if (handler.getLooper() == Looper.myLooper()) {
                runnable.run();
            } else {
                handler.post(runnable);
            }
        } else {
            runnable.run();
        }
    }

    private void runOnDelegateThread(Runnable runnable) {
        Handler handler = mDelegateHandler;
        if (handler != null) {
            if (handler.getLooper() == Looper.myLooper()) {
                runnable.run();
            } else {
                handler.post(runnable);
            }
        } else {
            runnable.run();
        }
    }

    @Override
    public void setDelegate(TRTCChatSalonDelegate delegate) {
        mDelegate = delegate;
    }

    @Override
    public void setDelegateHandler(Handler handler) {
        mDelegateHandler = handler;
    }

    @Override
    public void login(final int sdkAppId, final String userId, final String userSig, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start login, sdkAppId:" + sdkAppId + " userId:" + userId + " sign is empty:" + TextUtils.isEmpty(userSig));
                if (sdkAppId == 0 || TextUtils.isEmpty(userId) || TextUtils.isEmpty(userSig)) {
                    TRTCLogger.e(TAG, "start login fail. params invalid.");
                    if (callback != null) {
                        callback.onCallback(-1, "登录失败，参数有误");
                    }
                    return;
                }
                mSdkAppId = sdkAppId;
                mUserId = userId;
                mUserSig = userSig;
                TRTCLogger.i(TAG, "start login room service");
                TXRoomService.getInstance().login(sdkAppId, userId, userSig, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void logout(final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start logout");
                mSdkAppId = 0;
                mUserId = "";
                mUserSig = "";
                TRTCLogger.i(TAG, "start logout room service");
                TXRoomService.getInstance().logout(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "logout room service finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void setSelfProfile(final String userName, final String avatarURL, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "set profile, user name:" + userName + " avatar url:" + avatarURL);
                TXRoomService.getInstance().setSelfProfile(userName, avatarURL, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "set profile finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void createRoom(final int roomId, final TRTCChatSalonDef.RoomParam roomParam, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "create room, room id:" + roomId + " info:" + roomParam);
                if (roomId == 0) {
                    TRTCLogger.e(TAG, "create room fail. params invalid");
                    return;
                }

                mRoomId = String.valueOf(roomId);

                clearList();

                final String           roomName       = (roomParam == null ? "" : roomParam.roomName);
                final String           roomCover      = (roomParam == null ? "" : roomParam.coverUrl);
                final boolean          isNeedRequest  = (roomParam != null && roomParam.needRequest);

                // 创建房间
                TXRoomService.getInstance().createRoom(mRoomId, roomName, roomCover, isNeedRequest, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "create room in service, code:" + code + " msg:" + msg);
                        if (code == 0) {
                            enterTRTCRoomInner(mRoomId, mUserId, mUserSig, TRTCCloudDef.TRTCRoleAnchor, new TRTCChatSalonCallback.ActionCallback() {
                                @Override
                                public void onCallback(final int code, final String msg) {
                                    TRTCLogger.i(TAG, "trtc enter room finish, room id:" + roomId + " code:" + code + " msg:" + msg);
                                    runOnDelegateThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            TXRoomService.getInstance().onSeatTake(mUserId);
                                            if (callback != null) {
                                                callback.onCallback(code, msg);
                                            }
                                        }
                                    });
                                }
                            });
                        } else {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (mDelegate != null) {
                                        mDelegate.onError(code, msg);
                                    }
                                }
                            });
                        }
                    }
                });
            }
        });
    }

    @Override
    public void destroyRoom(final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start destroy room.");
                // TRTC 房间退房结果不关心
                TRTCLogger.i(TAG, "start exit trtc room.");
                ChatSalonTRTCService.getInstance().exitRoom(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "exit trtc room finish, code:" + code + " msg:" + msg);
                        if (code != 0) {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (mDelegate != null) {
                                        mDelegate.onError(code, msg);
                                    }
                                }
                            });
                        }
                    }
                });

                TRTCLogger.i(TAG, "start destroy room service.");
                TXRoomService.getInstance().destroyRoom(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "destroy room finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });

                // 恢复设定
                clearList();
            }
        });
    }


    @Override
    public void enterRoom(final int roomId, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                // 恢复设定
                clearList();
                mRoomId = String.valueOf(roomId);
                TRTCLogger.i(TAG, "start enter room, room id:" + roomId);
                TXRoomService.getInstance().enterRoom(mRoomId, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "enter room service finish, room id:" + roomId + " code:" + code + " msg:" + msg);
                        runOnMainThread(new Runnable() {
                            @Override
                            public void run() {
                                if (code == 0) {
                                    enterTRTCRoomInner(mRoomId, mUserId, mUserSig, TRTCCloudDef.TRTCRoleAudience, callback);
                                } else {
                                    runOnDelegateThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            if (mDelegate != null) {
                                                mDelegate.onError(code, msg);
                                            }
                                        }
                                    });
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void exitRoom(final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start exit room.");
                // 退房的时候需要判断主播是否在座位，如果是麦上主播，需要先清空座位列表
                if (isOnSeat(mUserId)) {
                    leaveSeat(new TRTCChatSalonCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {
                            exitRoomInternal(callback);
                        }
                    });
                } else {
                    exitRoomInternal(callback);
                }
            }
        });
    }

    private void exitRoomInternal(final TRTCChatSalonCallback.ActionCallback callback) {
        ChatSalonTRTCService.getInstance().exitRoom(new TXCallback() {
            @Override
            public void onCallback(final int code, final String msg) {
                if (code != 0) {
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (mDelegate != null) {
                                mDelegate.onError(code, msg);
                            }
                        }
                    });
                }
            }
        });
        TRTCLogger.i(TAG, "start exit room service.");
        TXRoomService.getInstance().exitRoom(new TXCallback() {
            @Override
            public void onCallback(final int code, final String msg) {
                TRTCLogger.i(TAG, "exit room finish, code:" + code + " msg:" + msg);
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
        clearList();
        mRoomId = "";
    }

    private boolean isOnSeat(String userId) {
        return mAnchorList.contains(userId);
    }

    @Override
    public void getRoomInfoList(final List<Integer> roomIdList, final TRTCChatSalonCallback.RoomInfoCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (roomIdList == null) {
                    TRTCLogger.e(TAG, "getRoomInfoList room id list is empty.");
                    return;
                }
                final List<TRTCChatSalonDef.RoomInfo> trtcLiveRoomInfoList = new ArrayList<>();
                TRTCLogger.i(TAG, "start getRoomInfoList: " + roomIdList);
                List<String> strings = new ArrayList<>();

                for (Integer id : roomIdList) {
                    strings.add(String.valueOf(id));
                }
                TXRoomService.getInstance().getRoomInfoList(strings, new TXRoomInfoListCallback() {
                    @Override
                    public void onCallback(int code, String msg, List<TXRoomInfo> list) {
                        if (code == 0) {
                            for (TXRoomInfo info : list) {
                                TRTCLogger.i(TAG, info.toString());
                                TRTCChatSalonDef.RoomInfo roomInfo = new TRTCChatSalonDef.RoomInfo();
                                int                       translateRoomId;
                                try {
                                    translateRoomId = Integer.valueOf(info.roomId);
                                } catch (NumberFormatException e) {
                                    continue;
                                }
                                roomInfo.roomId = translateRoomId;
                                roomInfo.memberCount = info.memberCount;
                                roomInfo.roomName = info.roomName;
                                roomInfo.ownerId = info.ownerId;
                                roomInfo.coverUrl = info.cover;
                                roomInfo.ownerName = info.ownerName;
                                trtcLiveRoomInfoList.add(roomInfo);
                            }
                        }
                        if (callback != null) {
                            callback.onCallback(code, msg, trtcLiveRoomInfoList);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void getUserInfoList(final List<String> userIdList, final TRTCChatSalonCallback.UserListCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (userIdList == null) {
                    getAudienceList(callback);
                    return;
                }
                TXRoomService.getInstance().getUserInfo(userIdList, new TXUserListCallback() {
                    @Override
                    public void onCallback(final int code, final String msg, final List<TXUserInfo> list) {
                        TRTCLogger.i(TAG, "get audience list finish, code:" + code + " msg:" + msg + " list:" + (list != null ? list.size() : 0));
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    List<TRTCChatSalonDef.UserInfo> userList = new ArrayList<>();
                                    if (list != null) {
                                        for (TXUserInfo info : list) {
                                            TRTCChatSalonDef.UserInfo trtcUserInfo = new TRTCChatSalonDef.UserInfo();
                                            trtcUserInfo.userId = info.userId;
                                            trtcUserInfo.userAvatar = info.avatarURL;
                                            trtcUserInfo.userName = info.userName;
                                            userList.add(trtcUserInfo);
                                            TRTCLogger.i(TAG, "info:" + info);
                                        }
                                    }
                                    callback.onCallback(code, msg, userList);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    private void getAudienceList(final TRTCChatSalonCallback.UserListCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TXRoomService.getInstance().getAudienceList(new TXUserListCallback() {
                    @Override
                    public void onCallback(final int code, final String msg, final List<TXUserInfo> list) {
                        TRTCLogger.i(TAG, "get audience list finish, code:" + code + " msg:" + msg + " list:" + (list != null ? list.size() : 0));
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    List<TRTCChatSalonDef.UserInfo> userList = new ArrayList<>();
                                    if (list != null) {
                                        for (TXUserInfo info : list) {
                                            TRTCChatSalonDef.UserInfo trtcUserInfo = new TRTCChatSalonDef.UserInfo();
                                            trtcUserInfo.userId = info.userId;
                                            trtcUserInfo.userAvatar = info.avatarURL;
                                            trtcUserInfo.userName = info.userName;
                                            userList.add(trtcUserInfo);
                                            TRTCLogger.i(TAG, "info:" + info);
                                        }
                                    }
                                    callback.onCallback(code, msg, userList);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void enterSeat(final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "enterSeat " + mUserId);
                if (isOnSeat(mUserId)) {
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (callback != null) {
                                callback.onCallback(-1, "you are already in the seat");
                            }
                        }
                    });
                    return;
                }
                mEnterSeatCallback = callback;
                TXRoomService.getInstance().onSeatTake(mUserId);
            }
        });
    }

    @Override
    public void leaveSeat(final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "leaveSeat " + mUserId);
                if (mUserId == null) {
                    //已经不再座位上了
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (callback != null) {
                                callback.onCallback(-1, "seat userId is null");
                            }
                        }
                    });
                    return;
                }
                mLeaveSeatCallback = callback;
                TXRoomService.getInstance().onSeatLeave(mUserId);
            }
        });
    }

    @Override
    public void pickSeat(final String userId, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                //判断该用户是否已经在麦上
                TRTCLogger.i(TAG, "pickSeat " + userId);
                if (isOnSeat(userId)) {
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (callback != null) {
                                callback.onCallback(-1, mContext.getString(R.string.trtcchatsalon_already_anchor));
                            }
                        }
                    });
                    return;
                }
                mPickSeatCallback = callback;
                TXRoomService.getInstance().sendPickMsg(userId, new TXCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void kickSeat(final String userId, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "kickSeat " + userId);
                mKickSeatCallback = callback;
                TXRoomService.getInstance().sendKickMsg(userId, new TXCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void startMicrophone() {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ChatSalonTRTCService.getInstance().startMicrophone();
            }
        });
    }

    @Override
    public void stopMicrophone() {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ChatSalonTRTCService.getInstance().stopMicrophone();
            }
        });
    }

    @Override
    public void setAudioQuality(final int quality) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ChatSalonTRTCService.getInstance().setAudioQuality(quality);
            }
        });
    }

    /**
     * 静音本地
     * <p>
     * 直接调用 TRTC 设置：TXTRTCLiveRoom.muteLocalAudio
     *
     * @param mute
     */
    @Override
    public void muteLocalAudio(final boolean mute) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "mute local audio, mute:" + mute);
                ChatSalonTRTCService.getInstance().muteLocalAudio(mute);
                muteSeat(mUserId, mute, null);
            }
        });
    }

    @Override
    public void setSpeaker(final boolean useSpeaker) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ChatSalonTRTCService.getInstance().setSpeaker(useSpeaker);
            }
        });
    }

    @Override
    public void setAudioCaptureVolume(final int volume) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ChatSalonTRTCService.getInstance().setAudioCaptureVolume(volume);
            }
        });
    }

    @Override
    public void setAudioPlayoutVolume(final int volume) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ChatSalonTRTCService.getInstance().setAudioPlayoutVolume(volume);
            }
        });
    }

    /**
     * 静音音频
     *
     * @param userId
     * @param mute
     */
    @Override
    public void muteRemoteAudio(final String userId, final boolean mute) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "mute trtc audio, user id:" + userId);
                ChatSalonTRTCService.getInstance().muteRemoteAudio(userId, mute);
            }
        });
    }

    /**
     * 静音所有音频
     *
     * @param mute
     */
    @Override
    public void muteAllRemoteAudio(final boolean mute) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "mute all trtc remote audio success, mute:" + mute);
                ChatSalonTRTCService.getInstance().muteAllRemoteAudio(mute);
            }
        });
    }


    @Override
    public TXAudioEffectManager getAudioEffectManager() {
        return ChatSalonTRTCService.getInstance().getAudioEffectManager();
    }

    @Override
    public void sendRoomTextMsg(final String message, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "sendRoomTextMsg");
                TXRoomService.getInstance().sendRoomTextMsg(message, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void sendRoomCustomMsg(final String cmd, final String message, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "sendRoomCustomMsg");
                TXRoomService.getInstance().sendRoomCustomMsg(cmd, message, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public String sendInvitation(final String cmd, final String userId, final String content, final TRTCChatSalonCallback.ActionCallback callback) {
        final String cmdId = cmd + userId;
        if (mInvitationMap.containsKey(cmdId)) {
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    if (callback != null) {
                        callback.onCallback(TRTCChatSalonDef.INVITATION_REQUEST_LIMIT, "handling the invitation");
                    }
                }
            });
            return "";
        }
        final String id = TXRoomService.getInstance().sendInvitation(cmd, userId, content, new TXCallback() {
            @Override
            public void onCallback(final int code, final String msg) {
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        if (code != 0) {
                            mInvitationMap.remove(cmdId);
                        }
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
        mInvitationMap.put(cmdId, id);
        TRTCLogger.i(TAG, "sendInvitation to " + userId + " cmd:" + cmd + " content:" + content + " id: "+id);
        return id;
    }

    @Override
    public void acceptInvitation(final String id, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "acceptInvitation " + id);
                TXRoomService.getInstance().acceptInvitation(id, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void rejectInvitation(final String id, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "rejectInvitation " + id);
                TXRoomService.getInstance().rejectInvitation(id, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void cancelInvitation(final String id, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "cancelInvitation " + id);
                TXRoomService.getInstance().cancelInvitation(id, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void onInvitationTimeout(final String id, List<String> inviteeList) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "onInvitationTimeout " + id);
                updateInvitationMap(id);
                if (mDelegate != null) {
                    mDelegate.onInvitationTimeout(id);
                }
            }
        });
    }

    private void updateInvitationMap(String id) {
        if (TextUtils.isEmpty(id)) {
            return;
        }
        for (Map.Entry<String, String> entry: mInvitationMap.entrySet()) {
            if (id.equals(entry.getValue())) {
                mInvitationMap.remove(entry.getKey());
            }
        }
    }

    private void muteSeat(final String userId, final boolean isMute, final TRTCChatSalonCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "muteSeat " + userId + " " + isMute);
                TXRoomService.getInstance().onSeatMute(userId, isMute);
            }
        });
    }

    private void enterTRTCRoomInner(final String roomId, final String userId, final String userSig, final int role, final TRTCChatSalonCallback.ActionCallback callback) {
        // 进入 TRTC 房间
        TRTCLogger.i(TAG, "enter trtc room.");
        ChatSalonTRTCService.getInstance().enterRoom(mSdkAppId, roomId, userId, userSig, role, new TXCallback() {
            @Override
            public void onCallback(final int code, final String msg) {
                TRTCLogger.i(TAG, "enter trtc room finish, code:" + code + " msg:" + msg);
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void onRoomDestroy(final String roomId) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                exitRoom(null);
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mDelegate != null) {
                            mDelegate.onRoomDestroy(roomId);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void onRoomRecvRoomTextMsg(final String roomId, final String message, final TXUserInfo userInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mDelegate != null) {
                    TRTCChatSalonDef.UserInfo throwUser = new TRTCChatSalonDef.UserInfo();
                    throwUser.userId = userInfo.userId;
                    throwUser.userName = userInfo.userName;
                    throwUser.userAvatar = userInfo.avatarURL;
                    mDelegate.onRecvRoomTextMsg(message, throwUser);
                }
            }
        });
    }

    @Override
    public void onRoomRecvRoomCustomMsg(final String roomId, final String cmd, final String message, final TXUserInfo userInfo) {
        TRTCLogger.i(TAG, "onRoomRecvRoomTextMsg:" + roomId + " msg:" + message);

        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mDelegate != null) {
                    TRTCChatSalonDef.UserInfo throwUser = new TRTCChatSalonDef.UserInfo();
                    throwUser.userId = userInfo.userId;
                    throwUser.userName = userInfo.userName;
                    throwUser.userAvatar = userInfo.avatarURL;
                    mDelegate.onRecvRoomCustomMsg(cmd, message, throwUser);
                }
            }
        });
    }

    @Override
    public void onRoomInfoChange(final TXRoomInfo tXRoomInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCChatSalonDef.RoomInfo roomInfo = new TRTCChatSalonDef.RoomInfo();
                roomInfo.roomName = tXRoomInfo.roomName;
                roomInfo.roomId = Integer.valueOf(mRoomId);
                roomInfo.ownerId = tXRoomInfo.ownerId;
                roomInfo.ownerName = tXRoomInfo.ownerName;
                roomInfo.coverUrl = tXRoomInfo.cover;
                roomInfo.memberCount = tXRoomInfo.memberCount;
                roomInfo.needRequest = (tXRoomInfo.needRequest == 1);
                if (mDelegate != null) {
                    mDelegate.onRoomInfoChange(roomInfo);
                }
            }
        });
    }

    @Override
    public void onRoomAudienceEnter(final TXUserInfo userInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mDelegate != null) {
                    TRTCChatSalonDef.UserInfo throwUser = new TRTCChatSalonDef.UserInfo();
                    throwUser.userId = userInfo.userId;
                    throwUser.userName = userInfo.userName;
                    throwUser.userAvatar = userInfo.avatarURL;
                    mDelegate.onAudienceEnter(throwUser);
                }
            }
        });
    }

    @Override
    public void onRoomAudienceLeave(final TXUserInfo userInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mDelegate != null) {
                    TRTCChatSalonDef.UserInfo throwUser = new TRTCChatSalonDef.UserInfo();
                    throwUser.userId = userInfo.userId;
                    throwUser.userName = userInfo.userName;
                    throwUser.userAvatar = userInfo.avatarURL;
                    mDelegate.onAudienceExit(throwUser);
                }
            }
        });
    }

    @Override
    public void onSeatTake(final TXUserInfo userInfo) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        final String userId = userInfo.userId;
                        if (userId.equals(mUserId)) {
                            //是自己上线了, 切换角色
                            ChatSalonTRTCService.getInstance().switchToAnchor(new ChatSalonTRTCService.OnSwitchRoleListener() {
                                @Override
                                public void onTRTCSwitchRole(int code, String message) {
                                    onAnchorEnterSeat(userInfo);
                                    ChatSalonTRTCService.getInstance().muteLocalAudio(false);
                                    muteSeat(userId, false, null);
                                }
                            });
                        } else {
                            onAnchorEnterSeat(userInfo);
                        }
                    }
                });
                if (userInfo.userId.equals(mUserId)) {
                    //在回调出去
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (mEnterSeatCallback != null) {
                                mEnterSeatCallback.onCallback(0, "enter seat success");
                                mEnterSeatCallback = null;
                            }
                        }
                    });
                }
            }
        });
    }

    @Override
    public void onSeatLeave(final TXUserInfo userInfo) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        String userId = userInfo.userId;
                        mAnchorList.remove(userId);
                        if (userInfo.userId.equals(mUserId)) {
                            //自己下线了~
                            ChatSalonTRTCService.getInstance().switchToAudience(new ChatSalonTRTCService.OnSwitchRoleListener() {
                                @Override
                                public void onTRTCSwitchRole(int code, String message) {
                                    onAnchorLeaveSeat(userInfo);
                                }
                            });
                        } else {
                            onAnchorLeaveSeat(userInfo);
                        }
                    }
                });
            }
        });
    }

    private void onAnchorEnterSeat(TXUserInfo userInfo) {
        String userId = userInfo.userId;
        mAnchorList.add(userId);
        if (mDelegate != null) {
            TRTCChatSalonDef.UserInfo info = new TRTCChatSalonDef.UserInfo();
            info.userId = userInfo.userId;
            info.userAvatar = userInfo.avatarURL;
            info.userName = userInfo.userName;
            mDelegate.onAnchorEnterSeat(info);
        }
        //保存静音状态
        if (mMuteMap.containsKey(userId)) {
            boolean mute = mMuteMap.get(userId);
            muteSeat(userId, mute, null);
            mMuteMap.remove(userId);
        }
        if (mPickSeatCallback != null) {
            mPickSeatCallback.onCallback(0, "pick seat success");
            mPickSeatCallback = null;
        }
    }

    private void onAnchorLeaveSeat(TXUserInfo userInfo) {
        if (mDelegate != null) {
            TRTCChatSalonDef.UserInfo info = new TRTCChatSalonDef.UserInfo();
            info.userId = userInfo.userId;
            info.userAvatar = userInfo.avatarURL;
            info.userName = userInfo.userName;
            mDelegate.onAnchorLeaveSeat(info);
        }
        if (mKickSeatCallback != null) {
            mKickSeatCallback.onCallback(0, "kick seat success");
            mKickSeatCallback = null;
        }

        if (userInfo.userId.equals(mUserId)) {
            runOnDelegateThread(new Runnable() {
                @Override
                public void run() {
                    if (mLeaveSeatCallback != null) {
                        mLeaveSeatCallback.onCallback(0, "enter seat success");
                        mLeaveSeatCallback = null;
                    }
                }
            });
        }
    }

    @Override
    public void onSeatMute(final String userId, final boolean mute) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mDelegate != null) {
                    mDelegate.onSeatMute(userId, mute);
                }
            }
        });
    }

    @Override
    public void onReceiveNewInvitation(final String id, final String inviter, final String cmd, final String content) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mDelegate != null) {
                    mDelegate.onReceiveNewInvitation(id, inviter, cmd, content);
                }
            }
        });
    }

    @Override
    public void onInviteeAccepted(final String id, final String invitee) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                updateInvitationMap(id);
                if (mDelegate != null) {
                    mDelegate.onInviteeAccepted(id, invitee);
                }
            }
        });
    }

    @Override
    public void onInviteeRejected(final String id, final String invitee) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                updateInvitationMap(id);
                if (mDelegate != null) {
                    mDelegate.onInviteeRejected(id, invitee);
                }
            }
        });
    }

    @Override
    public void onInvitationCancelled(final String id, final String inviter) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                updateInvitationMap(id);
                if (mDelegate != null) {
                    mDelegate.onInvitationCancelled(id, inviter);
                }
            }
        });
    }

    @Override
    public void onTRTCAnchorEnter(String userId) {
        TXRoomService.getInstance().onSeatTake(userId);
    }

    @Override
    public void onTRTCAnchorExit(String userId) {
        TXRoomService.getInstance().onSeatLeave(userId);
    }

    @Override
    public void onTRTCAudioAvailable(String userId, boolean available) {
        if (mAnchorList.contains(userId)) {
            mDelegate.onSeatMute(userId, !available);
        } else {
            mMuteMap.put(userId, !available);
        }
    }

    @Override
    public void onError(final int errorCode, final String errorMsg) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mDelegate != null) {
                    mDelegate.onError(errorCode, errorMsg);
                }
            }
        });
    }

    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality trtcQuality, ArrayList<TRTCCloudDef.TRTCQuality> arrayList) {

    }

    @Override
    public void onUserVoiceVolume(final ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, final int totalVolume) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mDelegate != null && userVolumes != null) {
                    for (TRTCCloudDef.TRTCVolumeInfo info : userVolumes) {
                        mDelegate.onUserVolumeUpdate(userVolumes, totalVolume);
                    }
                }
            }
        });
    }
}
