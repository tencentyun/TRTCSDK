package com.tencent.liteav.meeting.model;

import com.tencent.trtc.TRTCCloudDef;

import java.util.List;

public interface TRTCMeetingDelegate {

    //////////////////////////////////////////////////////////
    //
    //                通用事件回调
    //
    //////////////////////////////////////////////////////////
    /**
     * 组件出错信息，请务必监听并处理
     *
     * @param code
     * @param message
     */
    void onError(int code, String message);

    //////////////////////////////////////////////////////////
    //
    //                会议房间事件回调
    //
    //////////////////////////////////////////////////////////

    /**
     * 房间被销毁的回调。主持人退房时，房间内的所有用户都会收到此通知。
     *
     * @param roomId 房间 ID
     */
    void onRoomDestroy(String roomId);

    /**
     * 网络状态回调。
     *
     * @param localQuality 上行网络质量。
     * @param remoteQuality 下行网络质量。
     */
    void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, List<TRTCCloudDef.TRTCQuality> remoteQuality);

    /**
     * 启用音量大小提示，会通知每个成员的音量大小
     *
     * @param userId 用户信息。
     * @param volume 音量大小，取值0-100。
     */
    void onUserVolumeUpdate(String userId, int volume);

    //////////////////////////////////////////////////////////
    //
    //               成员进出事件回调
    //
    //////////////////////////////////////////////////////////

    /**
     * 新成员进房通知。
     *
     * @param userId 新进房成员 ID
     */
    void onUserEnterRoom(String userId);

    /**
     * 成员退房通知。
     *
     * @param userId 退房成员 ID
     */
    void onUserLeaveRoom(String userId);

    //////////////////////////////////////////////////////////
    //
    //               成员音视频事件回调
    //
    //////////////////////////////////////////////////////////

    /**
     * 成员开启/关闭摄像头的通知。
     *
     * @param userId 用户信息。
     * @param available true：用户打开摄像头；false：用户关闭摄像头。
     */
    void onUserVideoAvailable(String userId, boolean available);

    /**
     * 成员开启/关闭麦克风的通知。
     *
     * @param userId 用户信息。
     * @param available true：用户打开麦克风；false：用户关闭麦克风。
     */
    void onUserAudioAvailable(String userId, boolean available);

    //////////////////////////////////////////////////////////
    //
    //               消息事件回调
    //
    //////////////////////////////////////////////////////////

    /**
     * 收到文本消息。
     *
     * @param message 文本消息。
     * @param userInfo 发送者用户信息。
     */
    void onRecvRoomTextMsg(String message, TRTCMeetingDef.UserInfo userInfo);

    /**
     * 收到自定义消息。
     *
     * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型。
     * @param message 文本消息。
     * @param userInfo 发送者用户信息。
     */
    void onRecvRoomCustomMsg(String cmd, String message, TRTCMeetingDef.UserInfo userInfo);

    //////////////////////////////////////////////////////////
    //
    //               录屏事件回调
    //
    //////////////////////////////////////////////////////////

    /**
     * 录屏开始通知。
     */
    void onScreenCaptureStarted();

    /**
     * 录屏暂停通知。
     */
    void onScreenCapturePaused();

    /**
     * 录屏恢复通知。
     */
    void onScreenCaptureResumed();

    /**
     * 录屏停止通知。
     *
     * @param reason 停止原因，0：用户主动停止；1：被其他应用抢占导致停止
     */
    void onScreenCaptureStopped(int reason);
}
