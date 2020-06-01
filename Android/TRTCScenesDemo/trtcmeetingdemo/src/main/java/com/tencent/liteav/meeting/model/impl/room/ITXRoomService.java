package com.tencent.liteav.meeting.model.impl.room;

import android.content.Context;

import com.tencent.liteav.meeting.model.impl.base.TXCallback;
import com.tencent.liteav.meeting.model.impl.base.TXUserListCallback;

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

    void getUserInfo(List<String> userList, TXUserListCallback callback);

    void sendRoomTextMsg(String msg, TXCallback callback);

    void sendRoomCustomMsg(String cmd, String message, TXCallback callback);

    boolean isLogin();

    boolean isEnterRoom();

    String getOwnerUserId();

    boolean isOwner();
}
