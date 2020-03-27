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
     * @param roomInfo 房间信息
     */
    void onRoomInfoChange(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo);

    /**
     * 房间被销毁，当主播
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
     * @param timeOut
     */
    void onRequestJoinAnchor(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String reason, int timeOut);

    /**
     * 观众收到踢出连麦
     */
    void onKickoutJoinAnchor();

    /**
     * 主播收到PK请求
     * @param userInfo
     * @param timeout
     */
    void onRequestRoomPK(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, int timeout);

    /**
     * 退出PK
     */
    void onQuitRoomPK();

    /**
     * 收到文字消息
     * @param roomId
     * @param message
     * @param userInfo
     */
    void onRecvRoomTextMsg(String roomId, String message, TRTCLiveRoomDef.TRTCLiveUserInfo userInfo);

    /**
     * 收到自定义消息
     * @param roomId
     * @param cmd
     * @param message
     * @param userInfo
     */
    void onRecvRoomCustomMsg(String roomId, String cmd, String message, TRTCLiveRoomDef.TRTCLiveUserInfo userInfo);

}
