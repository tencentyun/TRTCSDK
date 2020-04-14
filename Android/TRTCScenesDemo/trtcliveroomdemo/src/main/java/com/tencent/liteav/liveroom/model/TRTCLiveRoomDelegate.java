package com.tencent.liteav.liveroom.model;

import java.util.List;

public interface TRTCLiveRoomDelegate {

    /**
     * 组件出错信息，请务必监听并处理
     * @param code
     * @param message
     */
    void onError(int code, String message);

    /**
     * 组件告警信息
     * @param code
     * @param message
     */
    void onWarning(int code, String message);

    /**
     * 组件log信息
     * @param message
     */
    void onDebugLog(String message);

    /**
     * 房间信息改变的通知
     *
     * 房间信息发生改变回调，多用于直播连麦、PK下房间状态变化通知场景。
     *
     * @param roomInfo 房间信息
     */
    void onRoomInfoChange(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo);

    /**
     * 房间被销毁，当主播调用destroyRoom后，观众会收到该回调
     * @param roomId
     */
    void onRoomDestroy(String roomId);

    /**
     * 主播进入房间, 你可以调用 startPlay() 启动播放用户视频
     * @param userId
     */
    void onAnchorEnter(String userId);

    /**
     * 主播离开房间, 你可以调用 stopPlay() 停止播放用户视频
     * @param userId
     */
    void onAnchorExit(String userId);

    /**
     * 观众进入房间
     */
    void onAudienceEnter(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo);

    /**
     * 观众离开房间
     */
    void onAudienceExit(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo);

    /**
     * 主播收到连麦请求
     * @param userInfo 连麦对象
     * @param reason 原因
     * @param timeOut 处理请求的超时时间，如果上层超过该时间没有处理，则会自动将该次请求废弃
     */
    void onRequestJoinAnchor(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String reason, int timeOut);

    /**
     * 观众收到踢出连麦
     */
    void onKickoutJoinAnchor();

    /**
     * 收到请求跨房 PK 通知
     *
     * 主播收到其他房间主播的 PK 请求，如果同意 PK ，您需要等待 `TRTCLiveRoomDelegate` 的 `onAnchorEnter` 通知，然后调用 `startPlay()` 来播放邀约主播的流。
     *
     * @param userInfo
     * @param timeout 处理请求的超时时间，如果上层超过该时间没有处理，则会自动将该次请求废弃
     */
    void onRequestRoomPK(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, int timeout);

    /**
     * 退出PK
     */
    void onQuitRoomPK();

    /**
     * 收到文字消息
     * @param message
     * @param userInfo
     */
    void onRecvRoomTextMsg(String message, TRTCLiveRoomDef.TRTCLiveUserInfo userInfo);

    /**
     * 收到自定义消息
     * @param cmd
     * @param message
     * @param userInfo
     */
    void onRecvRoomCustomMsg(String cmd, String message, TRTCLiveRoomDef.TRTCLiveUserInfo userInfo);

}
