package com.tencent.liteav.demo;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.blankj.utilcode.util.SPUtils;
import com.blankj.utilcode.util.ServiceUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.imsdk.session.SessionWrapper;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.liveroom.model.TRTCLiveRoom;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.ui.common.utils.TCConstants;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.model.UserModel;
import com.tencent.liteav.meeting.model.TRTCMeeting;
import com.tencent.liteav.meeting.model.TRTCMeetingCallback;
import com.tencent.liteav.trtccalling.model.TRTCCalling;
import com.tencent.liteav.trtccalling.model.TRTCCallingDelegate;
import com.tencent.liteav.trtccalling.model.impl.TRTCCallingImpl;
import com.tencent.liteav.trtccalling.ui.audiocall.TRTCAudioCallActivity;
import com.tencent.liteav.trtccalling.ui.videocall.TRTCVideoCallActivity;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalon;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonCallback;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoom;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomCallback;

import java.util.List;
import java.util.Map;

public class CallService extends Service {
    private static final int NOTIFICATION_ID = 1001;

    private TRTCCalling         mTRTCCalling;
    private TRTCCallingDelegate mTRTCCallingDelegate = new TRTCCallingDelegate() {
        // <editor-fold  desc="视频监听代码">
        @Override
        public void onError(int code, String msg) {
        }

        @Override
        public void onInvited(String sponsor, final List<String> userIdList, boolean isFromGroup, final int callType) {
            //1. 收到邀请，先到服务器查询
            ProfileManager.getInstance().getUserInfoByUserId(sponsor, new ProfileManager.GetUserInfoCallback() {
                @Override
                public void onSuccess(final UserModel model) {
                    if (callType == TRTCCalling.TYPE_VIDEO_CALL) {
                        TRTCVideoCallActivity.UserInfo selfInfo = new TRTCVideoCallActivity.UserInfo();
                        selfInfo.userId = ProfileManager.getInstance().getUserModel().userId;
                        selfInfo.userAvatar = ProfileManager.getInstance().getUserModel().userAvatar;
                        selfInfo.userName = ProfileManager.getInstance().getUserModel().userName;
                        TRTCVideoCallActivity.UserInfo callUserInfo = new TRTCVideoCallActivity.UserInfo();
                        callUserInfo.userId = model.userId;
                        callUserInfo.userAvatar = model.userAvatar;
                        callUserInfo.userName = model.userName;
                        TRTCVideoCallActivity.startBeingCall(CallService.this, selfInfo, callUserInfo, null);
                    } else if (callType == TRTCCalling.TYPE_AUDIO_CALL) {
                        TRTCAudioCallActivity.UserInfo selfInfo = new TRTCAudioCallActivity.UserInfo();
                        selfInfo.userId = ProfileManager.getInstance().getUserModel().userId;
                        selfInfo.userAvatar = ProfileManager.getInstance().getUserModel().userAvatar;
                        selfInfo.userName = ProfileManager.getInstance().getUserModel().userName;
                        TRTCAudioCallActivity.UserInfo callUserInfo = new TRTCAudioCallActivity.UserInfo();
                        callUserInfo.userId = model.userId;
                        callUserInfo.userAvatar = model.userAvatar;
                        callUserInfo.userName = model.userName;
                        TRTCAudioCallActivity.startBeingCall(CallService.this, selfInfo, callUserInfo, null);
                    }
                }

                @Override
                public void onFailed(int code, String msg) {

                }
            });
        }

        @Override
        public void onGroupCallInviteeListUpdate(List<String> userIdList) {

        }

        @Override
        public void onUserEnter(String userId) {

        }

        @Override
        public void onUserLeave(String userId) {

        }

        @Override
        public void onReject(String userId) {

        }

        @Override
        public void onNoResp(String userId) {

        }

        @Override
        public void onLineBusy(String userId) {

        }

        @Override
        public void onCallingCancel() {

        }

        @Override
        public void onCallingTimeout() {

        }

        @Override
        public void onCallEnd() {

        }

        @Override
        public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {

        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {

        }

        @Override
        public void onUserVoiceVolume(Map<String, Integer> volumeMap) {

        }
        // </editor-fold  desc="视频监听代码">
    };
    //视频直播
    private TRTCLiveRoom        mTRTCLiveRoom;

    public static void start(Context context) {
        if (ServiceUtils.isServiceRunning(CallService.class)) {
            return;
        }
        Intent starter = new Intent(context, CallService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(starter);
        } else {
            context.startService(starter);
        }
    }

    public static void stop(Context context) {
        Intent intent = new Intent(context, CallService.class);
        context.stopService(intent);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        // 获取服务通知
        Notification notification = createForegroundNotification();
        //将服务置于启动状态 ,NOTIFICATION_ID指的是创建的通知的ID
        startForeground(NOTIFICATION_ID, notification);

        // 由于两个模块公用一个IM，所以需要在这里先进行登录，您的App只使用一个model，可以直接调用VideoCall 对应函数
        // 目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
        if (SessionWrapper.isMainProcess(this)) {
            V2TIMSDKConfig config = new V2TIMSDKConfig();
            config.setLogLevel(V2TIMSDKConfig.V2TIM_LOG_DEBUG);
            V2TIMManager.getInstance().initSDK(this, GenerateTestUserSig.SDKAPPID, config, new V2TIMSDKListener() {
                @Override
                public void onConnecting() {
                }

                @Override
                public void onConnectSuccess() {
                }

                @Override
                public void onConnectFailed(int code, String error) {
                }
            });
        }
        String userId  = ProfileManager.getInstance().getUserModel().userId;
        String userSig = ProfileManager.getInstance().getUserModel().userSig;
        Log.d("Login", "login: " + userId + " " + userSig);
        // 由于这里提前登陆了，所以会导致上一次的消息收不到，您在APP中单独使用 ITRTCAudioCall.login 不会出现这种问题
        V2TIMManager.getInstance().login(userId, userSig, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                // 登录IM失败
                ToastUtils.showLong(getString(R.string.app_toast_login_fail, i, s));
            }

            @Override
            public void onSuccess() {
                //1. 登录IM成功
                ToastUtils.showLong(getString(R.string.app_toast_login_success));
                initTRTCCallingData();
                initLiveRoom();
                initMeetingData();
                initVoiceRoom();
                initChatSalon();
            }
        });
    }

    private Notification createForegroundNotification() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // 唯一的通知通道的id.
        String notificationChannelId = "notification_channel_id_01";

        // Android8.0以上的系统，新建消息通道
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //用户可见的通道名称
            String channelName = "TRTC Foreground Service Notification";
            //通道的重要程度
            int                 importance          = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel notificationChannel = new NotificationChannel(notificationChannelId, channelName, importance);
            notificationChannel.setDescription("Channel description");
            //震动
            notificationChannel.setVibrationPattern(new long[]{0, 1000, 500, 1000});
            notificationChannel.enableVibration(true);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(notificationChannel);
            }
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, notificationChannelId);
        //通知小图标
        builder.setSmallIcon(R.drawable.ic_launcher);
        //通知标题
        builder.setContentTitle(getString(R.string.app_name));
        //通知内容
        builder.setContentText(getString(R.string.working));
        //设定通知显示的时间
        builder.setWhen(System.currentTimeMillis());

        //创建通知并返回
        return builder.build();
    }

    private void initLiveRoom() {
        final UserModel userModel = ProfileManager.getInstance().getUserModel();
        mTRTCLiveRoom = TRTCLiveRoom.sharedInstance(this);
        boolean                            useCDNFirst = SPUtils.getInstance().getBoolean(TCConstants.USE_CDN_PLAY, false);
        TRTCLiveRoomDef.TRTCLiveRoomConfig config      = new TRTCLiveRoomDef.TRTCLiveRoomConfig(useCDNFirst, "请替换成您的业务服务器地址");
        mTRTCLiveRoom.login(GenerateTestUserSig.SDKAPPID, userModel.userId, userModel.userSig, config, new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    mTRTCLiveRoom.setSelfProfile(userModel.userName, userModel.userAvatar, new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {
                        }
                    });
                }
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mTRTCCalling != null) {
            mTRTCCalling.removeDelegate(mTRTCCallingDelegate);
        }
    }

    private void initTRTCCallingData() {
        mTRTCCalling = TRTCCallingImpl.sharedInstance(this);
        mTRTCCalling.addDelegate(mTRTCCallingDelegate);
        int    appid   = GenerateTestUserSig.SDKAPPID;
        String userId  = ProfileManager.getInstance().getUserModel().userId;
        String userSig = ProfileManager.getInstance().getUserModel().userSig;
        mTRTCCalling.login(appid, userId, userSig, null);
    }

    private void initMeetingData() {
        final UserModel userModel = ProfileManager.getInstance().getUserModel();
        TRTCMeeting.sharedInstance(this).login(GenerateTestUserSig.SDKAPPID, userModel.userId, userModel.userSig, new TRTCMeetingCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
            }
        });
    }

    private void initVoiceRoom() {
        final UserModel     userModel = ProfileManager.getInstance().getUserModel();
        final TRTCVoiceRoom voiceRoom = TRTCVoiceRoom.sharedInstance(this);
        voiceRoom.login(GenerateTestUserSig.SDKAPPID, userModel.userId, userModel.userSig, new TRTCVoiceRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    voiceRoom.setSelfProfile(userModel.userName, userModel.userAvatar, new TRTCVoiceRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {
                            if (code == 0) {
                            }
                        }
                    });
                }
            }
        });
    }

    private void initChatSalon() {
        final UserModel     userModel = ProfileManager.getInstance().getUserModel();
        final TRTCChatSalon chatSalonRoom = TRTCChatSalon.sharedInstance(this);
        chatSalonRoom.login(GenerateTestUserSig.SDKAPPID, userModel.userId, userModel.userSig, new TRTCChatSalonCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    chatSalonRoom.setSelfProfile(userModel.userName, userModel.userAvatar, new TRTCChatSalonCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {
                            if (code == 0) {
                            }
                        }
                    });
                }
            }
        });
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }
}