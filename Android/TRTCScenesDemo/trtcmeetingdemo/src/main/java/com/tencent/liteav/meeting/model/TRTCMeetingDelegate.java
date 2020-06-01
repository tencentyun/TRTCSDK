package com.tencent.liteav.meeting.model;

import com.tencent.trtc.TRTCCloudDef;

import java.util.List;

public interface TRTCMeetingDelegate {
    /**
     * 组件出错信息，请务必监听并处理
     *
     * @param code
     * @param message
     */
    void onError(int code, String message);

    void onRoomDestroy(String roomId);

    void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, List<TRTCCloudDef.TRTCQuality> remoteQuality);

    void onUserVolumeUpdate(String userId, int volume);

    void onUserEnterRoom(String userId);

    void onUserLeaveRoom(String userId);

    void onUserVideoAvailable(String userId, boolean available);

    void onUserAudioAvailable(String userId, boolean available);

    void onRecvRoomTextMsg(String message, TRTCMeetingDef.UserInfo userInfo);

    void onRecvRoomCustomMsg(String cmd, String message, TRTCMeetingDef.UserInfo userInfo);
}
