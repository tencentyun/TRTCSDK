package com.tencent.liteav.meeting.model.impl.room;

import com.tencent.liteav.meeting.model.impl.base.TXUserInfo;

public interface ITXRoomServiceDelegate {
    void onRoomDestroy(String roomId);

    void onRoomRecvRoomTextMsg(String roomId, String message, TXUserInfo userInfo);

    void onRoomRecvRoomCustomMsg(String roomId, String cmd, String message, TXUserInfo userInfo);
}
