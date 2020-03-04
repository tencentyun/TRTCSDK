package com.tencent.liteav.trtcaudiocalldemo.model;

import java.util.List;

/**
 * TRTC 语音通话接口
 * 本功能使用腾讯云实时音视频 / 腾讯云即时通信IM 组合实现
 * 使用方式如下
 * 1. 初始化
 * ITRTCAudioCall sCall = TRTCAudioCallImpl.sharedInstance(context);
 * sCall.init();
 * <p>
 * 2. 监听回调
 * sCall.addListener(new TRTCVideoCallListener());
 * <p>
 * 3. 登录到IM系统中
 * sCall.login(A, password, callback);
 * <p>
 * 4. 给B拨打电话
 * sCall.call(B);
 * <p>
 * 5. 接听/拒绝电话
 * 此时B如果也登录了IM系统，会收到TRTCVideoCallListener的onInvited(A, null, false)回调
 * B 可以调用 sCall.accept 接受 / sCall.reject 拒绝
 * <p>
 * 8. 结束通话
 * 需要结束通话时，A、B 任意一方可以调用 sCall.hangup 挂断电话
 * <p>
 * 9. 销毁实例
 * sCall.destroy();
 * TRTCVideoCallImpl.destroySharedInstance();
 */
public interface ITRTCAudioCall {
    int TYPE_UNKNOWN    = 0;
    int TYPE_VOICE_CALL = 1;

    public interface ActionCallBack {
        void onError(int code, String msg);

        void onSuccess();
    }

    /**
     * 初始化函数，请在使用所有功能之前先调用该函数进行必要的初始化
     */
    void init();

    /**
     * 销毁函数，如果不需要再运行该实例，请调用该接口
     */
    void destroy();

    /**
     * 增加回调接口
     *
     * @param listener 上层可以通过回调监听事件
     */
    void addListener(TRTCAudioCallListener listener);


    /**
     * 移除回调接口
     *
     * @param listener 需要移除的监听器
     */
    void removeListener(TRTCAudioCallListener listener);

    /**
     * 登录IM接口，所有功能需要先进行登录后才能使用
     *
     * @param sdkAppId app Id
     * @param userId
     * @param userSign
     * @param callback
     */
    void login(int sdkAppId, final String userId, String userSign, final ActionCallBack callback);

    /**
     * 登出接口，登出后无法再进行拨打操作
     */
    void logout(final ActionCallBack callBack);

    /**
     * C2C邀请通话，被邀请方会收到 {@link TRTCAudioCallListener#onInvited } 的回调
     * 如果当前处于通话中，可以调用该函数以邀请第三方进入通话
     *
     * @param userId 被邀请方
     */
    void call(String userId);

    /**
     * IM群组邀请通话，被邀请方会收到 {@link TRTCAudioCallListener#onInvited } 的回调
     * 如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到 {@link TRTCAudioCallListener#onGroupCallInviteeListUpdate(List)} 的回调
     *
     * @param userIdList 邀请列表
     * @param groupId    IM群组ID
     */
    void groupCall(List<String> userIdList, String groupId);

    /**
     * 当您作为被邀请方收到 {@link TRTCAudioCallListener#onInvited } 的回调时，可以调用该函数接听来电
     */
    void accept();

    /**
     * 当您作为被邀请方收到 {@link TRTCAudioCallListener#onInvited } 的回调时，可以调用该函数拒绝来电
     */
    void reject();

    /**
     * 当您处于通话中，可以调用该函数结束通话
     */
    void hangup();

    /**
     * 是否静音mic
     *
     * @param isMute true:麦克风关闭 false:麦克风打开
     */
    void setMicMute(boolean isMute);

    /**
     * 是否开启免提
     *
     * @param isHandsFree true:开启免提 false:关闭免提
     */
    void setHandsFree(boolean isHandsFree);
}
