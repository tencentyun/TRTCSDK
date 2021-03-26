package com.tencent.liteav.trtcchatsalon.model.impl.room;


import com.tencent.liteav.trtcchatsalon.model.impl.base.TXRoomInfo;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXUserInfo;

import java.util.List;

public interface ITXRoomServiceDelegate {
    void onRoomDestroy(String roomId);

    void onRoomRecvRoomTextMsg(String roomId, String message, TXUserInfo userInfo);

    void onRoomRecvRoomCustomMsg(String roomId, String cmd, String message, TXUserInfo userInfo);

    void onRoomInfoChange(TXRoomInfo TXRoomInfo);

    void onRoomAudienceEnter(TXUserInfo userInfo);

    void onRoomAudienceLeave(TXUserInfo userInfo);

    void onSeatTake(TXUserInfo userInfo);

    void onSeatLeave(TXUserInfo userInfo);

    void onSeatMute(String seatUserId, boolean mute);

    void onReceiveNewInvitation(String id, String inviter, String cmd, String content);

    void onInviteeAccepted(String id, String invitee);

    void onInviteeRejected(String id, String invitee);

    void onInvitationCancelled(String id, String inviter);

    void onInvitationTimeout(String id, List<String> inviteeList);
}