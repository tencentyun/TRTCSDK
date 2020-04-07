package com.tencent.liteav.liveroom.model.impl.room;

import android.content.Context;

import com.tencent.liteav.liveroom.model.impl.base.TXCallback;
import com.tencent.liteav.liveroom.model.impl.base.TXRoomInfoListCallback;
import com.tencent.liteav.liveroom.model.impl.base.TXUserListCallback;

import java.util.List;

public interface ITXRoomService {
    void init(Context context);

    void setDelegate(ITXRoomServiceDelegate delegate);

    void login(int sdkAppId, String userId, String userSign, TXCallback callback);

    void logout(TXCallback callback);

    void setSelfProfile(String userName, String avatarURL, TXCallback callback);

    void createRoom(String roomId, String roomInfo, String coverUrl, TXCallback callback);

    void destroyRoom(TXCallback callback);

    void enterRoom(String roomId, TXCallback callback);

    void exitRoom(TXCallback callback);

    void getRoomInfos(List<String> roomId, TXRoomInfoListCallback callback);

    void updateStreamId(String streamId, TXCallback callback);

    void getAudienceList(TXUserListCallback callback);

    void getUserInfo(List<String> userList, TXUserListCallback callback);

    void sendRoomTextMsg(String msg, TXCallback callback);

    void sendRoomCustomMsg(String cmd, String message, TXCallback callback);

    void requestJoinAnchor(String reason, TXCallback callback);

    void responseJoinAnchor(String userId, boolean agree, String reason);

    void kickoutJoinAnchor(String userId, TXCallback callback);

    void requestRoomPK(String roomId, String userId, TXCallback callback);

    void responseRoomPK(String userId, boolean agree, String reason);

    void resetRoomStatus();

    void quitRoomPK(TXCallback callback);

    String exchangeStreamId(String userId);

    boolean isLogin();

    boolean isEnterRoom();

    String getOwnerUserId();

    boolean isOwner();

    boolean isPKing();

    String getPKRoomId();

    String getPKUserId();

}
