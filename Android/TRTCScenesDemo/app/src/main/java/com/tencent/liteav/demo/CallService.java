package com.tencent.liteav.demo;

import android.app.Service;
import android.content.Intent;
import android.os.Environment;
import android.os.IBinder;
import android.util.Log;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.SPUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMLogLevel;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMSdkConfig;
import com.tencent.imsdk.session.SessionWrapper;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.liveroom.model.TRTCLiveRoom;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.ui.common.utils.TCConstants;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.UserModel;
import com.tencent.liteav.trtcaudiocalldemo.model.ITRTCAudioCall;
import com.tencent.liteav.trtcaudiocalldemo.model.TRTCAudioCallImpl;
import com.tencent.liteav.trtcaudiocalldemo.model.TRTCAudioCallListener;
import com.tencent.liteav.trtcaudiocalldemo.ui.TRTCAudioCallActivity;
import com.tencent.liteav.trtcvideocalldemo.model.ITRTCVideoCall;
import com.tencent.liteav.trtcvideocalldemo.model.TRTCVideoCallImpl;
import com.tencent.liteav.trtcvideocalldemo.model.TRTCVideoCallListener;
import com.tencent.liteav.trtcvideocalldemo.ui.TRTCVideoCallActivity;

import java.util.List;
import java.util.Map;

public class CallService extends Service {
    private ITRTCAudioCall        mITRTCAudioCall;
    private TRTCAudioCallListener mTRTCAudioCallListener = new TRTCAudioCallListener() {
        // <editor-fold  desc="音频监听代码">
        @Override
        public void onError(int code, String msg) {
        }

        @Override
        public void onInvited(String sponsor, final List<String> userIdList, boolean isFromGroup, int callType) {
            //1. 收到邀请，先到服务器查询
            ProfileManager.getInstance().getUserInfoByUserId(sponsor, new ProfileManager.GetUserInfoCallback() {
                @Override
                public void onSuccess(final UserModel model) {
                    if (!CollectionUtils.isEmpty(userIdList)) {
                        ProfileManager.getInstance().getUserInfoBatch(userIdList, new ProfileManager.GetUserInfoBatchCallback() {
                            @Override
                            public void onSuccess(List<UserModel> modelList) {
                                TRTCAudioCallActivity.startBeingCall(CallService.this, model, modelList);
                            }

                            @Override
                            public void onFailed(int code, String msg) {
                                TRTCAudioCallActivity.startBeingCall(CallService.this, model, null);
                            }
                        });
                    } else {
                        TRTCAudioCallActivity.startBeingCall(CallService.this, model, null);
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
        public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {
        }

        @Override
        public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
        }
        // </editor-fold>
    };
    //
    private ITRTCVideoCall        mITRTCVideoCall;
    private TRTCVideoCallListener mTRTCVideoCallListener = new TRTCVideoCallListener() {
        // <editor-fold  desc="视频监听代码">
        @Override
        public void onError(int code, String msg) {
        }

        @Override
        public void onInvited(String sponsor, final List<String> userIdList, boolean isFromGroup, int callType) {
            //1. 收到邀请，先到服务器查询
            ProfileManager.getInstance().getUserInfoByUserId(sponsor, new ProfileManager.GetUserInfoCallback() {
                @Override
                public void onSuccess(final UserModel model) {
                    if (!CollectionUtils.isEmpty(userIdList)) {
                        ProfileManager.getInstance().getUserInfoBatch(userIdList, new ProfileManager.GetUserInfoBatchCallback() {
                            @Override
                            public void onSuccess(List<UserModel> modelList) {
                                TRTCVideoCallActivity.startBeingCall(CallService.this, model, modelList);
                            }

                            @Override
                            public void onFailed(int code, String msg) {
                                TRTCVideoCallActivity.startBeingCall(CallService.this, model, null);
                            }
                        });
                    } else {
                        TRTCVideoCallActivity.startBeingCall(CallService.this, model, null);
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
    private TRTCLiveRoom          mTRTCLiveRoom;


    public CallService() {
    }

    @Override
    public void onCreate() {
        super.onCreate();
        // 由于两个模块公用一个IM，所以需要在这里先进行登录，您的App只使用一个model，可以直接调用VideoCall 对应函数
        // 目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
        if (SessionWrapper.isMainProcess(this)) {
            TIMSdkConfig config = new TIMSdkConfig(GenerateTestUserSig.SDKAPPID)
                    .enableLogPrint(true)
                    .setLogLevel(TIMLogLevel.DEBUG)
                    .setLogPath(Environment.getExternalStorageDirectory().getPath() + "/justfortest/");
            //初始化 SDK
            TIMManager.getInstance().init(this, config);
        }
        String userId  = ProfileManager.getInstance().getUserModel().userId;
        String userSig = ProfileManager.getInstance().getUserModel().userSig;
        Log.d("Login", "login: " + userId + " " + userSig);
        // 由于这里提前登陆了，所以会导致上一次的消息收不到，您在APP中单独使用 ITRTCAudioCall.login 不会出现这种问题
        TIMManager.getInstance().login(userId, userSig, new TIMCallBack() {
            @Override
            public void onError(int i, String s) {
                // 登录IM失败
                ToastUtils.showLong("登录IM失败，所有功能不可用[" + i + "]" + s);
            }

            @Override
            public void onSuccess() {
                //1. 登录IM成功
                ToastUtils.showLong("登录IM成功");
                initAudioCallData();
                initVideoCallData();
                initLiveRoom();
            }
        });
    }

    private void initLiveRoom() {
        final UserModel userModel = ProfileManager.getInstance().getUserModel();
        mTRTCLiveRoom = TRTCLiveRoom.sharedInstance(this);
        boolean                            useCDNFirst = SPUtils.getInstance().getBoolean(TCConstants.USE_CDN_PLAY, false);
        //您可以设置类似于 http://{bizid}.liveplay.myqcloud.com/live 的播放地址
        TRTCLiveRoomDef.TRTCLiveRoomConfig config      = new TRTCLiveRoomDef.TRTCLiveRoomConfig(useCDNFirst, "");
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
        mITRTCAudioCall.removeListener(mTRTCAudioCallListener);
        TRTCAudioCallImpl.destroySharedInstance();
        mITRTCVideoCall.removeListener(mTRTCVideoCallListener);
        TRTCVideoCallImpl.destroySharedInstance();
    }

    private void initAudioCallData() {
        mITRTCAudioCall = TRTCAudioCallImpl.sharedInstance(this);
        mITRTCAudioCall.init();
        mITRTCAudioCall.addListener(mTRTCAudioCallListener);
        //为了方便接入和测试
        int    appid   = GenerateTestUserSig.SDKAPPID;
        String userId  = ProfileManager.getInstance().getUserModel().userId;
        String userSig = ProfileManager.getInstance().getUserModel().userSig;
        mITRTCAudioCall.login(appid, userId, userSig, null);
    }

    private void initVideoCallData() {
        mITRTCVideoCall = TRTCVideoCallImpl.sharedInstance(this);
        mITRTCVideoCall.init();
        mITRTCVideoCall.addListener(mTRTCVideoCallListener);
        int    appid   = GenerateTestUserSig.SDKAPPID;
        String userId  = ProfileManager.getInstance().getUserModel().userId;
        String userSig = ProfileManager.getInstance().getUserModel().userSig;
        mITRTCVideoCall.login(appid, userId, userSig, null);
    }


    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }
}
