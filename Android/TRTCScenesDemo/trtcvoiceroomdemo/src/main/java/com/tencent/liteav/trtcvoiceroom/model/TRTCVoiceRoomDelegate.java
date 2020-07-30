package com.tencent.liteav.trtcvoiceroom.model;

import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomDef.SeatInfo;

import java.util.List;

public interface TRTCVoiceRoomDelegate {
    /**
     * 组件出错信息，请务必监听并处理
     */
    void onError(int code, String message);

    /**
     * 组件告警信息
     */
    void onWarning(int code, String message);

    /**
     * 组件log信息
     */
    void onDebugLog(String message);

    /**
     * 房间被销毁，当主播调用destroyRoom后，观众会收到该回调
     */
    void onRoomDestroy(String roomId);

    /**
     * 房间信息改变的通知
     */
    void onRoomInfoChange(TRTCVoiceRoomDef.RoomInfo roomInfo);

    /**
     * 全量的麦位列表变化,包含了整个麦位表
     * @param seatInfoList 全量的麦位列表
     */
    void onSeatListChange(List<SeatInfo> seatInfoList);

    /**
     * 有成员上麦(主动上麦/主播抱人上麦)
     * @param index 上麦的麦位
     * @param user  用户详细信息
     */
    void onAnchorEnterSeat(int index, TRTCVoiceRoomDef.UserInfo user);

    /**
     * 有成员下麦(主动下麦/主播踢人下麦)
     * @param index 下麦的麦位
     * @param user  用户详细信息
     */
    void onAnchorLeaveSeat(int index, TRTCVoiceRoomDef.UserInfo user);

    /**
     * 主播禁麦
     * @param index  操作的麦位
     * @param isMute 是否静音
     */
    void onSeatMute(int index, boolean isMute);

    /**
     * 主播封麦
     * @param index  操作的麦位
     * @param isClose 是否封禁麦位
     */
    void onSeatClose(int index, boolean isClose);

    /**
     * 观众进入房间
     *
     * @param userInfo 观众的详细信息
     */
    void onAudienceEnter(TRTCVoiceRoomDef.UserInfo userInfo);

    /**
     * 观众离开房间
     *
     * @param userInfo 观众的详细信息
     */
    void onAudienceExit(TRTCVoiceRoomDef.UserInfo userInfo);

    /**
     * 上麦成员的音量变化
     *
     * @param userId 用户 ID
     * @param volume 音量大小 0-100
     */
    void onUserVolumeUpdate(String userId, int volume);

    /**
     * 收到文本消息。
     *
     * @param message 文本消息。
     * @param userInfo 发送者用户信息。
     */
    void onRecvRoomTextMsg(String message, TRTCVoiceRoomDef.UserInfo userInfo);

    /**
     * 收到自定义消息。
     *
     * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型。
     * @param message 文本消息。
     * @param userInfo 发送者用户信息。
     */
    void onRecvRoomCustomMsg(String cmd, String message, TRTCVoiceRoomDef.UserInfo userInfo);

    /**
     * 收到新的邀请请求
     *
     * @param id  邀请id
     * @param inviter 邀请人userId
     * @param cmd 业务指定的命令字
     * @param content 业务指定的内容
     */
    void onReceiveNewInvitation(String id, String inviter, String cmd, String content);

    /**
     * 被邀请者接受邀请
     *
     * @param id  邀请id
     * @param invitee 被邀请人userId
     */
    void onInviteeAccepted(String id, String invitee);

    /**
     * 被邀请者拒绝邀请
     *
     * @param id  邀请id
     * @param invitee 被邀请人userId
     */
    void onInviteeRejected(String id, String invitee);

    /**
     * 邀请人取消邀请
     *
     * @param id  邀请id
     * @param inviter 邀请人userId
     */
    void onInvitationCancelled(String id, String inviter);
}
